#!/bin/bash

# Простой скрипт для запуска UI тестов
# Использует xcodebuild напрямую без сложной логики

echo "🧪 Запуск UI тестов..."

# Запускаем тесты
xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' \
    -only-testing:LMSUITests \
    2>&1 | grep -E "(Test Case|passed|failed|error:|Executed)"

# Проверяем результат
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✅ Все тесты прошли успешно!"
    exit 0
else
    echo "❌ Тесты провалились!"
    exit 1
fi 