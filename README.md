# DevOps Actions

A centralized GitHub Actions repository providing reusable composite actions for deploying Rails applications with Kamal (supporting both v1 and v2) and sending Slack notifications.

## 🎯 Overview

This repository enables multiple projects to reference standardized deployment and notification processes, ensuring consistency, maintainability, and scalability across your organization.

**✅ Complete Coverage Achieved:**
- 🎯 **Backend Actions**: Kamal v1 & v2 (setup + deploy)
- 🎨 **Frontend Actions**: Nuxt with Kamal v1 (setup + deploy)  
- 📢 **Notifications**: Integrated Slack notifications for all workflows
- 🔧 **Enhanced Environment Variables**: Redis, Mail, AWS S3, Azure AD, and more

## 🚀 Features

- **Centralized Actions**: Reusable composite actions for Kamal deployments and notifications
- **Version Support**: Support for both Kamal v1 (legacy) and v2 (current)
- **Comprehensive Notifications**: Slack integration with rich formatting and status updates
- **Best Practices**: Built-in security, validation, health checks, and rollback capabilities
- **Enhanced Environment Support**: Redis/Sidekiq, Mail servers, AWS S3, Azure AD integration
- **Flexible Configuration**: Environment-specific secrets and configurations
- **Self-hosted Runner Support**: Optimized for deployment environments

## 📦 Available Actions

### ✨ **Simplified Actions (Recommended)**
- **`validate-secrets`** - Validates and populates secrets from `.kamal/secrets-common` template
- **`nuxt-kamal-v2-deploy-simple`** - Simplified Nuxt deployment (only needs `environment`)
- **`nuxt-kamal-v2-setup-simple`** - Simplified Nuxt setup (only needs `environment`)
- **`slack-notify`** - Slack notifications for workflows (uses GitHub secrets directly)

> **💡 New Approach**: These actions use the `validate-secrets` action to automatically populate all needed environment variables. You only need to pass the `environment` parameter!

### 🔧 **Legacy Actions (Complex Configuration)**

#### Backend Actions (Rails Applications)
- **`kamal-v2-setup`**: Initial setup and configuration for Kamal v2 (requires all individual secrets)
- **`kamal-v2-deploy`**: Full-featured deployment (requires all individual secrets)
- **`kamal-v1-setup`**: Initial setup for Kamal v1 deployments
- **`kamal-v1-deploy`**: Basic deployment capabilities for legacy projects

#### Frontend Actions (Nuxt Applications)
- **`nuxt-kamal-v1-setup`**: Initial setup for Nuxt frontend applications
- **`nuxt-kamal-v1-deploy`**: Deployment with Azure AD, Rails API integration
- **`nuxt-kamal-v2-setup`**: Full Nuxt setup (requires all individual secrets)
- **`nuxt-kamal-v2-deploy`**: Full Nuxt deployment (requires all individual secrets)

#### Validation Actions
- **`validate-workflow`**: Validates workflow configuration and ensures proper setup

## 🛠 Quick Start

> **💡 Start Simple**: You only need 3 secrets to get started: `KAMAL_REGISTRY_USERNAME`, `KAMAL_REGISTRY_PASSWORD`, and `SSH_PRIVATE_KEY` (plus `RAILS_MASTER_KEY` for Rails apps).

### 1. Copy Example Workflows

Choose the appropriate workflow from our examples:

- **`.github/workflows/kamal-v1-backend-example.yml`** - Rails backend with Kamal v1
- **`.github/workflows/kamal-v2-backend-example.yml`** - Rails backend with Kamal v2  
- **`.github/workflows/nuxt-frontend-v1-example.yml`** - Nuxt frontend with Kamal v1
- **`.github/workflows/nuxt-frontend-v2-example.yml`** - Nuxt frontend with Kamal v2
- **`.github/workflows/kamal-setup-example.yml`** - Initial setup workflows
- **`.github/workflows/consumer-example.yml`** - Complete reference guide

### 2. Configure Secrets

#### Create Secrets File
Choose the appropriate template for your needs:

**For basic Rails deployment:**
```bash
cp .kamal/secrets-common.minimal.template .kamal/secrets-common
```

**For full-featured Rails deployment:**
```bash
cp .kamal/secrets-common.template .kamal/secrets-common
```

