#!/bin/bash
# Piano Fitness - iPad Simulator Launch Script
# Finds and launches the app on an available iPad simulator

set -e

echo "🚀 Launching iPad simulator..."
open -a Simulator

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