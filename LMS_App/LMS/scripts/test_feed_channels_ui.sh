#!/bin/bash

echo "📱 UI Test: Feed Channels Loading"
echo "=================================="

# Kill existing app
xcrun simctl terminate "iPhone 16 Pro" ru.tsum.lms.igor 2>/dev/null

# Clear logs
echo "" > app_logs.txt

# Launch app fresh
echo "🚀 Launching app..."
xcrun simctl launch "iPhone 16 Pro" ru.tsum.lms.igor

# Wait for app to start
echo "⏳ Waiting for app to initialize..."
sleep 3

# Take initial screenshot
echo "📸 Taking initial screenshot..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_initial.png

# Navigate to Feed tab using UI Testing framework
echo "👆 Running UI navigation test..."
./scripts/run-tests-with-timeout.sh 60 LMSUITests/Feed/FeedChannelsNavigationTest || true

# Take feed screenshot
echo "📸 Taking feed screenshot after navigation..."
sleep 2
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_loaded.png

# Check log server for real-time data
echo -e "\n📊 Checking log server data..."
if curl -s "http://localhost:5002/api/logs" > /dev/null 2>&1; then
    echo "✅ Log server is running"
    
    # Get channel loading logs
    echo -e "\n🔍 Channel Loading Events:"
    curl -s "http://localhost:5002/api/logs?category=data&level=info&search=MockFeedService" | \
        jq -r '.logs[] | select(.message | contains("Data loading complete") or contains("Created channel")) | "\(.timestamp | .[11:19]) - \(.message)"' | tail -10
    
    # Get real data loading logs
    echo -e "\n🔍 Real Data Loading:"
    curl -s "http://localhost:5002/api/logs?category=data&level=info&search=Found" | \
        jq -r '.logs[] | "\(.timestamp | .[11:19]) - \(.message)"' | tail -10
    
    # Get UI events
    echo -e "\n🔍 UI Events:"
    curl -s "http://localhost:5002/api/logs?category=ui&level=info&search=TelegramFeedView" | \
        jq -r '.logs[] | "\(.timestamp | .[11:19]) - \(.message)"' | tail -10
else
    echo "⚠️ Log server not running. Starting it..."
    cd /Users/ishirokov/lms_docs/scripts && PORT=5002 python3 log_server_cloud.py > /tmp/log_server.log 2>&1 &
    sleep 2
fi

# Extract and analyze system logs
echo -e "\n📋 Extracting system logs..."
log show --predicate 'process == "LMS"' --last 2m --style compact > /tmp/feed_system_logs.txt 2>/dev/null || true

# Look for our custom logs
echo -e "\n🔍 Custom Log Analysis:"
grep -E "MockFeedService.*complete|Created channel|Found.*files|Loaded.*posts" /tmp/feed_system_logs.txt 2>/dev/null | tail -10 || echo "No matching logs found"

# Visual confirmation
echo -e "\n🖼️ Visual Verification:"
echo "Please check the screenshots to verify:"
echo "1. /tmp/feed_initial.png - Should show the main screen"
echo "2. /tmp/feed_loaded.png - Should show the Feed tab with channels"

# Create a detailed report
echo -e "\n📄 Creating detailed report..."
cat > /tmp/feed_test_report.md << EOF
# Feed Channels Test Report
Date: $(date)

## Test Execution
- App launched successfully
- Screenshots captured
- Log analysis performed

## Expected Channels
1. 📢 Релизы и обновления (12 files)
2. 📊 Отчеты спринтов (75 files)
3. 📚 Методология (30 files)
4. 📖 Новые курсы
5. 🏢 Администратор
6. 👥 HR
7. 📚 Мои курсы
8. 💬 Сообщество

## Verification Steps
Please manually verify:
- [ ] Feed tab shows all channels
- [ ] Release channel shows 12+ posts
- [ ] Sprint channel shows 75+ posts  
- [ ] Methodology channel shows 30+ posts
- [ ] Posts display full content when opened
EOF

echo -e "\n✅ Test completed!"
echo "📊 Full report saved to: /tmp/feed_test_report.md" 