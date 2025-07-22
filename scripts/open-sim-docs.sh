#!/bin/bash

# Простой скрипт для открытия папки Documents симулятора LMS

echo "🔍 Открываю папку Documents симулятора LMS..."

# Получаем путь и открываем
DATA_PATH=$(xcrun simctl get_app_container booted ru.tsum.lms.igor data 2>/dev/null)

if [ -z "$DATA_PATH" ]; then
    echo "❌ Ошибка: Симулятор не запущен или приложение LMS не установлено"
    echo "💡 Запустите симулятор и приложение LMS"
    exit 1
fi

DOCS_PATH="${DATA_PATH}/Documents"

echo "📁 Путь: $DOCS_PATH"
echo ""
echo "📄 CSV файлы:"
ls -la "$DOCS_PATH"/*.csv 2>/dev/null || echo "   Пока нет CSV файлов"

echo ""
echo "🚀 Открываю в Finder..."
open "$DOCS_PATH" 