**For Nuxt frontend deployment:**
```bash
cp .kamal/secrets-common.nuxt.template .kamal/secrets-common
```

#### Add Secrets to GitHub Environment
Add secrets to your repository's environment (staging/production) based on your needs:

#### ✅ **Required for Any Deployment**
```
KAMAL_REGISTRY_USERNAME     # Docker registry username  
KAMAL_REGISTRY_PASSWORD     # Docker registry password
SSH_PRIVATE_KEY            # SSH key for server access (in action inputs, not template)
```

#### 🔧 **Required for Rails Backend**
```
RAILS_MASTER_KEY           # Rails master key
```

#### 💾 **Required if Using Database**
```
DATABASE_HOSTNAME          # Database host
DATABASE_NAME              # Database name  
DATABASE_USERNAME          # Database username
DATABASE_PASSWORD          # Database password
DATABASE_PORT              # Database port (usually 5432)
```

#### 📢 **GitHub Workflow Secrets: Slack Notifications**
> **Note**: Slack secrets are NOT added to `.kamal/secrets-common` - they're only used by GitHub Actions workflows.

```
SLACK_BOT_TOKEN            # Slack bot token (GitHub Secret only)
SLACK_CHANNEL_ID           # Slack channel ID (GitHub Secret only)
```

#### 🎨 **Optional: Frontend/Nuxt Applications**
```
FRONTEND_APP_NAME                    # Your app name
AUTH_ORIGIN                          # Auth origin URL
NUXT_PUBLIC_RAILS_API_SERVER         # Rails API URL
RAILS_DEFAULT_PUBLIC_APP_HOST        # Rails host
RAILS_DEFAULT_PUBLIC_APP_HOST_PROTOCOL # Usually https
```

#### 🔐 **Optional: Azure AD Integration**
```
NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_ID
NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_SECRET  
NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_TENANT_ID
```

#### ☁️ **Optional: AWS Services**
```
AWS_ACCESS_KEY_ID          # AWS access key
AWS_SECRET_ACCESS_KEY      # AWS secret key
AWS_REGION                 # AWS region
```

> **💡 Tip**: Start with just the required secrets for your use case. Add optional ones only when needed.

### 3. Basic Usage Examples

#### Simple Nuxt Frontend Deployment (Kamal v2 - Simplified)

```yaml
name: Deploy Nuxt Frontend

on:
  push:
    branches: [main]

jobs:
  deploy:
    name: Deploy to Production
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # Step 1: Validate and populate ALL Kamal secrets
      - name: Validate and Populate Secrets
        uses: unepwcmc/devops-actions/.github/actions/validate-secrets@v1
        with:
          secrets-file: '.kamal/secrets-common'
          environment: 'production'

      # Step 2: Start notification
      - name: Notify Deployment Start
        id: notify-start
        uses: unepwcmc/devops-actions/.github/actions/slack-notify@v1
        with:
          slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
          slack-channel-id: ${{ secrets.SLACK_CHANNEL_ID }}
          notification-type: 'started'
          action-type: 'deploy'
          environment: 'production'
          repository: ${{ github.repository }}

      # Step 3: Deploy (SIMPLIFIED - only needs environment!)
      - name: Deploy Nuxt Application
        id: deploy
        uses: unepwcmc/devops-actions/.github/actions/nuxt-kamal-v2-deploy-simple@v1
        with:
          environment: 'production'

      # Step 4: Success notification
      - name: Notify Deployment Success
        if: success()
        uses: unepwcmc/devops-actions/.github/actions/slack-notify@v1
        with:
          slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
          slack-channel-id: ${{ secrets.SLACK_CHANNEL_ID }}
          notification-type: 'success'
          action-type: 'deploy'
          environment: 'production'
          update-message-ts: ${{ steps.notify-start.outputs.message-ts }}
          repository: ${{ github.repository }}
          deployment-duration: ${{ steps.deploy.outputs.deployment-duration }}

      # Step 5: Failure notification
      - name: Notify Deployment Failure
        if: failure()
        uses: unepwcmc/devops-actions/.github/actions/slack-notify@v1
        with:
          slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}
          slack-channel-id: ${{ secrets.SLACK_CHANNEL_ID }}
          notification-type: 'failure'
          action-type: 'deploy'
          environment: 'production'
          update-message-ts: ${{ steps.notify-start.outputs.message-ts }}
          repository: ${{ github.repository }}
          error-message: 'Deployment failed - check logs for details'
```

