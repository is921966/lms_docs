#!/bin/bash

echo "📱 Navigating to Feed and capturing screen..."

# Navigate to Feed tab
xcrun simctl io booted tap 200 800  # Assuming Feed tab position

# Wait for animation
sleep 2

# Take screenshot
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SCREENSHOT_PATH="/Users/ishirokov/lms_docs/feedback_screenshots/feed_redesign_${TIMESTAMP}.png"
xcrun simctl io booted screenshot "$SCREENSHOT_PATH"

echo "✅ Screenshot saved to: $SCREENSHOT_PATH"
open "$SCREENSHOT_PATH" 