# Piano Fitness - Development Makefile
# Complete developer workflow commands for building, testing, and releasing

.PHONY: help setup deps deps-upgrade clean \
	build-ios build-macos build-ipa build-web \
	test test-coverage test-watch lint format validate profile bundle-size \
	screenshot-iphone screenshot-ipad \
	run-iphone run-ipad run-web dev hot-reload \
	devices reset-simulators install-certificates \
	release version changelog \
	ios ipad web build \
	help-first-time help-daily help-release

# Default target
help:
	@echo "Piano Fitness Developer Commands"
	@echo "==============================="
	@echo ""
	@echo "🚀 Quick Start:"
	@echo "  setup          - Complete project setup (first time)"
	@echo "  dev            - Start development (iPhone simulator)"
	@echo "  ios            - Launch on iPhone (alias for run-iphone)"
	@echo "  ipad           - Launch on iPad (alias for run-ipad)"
	@echo "  web            - Launch on web (alias for run-web)"
	@echo ""
	@echo "📱 Simulators:"
	@echo "  run-iphone     - Launch app on iPhone 16 Pro Max simulator"
	@echo "  run-ipad       - Launch app on iPad Pro 13-inch simulator"
	@echo "  run-web        - Launch app in web browser"
	@echo "  hot-reload     - Trigger hot reload (r key)"
	@echo ""
	@echo "📸 Screenshots:"
	@echo "  screenshot-iphone - Take screenshot on iPhone simulator"
	@echo "  screenshot-ipad   - Take screenshot on iPad simulator"
	@echo ""
	@echo "🔧 Building:"
	@echo "  build          - Build release IPA (alias for build-ipa)"
	@echo "  build-ipa      - Build release IPA for App Store"
	@echo "  build-ios      - Build iOS debug version"
	@echo "  build-macos    - Build macOS release version"
	@echo "  build-web      - Build web version"
	@echo ""
	@echo "🧪 Testing & Quality:"
	@echo "  test           - Run all tests"
	@echo "  test-coverage  - Run tests with coverage report"
	@echo "  test-watch     - Run tests in watch mode"
	@echo "  lint           - Run code analysis"
	@echo "  format         - Format code"
	@echo "  validate       - Run all quality checks"
	@echo ""
	@echo "📦 Dependencies:"
	@echo "  deps           - Get Flutter dependencies"
	@echo "  deps-upgrade   - Upgrade Flutter dependencies"
	@echo ""
	@echo "🚢 Release:"
	@echo "  release        - Complete release workflow (TODO)"
	@echo "  version        - Show current version"
	@echo "  changelog      - Generate changelog (TODO)"
	@echo ""
	@echo "⚡ Performance:"
	@echo "  profile        - Run performance profiling (TODO)"
	@echo "  bundle-size    - Analyze bundle size (TODO)"
	@echo ""
	@echo "🛠️  Utilities:"
	@echo "  clean          - Clean build artifacts"
	@echo "  devices        - List available simulators"
	@echo "  reset-simulators - Reset all simulators (TODO)"
	@echo "  install-certificates - Setup iOS certificates (TODO)"
	@echo ""
	@echo "💡 Workflow Help:"
	@echo "  help-first-time - First time setup guide"
	@echo "  help-daily      - Daily development workflow"
	@echo "  help-release    - Release workflow guide"

# Prerequisites check
check-flutter:
	@which flutter > /dev/null || (echo "❌ Flutter not found. Install from https://flutter.dev" && exit 1)
	@echo "✅ Flutter found: $$(flutter --version | head -1)"

check-xcode:
	@which xcodebuild > /dev/null || (echo "❌ Xcode not found. Install from App Store" && exit 1)
	@echo "✅ Xcode found"

# Setup & Dependencies
setup: check-flutter check-xcode
	@echo "🚀 Setting up Piano Fitness development environment..."
	@flutter doctor
	@echo "📦 Getting dependencies..."
	@flutter pub get
	@echo "🪝 Installing git hooks..."
	@lefthook install || echo "⚠️  Lefthook not found - install with 'brew install lefthook'"
	@echo "✅ Setup complete! Run 'make dev' to start developing."

deps:
	@echo "📦 Getting Flutter dependencies..."
	@flutter pub get

deps-upgrade:
	@echo "⬆️  Upgrading Flutter dependencies..."
	@flutter pub upgrade
	@flutter pub get

# Development & Hot Reload
dev: check-flutter
	@echo "🚀 Starting development on iPhone simulator..."
	@$(MAKE) run-iphone

hot-reload:
	@echo "🔥 Triggering hot reload..."
	@echo "Hot reload typically triggered with 'r' key in running Flutter session"
	@echo "Or use your IDE's hot reload button"

# Simulator Management
run-iphone: check-flutter
	@echo "🚀 Launching iPhone 16 Pro Max simulator..."
	@open -a Simulator
	@sleep 2
	@xcrun simctl boot "iPhone 16 Pro Max" 2>/dev/null || true
	@echo "⏳ Waiting for simulator to start..."
	@sleep 3
	@echo "🎯 Launching app..."
	@flutter run -d "iPhone 16 Pro Max" --debug

run-ipad: check-flutter
	@echo "🚀 Launching iPad Pro 13-inch simulator..."
	@open -a Simulator
	@sleep 2
	@xcrun simctl boot "iPad Pro 13-inch (M4)" 2>/dev/null || true
	@echo "⏳ Waiting for simulator to start..."
	@sleep 3
	@echo "🎯 Launching app..."
	@flutter run -d "iPad Pro 13-inch (M4)" --debug

