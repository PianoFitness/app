#!/usr/bin/env bash
# Locates the Flutter SDK binary and runs the test suite.
#
# Git hook environments use a minimal PATH that often omits the Flutter SDK
# directory added by shell profiles (e.g. ~/.zprofile, ~/.zshrc). This script
# searches several locations so hooks work regardless of how Flutter was
# installed, in priority order:
#
#  1. flutter binary co-located with the dart binary on PATH (covers Flutter
#     SDK dart, but not a standalone Homebrew dart installation).
#  2. FLUTTER_ROOT environment variable, if set.
#  3. Common macOS / Linux installation directories.
#  4. flutter from PATH as a last resort.
#
# --no-pub is passed to flutter test to skip dependency resolution.
# The hook env may have a stale flutter.version.json cache that reports a
# wrong SDK version (e.g. the app's git HEAD is mistaken for the Flutter
# framework revision), causing pub to reject the pubspec flutter constraint.
# Packages are expected to already be resolved during development.

set -e

_run_tests() {
  local flutter="$1"
  exec "$flutter" test --no-pub
}

# 1. Check for flutter alongside the dart binary on PATH.
DART_PATH=$(command -v dart 2>/dev/null || true)
if [ -n "$DART_PATH" ]; then
  FLUTTER_CANDIDATE="$(dirname "$DART_PATH")/flutter"
  if [ -x "$FLUTTER_CANDIDATE" ]; then
    _run_tests "$FLUTTER_CANDIDATE"
  fi
fi

# 2. FLUTTER_ROOT environment variable (set by some CI systems and IDEs).
if [ -n "$FLUTTER_ROOT" ] && [ -x "$FLUTTER_ROOT/bin/flutter" ]; then
  _run_tests "$FLUTTER_ROOT/bin/flutter"
fi

# 3. Common installation paths.
for CANDIDATE in \
  "$HOME/code/Flutter/SDK/bin/flutter" \
  "$HOME/development/flutter/bin/flutter" \
  "$HOME/flutter/bin/flutter" \
  "/opt/flutter/bin/flutter" \
  "/usr/local/flutter/bin/flutter"; do
  if [ -x "$CANDIDATE" ]; then
    _run_tests "$CANDIDATE"
  fi
done

# 4. Last resort: rely on whatever flutter is on PATH.
exec flutter test --no-pub
