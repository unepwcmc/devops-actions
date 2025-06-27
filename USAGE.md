# DevOps Actions Usage Guide

## Quick Start

This repository provides centralized, reusable GitHub Actions for deploying Rails applications with Kamal (v1 and v2), Nuxt frontend applications, and includes comprehensive security validation and Slack notifications.

> **🚀 Minimal Setup**: Start with just `KAMAL_REGISTRY_USERNAME`, `KAMAL_REGISTRY_PASSWORD`, `SSH_PRIVATE_KEY`, and `RAILS_MASTER_KEY` (for Rails). Add other secrets only when needed.

## ⚠️ **Important: Recent Critical Fixes**

**Updated v1 Tag (Latest)**: We've fixed several critical bugs that were preventing deployments:

1. **Environment Variable Validation**: Actions now correctly validate environment variables instead of input parameters
2. **SSH Key Access**: Fixed SSH authentication by using environment variables instead of action inputs  
3. **Slack Notifications**: Self-contained templates with proper error handling and dynamic action types
4. **Consistent Usage**: All actions now use `env:` blocks for secrets instead of `with:` parameters

**Migration Required**: If you're using older examples, update your workflows to use `env:` blocks for secrets.

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

> **⚠️ Updated**: Now uses environment variables instead of input parameters for secrets.

```yaml
name: Deploy Nuxt Frontend
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate and Populate Secrets
        uses: unepwcmc/devops-actions/.github/actions/validate-secrets@v1
        with:
          secrets-file: '.kamal/secrets-common'
          environment: 'production'
      
      - name: Setup Nuxt Kamal v1
        uses: unepwcmc/devops-actions/.github/actions/nuxt-kamal-v1-setup@v1
        with:
          environment: production
        env:
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
          KAMAL_REGISTRY_USERNAME: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
          KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
          GH_TOKEN: ${{ secrets.GH_TOKEN }}
          WEB_SERVER_DNS_NAME: ${{ secrets.WEB_SERVER_DNS_NAME }}
          NUXT_API_BASE_URL: ${{ secrets.NUXT_API_BASE_URL }}
          NUXT_PUBLIC_APP_URL: ${{ secrets.NUXT_PUBLIC_APP_URL }}
          NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_ID: ${{ secrets.AZURE_AD_CLIENT_ID }}
          NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_SECRET: ${{ secrets.AZURE_AD_CLIENT_SECRET }}
          NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_TENANT_ID: ${{ secrets.AZURE_AD_TENANT_ID }}
          
      - name: Deploy Nuxt Application
        uses: unepwcmc/devops-actions/.github/actions/nuxt-kamal-v1-deploy@v1
        with:
          environment: production
          enable-health-checks: true
        env:
          # Environment variables are automatically populated by validate-secrets
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
          KAMAL_REGISTRY_USERNAME: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
          KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
          GH_TOKEN: ${{ secrets.GH_TOKEN }}
          WEB_SERVER_DNS_NAME: ${{ secrets.WEB_SERVER_DNS_NAME }}
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
DATABASE_HOST                   # Database hostname
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

### Recently Fixed Issues ✅

1. **"Missing download info" Error** 
   - **Fixed**: Repository privacy issues resolved
   - **Solution**: Ensure devops-actions repository is accessible to your workflows

2. **Environment Variable Validation Failures**
   - **Fixed**: Actions now correctly validate environment variables
   - **Previous Issue**: Actions were reading `${{ inputs.* }}` instead of environment variables
   - **Solution**: Update to latest v1 tag

3. **SSH Authentication Failures** 
   - **Fixed**: Actions now use `${{ env.SSH_PRIVATE_KEY }}` correctly
   - **Previous Issue**: Actions were expecting SSH key as input parameter
   - **Solution**: Use `env:` blocks instead of `with:` parameters for secrets

4. **Slack Notification Errors**
   - **Fixed**: Templates are now self-contained within slack-notify action
   - **Previous Issue**: Templates referenced wrong paths or caused JSON parsing errors
   - **Solution**: Update to latest v1 tag

### Current Common Issues

1. **SSH Connection Failures**
   - Ensure SSH key is properly formatted in secrets (should be the full private key content)
   - Verify server hostnames in Kamal config
   - Check firewall settings

2. **Docker Registry Issues**
   - Verify registry credentials are correct
   - Check Docker registry URL format
   - Ensure proper permissions for pushing images

3. **Database Connection Problems**
   - Verify database credentials
   - Check database hostname accessibility from deployment server
   - Ensure database exists and is properly configured

### Getting Help

1. **Check Action Logs**: Detailed logging is built into all actions
2. **Review Configuration**: Ensure all required secrets are set in the correct GitHub environment
3. **Validate Locally**: Use `kamal config validate` locally first
4. **Check v1 Tag**: Ensure you're using the latest v1 tag with our recent fixes
5. **Environment Variables**: Make sure you're using `env:` blocks for secrets, not `with:` parameters
6. **Contact DevOps Team**: For WCMC-specific configuration issues

### Migration from Old Usage

If your workflows are failing after our updates, check if you're using the old format:

**❌ Old (Broken)**:
```yaml
- name: Deploy
  uses: unepwcmc/devops-actions/.github/actions/nuxt-kamal-v1-deploy@v1
  with:
    ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
    kamal-registry-username: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
```

**✅ New (Working)**:
```yaml
- name: Deploy
  uses: unepwcmc/devops-actions/.github/actions/nuxt-kamal-v1-deploy@v1
  with:
    environment: production
  env:
    SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
    KAMAL_REGISTRY_USERNAME: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
```

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