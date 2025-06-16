# DevOps Actions Usage Guide

## Quick Start

This repository provides centralized, reusable GitHub Actions for deploying Rails applications with Kamal (v1 and v2), Nuxt frontend applications, and includes comprehensive security validation and Slack notifications.

> **🚀 Minimal Setup**: Start with just `KAMAL_REGISTRY_USERNAME`, `KAMAL_REGISTRY_PASSWORD`, `SSH_PRIVATE_KEY`, and `RAILS_MASTER_KEY` (for Rails). Add other secrets only when needed.

## Basic Implementation

### 1. Backend Rails Application with Kamal v2

```yaml
name: Deploy to Staging
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate and Populate Secrets
        uses: unepwcmc/devops-actions/.github/actions/validate-secrets@v1
        with:
          secrets-file: '.kamal/secrets-common'
          environment: 'staging'
      
      - name: Setup Kamal v2
        uses: unepwcmc/devops-actions/.github/actions/kamal-v2-setup@v1
        with:
          environment: staging
          
      - name: Deploy with Kamal v2
        uses: unepwcmc/devops-actions/.github/actions/kamal-v2-deploy@v1
        with:
          environment: staging
          deployment-strategy: rolling
          
      - name: Notify Slack
        if: always()
        uses: unepwcmc/devops-actions/.github/actions/slack-notify@v1
        with:
          slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
          slack-channel-id: ${{ secrets.SLACK_CHANNEL_ID }}
          notification-type: ${{ job.status == 'success' && 'success' || 'failure' }}
          action-type: deploy
          environment: staging
```

### 2. Frontend Nuxt Application with Kamal v1

```yaml
name: Deploy Nuxt Frontend
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Nuxt Kamal v1
        uses: unepwcmc/devops-actions/.github/actions/nuxt-kamal-v1-setup@v1
        with:
          environment: production
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
          kamal-registry-username: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
          kamal-registry-password: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
          nuxt-api-base-url: ${{ secrets.NUXT_API_BASE_URL }}
          nuxt-public-app-url: ${{ secrets.NUXT_PUBLIC_APP_URL }}
          azure-ad-client-id: ${{ secrets.AZURE_AD_CLIENT_ID }}
          azure-ad-client-secret: ${{ secrets.AZURE_AD_CLIENT_SECRET }}
          azure-ad-tenant-id: ${{ secrets.AZURE_AD_TENANT_ID }}
          
      - name: Deploy Nuxt Application
        uses: unepwcmc/devops-actions/.github/actions/nuxt-kamal-v1-deploy@v1
        with:
          environment: production
          enable-health-checks: true
```

## Advanced Configuration

### Multi-Environment Setup

```yaml
name: Deploy to Multiple Environments
on:
  push:
    branches: [main, staging]

jobs:
  determine-environment:
    runs-on: ubuntu-latest
    outputs:
      environment: ${{ steps.env.outputs.environment }}
    steps:
      - id: env
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            echo "environment=production" >> $GITHUB_OUTPUT
          else
            echo "environment=staging" >> $GITHUB_OUTPUT
          fi

  deploy:
    needs: determine-environment
    runs-on: ubuntu-latest
    environment: ${{ needs.determine-environment.outputs.environment }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Kamal
        uses: unepwcmc/devops-actions/.github/actions/kamal-v2-setup@v1
        with:
          environment: ${{ needs.determine-environment.outputs.environment }}
          # ... other secrets
          
      - name: Deploy
        uses: unepwcmc/devops-actions/.github/actions/kamal-v2-deploy@v1
        with:
          environment: ${{ needs.determine-environment.outputs.environment }}
          deployment-strategy: ${{ needs.determine-environment.outputs.environment == 'production' && 'blue-green' || 'rolling' }}
```

### Database Migration Integration

```yaml
      - name: Setup Kamal with Migrations
        uses: unepwcmc/devops-actions/.github/actions/kamal-v2-setup@v1
        with:
          environment: staging
          pre-setup-commands: |
            echo "Running database migrations..."
            bundle exec rails db:migrate
          post-setup-commands: |
            echo "Warming up application..."
            curl -f https://myapp.staging.com/health || echo "Health check failed"
          # ... other configuration
```

## Security & Validation

### Using validate-secrets Action

The `validate-secrets` action ensures all required secrets are configured before deployment:

```yaml
- name: Validate and Populate Secrets
  uses: unepwcmc/devops-actions/.github/actions/validate-secrets@v1
  with:
    secrets-file: '.kamal/secrets-common'     # Path to your secrets template
    environment: 'production'                 # GitHub environment name
```

