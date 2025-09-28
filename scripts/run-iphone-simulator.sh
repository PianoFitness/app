#!/bin/bash
# Piano Fitness - iPhone Simulator Launch Script  
# Finds and launches the app on an available iPhone simulator
# Usage: ./run-iphone-simulator.sh [SIMULATOR_NAME]
# If SIMULATOR_NAME is provided, tries to boot that specific simulator first

set -e

PREFERRED_SIMULATOR="$1"

echo "🚀 Launching iPhone simulator..."
open -a Simulator

# If a specific simulator name was provided, try to boot it
if [ -n "$PREFERRED_SIMULATOR" ]; then
    echo "🎯 Attempting to boot preferred simulator: $PREFERRED_SIMULATOR"
    xcrun simctl boot "$PREFERRED_SIMULATOR" 2>/dev/null || echo "⚠️  Could not boot $PREFERRED_SIMULATOR, will use any available iPhone"
fi

echo "⏳ Finding available iPhone simulator..."
IPHONE_DEVICE=$(flutter devices | grep -E "iPhone.*simulator" | grep -o " • [A-Z0-9-]* • " | tr -d ' •' | head -1)

if [ -n "$IPHONE_DEVICE" ]; then
    echo "📱 Found iPhone device ID: $IPHONE_DEVICE"
    echo "🎯 Launching app..."
    flutter run -d "$IPHONE_DEVICE" --debug
else
    echo "❌ No iPhone simulator found. Available devices:"
    flutter devices
    exit 1
fi