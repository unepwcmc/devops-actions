# UNBL Geoanalytics v1 Deploy Action

Builds and deploys UNBL geoanalytics services to Azure:
- Deploys/updates shared resources (storage + ACR + container environment)
- Builds/pushes Docker images and deploys:
  - `stacman:latest`
  - `pretiler:latest`
  - `zonal-metrics-exact-extract:latest`

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `environment` | Yes | - | `staging` or `production` |
| `azure-credentials` | Yes | - | Azure service principal credentials (JSON) |
| `geoanalytics-ref` | No | `main` | Branch/tag to checkout from `unbl-geoanalytics` |
| `location` | No | `uksouth` | Azure region |
| `deploy-shared-infra` | No | `true` | Deploy shared resources |
| `deploy-stacman` | No | `true` | Deploy stacman |
| `deploy-pretiler` | No | `true` | Deploy pretiler |
| `deploy-exactextract` | No | `true` | Deploy exactextract |

## Outputs

| Output | Description |
|--------|-------------|
| `deployment-status` | `success` if the action completes |
| `deployment-duration` | Duration in seconds |
| `resource-group` | Resource group name used |
| `container-registry` | ACR name used |

## Environment Variables Required

- `GH_TOKEN` - GitHub token/PAT to checkout private repos

## Secrets/Env expected by templates (set these in your workflow `env:`)

The action reads these as environment variables:

- `RASTER_STORAGE_CONNECTION_STRING`
- `DEFAULT_STAC_HOST`
- `PGHOST`
- `PGDATABASE`
- `PGUSER`
- `PGPASSWORD`
- `TITILER_URL`
- `STAC_SERVER_URL`

## Shared infra auto-skip behavior

If `deploy-shared-infra: 'true'`, the action will first check whether the **shared infra already exists** in the target resource group:
- Storage account (`storage` name computed by the action)
- Azure Container Registry (`acr` name computed by the action)
- Container Apps managed environment (`container_env` name computed by the action)

If all three exist, the action **skips** the shared infra deployment step and proceeds to app deployment.

If you request any app deployment (`deploy-stacman`, `deploy-pretiler`, `deploy-exactextract`) and the shared infra is missing, the action will **fail fast** with a clear error message.

## Usage Example

```yaml
- name: Deploy Geoanalytics
  uses: unepwcmc/devops-actions/.github/actions/unbl-geoanalytics-v1-deploy@v1
  with:
    environment: staging
    azure-credentials: ${{ secrets.AZURE_SP_UNBL }}
  env:
    GH_TOKEN: ${{ secrets.GH_TOKEN }}
    RASTER_STORAGE_CONNECTION_STRING: ${{ secrets.RASTER_STORAGE_CONNECTION_STRING }}
    DEFAULT_STAC_HOST: ${{ secrets.DEFAULT_STAC_HOST }}
    PGHOST: ${{ secrets.PGHOST }}
    PGDATABASE: ${{ secrets.PGDATABASE }}
    PGUSER: ${{ secrets.PGUSER }}
    PGPASSWORD: ${{ secrets.PGPASSWORD }}
    TITILER_URL: ${{ secrets.TITILER_URL }}
    STAC_SERVER_URL: ${{ secrets.STAC_SERVER_URL }}
```

## Notes

- Shared infra is deployed from the geoanalytics repo using Bicep at `unbl-geoanalytics/azure/bicep/main.bicep`.


