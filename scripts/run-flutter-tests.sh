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

set -e

# 1. Check for flutter alongside the dart binary on PATH.
DART_PATH=$(command -v dart 2>/dev/null || true)
if [ -n "$DART_PATH" ]; then
  FLUTTER_CANDIDATE="$(dirname "$DART_PATH")/flutter"
  if [ -x "$FLUTTER_CANDIDATE" ]; then
    exec "$FLUTTER_CANDIDATE" test "$@"
  fi
fi

# 2. FLUTTER_ROOT environment variable (set by some CI systems and IDEs).
if [ -n "$FLUTTER_ROOT" ] && [ -x "$FLUTTER_ROOT/bin/flutter" ]; then
  exec "$FLUTTER_ROOT/bin/flutter" test "$@"
fi

# 3. Common installation paths.
for CANDIDATE in \
  "$HOME/code/Flutter/SDK/bin/flutter" \
  "$HOME/development/flutter/bin/flutter" \
  "$HOME/flutter/bin/flutter" \
  "/opt/flutter/bin/flutter" \
  "/usr/local/flutter/bin/flutter"; do
  if [ -x "$CANDIDATE" ]; then
    exec "$CANDIDATE" test "$@"
  fi
done

# 4. Last resort: rely on whatever flutter is on PATH.
exec flutter test "$@"
