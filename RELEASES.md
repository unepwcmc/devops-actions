# Release Strategy

## Early Development Versioning

This repository is currently in **early development** and uses a simplified versioning strategy.

### Current Approach
- **v1**: Single rolling tag that points to the latest stable version
- **main**: Development branch with latest changes
- **No semver yet**: We'll adopt semantic versioning (v1.0.0, v1.1.0, etc.) once the actions are more mature

### Why v1 Only?
- **Simplicity**: Teams reference `@v1` without worrying about patch versions
- **Flexibility**: We can iterate quickly without version management overhead
- **Standard Practice**: Most GitHub Actions start with a single v1 tag
- **Early Stage**: Actions are still evolving rapidly

## Usage

Teams should reference actions using the `v1` tag:
```yaml
uses: unepwcmc/devops-actions/.github/actions/kamal-v2-setup@v1
uses: unepwcmc/devops-actions/.github/actions/slack-notify@v1
```

## Release Process

### Current Process
1. Make changes on feature branches
2. Merge to `main` via PR
3. Update `v1` tag to point to latest `main`
4. Test and validate in staging environments

### Future Process (When Mature)
We'll adopt semantic versioning when:
- Actions are stable and widely adopted
- Breaking changes need careful management
- Teams need to pin to specific versions

**Future versioning will follow:**
- **Major** (v2.0.0): Breaking changes, new action structure
- **Minor** (v2.1.0): New features, additional inputs, backward compatible
- **Patch** (v2.0.1): Bug fixes, security updates, no breaking changes

## Current Release

### v1 (Current)
**Status**: Production Ready - Active
**Last Updated**: December 2024

**Features:**
- ✅ Kamal v1 and v2 support
- ✅ Backend (Rails) and Frontend (Nuxt) actions
- ✅ Slack notifications with rich formatting
- ✅ Security validation with `validate-secrets` action
- ✅ Comprehensive validation and testing
- ✅ Multi-environment support
- ✅ Security best practices and fail-fast validation
- ✅ Automated environment variable population

**Actions Available:**
- `kamal-v1-setup` / `kamal-v1-deploy`
- `kamal-v2-setup` / `kamal-v2-deploy`
- `nuxt-kamal-v1-setup` / `nuxt-kamal-v1-deploy`
- `nuxt-kamal-v2-setup` / `nuxt-kamal-v2-deploy`
- `slack-notify`
- `validate-secrets` ✨ **NEW**
- `validate-workflow` ✨ **NEW**

**Recent Updates (v1.1 - December 2024):**
- 🔐 **Security Enhancement**: Added `validate-secrets` action for comprehensive secrets validation
- 📋 **Workflow Validation**: Added `validate-workflow` action to ensure proper workflow configuration
- 🔄 **Environment Variables**: Automatic population of environment variables from validated secrets
- 🛡️ **Fail-Fast Validation**: Early detection of missing configuration with clear error messages
- 📚 **Documentation Updates**: Comprehensive updates to README.md and USAGE.md reflecting new patterns
- 🏗️ **Template System**: Standardized secrets template system with `.kamal/secrets-common.template`

## Migration Guide

### From Manual Workflows to v1

**Step 1**: Replace manual Kamal commands
```diff
- run: |
-   gem install kamal
-   # ... 50+ lines of setup
+ uses: unepwcmc/devops-actions/.github/actions/kamal-v2-setup@v1
+   with:
+     environment: staging
```

**Step 2**: Update secret names to match action inputs
```diff
- REGISTRY_USERNAME
+ KAMAL_REGISTRY_USERNAME
```

**Step 3**: Test in staging environment first

## Maintenance Schedule

### Regular Updates
- **Weekly**: Bug fixes and minor improvements to v1 tag
- **Monthly**: Feature additions and dependency updates
- **As Needed**: Security patches and critical fixes

### Communication
- **GitHub releases**: For significant updates
- **Slack notifications**: For breaking changes or important updates
- **Documentation updates**: Keep USAGE.md current

## Testing Strategy

### Pre-Release Testing
- All actions tested with v1, v2, backend, frontend combinations
- Integration testing with real deployments
- Security scanning and validation

### Release Validation
- Automated testing pipeline runs on all PRs
- Manual testing in staging environments
- Community feedback via issues and discussions

## Future Roadmap

### When We'll Move to Semantic Versioning
- Multiple teams actively using the actions
- Need for stable API contracts
- Breaking changes require careful planning
- Actions reach production maturity

### Transition Plan
1. Announce semantic versioning adoption
2. Create v1.0.0 from current v1
3. Maintain v1 as alias to latest v1.x
4. Provide migration timeline for teams 