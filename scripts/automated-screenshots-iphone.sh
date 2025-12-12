#!/bin/bash
# Piano Fitness - Automated Screenshot Script (iPhone)
# Launches iPhone Pro Max simulator, runs app, and provides screenshot commands
# Usage: ./automated-screenshots-iphone.sh

set -e

echo "📸 Piano Fitness - Automated Screenshot Setup (iPhone)"
echo "======================================================="

# Configuration - try to find the best iPhone Pro Max available
IPHONE_MODELS=("iPhone 17 Pro Max" "iPhone 16 Pro Max" "iPhone 15 Pro Max")
SCREENSHOT_DIR="screenshots"

# Create screenshots directory
mkdir -p "$SCREENSHOT_DIR"

echo ""
echo "🔍 Finding iPhone Pro Max simulator..."

# Try each model in order of preference
DEVICE_ID=""
IPHONE_MODEL=""
for model in "${IPHONE_MODELS[@]}"; do
    DEVICE_ID=$(xcrun simctl list devices available | grep "$model" | head -1 | grep -o '([A-F0-9-]*[A-F0-9])' | tr -d '()')
    if [ -n "$DEVICE_ID" ]; then
        IPHONE_MODEL="$model"
        break
    fi
done

if [ -z "$DEVICE_ID" ]; then
    echo "❌ Could not find any iPhone Pro Max simulator"
    echo ""
    echo "📋 Available iPhone simulators:"
    xcrun simctl list devices available | grep -i "iphone"
    exit 1
fi

echo "✅ Found $IPHONE_MODEL"
echo "   Device ID: $DEVICE_ID"

# Shutdown any running simulators to ensure clean state
echo ""
echo "🛑 Shutting down all running simulators..."
xcrun simctl shutdown all 2>/dev/null || true

# Boot the iPhone
echo ""
echo "🚀 Booting $IPHONE_MODEL..."
xcrun simctl boot "$DEVICE_ID"

echo "⏳ Waiting for simulator to fully boot..."
xcrun simctl bootstatus "$DEVICE_ID" -b

# Open Simulator app
echo ""
echo "📱 Opening Simulator..."
open -a Simulator

# Wait a moment for Simulator to open
sleep 2

# Launch the app
echo ""
echo "🎯 Launching Piano Fitness on iPhone..."
flutter run -d "$DEVICE_ID" &
FLUTTER_PID=$!

echo ""
echo "======================================================="
echo "✅ Setup Complete!"
echo "======================================================="
echo ""
echo "The app is launching on $IPHONE_MODEL"
echo "Device ID: $DEVICE_ID"
echo ""
echo "📸 To take screenshots:"
echo ""
echo "  Manual (in Simulator):"
echo "    Press Cmd+S to save screenshot to Desktop"
echo ""
echo "  Automated (from terminal):"
echo "    xcrun simctl io $DEVICE_ID screenshot $SCREENSHOT_DIR/iphone-\$(date +%Y%m%d-%H%M%S).png"
echo ""
echo "📋 Screenshot Checklist for 0.4.0:"
echo "  1. Practice page with Hand Selection visible"
echo "  2. Scale practice showing hand options"
echo "  3. Chord practice with hand selection"
echo "  4. Practice Hub overview"
echo "  5. Play page with virtual piano"
echo ""
echo "Press Ctrl+C when done taking screenshots to stop the app"

# Wait for user to stop
wait $FLUTTER_PID 2>/dev/null || true
