#!/bin/bash
# Piano Fitness - iPad Screenshot Script
# Takes a screenshot of the specified iPad simulator

set -e

IPAD_SIM="${1:-iPad Pro 13-inch (M4)}"

echo "📸 Taking iPad screenshot..."
mkdir -p screenshots
open -a Simulator

echo "🚀 Booting $IPAD_SIM..."
xcrun simctl boot "$IPAD_SIM" 2>/dev/null || true

echo "⏳ Waiting for simulator to fully boot..."
xcrun simctl bootstatus "$IPAD_SIM" -b

echo "🔍 Finding device ID..."
DEVICE_ID=$(flutter devices | grep -E "iPad.*simulator" | grep -o " • [A-Z0-9-]* • " | tr -d ' •' | head -1)

if [ -n "$DEVICE_ID" ]; then
    FILE="screenshots/ipad-$(date +%Y%m%d-%H%M%S).png"
    echo "📱 Taking screenshot with device ID: $DEVICE_ID"
    xcrun simctl io "$DEVICE_ID" screenshot "$FILE"
    echo "✅ Screenshot saved: $FILE"
    ls -la "$FILE"
else
    echo "❌ Could not find iPad simulator device ID for: $IPAD_SIM"
    exit 1
fi