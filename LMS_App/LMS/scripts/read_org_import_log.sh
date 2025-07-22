#!/bin/bash

# Получаем контейнер приложения
APP_CONTAINER=$(xcrun simctl get_app_container "iPhone 16" ru.tsum.lms.igor data 2>/dev/null)

if [ -z "$APP_CONTAINER" ]; then
    echo "❌ Не удалось найти контейнер приложения"
    exit 1
fi

# Путь к лог-файлу
LOG_FILE="$APP_CONTAINER/Documents/org_import_log.txt"

echo "📱 Контейнер приложения: $APP_CONTAINER"
echo "📄 Путь к лог-файлу: $LOG_FILE"
echo ""

if [ -f "$LOG_FILE" ]; then
    echo "📝 Содержимое лог-файла:"
    echo "========================"
    cat "$LOG_FILE"
    echo "========================"
else
    echo "⚠️ Лог-файл еще не создан"
    echo "Попробуйте нажать кнопку 'Скачать шаблон Excel' в приложении"
fi

# Также показываем список файлов в Documents
echo ""
echo "📁 Файлы в Documents:"
ls -la "$APP_CONTAINER/Documents/" 2>/dev/null || echo "Директория пуста или недоступна" 