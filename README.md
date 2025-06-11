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

### 🎯 Backend Actions (Rails Applications)

#### Kamal v2 (Recommended)
- **`kamal-v2-setup`**: Initial setup and configuration for Kamal v2
- **`kamal-v2-deploy`**: Full-featured deployment with health checks, rollbacks, and monitoring

#### Kamal v1 (Legacy Support)
- **`kamal-v1-setup`**: Initial setup for Kamal v1 deployments
- **`kamal-v1-deploy`**: Basic deployment capabilities for legacy projects

### 🎨 Frontend Actions (Nuxt Applications)

#### Nuxt with Kamal v1
- **`nuxt-kamal-v1-setup`**: Initial setup for Nuxt frontend applications
- **`nuxt-kamal-v1-deploy`**: Deployment with Azure AD, Rails API integration, and WCMC User Management

### 📢 Notification Actions

#### Slack Notifications
- **`slack-notify`**: Rich Slack notifications with start/success/failure states and message updating

## 🛠 Quick Start

### 1. Copy Example Workflows

Choose the appropriate workflow from our examples:

- **`.github/workflows/kamal-v1-backend-example.yml`** - Rails backend with Kamal v1
- **`.github/workflows/kamal-v2-backend-example.yml`** - Rails backend with Kamal v2  
- **`.github/workflows/nuxt-frontend-example.yml`** - Nuxt frontend deployment
- **`.github/workflows/kamal-setup-example.yml`** - Initial setup workflows

### 2. Configure Secrets

Add these secrets to your repository:

#### Core Deployment Secrets
```
SSH_PRIVATE_KEY
KAMAL_REGISTRY_USERNAME
KAMAL_REGISTRY_PASSWORD
RAILS_MASTER_KEY
RAILS_DEFAULT_PUBLIC_APP_HOST
RAILS_DEFAULT_PUBLIC_APP_HOST_PROTOCOL
DATABASE_HOST
DATABASE_NAME
DATABASE_USERNAME
DATABASE_PASSWORD
DATABASE_PORT
```

#### Slack Notification Secrets
```
SLACK_BOT_TOKEN
SLACK_CHANNEL_ID
```

#### Optional Enhancement Secrets
```
# Redis/Sidekiq
REDIS_USERNAME
REDIS_PASSWORD

# Mail Server
MAIL_USERNAME
MAIL_PASSWORD

# AWS S3
AWS_S3_ACCESS_KEY_ID
AWS_S3_SECRET_ACCESS_KEY
AWS_S3_REGION
AWS_S3_NAME

# Frontend Integration
FRONTEND_APP_NAME
NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_ID
NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_SECRET
NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_TENANT_ID
NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_SECRET
```

### 3. Basic Usage Examples

#### Simple Rails Backend Deployment (Kamal v2)

```yaml
name: Deploy Rails Backend

on:
  push:
    branches: [main]

jobs:
  deploy:
    name: Deploy to Production
    runs-on: self-hosted
    environment: production
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # Slack Notification: Start
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

      # Main Deployment
      - name: Deploy with Kamal v2
        id: deploy
        uses: unepwcmc/devops-actions/.github/actions/kamal-v2-deploy@v1
        with:
          environment: 'production'
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
          kamal-registry-username: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
          kamal-registry-password: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
          rails-master-key: ${{ secrets.RAILS_MASTER_KEY }}
          rails-default-public-app-host: ${{ secrets.RAILS_DEFAULT_PUBLIC_APP_HOST }}
          rails-default-public-app-host-protocol: ${{ secrets.RAILS_DEFAULT_PUBLIC_APP_HOST_PROTOCOL }}
          database-env-prefix: 'MY_APP'  # Change to your project's prefix
          database-host: ${{ secrets.DATABASE_HOST }}
          database-name: ${{ secrets.DATABASE_NAME }}
          database-username: ${{ secrets.DATABASE_USERNAME }}
          database-password: ${{ secrets.DATABASE_PASSWORD }}

      # Slack Notification: Success
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

      # Slack Notification: Failure
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

```yaml
      # Nuxt Frontend Deployment  
      - name: Deploy Nuxt Frontend
        uses: unepwcmc/devops-actions/.github/actions/nuxt-kamal-v1-deploy@v1
        with:
          environment: 'staging'
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
          kamal-registry-username: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
          kamal-registry-password: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
          gh-token: ${{ secrets.GH_TOKEN }}
          web-server-dns-name: ${{ secrets.WEB_SERVER_DNS_NAME }}
          
          # Rails API Integration
          rails-master-key: ${{ secrets.RAILS_MASTER_KEY }}
          rails-default-public-app-host: ${{ secrets.RAILS_DEFAULT_PUBLIC_APP_HOST }}
          rails-default-public-app-host-protocol: ${{ secrets.RAILS_DEFAULT_PUBLIC_APP_HOST_PROTOCOL }}
          
          # Frontend Configuration
          frontend-app-name: ${{ secrets.FRONTEND_APP_NAME }}
          auth-origin: ${{ secrets.AUTH_ORIGIN }}
          nuxt-public-rails-api-server: ${{ secrets.NUXT_PUBLIC_RAILS_API_SERVER }}
          
          # Azure AD & WCMC User Management
          azure-ad-client-id: ${{ secrets.NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_ID }}
          azure-ad-client-secret: ${{ secrets.NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_SECRET }}
          azure-ad-tenant-id: ${{ secrets.NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_TENANT_ID }}
          wcmc-user-management-secret: ${{ secrets.NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_SECRET }}
          wcmc-user-management-rails-api-server: ${{ secrets.NUXT_PUBLIC_WCMC_MODULES_WCMC_USER_MANAGEMENT_RAILS_API_SERVER }}
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
uses: unepwcmc/devops-actions/.github/actions/kamal-v2-deploy@v1.2.0
uses: unepwcmc/devops-actions/.github/actions/kamal-v2-deploy@main  # latest
```

## 🤝 Contributing

1. Make changes to actions in `.github/actions/`
2. Update examples in `.github/workflows/`
3. Test with your application
4. Update this README if needed
5. Create a pull request

## 📞 Support

For issues, questions, or feature requests:
1. Check existing issues
2. Create a new issue with detailed information
3. Contact the WCMC DevOps team

---

**Made with ❤️ by WCMC DevOps Team**