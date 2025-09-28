#!/bin/bash
# Piano Fitness - iPad Simulator Launch Script
# Finds and launches the app on an available iPad simulator
# Usage: ./run-ipad-simulator.sh [SIMULATOR_NAME]
# If SIMULATOR_NAME is provided, tries to boot that specific simulator first

set -e

# Preflight checks - verify required tools are available
echo "🔧 Checking prerequisites..."

if ! command -v flutter >/dev/null 2>&1; then
    echo "❌ Error: flutter command not found in PATH"
    echo "   Please install Flutter from https://flutter.dev"
    exit 1
fi

if ! command -v xcrun >/dev/null 2>&1; then
    echo "❌ Error: xcrun command not found in PATH" 
    echo "   Please install Xcode Command Line Tools"
    exit 1
fi

if ! command -v open >/dev/null 2>&1; then
    echo "❌ Error: open command not found in PATH"
    echo "   This script requires macOS"
    exit 1
fi

echo "✅ Prerequisites verified"

PREFERRED_SIMULATOR="$1"

echo "🚀 Launching iPad simulator..."
open -a Simulator

# If a specific simulator name was provided, try to boot it
if [ -n "$PREFERRED_SIMULATOR" ]; then
    echo "🎯 Attempting to boot preferred simulator: $PREFERRED_SIMULATOR"
    xcrun simctl boot "$PREFERRED_SIMULATOR" 2>/dev/null || echo "⚠️  Could not boot $PREFERRED_SIMULATOR, will use any available iPad"
fi

echo "⏳ Finding available iPad simulator..."

# Use awk to reliably extract device ID from flutter devices output
# Format: "  DEVICE_NAME (TYPE) • DEVICE_ID • PLATFORM • ADDITIONAL_INFO"
# Split by literal " • " and take the second field, ensuring we get the first match
IPAD_DEVICE=$(flutter devices 2>/dev/null | awk '
    /iPad.*simulator/ {
        # Split the line by the literal " • " delimiter
        split($0, fields, " • ")
        if (length(fields) >= 2) {
            # The device ID is in the second field, trim whitespace
            gsub(/^[ \t]+|[ \t]+$/, "", fields[2])
            print fields[2]
            exit  # Take only the first match
        }
    }
' | head -1)

if [ -n "$IPAD_DEVICE" ]; then
    echo "📱 Found iPad device ID: $IPAD_DEVICE"
    echo "🎯 Launching app..."
    flutter run -d "$IPAD_DEVICE" --debug
else
    echo "❌ No iPad simulator found. Available devices:"
    flutter devices
    exit 1
fi