#### Enhanced Backend with Redis, Mail & S3

```yaml
      # Enhanced Rails Backend Deployment
      - name: Deploy with Enhanced Configuration
        uses: unepwcmc/devops-actions/.github/actions/kamal-v2-deploy@v1
        with:
          environment: 'production'
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
          kamal-registry-username: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
          kamal-registry-password: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
          rails-master-key: ${{ secrets.RAILS_MASTER_KEY }}
          rails-default-public-app-host: ${{ secrets.RAILS_DEFAULT_PUBLIC_APP_HOST }}
          rails-default-public-app-host-protocol: ${{ secrets.RAILS_DEFAULT_PUBLIC_APP_HOST_PROTOCOL }}
          
          # Database with custom prefix
          database-env-prefix: 'OCEAN_CENSUS'  # Example with different prefix
          database-host: ${{ secrets.DATABASE_HOST }}
          database-name: ${{ secrets.DATABASE_NAME }}
          database-username: ${{ secrets.DATABASE_USERNAME }}
          database-password: ${{ secrets.DATABASE_PASSWORD }}
          
          # Redis/Sidekiq configuration
          redis-username: ${{ secrets.REDIS_USERNAME }}
          redis-password: ${{ secrets.REDIS_PASSWORD }}
          
          # Mail server configuration  
          mail-username: ${{ secrets.MAIL_USERNAME }}
          mail-password: ${{ secrets.MAIL_PASSWORD }}
          
          # AWS S3 configuration
          aws-s3-access-key-id: ${{ secrets.AWS_S3_ACCESS_KEY_ID }}
          aws-s3-secret-access-key: ${{ secrets.AWS_S3_SECRET_ACCESS_KEY }}
          aws-s3-region: ${{ secrets.AWS_S3_REGION }}
          aws-s3-bucket-name: ${{ secrets.AWS_S3_NAME }}
          
          # Frontend integration (for full-stack projects)
          frontend-app-name: ${{ secrets.FRONTEND_APP_NAME }}
          azure-ad-client-id: ${{ secrets.NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_ID }}
          azure-ad-client-secret: ${{ secrets.NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_SECRET }}
          azure-ad-tenant-id: ${{ secrets.NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_TENANT_ID }}
          wcmc-user-management-secret: ${{ secrets.NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_SECRET }}
```

#### Nuxt Frontend Deployment

> **⚠️ Important**: All actions now use environment variables instead of input parameters for secrets.

```yaml
      # Nuxt Frontend Deployment - Environment variables are set automatically
      - name: Deploy Nuxt Frontend
        uses: unepwcmc/devops-actions/.github/actions/nuxt-kamal-v1-deploy@v1
        with:
          environment: 'staging'
        env:
          # Core secrets (automatically populated by validate-secrets action)
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
          KAMAL_REGISTRY_USERNAME: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
          KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
          GH_TOKEN: ${{ secrets.GH_TOKEN }}
          WEB_SERVER_DNS_NAME: ${{ secrets.WEB_SERVER_DNS_NAME }}
          
          # Rails API Integration
          RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}
          RAILS_DEFAULT_PUBLIC_APP_HOST: ${{ secrets.RAILS_DEFAULT_PUBLIC_APP_HOST }}
          RAILS_DEFAULT_PUBLIC_APP_HOST_PROTOCOL: ${{ secrets.RAILS_DEFAULT_PUBLIC_APP_HOST_PROTOCOL }}
          
          # Frontend Configuration
          FRONTEND_APP_NAME: ${{ secrets.FRONTEND_APP_NAME }}
          AUTH_ORIGIN: ${{ secrets.AUTH_ORIGIN }}
          NUXT_PUBLIC_RAILS_API_SERVER: ${{ secrets.NUXT_PUBLIC_RAILS_API_SERVER }}
          
          # Azure AD & WCMC User Management
          NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_ID: ${{ secrets.NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_ID }}
          NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_SECRET: ${{ secrets.NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_SECRET }}
          NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_TENANT_ID: ${{ secrets.NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_TENANT_ID }}
          NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_SECRET: ${{ secrets.NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_SECRET }}
          NUXT_PUBLIC_WCMC_MODULES_WCMC_USER_MANAGEMENT_RAILS_API_SERVER: ${{ secrets.NUXT_PUBLIC_WCMC_MODULES_WCMC_USER_MANAGEMENT_RAILS_API_SERVER }}
```

