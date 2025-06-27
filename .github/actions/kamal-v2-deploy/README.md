# Kamal v2 Deploy Action

This action deploys Rails applications using Kamal v2 with comprehensive configuration, health checks, and rollback capabilities.

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
- `DATABASE_PORT` - Database port

## Optional Environment Variables

These variables are optional and will use defaults or fallbacks if not provided:

- `RAILS_DEFAULT_PUBLIC_APP_HOST` - Rails application host (defaults to `HOST` if available)
- `RAILS_DEFAULT_PUBLIC_APP_HOST_PROTOCOL` - Protocol for Rails app (defaults to `https`)

## Usage Example

```yaml
- name: Deploy Backend with Kamal v2
  uses: unepwcmc/devops-actions/.github/actions/kamal-v2-deploy@v1
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
    DATABASE_PORT: ${{ secrets.DATABASE_PORT }}
    API_PORT: ${{ secrets.API_PORT }}
    BACKEND_APP_NAME: ${{ secrets.BACKEND_APP_NAME }}
    HOST: ${{ secrets.HOST }}
    # Optional: Add these if you need specific Rails host configuration
    # RAILS_DEFAULT_PUBLIC_APP_HOST: ${{ secrets.RAILS_DEFAULT_PUBLIC_APP_HOST }}
    # RAILS_DEFAULT_PUBLIC_APP_HOST_PROTOCOL: ${{ secrets.RAILS_DEFAULT_PUBLIC_APP_HOST_PROTOCOL }}
```

## Troubleshooting

### Missing RAILS_DEFAULT_PUBLIC_APP_HOST

If you see an error about `RAILS_DEFAULT_PUBLIC_APP_HOST` not being set:

1. **Option 1**: Add it to your GitHub secrets and include it in your workflow
2. **Option 2**: Ensure you have `HOST` set (it will be used as a fallback)
3. **Option 3**: Let it use the default behavior (may work for most Rails apps)

### Rollback Functionality

**Important**: Automatic rollback is **disabled by default** to prevent issues during deployment.

- If you need rollback functionality, you can set `rollback-on-failure: 'true'` in your action inputs
- Manual rollback is recommended for better control and debugging
- Check your deployment logs carefully before attempting any rollback

### Health Checks

The action includes basic deployment verification:
- Simplified health checks that verify container presence
- No external endpoint testing to avoid network-related failures
- Focus on confirming successful deployment completion 