run-web: check-flutter
	@echo "🌐 Launching web version..."
	@flutter run -d chrome --debug

devices:
	@echo "📱 Available simulators:"
	@xcrun simctl list devices available
	@echo ""
	@echo "🌐 Available devices for Flutter:"
	@flutter devices

reset-simulators:
	@echo "🔄 Resetting all simulators..."
	@echo "TODO: Implement simulator reset functionality"
	@echo "Manual: Device > Erase All Content and Settings in Simulator"

install-certificates:
	@echo "📜 Setting up iOS certificates..."
	@echo "TODO: Implement certificate installation automation"
	@echo "Manual: Open Xcode > Preferences > Accounts > Add Apple ID"

# Screenshots
screenshot-iphone:
	@echo "📸 Taking iPhone screenshot..."
	@mkdir -p screenshots
	@FILE="screenshots/iphone-$$(date +%Y%m%d-%H%M%S).png" && \
	 xcrun simctl io "iPhone 16 Pro Max" screenshot "$$FILE" && \
	 echo "✅ Screenshot saved: $$FILE" && \
	 ls -la "$$FILE"

screenshot-ipad:
	@echo "📸 Taking iPad screenshot..."
	@mkdir -p screenshots
	@FILE="screenshots/ipad-$$(date +%Y%m%d-%H%M%S).png" && \
	 xcrun simctl io "iPad Pro 13-inch (M4)" screenshot "$$FILE" && \
	 echo "✅ Screenshot saved: $$FILE" && \
	 ls -la "$$FILE"

# Building
build-ipa: check-flutter
	@echo "📦 Building release IPA for App Store..."
	@echo "⏳ This may take several minutes..."
	@flutter build ipa --release
	@echo "✅ IPA built successfully!"
	@ls -la build/ios/ipa/

build-ios: check-flutter
	@echo "📦 Building iOS debug version..."
	@flutter build ios --debug
	@echo "✅ iOS debug build complete"

build-macos: check-flutter
	@echo "📦 Building macOS release version..."
	@flutter build macos --release
	@echo "✅ macOS release build complete"

build-web: check-flutter
	@echo "🌐 Building web version..."
	@flutter build web --release
	@echo "✅ Web build complete: build/web/"

# Testing & Quality Assurance
test: check-flutter
	@echo "🧪 Running tests..."
	@flutter test
	@echo "✅ All tests completed"

test-coverage: check-flutter
	@echo "📊 Running tests with coverage..."
	@flutter test --coverage
	@echo "✅ Coverage report generated: coverage/lcov.info"
	@echo "💡 View with: genhtml coverage/lcov.info -o coverage/html"

test-watch:
	@echo "👀 Running tests in watch mode..."
	@echo "TODO: Implement test watch mode"
	@echo "Manual: Use your IDE's test runner or run tests manually after changes"

lint: check-flutter
	@echo "🔍 Running code analysis..."
	@flutter analyze
	@echo "✅ Code analysis complete"

format: check-flutter
	@echo "✨ Formatting code..."
	@dart format .
	@echo "✅ Code formatting complete"

validate: format lint test
	@echo "🎯 Running complete validation..."
	@echo "✅ All quality checks passed!"

# Performance & Analysis
profile:
	@echo "⚡ Performance profiling..."
	@echo "TODO: Implement performance profiling"
	@echo "Manual: flutter run --profile and use DevTools"

bundle-size:
	@echo "📦 Analyzing bundle size..."
	@echo "TODO: Implement bundle size analysis"
	@echo "Manual: flutter build --analyze-size"

# Release Workflow
release:
	@echo "🚢 Starting release workflow..."
	@echo "TODO: Implement complete release automation"
	@echo "This should: bump version, build IPA, run tests, take screenshots"
	@echo "Manual steps for now:"
	@echo "1. Update version in pubspec.yaml"
	@echo "2. Run: make validate"
	@echo "3. Run: make build-ipa"
	@echo "4. Take screenshots with: make screenshot-iphone screenshot-ipad"

version:
	@echo "📋 Current version:"
	@grep "^version:" pubspec.yaml || echo "Version not found in pubspec.yaml"

changelog:
	@echo "📝 Generating changelog..."
	@echo "TODO: Implement changelog generation"
	@echo "Manual: Update CHANGELOG.md with version $$(grep '^version:' pubspec.yaml | cut -d' ' -f2)"

# Shorter Aliases
ios: run-iphone
ipad: run-ipad
web: run-web
build: build-ipa

# Utilities
clean:
	@echo "🧹 Cleaning build artifacts..."
	@flutter clean
	@rm -rf build/
	@rm -rf .dart_tool/
	@echo "✅ Clean complete"

# Help for specific workflows
help-first-time:
	@echo "🆕 First time setup:"
	@echo "1. make setup"
	@echo "2. make dev"
	@echo ""

help-daily:
	@echo "📅 Daily development:"
	@echo "1. make dev (or make ios/ipad/web)"
	@echo "2. make test (run tests)"
	@echo "3. make validate (before committing)"
	@echo ""

help-release:
	@echo "🚢 Release workflow:"
	@echo "1. make version (check current)"
	@echo "2. Update version in pubspec.yaml"
	@echo "3. make validate"
	@echo "4. make build-ipa"
	@echo "5. make screenshot-iphone screenshot-ipad"
	@echo "6. Upload IPA and submit for review"