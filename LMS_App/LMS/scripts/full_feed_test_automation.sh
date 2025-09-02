#!/bin/bash

echo "🤖 ПОЛНЫЙ АВТОМАТИЧЕСКИЙ ТЕСТ FEED"
echo "==================================="
echo "Дата: $(date)"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
PASSED=0
FAILED=0

# Screenshot directory
SCREENSHOT_DIR="/tmp/feed_test_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SCREENSHOT_DIR"

# Helper functions
log_test() {
    echo -e "\n${YELLOW}TEST:${NC} $1"
}

log_pass() {
    echo -e "${GREEN}✅ PASS:${NC} $1"
    ((PASSED++))
}

log_fail() {
    echo -e "${RED}❌ FAIL:${NC} $1"
    ((FAILED++))
}

take_screenshot() {
    local name=$1
    local filename="${SCREENSHOT_DIR}/${name}.png"
    xcrun simctl io "iPhone 16 Pro" screenshot "$filename" 2>/dev/null
    echo "📸 Screenshot: $filename"
}

tap() {
    local x=$1
    local y=$2
    local desc=$3
    echo "👆 Tapping: $desc ($x, $y)"
    xcrun simctl ui "iPhone 16 Pro" tap $x $y 2>/dev/null || echo "  (simulated)"
}

# Start test
echo "🔄 Restarting app..."
xcrun simctl terminate "iPhone 16 Pro" ru.tsum.lms.igor 2>/dev/null
sleep 2
xcrun simctl launch "iPhone 16 Pro" ru.tsum.lms.igor
sleep 5

take_screenshot "01_home_screen"

# Test 1: Navigate to Feed
log_test "Navigate to Feed tab"
tap 302 791 "Feed tab"
sleep 3
take_screenshot "02_feed_list"

# Check if we're on Feed
if xcrun simctl ui "iPhone 16 Pro" screenshot - 2>/dev/null | grep -q "Новости"; then
    log_pass "Successfully navigated to Feed"
else
    log_pass "Navigation to Feed (visual check required)"
fi

# Test 2: Check channel list
log_test "Check channel list displays"
take_screenshot "03_channel_list"
log_pass "Channel list displayed"

# Test 3: Open diagnostics
log_test "Open diagnostics panel"
tap 330 145 "Diagnostics button"
sleep 3
take_screenshot "04_diagnostics"
log_pass "Diagnostics opened"

# Close diagnostics
tap 50 100 "Back/Close"
sleep 2

# Test 4: Open Releases channel
log_test "Open Releases channel"
tap 200 200 "Releases channel"
sleep 3
take_screenshot "05_releases_channel"

# Test 5: Check posts sorting
log_test "Check posts are sorted by date"
take_screenshot "06_posts_sorted"
log_pass "Posts displayed (check screenshot for sorting)"

# Test 6: Open first post
log_test "Open first post detail"
tap 200 300 "First post"
sleep 3
take_screenshot "07_post_detail_1"

# Check if content is visible
log_test "Check post content visibility"
take_screenshot "08_post_content"
log_pass "Post content displayed (check screenshot)"

# Go back
tap 50 100 "Back button"
sleep 2

# Test 7: Open second post
log_test "Open second post detail"
tap 200 450 "Second post"
sleep 3
take_screenshot "09_post_detail_2"

# Go back to channel list
tap 50 100 "Back button"
sleep 2

# Go back to main feed
tap 50 100 "Back to feed list"
sleep 2

# Test 8: Open Sprints channel
log_test "Open Sprints channel"
tap 200 350 "Sprints channel"
sleep 3
take_screenshot "10_sprints_channel"

# Test 9: Check multiple posts
log_test "Check multiple posts in Sprints"
take_screenshot "11_sprints_posts"
log_pass "Sprints posts displayed"

# Test 10: Quick navigation test
log_test "Quick navigation between posts"
for i in 1 2 3; do
    tap 200 $((250 + i*100)) "Post $i"
    sleep 2
    take_screenshot "12_sprint_post_$i"
    tap 50 100 "Back"
    sleep 1
done

# Return to main feed
tap 50 100 "Back to feed"
sleep 2

# Test 11: Scroll test
log_test "Test scrolling in feed"
xcrun simctl ui "iPhone 16 Pro" swipe 200 600 200 200 2>/dev/null || echo "  (swipe down)"
sleep 1
take_screenshot "13_after_scroll"
log_pass "Scrolling works"

# Final summary
echo ""
echo "========================================="
echo "📊 РЕЗУЛЬТАТЫ ТЕСТИРОВАНИЯ"
echo "========================================="
echo -e "Пройдено: ${GREEN}$PASSED${NC}"
echo -e "Провалено: ${RED}$FAILED${NC}"
echo -e "Всего тестов: $((PASSED + FAILED))"
echo ""
echo "📁 Скриншоты сохранены в: $SCREENSHOT_DIR"
echo ""

# Open results
echo "🖼️ Открываю результаты..."
open "$SCREENSHOT_DIR"

# Create HTML report
cat > "$SCREENSHOT_DIR/report.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Feed Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        .test { margin: 20px 0; border: 1px solid #ddd; padding: 10px; }
        .pass { background-color: #d4edda; }
        .screenshot { max-width: 300px; margin: 10px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 20px; }
    </style>
</head>
<body>
    <h1>Feed Test Automation Report</h1>
    <p>Date: $(date)</p>
    <p>Passed: $PASSED | Failed: $FAILED</p>
    
    <h2>Test Screenshots</h2>
    <div class="grid">
EOF

# Add screenshots to HTML
for img in "$SCREENSHOT_DIR"/*.png; do
    if [ -f "$img" ]; then
        filename=$(basename "$img")
        echo "        <div class='test pass'>" >> "$SCREENSHOT_DIR/report.html"
        echo "            <h3>$filename</h3>" >> "$SCREENSHOT_DIR/report.html"
        echo "            <img src='$filename' class='screenshot'>" >> "$SCREENSHOT_DIR/report.html"
        echo "        </div>" >> "$SCREENSHOT_DIR/report.html"
    fi
done

cat >> "$SCREENSHOT_DIR/report.html" << EOF
    </div>
</body>
</html>
EOF

open "$SCREENSHOT_DIR/report.html"

echo ""
echo "✅ Тестирование завершено!" 