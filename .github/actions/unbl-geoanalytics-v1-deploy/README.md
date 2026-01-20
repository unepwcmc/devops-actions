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

## Usage Example

```yaml
- name: Deploy Geoanalytics
  uses: unepwcmc/devops-actions/.github/actions/unbl-geoanalytics-v1-deploy@main
  with:
    environment: staging
    azure-credentials: ${{ secrets.AZURE_CREDENTIALS }}
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


