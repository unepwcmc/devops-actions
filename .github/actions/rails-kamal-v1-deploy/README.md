# Rails Kamal v1 Deploy Action

Deploy Rails API applications (with Sidekiq support) using Kamal v1 with comprehensive configuration and best practices.

## Features

- 🚢 **Kamal v1 Deployment**: Full support for Kamal v1.x deployment
- 🔄 **Sidekiq Support**: Built-in Redis and Sidekiq configuration
- 📧 **Mail Configuration**: Easy mail server setup
- 🔐 **Secure Secrets Management**: Environment-specific secret handling
- 🐳 **Docker Optimized**: Uses Docker Buildx for efficient builds
- 🔧 **Flexible Configuration**: Support for custom environment variables and commands
- ✅ **Validation**: Input and environment variable validation
- 🧹 **Automatic Cleanup**: Secure cleanup of sensitive files

## Usage

### Basic Example

```yaml
- name: Deploy Rails API
  uses: ./.github/actions/rails-kamal-v1-deploy
  with:
    environment: production
    ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
    kamal-registry-username: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
    kamal-registry-password: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
    rails-master-key: ${{ secrets.RAILS_MASTER_KEY }}
    database-hostname: ${{ secrets.DATABASE_HOSTNAME }}
    database-name: ${{ secrets.DATABASE_NAME }}
    database-username: ${{ secrets.DATABASE_USERNAME }}
    database-password: ${{ secrets.DATABASE_PASSWORD }}
    database-env-prefix: 'API_PP_AUTHENTICATION'
```

### Full Example with All Features

```yaml
- name: Deploy Rails API with Sidekiq
  uses: ./.github/actions/rails-kamal-v1-deploy
  with:
    # Environment
    environment: production
    kamal-version: '1.8.3'
    ruby-version: '3.2.2'
    node-version: '20.12.0'
    working-directory: '.'
    
    # Required Secrets
    ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
    kamal-registry-username: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
    kamal-registry-password: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
    rails-master-key: ${{ secrets.RAILS_MASTER_KEY }}
    
    # Database Configuration
    database-hostname: ${{ secrets.DATABASE_HOSTNAME }}
    database-name: ${{ secrets.DATABASE_NAME }}
    database-username: ${{ secrets.DATABASE_USERNAME }}
    database-password: ${{ secrets.DATABASE_PASSWORD }}
    database-port: '5432'
    database-env-prefix: 'API_PP_AUTHENTICATION'
    
    # Redis & Sidekiq
    redis-username: ${{ secrets.REDIS_USERNAME }}
    redis-password: ${{ secrets.REDIS_PASSWORD }}
    redis-host: 'host.docker.internal'
    redis-port: '6379'
    redis-database: '4'
    
    # Mail Server
    mail-username: ${{ secrets.MAIL_USERNAME }}
    mail-password: ${{ secrets.MAIL_PASSWORD }}
    
    # Application
    api-port: '3000'
    backend-app-name: 'my-rails-api'
    gh-token: ${{ secrets.GH_TOKEN }}
    
    # Optional Commands
    pre-deploy-commands: |
      echo "Running pre-deploy tasks..."
      # Add your pre-deploy commands here
    post-deploy-commands: |
      echo "Running post-deploy tasks..."
      # Add your post-deploy commands here
```

## Inputs

### Required Inputs

| Input | Description | Example |
|-------|-------------|---------|
| `environment` | Environment to deploy to | `production` or `staging` |
| `ssh-private-key` | SSH private key for server access | `${{ secrets.SSH_PRIVATE_KEY }}` |
| `kamal-registry-username` | Container registry username | `${{ secrets.KAMAL_REGISTRY_USERNAME }}` |
| `kamal-registry-password` | Container registry password | `${{ secrets.KAMAL_REGISTRY_PASSWORD }}` |
| `rails-master-key` | Rails master key for credentials | `${{ secrets.RAILS_MASTER_KEY }}` |
| `database-hostname` | Database hostname | `${{ secrets.DATABASE_HOSTNAME }}` |
| `database-name` | Database name | `${{ secrets.DATABASE_NAME }}` |
| `database-username` | Database username | `${{ secrets.DATABASE_USERNAME }}` |
| `database-password` | Database password | `${{ secrets.DATABASE_PASSWORD }}` |

### Optional Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `kamal-version` | Kamal v1 version to use | `1.8.3` |
| `ruby-version` | Ruby version to use | `3.2.2` |
| `node-version` | Node.js version (for assets) | `20.12.0` |
| `working-directory` | Working directory | `.` |
| `database-port` | Database port | `5432` |
| `database-env-prefix` | Database env var prefix | _(empty)_ |
| `redis-username` | Redis username | _(optional)_ |
| `redis-password` | Redis password | _(optional)_ |
| `redis-host` | Redis host | `host.docker.internal` |
| `redis-port` | Redis port | `6379` |
| `redis-database` | Redis database number | `4` |
| `mail-username` | Mail server username | _(optional)_ |
| `mail-password` | Mail server password | _(optional)_ |
| `api-port` | API port | `3000` |
| `backend-app-name` | Backend app name | _(optional)_ |
| `gh-token` | GitHub token | _(optional)_ |
| `skip-env-push` | Skip env push step | `false` |
| `enable-ssh-test` | Enable SSH testing | `true` |
| `additional-env-vars` | Additional env vars (multiline) | _(optional)_ |
| `pre-deploy-commands` | Pre-deploy commands | _(optional)_ |
| `post-deploy-commands` | Post-deploy commands | _(optional)_ |

