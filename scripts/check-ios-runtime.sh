#!/bin/bash
# Piano Fitness - iOS Runtime Status Script
# Checks and reports on iOS simulator runtime availability

set -e

echo "📱 Checking iOS simulator runtime status..."
echo ""
echo "🔧 Installed runtimes:"
xcrun simctl runtime list
echo ""

echo "📱 Available iOS SDKs:"
if ls -1 /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/ 2>/dev/null | grep iOS; then
    echo "✅ iOS SDKs found"
else
    echo "❌ No iOS SDKs found"
fi

echo ""
echo "🎯 Available Simulator SDKs:"
if ls -1 /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/ 2>/dev/null | grep Simulator; then
    echo "✅ Simulator SDKs found"
else
    echo "❌ No Simulator SDKs found"
fi

echo ""
echo "💡 To install iOS 26.0 Simulator:"
echo "  1. Open Xcode"
echo "  2. Go to Settings > Components (or Xcode > Preferences > Components)"
echo "  3. Look for iOS 26.0 Simulator and click GET/INSTALL"
echo "  4. Wait for download and installation (this may take a while)"
echo ""
echo "🎯 Current status summary:"

# Check if iOS 26.0 runtime is available
if xcrun simctl runtime list 2>/dev/null | grep -q "iOS-26-0"; then
    echo "✅ iOS 26.0 runtime is installed"
else
    echo "⚠️  iOS 26.0 runtime not found - you may need to install it"
fi

# Check if any simulators are available
SIMULATOR_COUNT=$(xcrun simctl list devices available 2>/dev/null | grep -E "(iPhone|iPad)" | wc -l)
if [ "$SIMULATOR_COUNT" -gt 0 ]; then
    echo "✅ $SIMULATOR_COUNT simulators are available"
else
    echo "❌ No simulators available"
fi