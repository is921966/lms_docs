#!/bin/bash

echo "📱 Feed Diagnostics Test"
echo "======================="

# Restart app
echo "🔄 Restarting app..."
xcrun simctl terminate "iPhone 16 Pro" ru.tsum.lms.igor 2>/dev/null
sleep 2
xcrun simctl launch "iPhone 16 Pro" ru.tsum.lms.igor
sleep 5

# Navigate to Feed
echo "👆 Going to Feed..."
xcrun simctl ui "iPhone 16 Pro" tap 302 791 2>/dev/null || echo "  (Feed tab)"
sleep 3

# Take screenshot of Feed
echo "📸 Feed screen..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_diagnostics_1.png

# Tap diagnostics button (orange stethoscope)
echo "👆 Opening diagnostics..."
xcrun simctl ui "iPhone 16 Pro" tap 330 145 2>/dev/null || echo "  (diagnostics button)"
sleep 3

# Take screenshot of diagnostics
echo "📸 Diagnostics screen..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_diagnostics_2.png

echo ""
echo "✅ Opening diagnostics screenshots..."
open /tmp/feed_diagnostics_1.png /tmp/feed_diagnostics_2.png 