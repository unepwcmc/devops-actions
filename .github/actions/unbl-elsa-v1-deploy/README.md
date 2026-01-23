# UNBL ELSA v1 Deploy Action

Deploys UNBL ELSA services to Azure (script-driven, like frontend/services):
- Checks out `unbl-elsa`
- Runs `unbl-elsa/azure/scripts/deploy-elsa.sh` which:
  - Deploys/updates infra via `unbl-elsa/azure/bicep/main.bicep` (idempotent)
  - Builds/pushes Docker images (`elsa_r:latest`, `elsa_trigger:latest`)
  - Updates the ELSA trigger Function App to use the new container image
  - Applies required app settings (without echoing secrets)

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `environment` | Yes | - | `staging` or `production` |
| `azure-credentials` | Yes | - | Azure service principal credentials (JSON) |
| `name-prefix` | No | `new-unbl-elsa` | Resource name prefix (kept for backward compat; infra names come from the repo parameters file) |
| `elsa-ref` | No | `new-staging-deploy` | Branch/tag to checkout from `unbl-elsa` |
| `location` | No | `uksouth` | Azure region |
| `build-elsa-r-image` | No | `true` | Build/push `elsa_r:latest` |
| `build-trigger-image` | No | `true` | Build/push `elsa_trigger:latest` |

## Outputs

| Output | Description |
|--------|-------------|
| `deployment-status` | `success` if the action completes |
| `deployment-duration` | Duration in seconds |
| `resource-group` | Resource group name used (currently not populated by the action) |

## Environment Variables Required

- `GH_TOKEN` - GitHub token/PAT to checkout private repos

## Secrets/Env expected by templates (set these in your workflow `env:`)

The action reads these as environment variables (do **not** echo them):

- `GUROBI_CLOUDACCESSID`
- `GUROBI_CLOUDSECRETKEY`
- `GUROBI_CLOUDPOOL`
- `AZURE_RASTER_STORAGE_ACCOUNT_NAME`
- `AZURE_RASTER_STORAGE_ACCOUNT_KEY`
- `AZURE_ELSA_INPUTS_FILE_SHARE_NAME`
- `AZURE_ELSA_RESULTS_STORAGE_CONTAINER`

## Usage Example

```yaml
- name: Deploy ELSA
  uses: unepwcmc/devops-actions/.github/actions/unbl-elsa-v1-deploy@v1
  with:
    environment: staging
    azure-credentials: ${{ secrets.AZURE_SP_UNBL }}
  env:
    GH_TOKEN: ${{ secrets.GH_TOKEN }}
    GUROBI_CLOUDACCESSID: ${{ secrets.GUROBI_CLOUDACCESSID }}
    GUROBI_CLOUDSECRETKEY: ${{ secrets.GUROBI_CLOUDSECRETKEY }}
    GUROBI_CLOUDPOOL: ${{ secrets.GUROBI_CLOUDPOOL }}
    AZURE_RASTER_STORAGE_ACCOUNT_NAME: ${{ secrets.AZURE_RASTER_STORAGE_ACCOUNT_NAME }}
    AZURE_RASTER_STORAGE_ACCOUNT_KEY: ${{ secrets.AZURE_RASTER_STORAGE_ACCOUNT_KEY }}
    AZURE_ELSA_INPUTS_FILE_SHARE_NAME: ${{ secrets.AZURE_ELSA_INPUTS_FILE_SHARE_NAME }}
    AZURE_ELSA_RESULTS_STORAGE_CONTAINER: ${{ secrets.AZURE_ELSA_RESULTS_STORAGE_CONTAINER }}
```


