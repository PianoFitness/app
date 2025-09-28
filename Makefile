# Piano Fitness - Development Makefile
# Complete developer workflow commands for building, testing, and releasing

# Simulator defaults (overridable): use `make IPHONE_SIM="..."` to override
IPHONE_SIM ?= iPhone 17 Pro
IPAD_SIM   ?= iPad Pro 13-inch (M4)

.PHONY: all help setup deps deps-upgrade clean \
	build-ios build-macos build-ipa build-web \
	test test-coverage test-watch lint format validate profile bundle-size \
	screenshot-iphone screenshot-ipad \
	run-iphone run-ipad run-web dev hot-reload \
	devices reset-simulators install-certificates \
	release version changelog \
	ios ipad web build \
	help-first-time help-daily help-release

# Conventional 'all' target for checkmake compliance
all: help

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
	@echo "  run-iphone     - Launch app on iPhone simulator"
	@echo "  run-ipad       - Launch app on iPad simulator"
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
	@echo "  install-ios-runtime - Check/install iOS 26.0 simulator"
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

# Simulator Management - Using Scripts for Maintainability
run-iphone: check-flutter check-xcode
	@./scripts/run-iphone-simulator.sh

run-ipad: check-flutter check-xcode
	@./scripts/run-ipad-simulator.sh

run-web: check-flutter
	@echo "🌐 Launching web version..."
	@flutter run -d chrome --debug

# Utilities
devices: check-xcode
	@echo "📱 Available simulators:"
	@xcrun simctl list devices available
	@echo ""
	@echo "🌐 Available devices for Flutter:"
	@flutter devices

# Building
build-ipa: check-flutter check-xcode
	@echo "📦 Building release IPA for App Store..."
	@echo "⏳ This may take several minutes..."
	@flutter build ipa --release
	@echo "✅ IPA built successfully!"
	@ls -la build/ios/ipa/

build-ios: check-flutter check-xcode
	@echo "📦 Building iOS debug version..."
	@flutter build ios --debug --no-codesign
	@echo "✅ iOS debug build complete"

build-macos: check-flutter check-xcode
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

# Screenshots - Using Scripts for Maintainability
screenshot-iphone: check-xcode
	@./scripts/take-iphone-screenshot.sh "$(IPHONE_SIM)"

screenshot-ipad: check-xcode
	@./scripts/take-ipad-screenshot.sh "$(IPAD_SIM)"

# iOS Runtime Management - Using Script for Maintainability
install-ios-runtime:
	@./scripts/check-ios-runtime.sh

# Utilities
clean:
	@echo "🧹 Cleaning build artifacts..."
	@flutter clean
	@rm -rf build/
	@rm -rf .dart_tool/
	@echo "✅ Clean complete"

version:
	@echo "📋 Current version:"
	@grep "^version:" pubspec.yaml || echo "Version not found in pubspec.yaml"

# Shorter Aliases
ios: run-iphone
ipad: run-ipad
web: run-web
build: build-ipa

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