**What it does:**
- ✅ Checks that `.kamal/secrets-common` file exists
- ✅ Extracts all required variable names from the file
- ✅ Validates that each secret exists in your GitHub environment
- ✅ Populates environment variables for use in subsequent steps
- ❌ Fails early with clear error messages if secrets are missing

**Benefits:**
- 🛡️ **Security**: Prevents deployments with missing credentials
- 🚀 **Fail Fast**: Catches configuration issues before deployment starts
- 📋 **Clear Guidance**: Shows exactly which secrets are missing and where to add them
- 🔄 **Environment Variables**: Automatically populates `${{ env.* }}` variables

## Required Secrets Configuration

### ✅ **Always Required**
```
KAMAL_REGISTRY_USERNAME         # Docker registry username  
KAMAL_REGISTRY_PASSWORD         # Docker registry password
SSH_PRIVATE_KEY                 # SSH key for server access
```

### 🔧 **Required for Rails Applications**
```
RAILS_MASTER_KEY               # Rails master key
```

### 💾 **Required if Using Database**
```
DATABASE_HOSTNAME              # Database hostname
DATABASE_NAME                  # Database name
DATABASE_USERNAME              # Database username
DATABASE_PASSWORD              # Database password
DATABASE_PORT                  # Database port (default: 5432)
```

### 📢 **GitHub Workflow Secrets: Slack Notifications**
> **Note**: Slack secrets are NOT added to `.kamal/secrets-common` - they're only used by GitHub Actions workflows.

```
SLACK_BOT_TOKEN                # Slack bot token (GitHub Secret only)
SLACK_CHANNEL_ID               # Slack channel ID (GitHub Secret only)
```

### 🎨 **Optional: Frontend Applications**
```
FRONTEND_APP_NAME              # Your frontend app name
AUTH_ORIGIN                    # Authentication origin
NUXT_PUBLIC_RAILS_API_SERVER   # Rails API server URL
```

### 🔐 **Optional: Azure AD Integration**
```
NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_ID
NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_SECRET
NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_TENANT_ID
```

### ☁️ **Optional: AWS Services**
```
AWS_ACCESS_KEY_ID              # AWS access key
AWS_SECRET_ACCESS_KEY          # AWS secret key
AWS_REGION                     # AWS region
```

> **Start Simple**: Begin with just the always required secrets + what you need for your specific application type.

## Migration Guide

### From Manual Kamal to DevOps Actions

**Before:**
```yaml
- name: Deploy with Kamal
  run: |
    # 50+ lines of setup and deployment logic
    gem install kamal
    mkdir -p .kamal
    echo "KAMAL_REGISTRY_USERNAME=${{ secrets.KAMAL_REGISTRY_USERNAME }}" > .kamal/secrets
    # ... many more lines
    kamal setup
    kamal deploy
```

**After:**
```yaml
- name: Setup Kamal
  uses: unepwcmc/devops-actions/.github/actions/kamal-v2-setup@v1
  with:
    environment: staging
    # ... configuration

- name: Deploy
  uses: unepwcmc/devops-actions/.github/actions/kamal-v2-deploy@v1
  with:
    environment: staging
```

**Benefits:**
- ✅ **90% reduction** in workflow complexity
- ✅ **Centralized maintenance** and updates
- ✅ **Standardized practices** across all projects
- ✅ **Built-in error handling** and security
- ✅ **Comprehensive validation** and health checks

## Troubleshooting

### Common Issues

1. **SSH Connection Failures**
   - Ensure SSH key is properly formatted in secrets
   - Verify server hostnames in Kamal config
   - Check firewall settings

2. **Docker Registry Issues**
   - Verify registry credentials
   - Check Docker registry URL format
   - Ensure proper permissions

3. **Database Connection Problems**
   - Verify database credentials
   - Check database hostname accessibility
   - Ensure database exists

### Getting Help

1. **Check Action Logs**: Detailed logging is built into all actions
2. **Review Configuration**: Ensure all required secrets are set
3. **Test Locally**: Use `kamal config validate` locally first
4. **Contact DevOps Team**: For WCMC-specific configuration issues

## Best Practices

### Security
- ✅ Use environment-specific secrets
- ✅ Rotate credentials regularly  
- ✅ Limit SSH key access
- ✅ Use least-privilege principles

### Deployment Strategy
- ✅ Use `rolling` for staging environments
- ✅ Use `blue-green` for production
- ✅ Enable health checks in production
- ✅ Implement proper monitoring

### Maintenance
- ✅ Simple versioning with `@v1` tag (early development approach)
- ✅ Test changes in staging first
- ✅ Keep Kamal versions updated
- ✅ Monitor deployment metrics

## Support

For questions or issues:
- **Documentation**: Check this guide and action READMEs
- **Issues**: Create GitHub issues for bugs or feature requests
- **DevOps Team**: Contact for WCMC-specific configuration help 