## Outputs

| Output | Description |
|--------|-------------|
| `deployment-status` | Status: `success` or `failed` |
| `deployment-duration` | Duration in seconds |
| `start-time` | Deployment start time (ISO 8601) |
| `end-time` | Deployment end time (ISO 8601) |

## Environment Variable Prefix

The `database-env-prefix` input is crucial for matching your Kamal configuration. For example:

If your Kamal `deploy.yml` has:
```yaml
env:
  secret:
    - API_PP_AUTHENTICATION_DATABASE_HOSTNAME
    - API_PP_AUTHENTICATION_DATABASE_NAME
```

Set `database-env-prefix: 'API_PP_AUTHENTICATION'`

The action will create:
- `API_PP_AUTHENTICATION_DATABASE_HOSTNAME`
- `API_PP_AUTHENTICATION_DATABASE_NAME`
- `API_PP_AUTHENTICATION_DATABASE_USERNAME`
- `API_PP_AUTHENTICATION_DATABASE_PASSWORD`
- `API_PP_AUTHENTICATION_DATABASE_PORT`
- `API_PP_AUTHENTICATION_API_PORT`

## Kamal Configuration Requirements

### Basic Kamal v1 Configuration

Your `config/deploy.yml` should include:

```yaml
image: your-registry/your-app/your-app-production

servers:
  web:
    hosts:
      - your-server.example.com
    options:
      add-host: host.docker.internal:host-gateway
    labels:
      traefik.http.routers.your-app-web-production.rule: Host(`your-app.example.com`)

  job:
    hosts:
      - your-server.example.com
    options:
      add-host: host.docker.internal:host-gateway
    cmd: bundle exec sidekiq
    healthcheck:
      cmd: /app/bin/docker-sidekiq-healthcheck

env:
  clear:
    RAILS_ENV: production
    YOUR_APP_API_PORT: 3000
  secret:
    - RAILS_MASTER_KEY
    - YOUR_APP_DATABASE_HOSTNAME
    - YOUR_APP_DATABASE_NAME
    - YOUR_APP_DATABASE_USERNAME
    - YOUR_APP_DATABASE_PASSWORD
    - YOUR_APP_DATABASE_PORT
    - REDIS_USERNAME
    - REDIS_PASSWORD
    - SIDEKIQ_REDIS_URL
    - MAIL_USERNAME
    - MAIL_PASSWORD

traefik:
  host_port: 3005
```

### Nginx Reverse Proxy Setup

If you're using Nginx as a reverse proxy (instead of or in addition to Traefik), configure:

#### Nginx Configuration Example

```nginx
server {
    listen 80;
    server_name your-app.example.com;

    location / {
        proxy_pass http://localhost:3005;  # Traefik host_port
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support (if needed)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

#### SSL/HTTPS Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name your-app.example.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:3005;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
```

## Complete Workflow Example

See [example-rails-kamal-v1-deploy.yml](../../workflows/example-rails-kamal-v1-deploy.yml) and [templates](../../../templates/) for complete workflows that include:
- Slack notifications (started/success/failure)
- Environment detection from branch names
- Manual workflow dispatch
- Full error handling

## Troubleshooting

### SSH Connection Issues

If SSH tests fail:
1. Verify `SSH_PRIVATE_KEY` is correct
2. Check server hostname in Kamal config
3. Ensure SSH key is authorized on target server
4. Set `enable-ssh-test: false` to skip if not needed

### Database Connection Issues

1. Verify `database-env-prefix` matches your Kamal config exactly
2. Check database credentials are correct
3. Ensure database port is accessible from container

### Redis/Sidekiq Issues

1. Verify Redis is running on host
2. Check `redis-host` is `host.docker.internal` for local Redis
3. Ensure Redis credentials are correct
4. Verify `redis-database` number is available

### Environment Variable Issues

If secrets aren't being passed correctly:
1. Check `.env.<environment>` file is created (temporary)
2. Verify `database-env-prefix` matches Kamal config
3. Use `additional-env-vars` for custom variables

## Security Notes

- All secrets are stored in environment-specific `.env` files with 600 permissions
- Environment files are automatically cleaned up after deployment
- Never commit `.env.*` files to version control
- Ensure GitHub secrets are properly configured per environment

## Migration from Manual Kamal Deployment

If migrating from manual Kamal commands:

**Before:**
```yaml
- name: Deploy with Kamal
  run: |
    kamal env push -d production
    kamal deploy -d production
```

**After:**
```yaml
- name: Deploy with Kamal
  uses: ./.github/actions/rails-kamal-v1-deploy
  with:
    environment: production
    # ... other inputs
```

## Support

For issues or questions:
- Check the [example workflow](../../workflows/example-rails-kamal-v1-deploy.yml)
- Review your Kamal `config/deploy.yml` configuration
- Verify all required secrets are set in GitHub

## Version Compatibility

- Kamal: v1.4.0 - v1.8.3 (v1.x series)
- Ruby: 3.0+
- Node.js: 18.x, 20.x, 22.x
- Rails: 6.x, 7.x

## Related Actions

- [slack-notify](../slack-notify) - Send deployment notifications
- [kamal-v2-deploy](../kamal-v2-deploy) - For Kamal v2.x deployments
- [validate-secrets](../validate-secrets) - Validate required secrets

