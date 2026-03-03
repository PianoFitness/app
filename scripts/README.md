# Piano Fitness - Development Scripts

This directory contains automation scripts for code quality, testing, and architecture enforcement.

## Architecture Enforcement

### `check-layer-boundaries.sh`

**Purpose**: Enforces Clean Architecture layer boundaries by detecting forbidden imports.

**Usage**:
```bash
./scripts/check-layer-boundaries.sh
```

**What it checks**:
- Domain layer (`lib/domain/`) must not import from `application/`, `presentation/`, or `features/`
- Application layer (`lib/application/`) must not import from `presentation/` or `features/`
- Presentation and features layers can import from any layer (they're the outermost layers)

**Integration**: Automatically runs via `lefthook` pre-commit hook when domain or application layer files are modified.

**Exit codes**:
- `0`: All layer boundaries respected ✅
- `1`: Violations found ❌ (commit will be blocked)

**Example output**:
```
🏗️  Checking Clean Architecture layer boundaries...
✅ All layer boundaries respected!
```

## Testing

### `check-test-selectors.sh`

**Purpose**: Ensures widget tests use key-based selectors instead of text-based selectors for better maintainability and i18n support.

**Usage**:
```bash
./scripts/check-test-selectors.sh test/**/*_test.dart
```

**What it checks**:
- Detects `find.text()` calls paired with `tester.tap()` in test files
- Encourages `find.byKey()` usage for interactive elements

**Integration**: Automatically runs via `lefthook` pre-commit hook when test files are modified.

## Screenshot Automation

### iOS Screenshot Scripts

- `automated-screenshots-iphone.sh` - Captures iPhone screenshots across different device sizes
- `automated-screenshots-ipad.sh` - Captures iPad screenshots
- `take-iphone-screenshot.sh` - Individual iPhone screenshot capture
- `take-ipad-screenshot.sh` - Individual iPad screenshot capture
- `check-ios-runtime.sh` - Verifies iOS simulator runtime availability

**Purpose**: Automated screenshot generation for App Store submissions.

**Prerequisites**:
- iOS simulators installed
- Piano Fitness app built for simulator
- Xcode command line tools

**Usage**:
```bash
# Run all iPhone screenshots
./scripts/automated-screenshots-iphone.sh

# Run all iPad screenshots
./scripts/automated-screenshots-ipad.sh
```

**Output**: Screenshots saved to `screenshots/` directory with device-specific naming.

## Git Hook Integration

All scripts are integrated with the project via [Lefthook](https://github.com/evilmartians/lefthook) configuration in `lefthook.yml`:

### Pre-commit Hooks (automatic on `git commit`)
1. **dart-fixes**: Auto-applies `dart fix` and formats code
2. **markdown-lint**: Lints and fixes markdown files
3. **test-selector-check**: Validates widget test selectors
4. **layer-boundaries**: Enforces Clean Architecture boundaries ⭐
5. **dart-analyze**: Runs static analysis

### Pre-push Hooks (automatic on `git push`)
1. **test**: Runs full test suite

## Adding New Scripts

When adding new scripts to this directory:

1. Make the script executable: `chmod +x scripts/your-script.sh`
2. Add script documentation to this README
3. If the script should run automatically, add it to `lefthook.yml`
4. Test the script manually before committing
5. Update lefthook hooks: `lefthook install`

## Troubleshooting

**Lefthook not running scripts**:
```bash
# Reinstall git hooks
lefthook install

# Verify hook configuration
lefthook run pre-commit --all-files
```

**Script permission errors**:
```bash
# Make script executable
chmod +x scripts/your-script.sh
```

**Layer boundary check false positives**:
- Review the script output to see which files are violating rules
- Ensure imports follow Clean Architecture principles
- If a genuine false positive, consider filing an issue for script improvement

## Further Reading

- [AGENTS.md](../AGENTS.md) - Complete development guidelines
- [lefthook.yml](../lefthook.yml) - Git hook configuration
- [analysis_options.yaml](../analysis_options.yaml) - Static analysis rules
- [ADRs](../docs/ADRs/) - Architecture decision records
