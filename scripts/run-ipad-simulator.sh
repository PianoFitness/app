#!/bin/bash
# Piano Fitness - iPad Simulator Launch Script
# Finds and launches the app on an available iPad simulator
# Usage: ./run-ipad-simulator.sh [SIMULATOR_NAME]
# If SIMULATOR_NAME is provided, tries to boot that specific simulator first

set -e

PREFERRED_SIMULATOR="$1"

echo "🚀 Launching iPad simulator..."
open -a Simulator

# If a specific simulator name was provided, try to boot it
if [ -n "$PREFERRED_SIMULATOR" ]; then
    echo "🎯 Attempting to boot preferred simulator: $PREFERRED_SIMULATOR"
    xcrun simctl boot "$PREFERRED_SIMULATOR" 2>/dev/null || echo "⚠️  Could not boot $PREFERRED_SIMULATOR, will use any available iPad"
fi

echo "⏳ Finding available iPad simulator..."
IPAD_DEVICE=$(flutter devices | grep -E "iPad.*simulator" | grep -o " • [A-Z0-9-]* • " | tr -d ' •' | head -1)

if [ -n "$IPAD_DEVICE" ]; then
    echo "📱 Found iPad device ID: $IPAD_DEVICE"
    echo "🎯 Launching app..."
    flutter run -d "$IPAD_DEVICE" --debug
else
    echo "❌ No iPad simulator found. Available devices:"
    flutter devices
    exit 1
fi