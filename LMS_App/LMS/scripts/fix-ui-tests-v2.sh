#!/bin/bash

echo "🔧 Улучшенное исправление UI тестов v2..."
echo "=========================================="

DEVICE_ID="C0F60722-8F57-46A8-A737-2A1CD8819E8E"

# 1. Убедимся что симулятор запущен
echo "📱 Проверка симулятора..."
if ! xcrun simctl list devices | grep "$DEVICE_ID" | grep -q "Booted"; then
    echo "🚀 Запуск симулятора..."
    xcrun simctl boot $DEVICE_ID
    sleep 10
fi

# 2. Очистка старых установок
echo "🧹 Очистка старых установок..."
xcrun simctl uninstall $DEVICE_ID ru.tsum.lms.igor 2>/dev/null || true
xcrun simctl uninstall $DEVICE_ID ru.tsum.LMSUITests 2>/dev/null || true
xcrun simctl uninstall $DEVICE_ID ru.tsum.LMSUITests.xctrunner 2>/dev/null || true

# 3. Пересборка с чистого листа
echo "🔨 Чистая пересборка..."
xcodebuild clean \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -quiet

xcodebuild build-for-testing \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -derivedDataPath build \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    DEVELOPMENT_TEAM="" \
    -quiet || { echo "❌ Ошибка сборки"; exit 1; }

# 4. Установка основного приложения
echo "📲 Установка основного приложения..."
if [ -d "build/Build/Products/Debug-iphonesimulator/LMS.app" ]; then
    xcrun simctl install $DEVICE_ID build/Build/Products/Debug-iphonesimulator/LMS.app
    echo "✅ Основное приложение установлено"
else
    echo "❌ Основное приложение не найдено"
    exit 1
fi

# 5. Установка test runner
echo "📲 Установка UI test runner..."
if [ -d "build/Build/Products/Debug-iphonesimulator/LMSUITests-Runner.app" ]; then
    xcrun simctl install $DEVICE_ID build/Build/Products/Debug-iphonesimulator/LMSUITests-Runner.app
    echo "✅ Test runner установлен"
else
    echo "❌ Test runner не найден"
    exit 1
fi

# 6. Проверка установки
echo "🔍 Проверка установленных приложений..."
echo "Установленные приложения LMS:"
xcrun simctl listapps $DEVICE_ID | grep -i "ru.tsum" | grep -E "(BundleID|DisplayName)" || echo "Приложения не найдены"

# 7. Тестовый запуск одного UI теста
echo ""
echo "🧪 Тестовый запуск простого UI теста..."
xcodebuild test \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -only-testing:LMSUITests/BasicLoginTest/testJustLaunchApp \
    -test-timeouts-enabled NO \
    2>&1 | grep -E "(Test case|passed|failed|error)" | tail -20

echo ""
echo "✅ Настройка завершена!" 