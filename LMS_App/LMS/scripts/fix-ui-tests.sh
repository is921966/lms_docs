#!/bin/bash

echo "🔧 Исправление конфигурации UI тестов..."

# 1. Убедимся, что симулятор запущен
echo "📱 Проверка симулятора..."
DEVICE_ID="C0F60722-8F57-46A8-A737-2A1CD8819E8E"
xcrun simctl boot $DEVICE_ID 2>/dev/null || echo "Симулятор уже запущен"

# 2. Ждем полной загрузки
echo "⏳ Ожидание загрузки симулятора..."
while [[ $(xcrun simctl list devices | grep "$DEVICE_ID" | grep -c "Booted") -eq 0 ]]; do
    sleep 1
done
echo "✅ Симулятор готов"

# 3. Установим приложение на симулятор
echo "📲 Установка приложения..."
xcodebuild install-for-testing \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -derivedDataPath build

# 4. Запустим простой UI тест для проверки
echo "🧪 Запуск тестового UI теста..."
xcodebuild test \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -only-testing:LMSUITests/SimpleSmokeTest/testAppLaunches \
    -derivedDataPath build \
    -enableCodeCoverage YES

echo "✅ Конфигурация завершена" 