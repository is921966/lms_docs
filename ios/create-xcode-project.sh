#!/bin/bash

echo "🔧 Создание Xcode проекта для LMS"
echo "================================="

cd /Users/ishirokov/lms_docs/ios/LMS

# Генерируем Xcode проект из Package.swift
echo "📦 Генерация проекта из Swift Package..."
swift package generate-xcodeproj

if [ $? -eq 0 ]; then
    echo "✅ Проект успешно создан!"
    echo ""
    echo "Теперь вы можете открыть проект:"
    echo "  open LMS.xcodeproj"
    echo ""
    echo "Или использовать Swift Package напрямую:"
    echo "  open Package.swift"
else
    echo "❌ Ошибка при создании проекта"
    echo ""
    echo "Альтернативный вариант - создать проект в Xcode:"
    echo "1. Откройте Xcode"
    echo "2. File → New → Project"
    echo "3. iOS → App"
    echo "4. Product Name: LMS"
    echo "5. Bundle Identifier: ru.tsum.lms"
    echo "6. Team: выберите ваш Team"
fi 