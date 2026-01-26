# UNBL Geoanalytics v1 Deploy Action

Builds and deploys UNBL geoanalytics services to Azure using per-service deployment:
- Deploys/updates shared resources (storage + ACR + managed environment) via `azure/bicep/shared-infra.bicep`
- Builds/pushes Docker images and deploys each service independently:
  - `stacman:latest` (via `stacman/azure/scripts/deploy.sh`)
  - `pretiler:latest` (via `pretiler/azure/scripts/deploy.sh`)
  - `zonal-metrics-exact-extract:latest` (via `exactextract/azure/scripts/deploy.sh`)

Each service deployment is isolated and won't affect other services.

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

## Deployment Behavior

- **Shared Infrastructure**: Deployed via `azure/bicep/shared-infra.bicep` (idempotent - creates if missing, skips if exists)
- **Service Deployments**: Each service is deployed independently using its own script:
  - `stacman/azure/scripts/deploy.sh` - Deploys stacman resources
  - `pretiler/azure/scripts/deploy.sh` - Deploys pretiler resources  
  - `exactextract/azure/scripts/deploy.sh` - Deploys exactextract resources

Each service script automatically deploys shared infrastructure first (unless `--skip-infra` is used), then deploys its own resources. This ensures infrastructure exists before service deployment.

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

- Shared infra is deployed from `unbl-geoanalytics/azure/bicep/shared-infra.bicep`
- Each service has its own Bicep template and deployment script for independent deployment
- Service deployments are isolated - deploying one service won't affect others


