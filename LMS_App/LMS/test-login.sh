#!/bin/bash

# Test login flow in LMS app

echo "🚀 Запуск LMS приложения для тестирования входа..."
echo ""

# Build the app
echo "📱 Сборка приложения..."
xcodebuild -project LMS.xcodeproj -scheme LMS -destination 'platform=iOS Simulator,name=iPhone 16' -configuration Debug build > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Приложение успешно собрано"
else
    echo "❌ Ошибка сборки приложения"
    exit 1
fi

# Boot simulator
echo "🖥️  Запуск симулятора..."
xcrun simctl boot "iPhone 16" 2>/dev/null || true

# Install app
echo "📲 Установка приложения..."
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "LMS.app" -path "*/Debug-iphonesimulator/*" | head -1)
xcrun simctl install "iPhone 16" "$APP_PATH"

# Launch app
echo "🚀 Запуск приложения..."
xcrun simctl launch "iPhone 16" ru.tsum.lms.igor

# Open simulator
open -a Simulator

echo ""
echo "✅ Приложение запущено!"
echo ""
echo "📝 Инструкция по тестированию входа:"
echo "1. На главном экране нажмите кнопку 'Войти (Dev Mode)'"
echo "2. В модальном окне выберите:"
echo "   - 'Войти как студент' - для входа с ожиданием одобрения"
echo "   - 'Войти как администратор' - для мгновенного доступа"
echo "3. Если вошли как студент, нажмите 'Одобрить себя (Dev)'"
echo "4. После входа вы увидите три вкладки: Обучение, Профиль, Ещё"
echo ""
echo "🔍 Для выхода: Профиль → кнопка 'Выйти' или Ещё → 'Выйти'" 