#!/bin/bash
echo "Checking Developer Tools in Settings..."

# Делаем скриншот текущего экрана
echo "Taking initial screenshot..."
xcrun simctl io 899AAE09-580D-4FF5-BF16-3574382CD796 screenshot /tmp/screen1.png

# Сохраняем скриншот с описанием
cp /tmp/screen1.png /Users/ishirokov/lms_docs/feedback_screenshots/developer_tools_check_$(date +%Y%m%d_%H%M%S).png

echo "Screenshot saved to feedback_screenshots/"
echo "Please manually navigate to Settings > Developer Tools in the simulator"
echo "The app is running in Debug mode, so Developer Tools should be visible"
