# Shipyard Deploy

Deploys the commit of the current run to a WCMC harbour through Shipyard, and
ends with Shipyard's result. You keep working in GitHub; the build and the
deploy happen on our side.

What it does:

1. Asks GitHub for an identity token for this run.
2. Calls the WCMC Platform, which checks the token and the run, brings the
   commit into the app's Shipyard repository and starts its pipeline.
3. Waits for the pipeline and shows each job as it changes.
4. Passes or fails the step to match, with a summary: site URL, job results,
   and the last lines of the failed job.

No deploy secret is stored in the repository.

## Usage

```yaml
jobs:
  deploy:
    runs-on: [self-hosted, deployment]
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: unepwcmc/devops-actions/.github/actions/shipyard-deploy@v2
        with:
          environment: staging
          platform-url: ${{ vars.SHIPYARD_PLATFORM_URL }}
```

`SHIPYARD_PLATFORM_URL` is an organisation variable; you do not set it per
repository.

A repository with more than one app names the one to deploy:

```yaml
        with:
          environment: staging
          app: my-app
          platform-url: ${{ vars.SHIPYARD_PLATFORM_URL }}
```

## Inputs

| Input | Description | Required | Default |
|---|---|---|---|
| `environment` | `staging` (production is not open yet) | Yes | |
| `app` | Shipyard app name, when the repository holds more than one | No | |
| `dry-run` | Report what the sync would add, change and delete; deploy nothing | No | `false` |
| `timeout-minutes` | How long to wait before failing the step | No | `30` |
| `poll-seconds` | Seconds between status checks | No | `10` |
| `platform-url` | Platform base URL: `${{ vars.SHIPYARD_PLATFORM_URL }}` | Yes | |
| `audience` | Identity token audience | No | `platform-url` |
| `ca-cert-file` | CA bundle on the runner for the Platform certificate | No | |

## Outputs

| Output | Description |
|---|---|
| `status` | `success`, `failed`, `canceled`, `refused` or `timeout` |
| `run-id` | Platform deploy run id |
| `deploy-url` | URL of the deployed app |
| `pipeline-url` | URL of the Shipyard pipeline |

## When it is refused

The step fails with the Platform's reason. The usual ones:

- the app has not been switched on for GitHub deploys yet (ask DevOps);
- the repository holds several apps and `app` is not set;
- the job has no `id-token: write` permission;
- the job is not on the self-hosted deployment runner.

A timeout does not cancel the deploy: it may still finish. Check Shipyard.
