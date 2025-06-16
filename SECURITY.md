# Security Guide

## 🛡️ Security Features

This repository implements comprehensive security measures to protect your deployments and sensitive data.

## 🔐 Secrets Management

### validate-secrets Action

The `validate-secrets` action provides secure secrets management:

**Features:**
- ✅ **Template-based validation**: Uses `.kamal/secrets-common` template files
- ✅ **Environment isolation**: Validates secrets per environment (staging/production)
- ✅ **Fail-fast approach**: Stops deployment immediately if secrets are missing
- ✅ **Clear error messages**: Shows exactly which secrets need to be configured
- ✅ **No raw credentials**: Never stores actual credentials in code

**Usage:**
```yaml
- name: Validate and Populate Secrets
  uses: unepwcmc/devops-actions/.github/actions/validate-secrets@v1
  with:
    secrets-file: '.kamal/secrets-common'
    environment: 'production'
```

## 🔒 Best Practices

### 1. Secrets Configuration

**✅ DO:**
- Store all secrets in GitHub Environment secrets
- Use separate environments for staging and production
- Follow the template pattern in `.kamal/secrets-common.template`
- Use the `validate-secrets` action in all deployment workflows

**❌ DON'T:**
- Store raw credentials in `.kamal/secrets-common` files
- Commit actual secrets to version control
- Use secrets directly in workflow files without validation

### 2. Environment Variables

**Secure Pattern:**
```yaml
# After validate-secrets action
- name: Deploy
  with:
    slack-bot-token: ${{ env.SLACK_BOT_TOKEN }}  # ✅ From environment
```

**Insecure Pattern:**
```yaml
# Direct secrets usage (not recommended)
- name: Deploy
  with:
    slack-bot-token: ${{ secrets.SLACK_BOT_TOKEN }}  # ❌ Direct access
```

### 3. SSH Keys

**Requirements:**
- Use RSA or Ed25519 keys
- Store private key in `SSH_PRIVATE_KEY` secret
- Ensure proper permissions on target servers
- Rotate keys regularly

**Format:**
```
-----BEGIN OPENSSH PRIVATE KEY-----
[your private key content]
-----END OPENSSH PRIVATE KEY-----
```

### 4. Registry Credentials

**Docker Registry Security:**
- Use dedicated service accounts for registry access
- Limit permissions to necessary repositories only
- Rotate credentials regularly
- Use organization-level secrets when possible

## 🔍 Validation Features

### Workflow Validation

The `validate-workflow` action ensures:
- ✅ Deployment workflows include `validate-secrets` action
- ✅ Proper environment configuration
- ✅ No direct secrets usage in deployment workflows

### Automatic Validation

All workflows are automatically validated:
- On pull requests affecting workflow files
- On pushes to main branch
- During workflow execution

## 🚨 Security Alerts

### Missing Secrets Detection

When secrets are missing, you'll see clear error messages:

```
Error: Missing required secret: KAMAL_REGISTRY_USERNAME
Please add this secret to your GitHub environment (production)
You can find the required format in .kamal/secrets-common
```

### Validation Failures

If validation fails:
1. **Check the error message** - it will tell you exactly what's missing
2. **Verify environment configuration** - ensure secrets are in the correct environment
3. **Check secret names** - they must match the template exactly
4. **Verify template file** - ensure `.kamal/secrets-common` exists

## 🔧 Security Configuration Checklist

### Repository Setup
- [ ] **Always Required**: Docker registry credentials (`KAMAL_REGISTRY_USERNAME/PASSWORD`)
- [ ] **Always Required**: SSH key properly formatted (`SSH_PRIVATE_KEY`)
- [ ] **If Rails**: Rails master key configured (`RAILS_MASTER_KEY`)
- [ ] **If Database**: Database credentials configured
- [ ] **If Notifications**: Slack credentials configured (optional)
- [ ] `.kamal/secrets-common` file exists (copied from template)

### Workflow Setup
- [ ] All deployment workflows include `validate-secrets` action
- [ ] Workflows use environment variables (`${{ env.* }}`) instead of direct secrets
- [ ] Proper environment configuration in workflow jobs
- [ ] Only required secrets configured (don't add what you don't need)

### Security Monitoring
- [ ] Regular secret rotation schedule
- [ ] Monitoring of deployment logs for security issues
- [ ] Regular validation of secret access patterns
- [ ] Documentation of who has access to production secrets

## 🆘 Security Issues

If you discover a security vulnerability:

1. **Do not open a public issue**
2. **Contact the WCMC DevOps team directly**
3. **Provide detailed information about the issue**
4. **Include steps to reproduce if applicable**

## 📚 Related Documentation

- [USAGE.md](USAGE.md) - Complete usage guide
- [README.md](README.md) - Quick start and examples
- [RELEASES.md](RELEASES.md) - Version history and updates

---

**Remember**: Security is everyone's responsibility. When in doubt, ask the DevOps team for guidance. 