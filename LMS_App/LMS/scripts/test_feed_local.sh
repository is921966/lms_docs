#!/bin/bash

echo "📱 Feed Channels Local Test"
echo "=========================="
echo "Тестирование каналов новостей с локальными логами"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Kill any existing app
echo "🔄 Перезапускаем приложение..."
xcrun simctl terminate "iPhone 16 Pro" ru.tsum.lms.igor 2>/dev/null
sleep 2

# Start log streaming in background
echo "📋 Запускаем мониторинг логов..."
xcrun simctl spawn "iPhone 16 Pro" log stream --predicate 'process == "LMS"' --style compact > /tmp/feed_logs.txt 2>&1 &
LOG_PID=$!
echo "Log streaming PID: $LOG_PID"

# Launch app
echo "🚀 Запускаем приложение..."
xcrun simctl launch "iPhone 16 Pro" ru.tsum.lms.igor
sleep 5

# Take screenshot
echo "📸 Скриншот главного экрана..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_main.png

# Create simple UI test that navigates to Feed
echo "🧪 Создаем простой UI тест..."
cat > LMSUITests/FeedLocalNavigationTest.swift << 'EOF'
import XCTest

final class FeedLocalNavigationTest: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func test_navigateToFeedAndCheckChannels() throws {
        // Wait for app
        sleep(2)
        
        // Find and tap Feed tab
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        let feedTab = tabBar.buttons["Новости"]
        if feedTab.exists {
            feedTab.tap()
            print("✅ Tapped Feed tab")
        } else {
            print("❌ Feed tab not found")
            // Try by index
            let tabs = tabBar.buttons
            if tabs.count > 1 {
                tabs.element(boundBy: 1).tap()
                print("✅ Tapped tab by index")
            }
        }
        
        // Wait for Feed screen
        sleep(3)
        
        // Look for channel cells
        let channelCells = app.cells
        print("📊 Found \(channelCells.count) cells")
        
        // Take screenshot
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Feed_Screen_With_Channels"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Check for specific text
        if app.staticTexts["Релизы и обновления"].exists {
            print("✅ Found 'Релизы и обновления' channel")
        }
        if app.staticTexts["Отчеты спринтов"].exists {
            print("✅ Found 'Отчеты спринтов' channel")
        }
        if app.staticTexts["Методология"].exists {
            print("✅ Found 'Методология' channel")
        }
        
        sleep(5) // Keep app open for logs
    }
}
EOF

# Run the UI test
echo ""
echo "🧪 Запускаем UI тест..."
xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -only-testing:LMSUITests/FeedLocalNavigationTest/test_navigateToFeedAndCheckChannels \
    -resultBundlePath /tmp/FeedTestResults.xcresult \
    2>&1 | grep -E "(Test Case|Passed|Failed|✅|❌|📊)" || true

# Kill log streaming
sleep 2
kill $LOG_PID 2>/dev/null

# Analyze logs
echo ""
echo "📊 Анализ логов..."
echo ""

# Check for specific log entries
echo -e "${YELLOW}=== TelegramFeedView logs ===${NC}"
grep -E "TelegramFeedView|FeedView" /tmp/feed_logs.txt | tail -10

echo ""
echo -e "${YELLOW}=== MockFeedService logs ===${NC}"
grep -E "MockFeedService|loadMockData" /tmp/feed_logs.txt | tail -10

echo ""
echo -e "${YELLOW}=== RealDataFeedService logs ===${NC}"
grep -E "RealDataFeedService|loadReleaseNotes|loadSprintReports|loadMethodologyUpdates" /tmp/feed_logs.txt | tail -10

echo ""
echo -e "${YELLOW}=== Channel loading logs ===${NC}"
grep -E "Channel|channels|Found.*files|Loaded.*posts" /tmp/feed_logs.txt | tail -10

# Count channels
echo ""
echo "📈 Статистика:"
echo -n "- Логи TelegramFeedView: "
grep -c "TelegramFeedView" /tmp/feed_logs.txt || echo "0"
echo -n "- Логи MockFeedService: "
grep -c "MockFeedService" /tmp/feed_logs.txt || echo "0"
echo -n "- Логи загрузки файлов: "
grep -c "Found.*files" /tmp/feed_logs.txt || echo "0"
echo -n "- Логи каналов: "
grep -c "Channel" /tmp/feed_logs.txt || echo "0"

# Save full logs
echo ""
echo "💾 Сохраняем полные логи..."
cp /tmp/feed_logs.txt /tmp/feed_logs_full_$(date +%Y%m%d_%H%M%S).txt

# Take final screenshot
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_final.png

echo ""
echo "========== ИТОГИ ТЕСТА =========="
echo "✅ Приложение протестировано"
echo "📸 Скриншоты:"
echo "   - /tmp/feed_main.png (главный экран)"
echo "   - /tmp/feed_final.png (экран Feed)"
echo "📋 Логи: /tmp/feed_logs.txt"
echo "🧪 Результаты тестов: /tmp/FeedTestResults.xcresult"
echo "=================================" 