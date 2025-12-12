#!/bin/bash
# Piano Fitness - Automated Screenshot Script
# Launches iPad Pro 13-inch simulator, runs app, and provides screenshot commands
# Usage: ./automated-screenshots.sh

set -e

echo "📸 Piano Fitness - Automated Screenshot Setup"
echo "=============================================="

# Configuration
IPAD_MODEL="iPad Pro 13-inch (M4)"
SCREENSHOT_DIR="screenshots"

# Create screenshots directory
mkdir -p "$SCREENSHOT_DIR"

echo ""
echo "🔍 Finding $IPAD_MODEL simulator..."

# Get the device ID for iPad Pro 13-inch (M4)
DEVICE_ID=$(xcrun simctl list devices available | grep "$IPAD_MODEL" | grep -o '([A-F0-9-]*[A-F0-9])' | tr -d '()')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ Could not find $IPAD_MODEL simulator"
    echo ""
    echo "📋 Available iPad simulators:"
    xcrun simctl list devices available | grep -i "ipad"
    exit 1
fi

echo "✅ Found device ID: $DEVICE_ID"

# Shutdown any running simulators to ensure clean state
echo ""
echo "🛑 Shutting down all running simulators..."
xcrun simctl shutdown all 2>/dev/null || true

# Boot the iPad Pro 13-inch
echo ""
echo "🚀 Booting $IPAD_MODEL..."
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
echo "🎯 Launching Piano Fitness on iPad..."
flutter run -d "$DEVICE_ID" &
FLUTTER_PID=$!

echo ""
echo "=============================================="
echo "✅ Setup Complete!"
echo "=============================================="
echo ""
echo "The app is launching on $IPAD_MODEL"
echo "Device ID: $DEVICE_ID"
echo ""
echo "📸 To take screenshots:"
echo ""
echo "  Manual (in Simulator):"
echo "    Press Cmd+S to save screenshot to Desktop"
echo ""
echo "  Automated (from terminal):"
echo "    ./scripts/take-ipad-screenshot.sh"
echo ""
echo "    Or use this command directly:"
echo "    xcrun simctl io $DEVICE_ID screenshot $SCREENSHOT_DIR/ipad-\$(date +%Y%m%d-%H%M%S).png"
echo ""
echo "📋 Screenshot Checklist for 0.4.0:"
echo "  1. Practice page with Hand Selection visible"
echo "  2. Scale practice showing hand options"
echo "  3. Chord practice with hand selection"
echo "  4. Practice Hub overview"
echo "  5. Play page with virtual piano"
echo ""
echo "Press Ctrl+C when done taking screenshots to stop the app"
echo ""

# Wait for user to stop
wait $FLUTTER_PID 2>/dev/null || true
