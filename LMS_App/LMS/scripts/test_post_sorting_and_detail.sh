#!/bin/bash

echo "📱 Testing Post Sorting and Detail View"
echo "======================================="

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

# Open releases channel
echo "👆 Opening Releases channel..."
xcrun simctl ui "iPhone 16 Pro" tap 200 200 2>/dev/null || echo "  (Releases channel)"
sleep 3

# Take screenshot of posts list
echo "📸 Posts list (check sorting by date)..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/posts_list_sorted.png

# Tap first post
echo "👆 Opening first post..."
xcrun simctl ui "iPhone 16 Pro" tap 200 300 2>/dev/null || echo "  (First post)"
sleep 3

# Take screenshot of post detail
echo "📸 Post detail (check content visibility)..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/post_detail_content.png

# Go back
echo "👆 Going back..."
xcrun simctl ui "iPhone 16 Pro" tap 50 100 2>/dev/null || echo "  (Back button)"
sleep 2

# Tap second post
echo "👆 Opening second post..."
xcrun simctl ui "iPhone 16 Pro" tap 200 450 2>/dev/null || echo "  (Second post)"
sleep 3

# Take screenshot
echo "📸 Second post detail..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/post_detail_content_2.png

echo ""
echo "✅ Opening screenshots..."
open /tmp/posts_list_sorted.png /tmp/post_detail_content.png /tmp/post_detail_content_2.png

echo ""
echo "🔍 Check:"
echo "1. Posts are sorted by date (newest first)"
echo "2. Post detail shows actual content (not empty)"
echo "3. Navigation works correctly" 