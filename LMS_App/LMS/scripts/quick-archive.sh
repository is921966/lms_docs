#!/bin/bash

echo "🚀 Быстрое создание архива для TestFlight..."
echo "=========================================="
echo ""

# Обновляем версию
echo "📱 Обновление версии до 2.1.1 (Build 205)..."
agvtool new-marketing-version 2.1.1
agvtool new-version -all 205

# Очищаем build folder
echo "🧹 Очистка старых сборок..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*

# Создаем архив
echo "📦 Создание архива..."
echo ""

xcodebuild -scheme LMS \
    -configuration Release \
    -sdk iphoneos \
    -archivePath ~/Desktop/LMS_TestFlight.xcarchive \
    clean archive \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM=8Y7XSRU6LB

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Архив успешно создан!"
    echo "📍 Расположение: ~/Desktop/LMS_TestFlight.xcarchive"
    echo ""
    echo "🎯 Следующие шаги:"
    echo "1. Откройте Xcode"
    echo "2. Window → Organizer (⌘⇧2)"
    echo "3. Выберите новый архив LMS"
    echo "4. Нажмите 'Distribute App'"
    echo "5. Выберите 'App Store Connect' → Upload"
else
    echo ""
    echo "❌ Ошибка при создании архива!"
    echo ""
    echo "Попробуйте создать архив через Xcode:"
    echo "1. Откройте LMS.xcodeproj"
    echo "2. Выберите схему LMS и устройство 'Any iOS Device'"
    echo "3. Product → Archive"
fi 