## 🔧 Environment Variables Automatically Created

### Database (Flexible Prefix Support)
```bash
# For database-env-prefix: 'OCEAN_CENSUS'
OCEAN_CENSUS_DATABASE_HOSTNAME
OCEAN_CENSUS_DATABASE_NAME
OCEAN_CENSUS_DATABASE_USERNAME
OCEAN_CENSUS_DATABASE_PASSWORD
OCEAN_CENSUS_DATABASE_PORT

# For database-env-prefix: 'MY_APP'
MY_APP_DATABASE_HOSTNAME
# ... etc
```

### Redis/Sidekiq (Auto-Generated URLs)
```bash
REDIS_USERNAME
REDIS_PASSWORD
SIDEKIQ_REDIS_URL=redis://username:password@host.docker.internal:6379/1
```

### Mail Configuration
```bash
MAIL_USERNAME
MAIL_PASSWORD
```

### AWS S3
```bash
AWS_S3_ACCESS_KEY_ID
AWS_S3_SECRET_ACCESS_KEY
AWS_S3_REGION
AWS_S3_NAME
```

### Frontend Integration
```bash
FRONTEND_APP_NAME
NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_ID
NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_SECRET
NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_TENANT_ID
NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_SECRET
```

## 📚 Complete Examples

## 📁 **Clean Workflow Examples**

All workflows in `.github/workflows/` are clean, reusable examples:

- **`kamal-v1-backend-example.yml`** - Rails backend deployment with Kamal v1
- **`kamal-v2-backend-example.yml`** - Rails backend deployment with Kamal v2
- **`nuxt-frontend-v1-example.yml`** - Nuxt frontend deployment with Kamal v1
- **`nuxt-frontend-v2-example.yml`** - Nuxt frontend deployment with Kamal v2 ✨ **NEW**
- **`kamal-setup-example.yml`** - Initial setup workflows (supports all combinations)
- **`consumer-example.yml`** - Reference guide for consuming repositories

## 📊 Complete Coverage Matrix

```mermaid
graph TD
    A[🚀 WCMC DevOps Actions<br/>Complete Coverage] --> B[Backend Support]
    A --> C[Frontend Support]
    A --> D[Setup & Reference]
    
    B --> E[Kamal v1 Backend]
    B --> F[Kamal v2 Backend]
    
    C --> G[Kamal v1 Frontend]
    C --> H[Kamal v2 Frontend - NEW!]
    
    D --> I[Universal Setup]
    D --> J[Consumer Reference]
    
    E --> E1["kamal-v1-backend-example.yml"]
    E --> E2[".github/actions/kamal-v1-deploy"]
    E --> E3[".github/actions/kamal-v1-setup"]
    
    F --> F1["kamal-v2-backend-example.yml"]
    F --> F2[".github/actions/kamal-v2-deploy"]
    F --> F3[".github/actions/kamal-v2-setup"]
    
    G --> G1["nuxt-frontend-v1-example.yml"]
    G --> G2[".github/actions/nuxt-kamal-v1-deploy"]
    G --> G3[".github/actions/nuxt-kamal-v1-setup"]
    
    H --> H1["nuxt-frontend-v2-example.yml - NEW!"]
    H --> H2[".github/actions/nuxt-kamal-v2-deploy - NEW!"]
    H --> H3[".github/actions/nuxt-kamal-v2-setup - NEW!"]
    
    I --> I1["kamal-setup-example.yml<br/>All versions & types"]
    J --> J1["consumer-example.yml<br/>Reference guide"]
    
    style A fill:#f8f9fa
    style H fill:#e8f5e8
    style H1 fill:#e8f5e8
    style H2 fill:#e8f5e8
    style H3 fill:#e8f5e8
    style I1 fill:#fff3e0
    style J1 fill:#f0f8ff
```

| **Application Type** | **Kamal v1** | **Kamal v2** |
|---------------------|-------------|-------------|
| **Backend (Rails)** | ✅ Complete | ✅ Complete |
| **Frontend (Nuxt)** | ✅ Complete | ✅ Complete |

## 🎉 **Latest Updates**

