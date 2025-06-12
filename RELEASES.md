# Release Strategy

## Versioning

This repository follows semantic versioning for releases.

### Version Format
- **Major** (v1.0.0): Breaking changes, new action structure
- **Minor** (v1.1.0): New features, additional inputs, backward compatible
- **Patch** (v1.0.1): Bug fixes, security updates, no breaking changes

## Release Process

### 1. Create Release Branch
```bash
git checkout -b release/v1.1.0
# Make final changes
git commit -m "🔖 Prepare release v1.1.0"
git push origin release/v1.1.0
```

### 2. Create GitHub Release
1. Create release from branch
2. Generate release notes
3. Tag with version number
4. Mark as latest release

### 3. Update Action References
Teams should update their workflows to use the new version:
```yaml
uses: unepwcmc/devops-actions/.github/actions/kamal-v2-setup@v1.1.0
```

## Current Releases

### v1.0.0 (Latest)
**Release Date**: December 2024
**Status**: Stable

**Features:**
- ✅ Kamal v1 and v2 support
- ✅ Backend (Rails) and Frontend (Nuxt) actions
- ✅ Slack notifications
- ✅ Comprehensive validation and testing
- ✅ Multi-environment support
- ✅ Security best practices

**Actions Available:**
- `kamal-v1-setup` / `kamal-v1-deploy`
- `kamal-v2-setup` / `kamal-v2-deploy`
- `nuxt-kamal-v1-setup` / `nuxt-kamal-v1-deploy`
- `nuxt-kamal-v2-setup` / `nuxt-kamal-v2-deploy`
- `slack-notify`

**Breaking Changes from v0.x:**
- Action paths changed to include version in name
- Input parameter names standardized
- Secret file structure updated

## Upgrade Guide

### From Manual Workflows to v1.0.0

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

### Future Upgrade Considerations

**v1.x to v2.x (Future)**
- May include Kamal v3 support
- Potential input parameter changes
- Updated security requirements

## Maintenance Schedule

### Regular Updates
- **Monthly**: Dependency updates and security patches
- **Quarterly**: Kamal version updates and feature additions
- **Annually**: Major version releases with breaking changes

### Security Updates
- Applied immediately when discovered
- Patch releases created within 24 hours
- Teams notified via Slack and GitHub

## Communication

### Release Notifications
- GitHub releases with detailed changelog
- Slack announcements in #devops channel
- Documentation updates in USAGE.md

### Migration Support
- 2-week notice for breaking changes
- Migration guides provided
- DevOps team available for assistance

## Rollback Strategy

### Emergency Rollback
If critical issues are found:
1. Revert to previous stable version tag
2. Notify all teams immediately
3. Create hotfix for issues
4. Release patch version

### Version Pinning
Teams can pin to specific versions:
```yaml
uses: unepwcmc/devops-actions/.github/actions/kamal-v2-setup@v1.0.0
```

## Testing Strategy

### Pre-Release Testing
- All actions tested with v1, v2, backend, frontend combinations
- Integration testing with real deployments
- Security scanning and validation

### Release Validation
- Automated testing pipeline runs on all PRs
- Manual testing in staging environments
- Community feedback period for RCs 