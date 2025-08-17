# Piano Fitness Release Guide

This document outlines the complete process for performing a feature release of the Piano Fitness app.

## 📋 Pre-Release Checklist

### 1. Development Complete

- [ ] All features tested and working
- [ ] All tests passing (`flutter test`)
- [ ] Code analysis clean (`flutter analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] Git hooks passing (lefthook)

### 2. Version Planning

- [ ] Determine version type (major.minor.patch)
- [ ] Review new features and changes for release notes
- [ ] Ensure all breaking changes are documented

## 🔄 Release Process

### Step 1: Update Version Information

#### 1.1 Update pubspec.yaml

```bash
# Update version in pubspec.yaml
# Format: major.minor.patch+build
# Example: 0.2.1+3
```

Edit `pubspec.yaml`:

```yaml
version: X.Y.Z+BUILD_NUMBER
```

#### 1.2 Update CHANGELOG.md

Add new release section at the top:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature descriptions

### Changed
- Modified feature descriptions

### Fixed
- Bug fix descriptions

### Removed
- Removed feature descriptions
```

### Step 2: Update App Store Listing

#### 2.1 Update App Store Documentation

Edit `docs/app_store.md`:

1. **Update Promotional Text** (if needed):
   - Review current promotional text for new features
   - Update feature highlights in the 170-character limit

2. **Update App Description**:
   - Add new features to appropriate sections
   - Update version-specific feature callouts
   - Ensure all new functionality is covered

3. **Update Document Version**:
   - Update the footer with new date and version
   - Update "Last Updated" timestamp

#### 2.2 Take New Screenshots (if needed)

If UI has changed significantly:

```bash
# Build and run app for screenshots
flutter build macos --release
flutter run -d macos

# Or for iOS simulator
flutter build ios --release
flutter run -d ios
```

Refer to `docs/screenshots.md` for screenshot requirements and guidelines.

### Step 3: Create Pull Request

#### 3.1 Commit Changes

```bash
# Stage all version-related changes
git add pubspec.yaml CHANGELOG.md docs/app_store.md

# Create conventional commit
git commit -m "release: prepare version X.Y.Z

- Update version to X.Y.Z+BUILD in pubspec.yaml
- Add CHANGELOG.md entry for X.Y.Z release
- Update app store listing with new features
- Prepare release documentation"
```

#### 3.2 Create Pull Request

```bash
# Push feature branch if not already done
git push origin feature-branch-name
```

### Step 4: Merge and Create GitHub Release

#### 4.1 Merge Pull Request

1. Review PR for completeness
2. Ensure all CI checks pass
3. Merge PR to main branch
4. Pull latest main branch locally

#### 4.2 Create GitHub Release

```bash
# Tag the release
git tag -a vX.Y.Z -m "Release X.Y.Z"
git push origin vX.Y.Z

# Create GitHub release using CLI
gh release create vX.Y.Z --title "Piano Fitness X.Y.Z" --notes "$(cat <<'EOF'
## What's New in X.Y.Z

[Copy relevant sections from CHANGELOG.md]

### Added
- Feature descriptions

### Changed  
- Change descriptions

### Fixed
- Bug fix descriptions

## Download

Available on the App Store and as direct download.

## Full Changelog
**Full Changelog**: https://github.com/PianoFitness/app/compare/vPREV.VERSION...vX.Y.Z
EOF
)"
```

### Step 5: Build Release Artifacts

#### 5.1 Clean Build Environment

```bash
flutter clean
flutter pub get
```

#### 5.2 Build for Release

```bash
# Build for macOS
flutter build macos --release

# Build for iOS (requires macOS with Xcode)
flutter build ios --release

# Build for web (if needed)
flutter build web --release
```

#### 5.3 Verify Builds

```bash
# Test macOS build
open build/macos/Build/Products/Release/piano_fitness.app

# Test iOS build in simulator
flutter run -d ios --release
```

### Step 6: App Store Submission

#### 6.1 Upload to App Store Connect

Using **Transporter** app (Apple's upload tool):

1. Open Transporter app
2. Sign in with Apple Developer credentials
3. Drag and drop the `.ipa` file (iOS) or `.app` bundle (macOS)
4. Click "Deliver" to upload

Alternative using Xcode:

```bash
# Archive and upload via Xcode
# Open ios/Runner.xcworkspace in Xcode
# Product > Archive > Distribute App > App Store Connect
```

#### 6.2 Update App Store Connect

1. **Login to App Store Connect**: <https://appstoreconnect.apple.com>
2. **Navigate to App**: Select Piano Fitness app
3. **Create New Version**:
   - Click "+" to add new version
   - Enter version number (X.Y.Z)

4. **Update App Information**:
   - Copy promotional text from `docs/app_store.md`
   - Copy app description from `docs/app_store.md`
   - Update keywords if changed
   - Upload new screenshots if available

5. **Select Build**:
   - Choose the uploaded build from Step 6.1
   - Add build notes if needed

6. **Review and Submit**:
   - Complete App Store review questionnaire
   - Submit for review

### Step 7: Post-Release Tasks

#### 7.1 Update Documentation

- [ ] Update README.md with new version info (if applicable)
- [ ] Update any API documentation
- [ ] Update development setup instructions if changed

#### 7.2 Communication

- [ ] Announce release on social media (if applicable)
- [ ] Update website with new features (if applicable)
- [ ] Notify beta testers and early users

#### 7.3 Monitor Release

- [ ] Check App Store Connect for approval status
- [ ] Monitor crash reports and user feedback
- [ ] Prepare hotfix process if critical issues found

## 🛠️ Tools and Resources

### Required Tools

- **Flutter SDK**: For building the app
- **Xcode**: For iOS builds and App Store submission
- **Transporter**: Apple's app upload tool
- **GitHub CLI**: For automated PR and release creation
- **Lefthook**: Git hooks for quality assurance

### Key Files

- `pubspec.yaml`: Version number and dependencies
- `CHANGELOG.md`: Release notes and version history
- `docs/app_store.md`: App Store listing content
- `docs/screenshots.md`: Screenshot guidelines

### Apple Developer Resources

- **App Store Connect**: <https://appstoreconnect.apple.com>
- **Developer Portal**: <https://developer.apple.com/account>
- **App Store Guidelines**: <https://developer.apple.com/app-store/review/guidelines/>

## 🔧 Troubleshooting

### Common Issues

#### Build Failures

```bash
# Clean and rebuild
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release
```

#### Code Signing Issues

- Verify certificates in Xcode
- Check provisioning profiles
- Ensure bundle identifier matches App Store Connect

#### Upload Failures

- Check app size limits
- Verify all required metadata is complete
- Ensure build number is higher than previous submission

#### App Store Rejection

- Review rejection feedback carefully
- Check App Store Review Guidelines
- Make necessary changes and resubmit

### Version Number Guidelines

#### Semantic Versioning

- **Major (X.0.0)**: Breaking changes, major new features
- **Minor (0.X.0)**: New features, backward compatible
- **Patch (0.0.X)**: Bug fixes, small improvements

#### Build Numbers

- Must be incremented for each App Store submission
- Can be reset when major/minor version changes
- Use integers only (no decimals)

## 📝 Release Checklist Template

Copy this checklist for each release:

```markdown
## Release X.Y.Z Checklist

### Pre-Release
- [ ] All tests passing
- [ ] Code analysis clean
- [ ] Features complete and tested

### Documentation
- [ ] pubspec.yaml version updated
- [ ] CHANGELOG.md updated
- [ ] App store listing updated
- [ ] Screenshots updated (if needed)

### Release Process
- [ ] Pull request created and merged
- [ ] GitHub release created
- [ ] Build artifacts created
- [ ] Builds tested locally

### App Store
- [ ] App uploaded to App Store Connect
- [ ] App Store Connect metadata updated
- [ ] App submitted for review
- [ ] Release monitoring in place

### Post-Release
- [ ] Documentation updated
- [ ] Communication completed
- [ ] Monitoring active
```

---

*Last Updated: August 17, 2025*
*Document Version: 1.0*
