#!/usr/bin/env bash
# Deploy the commit of this run through Shipyard and mirror the result.
# Inputs arrive as SY_* environment variables (see action.yml).
set -euo pipefail

# Workflow commands have to reach the step's own output, also from inside $( ).
exec 3>&1

fail() { echo "::error::$1"; echo "status=${2:-failed}" >> "$GITHUB_OUTPUT"; exit 1; }

command -v curl >/dev/null || fail "curl is not installed on this runner"
command -v python3 >/dev/null || fail "python3 is not installed on this runner"

platform="${SY_PLATFORM_URL%/}"
[ -n "$platform" ] || fail "platform-url is empty. Pass the organisation variable: platform-url: \${{ vars.SHIPYARD_PLATFORM_URL }}"
audience="${SY_AUDIENCE:-}"
[ -n "$audience" ] || audience="$platform"
case "$SY_ENVIRONMENT" in staging|production) ;; *) fail "environment must be staging or production, got '$SY_ENVIRONMENT'" ;; esac
case "$SY_DRY_RUN" in true|false) ;; *) fail "dry-run must be true or false" ;; esac
[[ "$SY_TIMEOUT_MINUTES" =~ ^[0-9]+$ && "$SY_POLL_SECONDS" =~ ^[0-9]+$ && "$SY_POLL_SECONDS" -ge 2 ]] || fail "timeout-minutes and poll-seconds must be whole numbers (poll at least 2)"

if [ -z "${ACTIONS_ID_TOKEN_REQUEST_URL:-}" ] || [ -z "${ACTIONS_ID_TOKEN_REQUEST_TOKEN:-}" ]; then
  fail "No identity token available. Add 'permissions: id-token: write' to the job that uses shipyard-deploy."
fi

curl_opts=(--silent --show-error --max-time 60)
[ -z "$SY_CA_CERT_FILE" ] || curl_opts+=(--cacert "$SY_CA_CERT_FILE")

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# json FILE KEY [DEFAULT] — one top-level value of a JSON file, as text.
json() {
  python3 - "$1" "$2" "${3:-}" <<'PY'
import json, sys
try:
    v = json.load(open(sys.argv[1])).get(sys.argv[2])
except Exception:
    v = None
if v is None:
    v = sys.argv[3]
print(v if isinstance(v, str) else json.dumps(v))
PY
}

# A fresh identity token for every call: they live about five minutes.
id_token() {
  curl "${curl_opts[@]}" --fail -H "Authorization: Bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" \
    "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=$(python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1], safe=""))' "$audience")" \
    > "$work/token.json" || return 1
  local t
  t="$(json "$work/token.json" value)"
  [ -n "$t" ] || return 1
  echo "::add-mask::$t" >&3
  printf '%s' "$t"
}

# call METHOD PATH [BODY_FILE] → HTTP status on stdout, body in $work/body.json
call() {
  local token code
  token="$(id_token)" || { echo "000"; return 0; }
  local args=("${curl_opts[@]}" -o "$work/body.json" -w '%{http_code}' -X "$1" -H "Authorization: Bearer $token" -H 'Accept: application/json')
  [ -z "${3:-}" ] || args+=(-H 'Content-Type: application/json' --data-binary "@$3")
  code="$(curl "${args[@]}" "$platform$2" || true)"
  echo "${code:-000}"
}

python3 - "$SY_ENVIRONMENT" "$SY_APP" "$SY_DRY_RUN" > "$work/request.json" <<'PY'
import json, sys
body = {"environment": sys.argv[1], "dry_run": sys.argv[3] == "true"}
if sys.argv[2]:
    body["app"] = sys.argv[2]
print(json.dumps(body))
PY

echo "Asking Shipyard to deploy ${GITHUB_REPOSITORY}@${GITHUB_SHA:0:8} to ${SY_ENVIRONMENT}${SY_APP:+ (app ${SY_APP})}"
code="$(call POST /api/hooks/github/deploy "$work/request.json")"
if [ "$code" = "000" ]; then
  fail "Could not reach the Platform at $platform (or could not get an identity token). The job must run on the self-hosted deployment runner."
fi
if [ "$code" -lt 200 ] || [ "$code" -ge 300 ]; then
  fail "Shipyard refused the deploy (HTTP $code): $(json "$work/body.json" error "no reason given")" refused
