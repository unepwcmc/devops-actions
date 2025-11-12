# Nuxt Kamal v1 Deploy (Flexible) Action

Deploy Nuxt frontend applications using Kamal v1 with **flexible configuration** - designed for projects where clear environment variables are in `config/deploy.yml` and only secrets are in GitHub Secrets.

## Key Differences from `nuxt-kamal-v1-deploy`

| Feature | `nuxt-kamal-v1-deploy` | `nuxt-kamal-v1-deploy-flexible` (this action) |
|---------|------------------------|-----------------------------------------------|
| **Required Env Vars** | 15+ hardcoded variables | Only 3 core secrets |
| **Flexibility** | Rigid validation | Flexible `additional-secrets` |
| **Rails Dependencies** | Requires RAILS_* vars | No Rails dependencies |
| **API Servers** | Single `NUXT_PUBLIC_RAILS_API_SERVER` | Any API servers via additional-secrets |
| **Use Case** | Full-stack Rails + Nuxt | Standalone Nuxt frontends |

## When to Use This Action

Use `nuxt-kamal-v1-deploy-flexible` when:
- ✅ Your clear env vars are in `config/deploy.yml` (best practice)
- ✅ You have multiple API servers
- ✅ You're deploying a standalone Nuxt app (no Rails backend dependency)
- ✅ You want minimal required secrets
- ✅ You need flexibility in your environment configuration

Use `nuxt-kamal-v1-deploy` when:
- ✅ You have a Rails + Nuxt monorepo
- ✅ You need the original action's full validation

## Features

- 🚢 **Kamal v1 Deployment**: Full support for Kamal v1.x
- 🔐 **Minimal Required Secrets**: Only registry and SSH credentials required
- 🎯 **Flexible Configuration**: Use `additional-secrets` for your specific needs
- 🧹 **Automatic Cleanup**: Secure cleanup of sensitive files
- ✅ **Smart Validation**: Validates only what's actually required
- 📦 **Bundler Cleanup**: Optional cleanup of `.bundle` and `vendor` directories

## Usage

### Minimal Example

```yaml
- name: Deploy Nuxt Frontend
  uses: unep-wcmc/devops-actions/.github/actions/nuxt-kamal-v1-deploy-flexible@main
  with:
    environment: production
  env:
    SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
    KAMAL_REGISTRY_USERNAME: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
    KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
```

### Full Example with Azure AD

```yaml
- name: Deploy Nuxt with Azure AD
  uses: unep-wcmc/devops-actions/.github/actions/nuxt-kamal-v1-deploy-flexible@main
  with:
    environment: production
    kamal-version: '1.4.0'
    ruby-version: '3.2.2'
    node-version: '22.3.0'
    clean-bundler-artifacts: 'true'
    
    additional-secrets: |
      NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_ID=${{ secrets.AZURE_AD_CLIENT_ID }}
      NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_CLIENT_SECRET=${{ secrets.AZURE_AD_CLIENT_SECRET }}
      NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_AZURE_AD_TENANT_ID=${{ secrets.AZURE_AD_TENANT_ID }}
      NUXT_WCMC_MODULES_WCMC_USER_MANAGEMENT_SECRET=${{ secrets.USER_MANAGEMENT_SECRET }}
  env:
    SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
    KAMAL_REGISTRY_USERNAME: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
    KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
    GH_TOKEN: ${{ secrets.GH_TOKEN }}
    WEB_SERVER_DNS_NAME: ${{ secrets.WEB_SERVER_DNS_NAME }}
```

## Inputs

### Required Inputs

| Input | Description |
|-------|-------------|
| `environment` | Environment to deploy to (`staging` or `production`) |

### Optional Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `kamal-version` | Kamal v1 version to use | `1.4.0` |
| `ruby-version` | Ruby version to use | `3.2.2` |
| `node-version` | Node.js version to use | `22.3.0` |
| `working-directory` | Working directory for Nuxt application | `.` |
| `additional-secrets` | Additional secret environment variables (multiline KEY=VALUE format) | _(optional)_ |
| `pre-deploy-commands` | Commands to run before deployment | _(optional)_ |
| `post-deploy-commands` | Commands to run after successful deployment | _(optional)_ |
| `enable-ssh-test` | Enable SSH connection testing | `true` |
| `skip-env-push` | Skip the kamal env push step | `false` |
| `clean-bundler-artifacts` | Clean up bundler artifacts before deployment | `false` |

## Environment Variables

### Required (via `env:`)

| Variable | Description |
|----------|-------------|
| `SSH_PRIVATE_KEY` | SSH private key for server access |
| `KAMAL_REGISTRY_USERNAME` | Container registry username |
| `KAMAL_REGISTRY_PASSWORD` | Container registry password |

### Optional (via `env:`)

| Variable | Description |
|----------|-------------|
| `GH_TOKEN` | GitHub token for private packages |
| `WEB_SERVER_DNS_NAME` | Server hostname for SSH testing |

## Outputs

| Output | Description |
|--------|-------------|
| `deployment-status` | Status: `success` or `failed` |
| `deployment-duration` | Duration in seconds |
| `start-time` | Deployment start time (ISO 8601) |
| `end-time` | Deployment end time (ISO 8601) |

## Kamal Configuration

