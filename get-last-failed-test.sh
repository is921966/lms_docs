#!/bin/bash

# Скрипт для быстрого получения ссылки на последний упавший тест

echo "🔍 Ищу последний упавший тест..."

# Получаем последний failed workflow
LAST_FAILED=$(gh run list --workflow "iOS CI/CD" --status failure --limit 1 --json databaseId,url,displayTitle,createdAt --jq '.[0]')

if [ -z "$LAST_FAILED" ]; then
    echo "✅ Нет упавших тестов!"
    exit 0
fi

# Извлекаем данные
RUN_ID=$(echo "$LAST_FAILED" | jq -r '.databaseId')
RUN_URL=$(echo "$LAST_FAILED" | jq -r '.url')
TITLE=$(echo "$LAST_FAILED" | jq -r '.displayTitle')
CREATED=$(echo "$LAST_FAILED" | jq -r '.createdAt')

echo "❌ Найден упавший тест!"
echo ""
echo "📋 Информация:"
echo "   Название: $TITLE"
echo "   Время: $CREATED"
echo "   Run ID: $RUN_ID"
echo ""
echo "🔗 Ссылки:"
echo "   Логи: $RUN_URL"
echo "   Артефакты: ${RUN_URL}#artifacts"
echo ""
echo "📋 Скопируйте для AI:"
echo "---"
echo "$RUN_URL"
echo "---"

# Копируем в буфер обмена (macOS)
echo "$RUN_URL" | pbcopy
echo ""
echo "✅ Ссылка скопирована в буфер обмена!"

# Опционально: открыть в браузере
read -p "Открыть в браузере? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$RUN_URL"
fi 