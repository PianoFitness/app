#!/bin/bash
# Piano Fitness - iPhone Simulator Launch Script  
# Finds and launches the app on an available iPhone simulator

set -e

echo "🚀 Launching iPhone simulator..."
open -a Simulator

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