#!/bin/bash
# Piano Fitness - iPhone Screenshot Script
# Takes a screenshot of the specified iPhone simulator

set -e

IPHONE_SIM="${1:-iPhone 16 Pro Max}"

echo "📸 Taking iPhone screenshot..."
mkdir -p screenshots
open -a Simulator

echo "🚀 Booting $IPHONE_SIM..."
xcrun simctl boot "$IPHONE_SIM" 2>/dev/null || true

echo "⏳ Waiting for simulator to fully boot..."
xcrun simctl bootstatus "$IPHONE_SIM" -b

echo "🔍 Finding device ID..."
DEVICE_ID=$(flutter devices | grep -E "iPhone.*simulator" | grep -o " • [A-Z0-9-]* • " | tr -d ' •' | head -1)

if [ -n "$DEVICE_ID" ]; then
    FILE="screenshots/iphone-$(date +%Y%m%d-%H%M%S).png"
    echo "📱 Taking screenshot with device ID: $DEVICE_ID"
    xcrun simctl io "$DEVICE_ID" screenshot "$FILE"
    echo "✅ Screenshot saved: $FILE"
    ls -la "$FILE"
else
    echo "❌ Could not find iPhone simulator device ID for: $IPHONE_SIM"
    exit 1
fi