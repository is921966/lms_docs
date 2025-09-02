#!/bin/bash

echo "🧪 Feed UI Test"
echo "==============="
echo "Запуск UI тестов для проверки каналов"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Ensure simulator is booted
echo "📱 Подготовка симулятора..."
xcrun simctl boot "iPhone 16 Pro" 2>/dev/null || true
sleep 2

# Run specific UI test
echo "🧪 Запускаем UI тест..."
xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -only-testing:LMSUITests/FeedChannelsUITest/test_feedChannels_checkAllChannelsExist \
    -quiet \
    2>&1 | tee /tmp/feed_ui_test.log

# Check results
if grep -q "Test Suite 'FeedChannelsUITest' passed" /tmp/feed_ui_test.log; then
    echo -e "${GREEN}✅ UI тест пройден успешно!${NC}"
else
    echo -e "${RED}❌ UI тест провален${NC}"
    echo "Показываем последние 50 строк лога:"
    tail -50 /tmp/feed_ui_test.log
fi

# Extract test results
echo ""
echo "📊 Результаты теста:"
grep -E "(✅ Found channel:|Missing:|Expected:|Found:)" /tmp/feed_ui_test.log || echo "Результаты не найдены"

echo ""
echo "✅ Тест завершен" 