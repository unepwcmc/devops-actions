# Kamal v2.x Deploy Action

This action deploys applications using Kamal v2 with a simplified, lightweight approach. It's designed to work with any application type and uses a `deploy` directory for deployment dependencies.

## Features

- ✅ Lightweight deployment with minimal configuration
- ✅ Support for any application type (Rails, Nuxt, Node.js, etc.)
- ✅ Ruby/Bundler-based dependency management via `deploy` directory
- ✅ Pre and post-deployment command hooks
- ✅ Multiple deployment strategies (rolling, blue-green, immediate)
- ✅ Docker Buildx integration

## Required Environment Variables

The following environment variables must be set in your GitHub repository secrets:

- `SSH_PRIVATE_KEY` - Private SSH key for server access

**Note**: Other secrets (registry credentials, application secrets, etc.) should be managed through your Kamal configuration files (`.kamal/secrets-common` or `.kamal/secrets.<environment>`).

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `environment` | Environment to deploy to (staging, production) | Yes | - |
| `buildx-version` | Docker Buildx version to use | No | `v0.17.1` |
| `working-directory` | Working directory for application | No | `.` |
| `kamal-config-path` | Path to Kamal config file relative to working directory | No | `config/deploy.yml` |
| `deployment-strategy` | Deployment strategy (rolling, blue-green, immediate) | No | `rolling` |
| `pre-deploy-commands` | Additional commands to run before deployment | No | - |
| `post-deploy-commands` | Additional commands to run after successful deployment | No | - |

## Outputs

| Output | Description |
|--------|-------------|
| `deployment-status` | Status of the deployment operation |
| `deployment-duration` | Duration of the deployment operation in seconds |
| `deployment-url` | URL of the deployed application |

## Usage Example

### Basic Deployment

```yaml
- name: Deploy with Kamal v2.x
  uses: unepwcmc/devops-actions/.github/actions/kamal-v2.x-deploy@v1
  with:
    environment: staging
    working-directory: '.'
  env:
    SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
```

### Deployment with Pre/Post Commands

```yaml
- name: Deploy with Kamal v2.x
  uses: unepwcmc/devops-actions/.github/actions/kamal-v2.x-deploy@v1
  with:
    environment: production
    deployment-strategy: rolling
    pre-deploy-commands: |
      echo "Running pre-deployment checks..."
      # Add your pre-deployment commands here
    post-deploy-commands: |
      echo "Running post-deployment tasks..."
      # Add your post-deployment commands here
  env:
    SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
```

### Custom Configuration

```yaml
- name: Deploy with Kamal v2.x
  uses: unepwcmc/devops-actions/.github/actions/kamal-v2.x-deploy@v1
  with:
    environment: staging
    working-directory: 'backend'
    kamal-config-path: 'config/deploy.yml'
    buildx-version: 'v0.17.1'
    deployment-strategy: 'blue-green'
  env:
    SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
```

## Project Setup Requirements

### 1. Deploy Directory Structure

This action expects a `deploy` directory in your project root with the following structure:

```
deploy/
├── Gemfile
├── Gemfile.lock
└── .ruby-version (or mise.toml or .tool-versions)
```

**Example `deploy/Gemfile`:**

```ruby
source 'https://rubygems.org'

gem 'kamal', '~> 2.5'
```

### 2. Kamal Configuration

Your Kamal configuration should be in the path specified by `kamal-config-path` (default: `config/deploy.yml`).

### 3. Secrets Management

Manage your secrets through Kamal's built-in secrets system:
- Create `.kamal/secrets-common` as a template
- Environment-specific secrets will be loaded automatically by Kamal

## Deployment Strategies

### Rolling (Default)
Deploy to servers one by one, with verbose output.

```yaml
deployment-strategy: rolling
```

### Blue-Green
Deploy to a new set of servers, then switch traffic over.

```yaml
deployment-strategy: blue-green
```

### Immediate
Deploy to all servers simultaneously without verbose output.

```yaml
deployment-strategy: immediate
```

## Troubleshooting

### Deployment Fails with "Buildx not installed"

Ensure Docker Buildx is properly configured in your workflow. The action handles this automatically, but if issues persist, try updating the `buildx-version` input.

### SSH Connection Issues

1. Verify your `SSH_PRIVATE_KEY` is correctly set in GitHub secrets
2. Ensure the key has proper permissions on the target servers
3. Check that your Kamal configuration has the correct server addresses

### Bundle Install Fails

Ensure your `deploy/Gemfile` and `deploy/Gemfile.lock` are up to date and committed to your repository.

```bash
cd deploy
bundle lock --update
git add Gemfile.lock
git commit -m "Update deploy dependencies"
```

### Working Directory Not Found

If you see an error about the working directory not existing:
- Verify the `working-directory` input matches your project structure
- Ensure you've checked out the repository in your workflow (use `actions/checkout@v4`)

## Differences from kamal-v2-deploy

This action (`kamal-v2.x-deploy`) is a simplified version of `kamal-v2-deploy` with the following differences:

- ❌ No automatic secrets file generation (use Kamal's native secrets management)
- ❌ No built-in health checks (handle in your application)
- ❌ No automatic rollback (manual rollback recommended)
- ❌ No maintenance mode handling
- ✅ Uses `deploy` directory for dependency management
- ✅ More flexible for different application types
- ✅ Simpler configuration and faster execution

## Example Workflow

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
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Deploy with Kamal v2.x
        uses: unepwcmc/devops-actions/.github/actions/kamal-v2.x-deploy@v1
        with:
          environment: staging
          deployment-strategy: rolling
        env:
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
```

## Support

For issues, questions, or contributions, please contact the WCMC DevOps Team.

