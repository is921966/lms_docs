#!/bin/bash

echo "📱 Visual Feed Test"
echo "=================="

# Helper function
take_screenshot() {
    local name=$1
    local desc=$2
    echo "📸 $desc"
    xcrun simctl io "iPhone 16 Pro" screenshot "/tmp/feed_test_${name}.png"
    echo "   Saved: /tmp/feed_test_${name}.png"
    sleep 1
}

# Terminate and restart app
echo "🔄 Restarting app..."
xcrun simctl terminate "iPhone 16 Pro" ru.tsum.lms.igor 2>/dev/null
sleep 2
xcrun simctl launch "iPhone 16 Pro" ru.tsum.lms.igor
sleep 5

# Take screenshots
take_screenshot "01_home" "Home screen"

# Navigate to Feed
echo "👆 Navigating to Feed..."
xcrun simctl ui "iPhone 16 Pro" tap 302 791 2>/dev/null || echo "  (simulated tap on Feed tab)"
sleep 3

take_screenshot "02_feed_list" "Feed list view"

# Tap on first channel (Releases)
echo "👆 Opening Releases channel..."
xcrun simctl ui "iPhone 16 Pro" tap 200 200 2>/dev/null || echo "  (simulated tap on Releases)"
sleep 3

take_screenshot "03_releases_channel" "Releases channel content"

# Check if we see multiple posts
echo ""
echo "🔍 Visual check results:"
echo "1. Check /tmp/feed_test_02_feed_list.png - Should show list of channels"
echo "2. Check /tmp/feed_test_03_releases_channel.png - Should show multiple posts"
echo ""
echo "Opening screenshots..."
open /tmp/feed_test_02_feed_list.png /tmp/feed_test_03_releases_channel.png 