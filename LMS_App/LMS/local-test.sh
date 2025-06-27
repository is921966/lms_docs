#!/bin/bash

# Скрипт для локального тестирования LMS на симуляторе
# Использование: ./local-test.sh

echo "🚀 Запуск локального тестирования LMS..."
echo ""

# Переменные
PROJECT="LMS.xcodeproj"
SCHEME="LMS"
SIMULATOR="iPhone 16 Pro"
OS_VERSION="18.5"

# Функция для проверки статуса
check_status() {
    if [ $? -ne 0 ]; then
        echo "❌ $1"
        exit 1
    fi
    echo "✅ $1"
}

# 1. Очистка старых билдов
echo "🧹 Очистка старых билдов..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*
check_status "Очистка завершена"

# 2. Сборка приложения для симулятора
echo "🔨 Сборка приложения..."
echo "   Это может занять несколько минут..."

# Проверяем наличие xcpretty
if command -v xcpretty &> /dev/null; then
    xcodebuild build \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,name=$SIMULATOR,OS=$OS_VERSION" \
        -configuration Debug \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGN_IDENTITY="" \
        ONLY_ACTIVE_ARCH=YES | xcpretty
else
    xcodebuild build \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,name=$SIMULATOR,OS=$OS_VERSION" \
        -configuration Debug \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGN_IDENTITY="" \
        ONLY_ACTIVE_ARCH=YES \
        -quiet
fi

check_status "Сборка завершена"

# 3. Запуск симулятора
echo "📱 Запуск симулятора..."

# Получаем ID устройства
DEVICE_ID=$(xcrun simctl list devices | grep "$SIMULATOR" | grep -oE "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}" | head -1)

if [ -z "$DEVICE_ID" ]; then
    echo "   Создаю новый симулятор..."
    DEVICE_ID=$(xcrun simctl create "$SIMULATOR" "com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro" "com.apple.CoreSimulator.SimRuntime.iOS-18-5")
fi

# Запускаем симулятор если не запущен
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
open -a Simulator

# Ждем загрузки симулятора
echo "⏳ Ожидание загрузки симулятора..."
while [ "$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -c Booted)" -eq 0 ]; do
    sleep 1
done
sleep 3

# 4. Установка приложения
echo "📲 Установка приложения на симулятор..."
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/LMS-*/Build/Products/Debug-iphonesimulator -name "LMS.app" | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ Не удалось найти собранное приложение"
    exit 1
fi

xcrun simctl install "$DEVICE_ID" "$APP_PATH"
check_status "Приложение установлено"

# 5. Запуск приложения
echo "🚀 Запуск приложения..."
xcrun simctl launch "$DEVICE_ID" ru.tsum.lms.igor
check_status "Приложение запущено"

echo ""
echo "✅ Локальное тестирование готово!"
echo ""
echo "📝 Дополнительные команды:"
echo "  - Перезапустить приложение: xcrun simctl launch $DEVICE_ID ru.tsum.lms.igor"
echo "  - Удалить приложение: xcrun simctl uninstall $DEVICE_ID ru.tsum.lms.igor"
echo "  - Сделать скриншот: xcrun simctl io $DEVICE_ID screenshot screenshot.png"
echo "  - Записать видео: xcrun simctl io $DEVICE_ID recordVideo video.mov"
echo ""

# 6. Опционально: запуск UI тестов
read -p "Запустить UI тесты? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧪 Запуск UI тестов..."
    if command -v xcpretty &> /dev/null; then
        xcodebuild test \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "platform=iOS Simulator,id=$DEVICE_ID" \
            -only-testing:LMSUITests \
            | xcpretty
    else
        xcodebuild test \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "platform=iOS Simulator,id=$DEVICE_ID" \
            -only-testing:LMSUITests \
            -quiet
    fi
fi

# Опционально: установка xcpretty
if ! command -v xcpretty &> /dev/null; then
    echo ""
    echo "💡 Совет: установите xcpretty для лучшего форматирования вывода:"
    echo "   gem install xcpretty"
fi 