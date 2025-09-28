#!/bin/bash
# Piano Fitness - iPad Screenshot Script
# Takes a screenshot of the specified iPad simulator

set -e

IPAD_SIM="${1:-iPad Pro 13-inch (M4)}"

echo "📸 Taking iPad screenshot..."
mkdir -p screenshots
open -a Simulator

echo "🔍 Finding device ID for: $IPAD_SIM"
DEVICE_ID=$(xcrun simctl list devices available | grep "$IPAD_SIM" | grep -o '([A-Fa-f0-9-]*)')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ Could not find available iPad simulator: $IPAD_SIM"
    echo "📋 Available iPad simulators:"
    xcrun simctl list devices available | grep -i ipad || echo "   None found"
    exit 1
fi

# Remove parentheses from DEVICE_ID
DEVICE_ID=$(echo "$DEVICE_ID" | tr -d '()')
echo "📱 Found device ID: $DEVICE_ID"

# Ensure the simulator is booted
echo "🚀 Ensuring $IPAD_SIM is booted..."
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true

echo "⏳ Waiting for simulator to fully boot..."
xcrun simctl bootstatus "$DEVICE_ID" -b

FILE="screenshots/ipad-$(date +%Y%m%d-%H%M%S).png"
echo "📸 Taking screenshot from: $IPAD_SIM"
xcrun simctl io "$DEVICE_ID" screenshot "$FILE"
echo "✅ Screenshot saved: $FILE"
ls -la "$FILE"
