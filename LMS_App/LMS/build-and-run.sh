#!/bin/bash

echo "🧹 Очистка проекта..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*
xcodebuild clean -project LMS.xcodeproj -scheme LMS -quiet

echo "🔨 Сборка проекта..."
xcodebuild -project LMS.xcodeproj \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -configuration Debug \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    -quiet | xcpretty --color --simple

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✅ Сборка успешна!"
    
    # Запуск симулятора
    echo "📱 Запуск симулятора..."
    xcrun simctl boot "iPhone 16 Pro" 2>/dev/null || true
    open -a Simulator
    
    # Установка и запуск приложения
    echo "🚀 Запуск приложения..."
    xcrun simctl install booted "$(find ~/Library/Developer/Xcode/DerivedData -name 'LMS.app' | head -1)"
    xcrun simctl launch booted ru.tsum.lms.igor
    
    echo "✅ Приложение запущено!"
else
    echo "❌ Ошибка сборки"
    exit 1
fi 