### 🐛 **Critical Bug Fixes (v1 Update)**

We've resolved several critical issues that were affecting deployments:

**🔧 Environment Variable Validation Bug Fixed:**
- **Issue**: Actions were incorrectly reading input parameters instead of environment variables during validation
- **Fixed Actions**: `nuxt-kamal-v2-setup`, `nuxt-kamal-v2-deploy`, `nuxt-kamal-v1-setup`, `nuxt-kamal-v1-deploy`
- **Impact**: Validation now properly checks environment variables set by GitHub secrets
- **Status**: ✅ All actions now correctly validate required environment variables

**📢 Slack Notification System Improved:**
- **Self-Contained Templates**: Slack templates are now embedded within the `slack-notify` action
- **Dynamic Action Types**: Notifications now correctly show "Setup", "Deploy", etc. based on the actual action
- **Better Error Handling**: Empty environment variables no longer cause JSON parsing errors
- **Template Fixes**: All notification types (started, success, failure) now work consistently

**🔑 SSH Key Access Fixed:**
- **Issue**: Actions were trying to access `${{ inputs.ssh-private-key }}` but workflows provide environment variables
- **Solution**: Updated all actions to use `${{ env.SSH_PRIVATE_KEY }}` and `${{ env.WEB_SERVER_DNS_NAME }}`
- **Affected Actions**: All Kamal deployment actions
- **Status**: ✅ SSH authentication now works correctly

### ✨ **Complete Kamal v2 Frontend Support Added**

We've achieved **100% coverage** for all deployment scenarios:

**New Actions Created:**
- 🆕 `.github/actions/nuxt-kamal-v2-setup` - Setup Nuxt apps with Kamal v2
- 🆕 `.github/actions/nuxt-kamal-v2-deploy` - Deploy Nuxt apps with Kamal v2 (enhanced features)

**New Workflows:**
- 🆕 `nuxt-frontend-v2-example.yml` - Complete Nuxt deployment example with Kamal v2

**Enhanced Features in Kamal v2 Actions:**
- 🔄 **Rolling Deployments** - Safer deployment strategy
- 🏥 **Health Checks** - Automated post-deployment verification
- 🔙 **Auto Rollback** - Automatic rollback on deployment failure
- 📊 **Enhanced Status Reporting** - Better monitoring and duration tracking
- 🔐 **Improved Security** - Enhanced secrets handling and validation

**Workflow Improvements:**
- 📝 **Consistent Naming** - All workflows follow `{type}-v{version}-example.yml` pattern
- 🧹 **Clean Structure** - Removed legacy/project-specific files
- 🔄 **Enhanced Setup** - `kamal-setup-example.yml` now supports frontend-v1 and frontend-v2 options

## 🎯 Migration Benefits

### Before (Manual Workflows)
- 60-100+ lines per deployment workflow
- Manual environment variable setup
- Inconsistent notification patterns
- Duplicated code across projects
- No validation or error handling
- Security concerns with secret exposure

### After (Using DevOps Actions)
- 20-30 lines per deployment workflow
- Centralized, validated environment setup
- Consistent Slack notifications across all projects
- Single source of truth for deployment logic
- Built-in security, validation, and error handling
- **90% reduction in workflow complexity**

## 🔄 Versioning

Use semantic versioning with tags:

```yaml
uses: unepwcmc/devops-actions/.github/actions/kamal-v2-deploy@v1
uses: unepwcmc/devops-actions/.github/actions/kamal-v2-deploy@v1
uses: unepwcmc/devops-actions/.github/actions/kamal-v2-deploy@main  # latest
```

## 🤝 Contributing

1. Make changes to actions in `.github/actions/`
2. Update examples in `.github/workflows/`
3. Test with your application
4. Update this README if needed
5. Create a pull request

## 📚 Documentation

- **[USAGE.md](USAGE.md)** - Comprehensive usage guide with examples
- **[SECURITY.md](SECURITY.md)** - Security features and best practices  
- **[RELEASES.md](RELEASES.md)** - Version history and release notes

## 📞 Support

For issues, questions, or feature requests:
1. Check existing issues
2. Create a new issue with detailed information
3. Contact the WCMC DevOps team

For security issues, see [SECURITY.md](SECURITY.md)

---

**Made with ❤️ by WCMC DevOps Team**