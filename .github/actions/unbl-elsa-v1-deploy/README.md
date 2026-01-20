# UNBL ELSA v1 Deploy Action

Builds and deploys UNBL ELSA services to Azure:
- Deploys/updates the **ACR** (from `unbl-elsa/template.json`)
- Builds/pushes Docker images (`elsa_r:latest`, `elsa_trigger:latest`)
- Deploys/updates the **queueTrigger** function app (from `unbl-elsa/queueTrigger/template.json`)

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `environment` | Yes | - | `staging` or `production` |
| `azure-credentials` | Yes | - | Azure service principal credentials (JSON) |
| `elsa-ref` | No | `main` | Branch/tag to checkout from `unbl-elsa` |
| `location` | No | `uksouth` | Azure region |
| `build-elsa-r-image` | No | `true` | Build/push `elsa_r:latest` |
| `build-trigger-image` | No | `true` | Build/push `elsa_trigger:latest` |

## Outputs

| Output | Description |
|--------|-------------|
| `deployment-status` | `success` if the action completes |
| `deployment-duration` | Duration in seconds |
| `resource-group` | Resource group name used |

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
  uses: unepwcmc/devops-actions/.github/actions/unbl-elsa-v1-deploy@main
  with:
    environment: staging
    azure-credentials: ${{ secrets.AZURE_CREDENTIALS }}
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


