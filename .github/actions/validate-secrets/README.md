# Validate and Populate Secrets Action

This action validates that all required secrets are available based on a secrets template file. It's designed to work with Kamal deployment workflows where you have a template file defining required environment variables.

## Purpose

- Validates that all required secrets defined in a template file are available as environment variables
- Provides clear error messages for missing secrets
- Ensures deployment consistency across environments

## Inputs

- `secrets-file`: Path to the secrets template file (default: `.kamal/secrets-common`)
- `environment`: Environment to validate against (default: `staging`)

## How It Works

1. **Check Template File**: Verifies the secrets template file exists
2. **Extract Variables**: Reads variable names from the template file
3. **Validate Secrets**: Checks that all required variables are set as environment variables
4. **Report Status**: Provides clear feedback on validation results

## Usage Example

```yaml
- name: Validate and Populate Secrets
  uses: unepwcmc/devops-actions/.github/actions/validate-secrets@v1
  with:
    secrets-file: 'rails-api/.kamal/secrets-common'
    environment: 'staging'
  env:
    KAMAL_REGISTRY_USERNAME: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
    KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
    SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
    # ... other required secrets
```

## Secrets Template File Format

The secrets template file should contain variable definitions like:

```bash
# Required secrets for deployment
KAMAL_REGISTRY_USERNAME=$KAMAL_REGISTRY_USERNAME
KAMAL_REGISTRY_PASSWORD=$KAMAL_REGISTRY_PASSWORD
SSH_PRIVATE_KEY=$SSH_PRIVATE_KEY
RAILS_MASTER_KEY=$RAILS_MASTER_KEY
DATABASE_HOST=$DATABASE_HOST
DATABASE_NAME=$DATABASE_NAME
DATABASE_USERNAME=$DATABASE_USERNAME
DATABASE_PASSWORD=$DATABASE_PASSWORD
```

## Troubleshooting

### Missing Secrets File
If you see "Secrets file not found":
- Ensure the file exists at the specified path
- Create the file from a template if needed

### Missing Required Secret
If you see "Missing required secret":
- Add the secret to your GitHub repository/environment secrets
- Ensure the secret name matches exactly what's in the template file
- Make sure you're passing the secret in the `env` section of your workflow 