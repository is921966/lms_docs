#!/bin/bash

# Быстрый запуск конкретного UI теста
# Использование: ./test-quick-ui.sh TestClass/testMethod

if [ -z "$1" ]; then
    echo "❌ Ошибка: Укажите тест для запуска"
    echo "Использование: ./test-quick-ui.sh TestClass/testMethod"
    echo "Пример: ./test-quick-ui.sh ComprehensiveUITests/test001_LaunchAndShowLoginScreen"
    exit 1
fi

TEST_PATH="LMSUITests/$1"

echo "🚀 Запуск теста: $TEST_PATH"
echo "⏱️  Начало: $(date +%H:%M:%S)"

# Запускаем тест
if xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -only-testing:"$TEST_PATH" \
    -quiet 2>&1 | grep -E "(Test Case|passed|failed|Executed)"
then
    echo "✅ Тест прошел успешно!"
    echo "⏱️  Конец: $(date +%H:%M:%S)"
    exit 0
else
    echo "❌ Тест провалился!"
    echo "⏱️  Конец: $(date +%H:%M:%S)"
    
    # Показываем последние логи
    echo ""
    echo "📋 Последние строки лога:"
    xcodebuild test \
        -scheme LMS \
        -destination 'platform=iOS Simulator,name=iPhone 16' \
        -only-testing:"$TEST_PATH" \
        2>&1 | tail -30
    
    exit 1
fi 