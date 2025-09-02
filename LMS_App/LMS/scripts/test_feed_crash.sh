#!/bin/bash

echo "🧪 Testing Feed Post Detail View..."

# Navigate to Feed
echo "📱 Navigating to Feed..."
xcrun simctl ui booted tap 10 800

sleep 2

# Tap on the first post (should be around middle of screen)
echo "👆 Tapping on first post..."
xcrun simctl ui booted tap 200 400

sleep 3

# Check if app is still running
APP_STATE=$(xcrun simctl appinfo booted ru.tsum.lms.igor | grep ProcessIdentifier)
if [[ -z "$APP_STATE" ]]; then
    echo "❌ App crashed!"
    exit 1
else
    echo "✅ App is still running"
    echo "$APP_STATE"
fi

# Take screenshot
echo "📸 Taking screenshot..."
xcrun simctl io booted screenshot feed_detail_test.png

echo "✅ Test completed successfully" 