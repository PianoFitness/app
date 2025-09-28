#!/bin/bash
# Piano Fitness - iOS Runtime Status Script
# Checks and reports on iOS simulator runtime availability
# Usage: ./check-ios-runtime.sh [IOS_VERSION]
# Examples: ./check-ios-runtime.sh 26.0
#           ./check-ios-runtime.sh 18.4
#           IOS_RUNTIME_VERSION=26.0 ./check-ios-runtime.sh

set -e

# Accept version via CLI argument or environment variable
IOS_VERSION="${1:-${IOS_RUNTIME_VERSION}}"

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
if [ -n "$IOS_VERSION" ]; then
    echo "💡 To install iOS $IOS_VERSION Simulator:"
    echo "  1. Open Xcode"
    echo "  2. Go to Settings > Components (or Xcode > Preferences > Components)"
    echo "  3. Look for iOS $IOS_VERSION Simulator and click GET/INSTALL"
    echo "  4. Wait for download and installation (this may take a while)"
    echo ""
    echo "🎯 Current status summary:"
    
    # Check if the specified iOS runtime is available
    if xcrun simctl runtime list 2>/dev/null | grep -q "iOS $IOS_VERSION"; then
        echo "✅ iOS $IOS_VERSION runtime is installed"
    else
        echo "⚠️  iOS $IOS_VERSION runtime not found - you may need to install it"
    fi
else
    echo "💡 No specific iOS version specified."
    echo "  Available iOS runtimes:"
    xcrun simctl runtime list 2>/dev/null | grep -E "iOS.*Ready" | sed 's/^/    /' || echo "    ❌ No iOS runtimes found"
    echo ""
    echo "🎯 General status summary:"
    echo "ℹ️  Use with a version argument to check specific runtime (e.g., ./check-ios-runtime.sh 26.0)"
fi

# Check if any simulators are available
SIMULATOR_COUNT=$(xcrun simctl list devices available 2>/dev/null | grep -E "(iPhone|iPad)" | wc -l)
if [ "$SIMULATOR_COUNT" -gt 0 ]; then
    echo "✅ $SIMULATOR_COUNT simulators are available"
else
    echo "❌ No simulators available"
fi