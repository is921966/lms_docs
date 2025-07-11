#!/bin/bash

echo "🔧 Комплексное исправление всех проблем с тестами..."

# 1. Очистка старых результатов
echo "🧹 Очистка старых результатов тестов..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*/
rm -rf build/
rm -rf TestResults/

# 2. Перезапуск симулятора
echo "📱 Перезапуск симулятора..."
xcrun simctl shutdown all
sleep 2

# 3. Запуск нужного симулятора
DEVICE_ID="C0F60722-8F57-46A8-A737-2A1CD8819E8E"
echo "📱 Запуск iPhone 16..."
xcrun simctl boot $DEVICE_ID || echo "Симулятор уже запущен"

# 4. Ожидание загрузки
echo "⏳ Ожидание полной загрузки симулятора..."
while [[ $(xcrun simctl list devices | grep "$DEVICE_ID" | grep -c "Booted") -eq 0 ]]; do
    sleep 1
done
sleep 5  # Дополнительное ожидание для полной инициализации

# 5. Установка приложения
echo "📲 Сборка и установка приложения..."
xcodebuild clean build-for-testing \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -derivedDataPath build \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    -quiet

# 6. Проверка установки
echo "✅ Проверка установки приложения..."
xcrun simctl install $DEVICE_ID build/Build/Products/Debug-iphonesimulator/LMS.app

# 7. Запуск приложения для проверки
echo "🚀 Тестовый запуск приложения..."
xcrun simctl launch $DEVICE_ID ru.tsum.lms.igor
sleep 3

# 8. Остановка приложения
xcrun simctl terminate $DEVICE_ID ru.tsum.lms.igor

echo "✅ Подготовка завершена. Теперь можно запускать тесты." 