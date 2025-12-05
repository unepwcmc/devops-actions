# UNBL Frontend Deploy Action

Builds and deploys UNBL frontend applications (earth-map and earth-admin) to Azure Storage static website hosting.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `environment` | Yes | - | Deployment environment (`staging` or `production`) |
| `azure-credentials` | Yes | - | Azure service principal credentials (JSON) |
| `infrastructure-ref` | No | `azure-bicep` | Branch/tag to checkout from unbl-infrastructure |
| `frontend-ref` | No | `main` | Branch/tag to checkout from unbl-frontend |

## Outputs

| Output | Description |
|--------|-------------|
| `deployment-duration` | Deployment duration in seconds |
| `frontend-url` | Frontend Map app URL |
| `admin-url` | Admin dashboard URL |

## Environment Variables Required

- `GH_TOKEN` - GitHub Personal Access Token (to checkout private repos)
- `GATSBY_AUTH0_DOMAIN` - Auth0 domain (e.g., `unbl-staging-wcmc.eu.auth0.com`)
- `AUTH0_CLIENT_ID` - Auth0 SPA client ID
- `AUTH0_APPLICATION_CLIENT_ID` - Auth0 M2M application client ID
- `GATSBY_AUTH0_AUDIENCE` - Auth0 API audience
- `GATSBY_MAPBOX_TOKEN` - Mapbox public token for maps

## Usage Example

```yaml
- name: Deploy Frontend
  id: frontend
  uses: unep-wcmc/devops-actions/.github/actions/unbl-frontend-deploy@v1
  with:
    environment: 'staging'
    azure-credentials: ${{ secrets.AZURE_SP_UNBL }}
  env:
    GH_TOKEN: ${{ secrets.GH_TOKEN }}
    GATSBY_AUTH0_DOMAIN: ${{ secrets.GATSBY_AUTH0_DOMAIN }}
    AUTH0_CLIENT_ID: ${{ secrets.AUTH0_CLIENT_ID }}
    AUTH0_APPLICATION_CLIENT_ID: ${{ secrets.AUTH0_APPLICATION_CLIENT_ID }}
    GATSBY_AUTH0_AUDIENCE: ${{ secrets.GATSBY_AUTH0_AUDIENCE }}
    GATSBY_MAPBOX_TOKEN: ${{ secrets.GATSBY_MAPBOX_TOKEN }}

- name: Show deployed URLs
  run: |
    echo "Map: ${{ steps.frontend.outputs.frontend-url }}"
    echo "Admin: ${{ steps.frontend.outputs.admin-url }}"
```

## What It Does

1. Checks out `unbl-frontend` (source code) and `unbl-infrastructure` (deployment scripts)
2. Logs into Azure
3. Calls **`unbl-infrastructure/azure/scripts/deploy-frontend-full.sh`**, which handles:
   - Creating `.env` file with Auth0 and Mapbox configuration
   - Getting frontend storage account name from Azure
   - Building both frontend apps via Docker:
     - `earth-map` (Map application)
     - `earth-admin` (Admin dashboard)
   - Uploading `earth-map` to storage root (`/`)
   - Uploading `earth-admin` to `/admin/` path
   - Enabling static website hosting with SPA routing
   - Printing deployment URLs
4. Calls **`unbl-infrastructure/azure/scripts/health-check.sh`** to validate deployment
5. Reports deployment status and duration

**Key Point:** This action orchestrates the deployment by calling scripts from the `unbl-infrastructure` repository. All deployment logic is centralized in the infrastructure repo.

**Scripts Used:**
- `unbl-infrastructure/azure/scripts/deploy-frontend-full.sh` - Frontend build and deployment
- `unbl-infrastructure/azure/scripts/health-check.sh` - Post-deployment validation

## Features

- **Dual app deployment**: Deploys both Map and Admin in one action
- **Docker builds**: Consistent builds across environments
- **SPA routing**: Configured for client-side routing
- **Health checks**: Validates both apps are accessible
- **Timing**: Reports deployment duration

## Frontend Structure

```
Storage Root ($web)
├── index.html           (earth-map)
├── static/
├── page-data/
└── admin/               (earth-admin)
    ├── index.html
    ├── static/
    └── page-data/
```

## Prerequisites

- Azure Storage Account deployed with static website enabled
- GitHub Personal Access Token with repo access
- All Auth0 configuration completed
- Mapbox token configured

