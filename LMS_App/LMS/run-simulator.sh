#!/bin/bash

echo "🚀 Запуск LMS в симуляторе..."

# Очистка DerivedData
echo "🧹 Очистка кэша..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*

# ID симулятора iPhone 16 Pro
SIMULATOR_ID="899AAE09-580D-4FF5-BF16-3574382CD796"

# Запуск симулятора если не запущен
echo "📱 Запуск симулятора..."
xcrun simctl boot $SIMULATOR_ID 2>/dev/null || true
open -a Simulator

# Ожидание запуска симулятора
echo "⏳ Ожидание запуска симулятора..."
sleep 3

# Сборка и установка
echo "🔨 Сборка приложения..."
xcodebuild -project LMS.xcodeproj \
    -scheme LMS \
    -configuration Debug \
    -destination "id=$SIMULATOR_ID" \
    -derivedDataPath build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    -allowProvisioningUpdates \
    build

if [ $? -eq 0 ]; then
    echo "✅ Сборка успешна!"
    
    # Получаем путь к app
    APP_PATH=$(find build/Build/Products -name "LMS.app" -type d | head -1)
    
    if [ -n "$APP_PATH" ]; then
        echo "📲 Установка приложения..."
        xcrun simctl install $SIMULATOR_ID "$APP_PATH"
        
        echo "🚀 Запуск приложения..."
        xcrun simctl launch $SIMULATOR_ID ru.tsum.lms.igor
        
        echo "✅ Приложение запущено!"
    else
        echo "❌ Не удалось найти собранное приложение"
        exit 1
    fi
else
    echo "❌ Ошибка сборки. Проверьте вывод выше."
    exit 1
fi 