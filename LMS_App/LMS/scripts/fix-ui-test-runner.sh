#!/bin/bash

echo "🔧 Исправление UI Test Runner..."

# 1. Убедимся, что симулятор запущен
DEVICE_ID="C0F60722-8F57-46A8-A737-2A1CD8819E8E"
xcrun simctl boot $DEVICE_ID 2>/dev/null || echo "Симулятор уже запущен"

# 2. Удаляем старое приложение test runner
echo "🗑️  Удаление старого test runner..."
xcrun simctl uninstall $DEVICE_ID ru.tsum.LMSUITests.xctrunner 2>/dev/null || true

# 3. Очищаем DerivedData
echo "🧹 Очистка DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*/

# 4. Пересобираем с правильными настройками
echo "🔨 Пересборка тестов..."
xcodebuild clean build-for-testing \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -derivedDataPath build \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    DEVELOPMENT_TEAM="" \
    -quiet || { echo "❌ Ошибка сборки"; exit 1; }

# 5. Проверяем, что test runner создан
echo "✅ Проверка test runner..."
if [ -d "build/Build/Products/Debug-iphonesimulator/LMSUITests-Runner.app" ]; then
    echo "✅ Test runner найден"
    
    # 6. Устанавливаем test runner
    echo "📲 Установка test runner..."
    xcrun simctl install $DEVICE_ID build/Build/Products/Debug-iphonesimulator/LMSUITests-Runner.app
    
    # 7. Проверяем установку
    if xcrun simctl listapps $DEVICE_ID | grep -q "ru.tsum.LMSUITests.xctrunner"; then
        echo "✅ Test runner успешно установлен!"
    else
        echo "❌ Test runner не установлен"
        exit 1
    fi
else
    echo "❌ Test runner не найден в build директории"
    exit 1
fi

echo "✅ Готово! Теперь UI тесты должны работать." 