Your `config/deploy.yml` should have clear environment variables:

```yaml
env:
  clear:
    # Public values - not secrets
    AUTH_ORIGIN: https://your-app.example.com/api/auth
    NUXT_PUBLIC_API_SERVER: https://api.example.com
    NUXT_PUBLIC_SITE_TITLE: "My App"
    NUXT_PUBLIC_SITE_DESCRIPTION: "Description"
  
  secret:
    # Secret keys (values come from GitHub Secrets)
    - NUXT_AZURE_AD_CLIENT_ID
    - NUXT_AZURE_AD_CLIENT_SECRET
    - GH_TOKEN
```

## How additional-secrets Works

The `additional-secrets` input allows you to pass any secrets your app needs:

```yaml
additional-secrets: |
  API_KEY=${{ secrets.API_KEY }}
  DATABASE_URL=${{ secrets.DATABASE_URL }}
  CUSTOM_SECRET=${{ secrets.CUSTOM_SECRET }}
```

These get added to the `.env.<environment>` file that Kamal uses.

## Complete Workflow Example

```yaml
name: Deploy Nuxt Frontend

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    name: Deploy to Production
    runs-on: self-hosted
    environment: production
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Deploy Nuxt Frontend
        uses: unep-wcmc/devops-actions/.github/actions/nuxt-kamal-v1-deploy-flexible@main
        with:
          environment: production
          kamal-version: '1.4.0'
          clean-bundler-artifacts: 'true'
          
          additional-secrets: |
            NUXT_AZURE_AD_CLIENT_ID=${{ secrets.AZURE_AD_CLIENT_ID }}
            NUXT_AZURE_AD_CLIENT_SECRET=${{ secrets.AZURE_AD_CLIENT_SECRET }}
        env:
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
          KAMAL_REGISTRY_USERNAME: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
          KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
          GH_TOKEN: ${{ secrets.GH_TOKEN }}
          WEB_SERVER_DNS_NAME: ${{ secrets.WEB_SERVER_DNS_NAME }}
```

## Migration from Manual Deployment

**Before** (manual):
```yaml
- name: Set up Node.js
  uses: actions/setup-node@v3
  with:
    node-version: "22.3.0"

- name: Install Yarn
  run: npm install -g yarn

- name: Set up Ruby
  uses: ruby/setup-ruby@v1
  with:
    ruby-version: 3.2.2

- name: Install Kamal
  run: gem install kamal -v 1.4.0

- name: Set up SSH
  uses: webfactory/ssh-agent@v0.5.3
  with:
    ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}

- name: Create .env file
  run: |
    cat > .env.production << 'EOF'
    KAMAL_REGISTRY_USERNAME=${{ secrets.KAMAL_REGISTRY_USERNAME }}
    # ... 15 more lines
    EOF

- name: Deploy
  run: |
    export $(cat .env.production | xargs)
    kamal env push -d production
    kamal deploy -d production
```

**After** (using action):
```yaml
- name: Deploy Nuxt Frontend
  uses: unep-wcmc/devops-actions/.github/actions/nuxt-kamal-v1-deploy-flexible@main
  with:
    environment: production
    additional-secrets: |
      YOUR_SECRET_1=${{ secrets.YOUR_SECRET_1 }}
      YOUR_SECRET_2=${{ secrets.YOUR_SECRET_2 }}
  env:
    SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
    KAMAL_REGISTRY_USERNAME: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
    KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
```

## Troubleshooting

### SSH Connection Test Fails

If SSH tests fail but you want to continue:
```yaml
enable-ssh-test: 'false'
```

Or ensure `WEB_SERVER_DNS_NAME` is set correctly.

### Missing Environment Variables

If deployment fails with missing variables:
1. Check they're in your `config/deploy.yml` `env.secret` section
2. Check the values are in GitHub Secrets
3. Pass them via `additional-secrets` input

### Bundler Artifacts Cause Issues

If you see bundler-related errors:
```yaml
clean-bundler-artifacts: 'true'
```

## Security Notes

- All secrets are stored in `.env.<environment>` files with 600 permissions
- Environment files are automatically cleaned up after deployment
- Never commit `.env.*` files to version control
- Ensure GitHub secrets are properly configured per environment

## Examples

See complete examples (in gitignored directories - copy what you need):
- [PP Data Management Portal template](../../../templates/pp-data-management-portal-nuxt-deploy.yml)
- [Comparison guide](../../../docs/PP_PORTAL_NUXT_COMPARISON.md)
- [All templates](../../../templates/)

## Support

For issues or questions:
- Check the [comparison guide](../../../docs/PP_PORTAL_NUXT_COMPARISON.md)
- Review the [templates](../../../templates/)
- Verify your `config/deploy.yml` configuration

## Version Compatibility

- Kamal: v1.0.0 - v1.9.x (v1.x series)
- Ruby: 3.0+
- Node.js: 18.x, 20.x, 22.x
- Nuxt: 2.x, 3.x

## Related Actions

- [nuxt-kamal-v1-deploy](../nuxt-kamal-v1-deploy) - Original action with full Rails integration
- [slack-notify](../slack-notify) - Send deployment notifications
- [nuxt-kamal-v2-deploy](../nuxt-kamal-v2-deploy) - For Kamal v2.x deployments

