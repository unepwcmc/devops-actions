# UNBL Frontend Deployment Workflow

## What `deploy.yml` Does

This workflow deploys UNBL frontend applications (Map and Admin) to Azure Storage Static Website.

**Location**: `unbl-frontend/.github/workflows/deploy.yml`

**Triggers**: Push to `main` (production) or `develop` (staging)

## Connection to devops-actions Repository

This workflow calls the `unbl-frontend-deploy` action from the `devops-actions` repository:

```yaml
uses: unep-wcmc/devops-actions/.github/actions/unbl-frontend-deploy@v1
```

The action is located at: `devops-actions/.github/actions/unbl-frontend-deploy/action.yml`

### Steps

1. **Notify Start**: Sends Slack notification that deployment has started
2. **Deploy Frontend**: Calls `unbl-frontend-deploy` action from `devops-actions` repository, which:
   - Checks out `unbl-frontend` and `unbl-infrastructure` repositories
   - Authenticates to Azure
   - Builds both frontend applications (earth-map and earth-admin) via Docker
   - Uploads files to Azure Storage Static Website
   - Enables static website hosting with SPA routing
   - Runs health checks via `unbl-infrastructure/azure/scripts/health-check.sh`
3. **Notify Success/Failure**: Sends Slack notification with deployment status and duration
4. **Show Deployment Info**: Displays deployment summary (Map URL, Admin URL, duration)

### Infrastructure Scripts

The `devops-actions` action uses scripts from the `unbl-infrastructure` repository:
- `unbl-infrastructure/azure/scripts/deploy-frontend-full.sh` - Builds and deploys static files
- `unbl-infrastructure/azure/scripts/health-check.sh` - Validates deployment health

