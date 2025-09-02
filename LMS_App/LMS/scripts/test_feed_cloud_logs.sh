#!/bin/bash

echo "📱 Feed Channels Cloud Test"
echo "==========================="
echo "Тестирование каналов новостей с облачным сервером логов"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Cloud server URL
CLOUD_LOG_SERVER="https://lms-log-server-production.up.railway.app"

# Function to check cloud logs
check_cloud_logs() {
    local search_term=$1
    echo -e "${YELLOW}🔍 Проверяем логи для: $search_term${NC}"
    
    local response=$(curl -s "${CLOUD_LOG_SERVER}/api/logs?search=${search_term}")
    local count=$(echo "$response" | jq -r '.logs | length' 2>/dev/null || echo "0")
    
    if [ "$count" -gt 0 ]; then
        echo -e "${GREEN}✅ Найдено $count записей${NC}"
        echo "$response" | jq -r '.logs[:3] | .[] | "\(.timestamp) - \(.event // .message)"' 2>/dev/null || echo "Ошибка парсинга JSON"
    else
        echo -e "${RED}❌ Записи не найдены${NC}"
    fi
    echo ""
}

# Step 1: Kill and restart app
echo "🔄 Перезапускаем приложение..."
xcrun simctl terminate "iPhone 16 Pro" ru.tsum.lms.igor 2>/dev/null
sleep 2
xcrun simctl launch "iPhone 16 Pro" ru.tsum.lms.igor
sleep 5

# Step 2: Take initial screenshot
echo "📸 Создаем скриншот главного экрана..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_test_main.png

# Step 3: Check initial logs
echo ""
echo "📊 Проверяем начальные логи..."
check_cloud_logs "TelegramFeedView"
check_cloud_logs "MockFeedService"
check_cloud_logs "loadReleaseNotes"

# Step 4: Navigate to Feed via UI test
echo "🧪 Запускаем UI тест для навигации к Feed..."
cd /Users/ishirokov/lms_docs/LMS_App/LMS

# Create a minimal UI test that navigates to Feed
cat > LMSUITests/FeedCloudTestNavigation.swift << 'EOF'
import XCTest

final class FeedCloudTestNavigation: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func test_navigateToFeedAndWait() throws {
        // Wait for tab bar
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // Tap Feed tab
        let feedTab = tabBar.buttons["Новости"]
        XCTAssertTrue(feedTab.exists)
        feedTab.tap()
        
        // Wait for Feed screen
        sleep(3)
        
        // Take screenshot
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Feed_Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Keep app open for a bit to let logs upload
        sleep(10)
    }
}
EOF

# Run the test
echo "Запускаем UI тест..."
xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -only-testing:LMSUITests/FeedCloudTestNavigation/test_navigateToFeedAndWait \
    2>&1 | grep -E "(Test Case|Passed|Failed)" || true

# Step 5: Wait for logs to upload (30 seconds cycle)
echo ""
echo "⏳ Ожидаем загрузку логов (35 секунд)..."
sleep 35

# Step 6: Check logs after navigation
echo ""
echo "📊 Проверяем логи после навигации..."
check_cloud_logs "TelegramFeedView appeared"
check_cloud_logs "Channel in Feed"
check_cloud_logs "=== Starting"
check_cloud_logs "Found.*files"

# Step 7: Get all recent logs
echo ""
echo "📋 Последние 10 логов с сервера:"
curl -s "${CLOUD_LOG_SERVER}/api/logs" | jq -r '.logs[:10] | .[] | "\(.timestamp | .[11:19]) [\(.category)] \(.event // .message // "unknown")"' 2>/dev/null || echo "Ошибка получения логов"

# Step 8: Check specific categories
echo ""
echo "📊 Логи по категориям:"
echo -e "${YELLOW}Data logs:${NC}"
curl -s "${CLOUD_LOG_SERVER}/api/logs?category=data" | jq -r '.logs | length' 2>/dev/null | xargs -I {} echo "Найдено {} записей"

echo -e "${YELLOW}UI logs:${NC}"
curl -s "${CLOUD_LOG_SERVER}/api/logs?category=ui" | jq -r '.logs | length' 2>/dev/null | xargs -I {} echo "Найдено {} записей"

# Step 9: Save full log dump
echo ""
echo "💾 Сохраняем полный дамп логов..."
curl -s "${CLOUD_LOG_SERVER}/api/logs" > /tmp/feed_cloud_logs_dump.json
echo "Сохранено в /tmp/feed_cloud_logs_dump.json"

# Final summary
echo ""
echo "========== ИТОГИ ТЕСТА =========="
echo "✅ Приложение запущено"
echo "✅ UI тест выполнен"
echo "✅ Логи проверены на облачном сервере"
echo "📸 Скриншоты: /tmp/feed_test_main.png"
echo "📋 Дамп логов: /tmp/feed_cloud_logs_dump.json"
echo "🔗 Облачный сервер: ${CLOUD_LOG_SERVER}"
echo "=================================" 