# UNBL Backend Deploy Action

Builds and deploys UNBL services (API) to Azure App Service using Docker containers.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `environment` | Yes | - | Deployment environment (`staging` or `production`) |
| `azure-credentials` | Yes | - | Azure service principal credentials (JSON) |
| `infrastructure-ref` | No | `azure-bicep` | Branch/tag to checkout from unbl-infrastructure |
| `services-ref` | No | `main` | Branch/tag to checkout from unbl-services |
| `run-tests` | No | `true` | Run unit tests before deployment |

## Outputs

| Output | Description |
|--------|-------------|
| `deployment-duration` | Deployment duration in seconds |
| `image-tag` | Docker image tag deployed (git SHA) |
| `api-url` | API endpoint URL |

## Environment Variables Required

- `GH_TOKEN` - GitHub Personal Access Token (to checkout private repos)

## Usage Example

```yaml
- name: Deploy Backend
  id: backend
  uses: unep-wcmc/devops-actions/.github/actions/unbl-backend-deploy@v1
  with:
    environment: 'staging'
    azure-credentials: ${{ secrets.AZURE_SP_UNBL }}
    run-tests: true
  env:
    GH_TOKEN: ${{ secrets.GH_TOKEN }}

- name: Show deployment info
  run: |
    echo "API URL: ${{ steps.backend.outputs.api-url }}"
    echo "Image: unbl-services:${{ steps.backend.outputs.image-tag }}"
    echo "Duration: ${{ steps.backend.outputs.deployment-duration }}s"
```

## What It Does

1. Checks out `unbl-services` (source code) and `unbl-infrastructure` (deployment scripts)
2. Logs into Azure
3. Runs unit tests in Docker (app-specific, not in infrastructure scripts)
4. Calls **`unbl-infrastructure/azure/scripts/deploy-backend.sh`**, which handles:
   - Finding ACR and services repository
   - Building Docker image using ACR Tasks (cloud build)
   - Tagging image with `latest` (and optionally git SHA)
   - Configuring App Services with Docker image
   - Setting ACR credentials
   - Restarting API and TiTiler services
   - Waiting for services to initialize
   - Printing service URLs
5. Calls **`unbl-infrastructure/azure/scripts/health-check.sh`** to validate deployment
6. Reports deployment status and duration

**Key Point:** This action orchestrates the deployment by calling scripts from the `unbl-infrastructure` repository. All deployment logic is centralized in the infrastructure repo.

**Scripts Used:**
- `unbl-infrastructure/azure/scripts/deploy-backend.sh` - Backend build and deployment
- `unbl-infrastructure/azure/scripts/health-check.sh` - Post-deployment validation

## Features

- **Cloud builds**: Uses ACR Tasks (no local Docker required)
- **Unit testing**: Optional pre-deployment testing
- **Health checks**: Validates API is responding
- **Git SHA tagging**: Images tagged with commit hash for traceability
- **Timing**: Reports deployment duration

## Prerequisites

- Azure Container Registry deployed
- Azure App Service deployed
- GitHub Personal Access Token with repo access
- Docker image configuration already set on App Service

