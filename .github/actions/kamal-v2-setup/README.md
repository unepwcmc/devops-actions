# Kamal v2 Setup Action

This action sets up and configures the Kamal v2 deployment environment with comprehensive validation and best practices.

## Required Environment Variables

The following environment variables must be set in your GitHub repository secrets:

- `SSH_PRIVATE_KEY` - Private SSH key for server access
- `KAMAL_REGISTRY_USERNAME` - Container registry username
- `KAMAL_REGISTRY_PASSWORD` - Container registry password
- `RAILS_MASTER_KEY` - Rails master key for encrypted credentials
- `DATABASE_HOST` - Database host
- `DATABASE_NAME` - Database name
- `DATABASE_USERNAME` - Database username
- `DATABASE_PASSWORD` - Database password

## Optional Environment Variables

These variables are optional and will be included in the setup if provided:

- `RAILS_DEFAULT_PUBLIC_APP_HOST` - Rails application host
- `RAILS_DEFAULT_PUBLIC_APP_HOST_PROTOCOL` - Protocol for Rails app
- `REDIS_USERNAME` - Redis username
- `REDIS_PASSWORD` - Redis password
- `MAIL_USERNAME` - Mail server username
- `MAIL_PASSWORD` - Mail server password
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `AWS_REGION` - AWS region

## Usage Example

```yaml
- name: Setup Kamal v2 Environment
  uses: unepwcmc/devops-actions/.github/actions/kamal-v2-setup@v1
  with:
    environment: staging
    working-directory: 'rails-api'
  env:
    KAMAL_REGISTRY_USERNAME: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
    KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
    SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
    RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}
    DATABASE_HOST: ${{ secrets.DATABASE_HOST }}
    DATABASE_NAME: ${{ secrets.DATABASE_NAME }}
    DATABASE_USERNAME: ${{ secrets.DATABASE_USERNAME }}
    DATABASE_PASSWORD: ${{ secrets.DATABASE_PASSWORD }}
    # Optional variables
    RAILS_DEFAULT_PUBLIC_APP_HOST: ${{ secrets.RAILS_DEFAULT_PUBLIC_APP_HOST }}
    RAILS_DEFAULT_PUBLIC_APP_HOST_PROTOCOL: ${{ secrets.RAILS_DEFAULT_PUBLIC_APP_HOST_PROTOCOL }}
```

## What This Action Does

1. **Environment Validation**: Validates all required environment variables
2. **Tool Installation**: Installs Ruby, Node.js, Yarn, Kamal v2, and PostgreSQL client
3. **SSH Setup**: Configures SSH access and tests connectivity
4. **Docker Setup**: Sets up Docker Buildx for container building
5. **Secrets Management**: Creates and secures Kamal secrets files
6. **Configuration Validation**: Validates Kamal configuration syntax

## Troubleshooting

### Missing RAILS_DEFAULT_PUBLIC_APP_HOST

This variable is now **optional**. If you see warnings about it:
- Add it to your secrets if your Rails app requires specific host configuration
- Otherwise, you can safely ignore the warning

### SSH Connection Issues

If SSH testing fails:
- Ensure your SSH key has access to all deployment servers
- Check that server IPs are correctly configured in your Kamal config
- The action will warn but continue if SSH testing fails 