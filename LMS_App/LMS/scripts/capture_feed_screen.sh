#!/bin/bash

echo "📱 Capturing Feed screen..."

# Navigate to Feed
xcrun simctl io booted screenshot /tmp/feed_screen.png

# Copy to feedback folder with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SCREENSHOT_PATH="/Users/ishirokov/lms_docs/feedback_screenshots/feed_redesign_${TIMESTAMP}.png"
cp /tmp/feed_screen.png "$SCREENSHOT_PATH"

echo "✅ Screenshot saved to: $SCREENSHOT_PATH"
open "$SCREENSHOT_PATH" 