#!/bin/bash

# Скрипт для открытия папки Documents симулятора LMS в Finder

echo "🔍 Поиск папки Documents симулятора LMS..."

# Находим путь к контейнеру данных приложения
APP_CONTAINER=$(xcrun simctl get_app_container booted ru.tsum.lms.igor data 2>/dev/null | tr -d '\n')

if [ -z "$APP_CONTAINER" ]; then
    echo "❌ Ошибка: Симулятор не запущен или приложение не установлено"
    echo "💡 Запустите симулятор и приложение LMS"
    exit 1
fi

DOCUMENTS_PATH="$APP_CONTAINER/Documents"

if [ -d "$DOCUMENTS_PATH" ]; then
    echo "✅ Найдена папка Documents:"
    echo "📁 $DOCUMENTS_PATH"
    
    # Показываем список CSV файлов
    echo ""
    echo "📄 CSV файлы в папке:"
    ls -la "$DOCUMENTS_PATH"/*.csv 2>/dev/null || echo "   Пока нет CSV файлов"
    
    # Открываем в Finder
    echo ""
    echo "🚀 Открываю в Finder..."
    open "$DOCUMENTS_PATH"
else
    echo "❌ Папка Documents не найдена"
    echo "📁 Проверен путь: $DOCUMENTS_PATH"
    exit 1
fi 