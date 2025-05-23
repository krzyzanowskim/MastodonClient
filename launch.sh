#!/bin/bash

# MastodonClient Launch Script

echo "🚀 MastodonClient iOS App"
echo "========================="

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed or not in PATH"
    exit 1
fi

# Check if project exists
if [ ! -f "MastodonClient.xcodeproj/project.pbxproj" ]; then
    echo "❌ MastodonClient.xcodeproj not found"
    exit 1
fi

echo "📱 Available simulators:"
xcrun simctl list devices | grep "iPhone"

echo ""
echo "🔨 Building project..."
xcodebuild -project MastodonClient.xcodeproj -scheme MastodonClient -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=latest' build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🎯 To run the app:"
    echo "1. Open Xcode: open MastodonClient.xcodeproj"
    echo "2. Select your target device"
    echo "3. Press Cmd+R to run"
    echo ""
    echo "📋 Features included:"
    echo "• OAuth Authentication"
    echo "• Timeline Views (Home/Local/Federated)"
    echo "• Post Composition"
    echo "• User Profiles"
    echo "• Notifications"
    echo "• Search"
    echo "• Settings"
else
    echo "❌ Build failed. Check the error messages above."
    exit 1
fi