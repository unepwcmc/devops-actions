# New UNBL STAC TiTiler v1 Infra (Composite Action)

This composite action provisions **UNBL STAC + TiTiler (pgSTAC)** Azure infrastructure using the Bicep templates in `unepwcmc/unbl-stac-titiler`.

It **does not** build or push Docker images yet (that will come later when you’re happy the infra provisioning is solid).

## What it provisions

Two subscription-scope deployments are executed (idempotent):

1. **RG + ACR** via `azure/bicep/setup-acr.bicep`
2. **pgSTAC infra** via `azure/bicep/main-pgstac.bicep`
   - Key Vault
   - Managed identity
   - PostgreSQL Flexible Server + database + firewall rules
   - App Service Plan + Web Apps (STAC API, STAC API Proxy, TiTiler, STAC Browser)

## Inputs

- **`environment`** *(required)*: `staging`, `prod`, or `production` (normalized to `prod` for Bicep)
- **`azure-credentials`** *(required)*: Service principal JSON (use `AZURE_SP_UNBL`)
- **`office-ip-address`** *(required)*: single IPv4 address to allow through the PostgreSQL firewall
- **`postgres-admin-password`** *(required)*: Postgres admin password (recommended from GitHub Secrets)
- **`stac-api-proxy-api-key`** *(required)*: API key for the STAC API Proxy
- **`location`** *(optional)*: default `uksouth`
- **`prefix`** *(optional)*: default `unbl`
- **`resource-group-name`** *(optional)*: default `<prefix>-<env>-pgstac-rg`
- **`postgres-database-name`** *(optional)*: default `pgstac`
- **`postgres-read-only-password`** *(optional)*: default empty
- **`azure-storage-connection-string`** *(optional)*: default empty
- **`stac-browser-custom-domain`** *(optional)*: default empty (only applied when env is `prod`)
- **`stac-whitelisted-ips`** *(optional)*: JSON array string, default `[]`
- **`titiler-cors-origins`** *(optional)*: JSON array string, default `[]`

## Outputs

- **`resource-group`**
- **`acr-name`**
- **`acr-login-server`**
- **`key-vault-name`**
- **`postgres-endpoint`**
- **`stac-api-url`**
- **`stac-api-proxy-url`**
- **`titiler-url`**
- **`stac-browser-url`**

## Example usage (in `unbl-stac-titiler`)

```yaml
name: Provision pgSTAC infra

on:
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        required: true
        options: [staging, production]

jobs:
  provision:
    runs-on: ubuntu-latest
    steps:
      - name: Provision infra (via devops-actions)
        uses: unepwcmc/devops-actions/.github/actions/unbl-stac-titiler-v1-infra@v1
        with:
          environment: ${{ inputs.environment }}
          azure-credentials: ${{ secrets.AZURE_SP_UNBL }}
          office-ip-address: ${{ secrets.OFFICE_IP_ADDRESS }}
          postgres-admin-password: ${{ secrets.PGSTAC_POSTGRES_ADMIN_PASSWORD }}
          stac-api-proxy-api-key: ${{ secrets.STAC_API_PROXY_API_KEY }}
        env:
          GH_TOKEN: ${{ secrets.GH_TOKEN }}
```

## Notes

- This action uses a **subscription-scope** deployment (`az deployment sub create`), so the service principal must have permissions to create/read deployments and manage resources.
- Secrets should be passed from **GitHub Secrets** to ensure masking.


