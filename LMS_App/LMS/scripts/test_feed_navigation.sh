#!/bin/bash

echo "🧪 Testing Feed Navigation..."

# Get device ID
DEVICE_ID=$(xcrun simctl list devices booted | grep -o "([A-Z0-9-]*)" | tr -d "()")

if [ -z "$DEVICE_ID" ]; then
    echo "❌ No booted device found"
    exit 1
fi

echo "📱 Using device: $DEVICE_ID"

# Take initial screenshot
echo "📸 Taking initial screenshot..."
xcrun simctl io booted screenshot feed_initial.png

# Navigate to Feed tab
echo "👆 Navigating to Feed tab..."
xcrun simctl ui booted tap 200 850

sleep 2

# Take feed screenshot
echo "📸 Taking feed screenshot..."
xcrun simctl io booted screenshot feed_screen.png

# Check if we're on classic feed
echo "🔍 Checking feed type..."
# If we see "Попробовать новую ленту" button, tap it
xcrun simctl ui booted tap 200 500

sleep 2

# Take new feed screenshot
echo "📸 Taking new feed screenshot..."
xcrun simctl io booted screenshot feed_new_design.png

# Try to open a post (tap in the middle of the screen)
echo "👆 Trying to open a post..."
xcrun simctl ui booted tap 200 400

sleep 3

# Take post detail screenshot
echo "📸 Taking post detail screenshot..."
xcrun simctl io booted screenshot feed_post_detail.png

# Check app state
APP_INFO=$(xcrun simctl appinfo booted ru.tsum.lms.igor 2>&1)
if [[ $APP_INFO == *"ProcessIdentifier"* ]]; then
    echo "✅ App is still running!"
    echo "$APP_INFO" | grep ProcessIdentifier
else
    echo "❌ App might have crashed"
    echo "$APP_INFO"
fi

echo "✅ Test completed"
echo "📂 Screenshots saved:"
ls -la feed_*.png 