fi

# A dry run is answered straight away with the plan; nothing is deployed.
if [ "$SY_DRY_RUN" = "true" ]; then
  echo "Dry run for $(json "$work/body.json" shipyard "this app"): nothing deployed."
  { echo "### Shipyard dry run: $(json "$work/body.json" shipyard)"; echo; echo '```json'; python3 -c 'import json,sys; print(json.dumps(json.load(open(sys.argv[1])).get("result"), indent=2))' "$work/body.json"; echo '```'; } >> "$GITHUB_STEP_SUMMARY"
  echo "status=success" >> "$GITHUB_OUTPUT"
  exit 0
fi

run_id="$(json "$work/body.json" id)"
echo "run-id=$run_id" >> "$GITHUB_OUTPUT"
echo "Shipyard run $run_id accepted for $(json "$work/body.json" shipyard "this app")"

deadline=$(( $(date +%s) + SY_TIMEOUT_MINUTES * 60 ))
last="" misses=0 status="syncing"
while :; do
  code="$(call GET "/api/hooks/github/deploy/$run_id")"
  if [ "$code" = "200" ]; then
    misses=0
    status="$(json "$work/body.json" status)"
    line="$(python3 - "$work/body.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
jobs = " ".join(f"{j.get('name')}={j.get('status')}" for j in d.get("jobs") or [])
print(f"{d.get('status')}{' · ' + d['stage'] if d.get('stage') else ''}{' · ' + jobs if jobs else ''}")
PY
)"
    [ "$line" = "$last" ] || { echo "$(date -u +%H:%M:%S) $line"; last="$line"; }
    case "$status" in success|failed|canceled) break ;; esac
  else
    misses=$((misses + 1))
    echo "$(date -u +%H:%M:%S) status check answered HTTP $code (attempt $misses)"
    [ "$misses" -lt 12 ] || fail "Lost contact with the Platform while waiting for run $run_id. The deploy may still be running: check Shipyard."
  fi
  [ "$(date +%s)" -lt "$deadline" ] || { status="timeout"; break; }
  sleep "$SY_POLL_SECONDS"
done

deploy_url="$(json "$work/body.json" deploy_url)"
pipeline_url="$(json "$work/body.json" pipeline_url)"
echo "status=$status" >> "$GITHUB_OUTPUT"
echo "deploy-url=$deploy_url" >> "$GITHUB_OUTPUT"
echo "pipeline-url=$pipeline_url" >> "$GITHUB_OUTPUT"

{
  echo "### Shipyard deploy: $status"
  echo
  echo "| | |"
  echo "|---|---|"
  echo "| App | $(json "$work/body.json" shipyard "$SY_APP") |"
  echo "| Environment | $SY_ENVIRONMENT |"
  echo "| Commit | \`${GITHUB_SHA:0:8}\` |"
  [ -z "$deploy_url" ] || echo "| Site | $deploy_url |"
  [ -z "$pipeline_url" ] || echo "| Shipyard pipeline | $pipeline_url |"
  python3 - "$work/body.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
jobs = d.get("jobs") or []
if jobs:
    print("\n| Job | Result |\n|---|---|")
    for j in jobs:
        print(f"| {j.get('name')} | {j.get('status')} |")
if d.get("error"):
    print(f"\n**Reason:** {d['error']}")
if d.get("log_tail"):
    print("\n<details><summary>Last lines of the failed job</summary>\n\n```\n" + d["log_tail"] + "\n```\n</details>")
PY
} >> "$GITHUB_STEP_SUMMARY"

case "$status" in
  success) echo "Deployed.${deploy_url:+ $deploy_url}" ;;
  timeout) fail "Still running after ${SY_TIMEOUT_MINUTES} minutes (run $run_id). It was not cancelled: check Shipyard." timeout ;;
  *)
    tail_text="$(json "$work/body.json" log_tail)"
    [ -z "$tail_text" ] || { echo "::group::Last lines of the failed job"; printf '%s\n' "$tail_text"; echo "::endgroup::"; }
    fail "Shipyard deploy $status: $(json "$work/body.json" error "see the job list above")" "$status"
    ;;
esac
