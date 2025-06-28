#!/bin/bash

# Мониторинг GitHub Issues с упавшими тестами

echo "🔍 Проверяю issues с упавшими тестами..."

# Получаем issues с нужными labels
ISSUES=$(gh issue list --label "ui-tests,automated" --state open --json number,title,url,createdAt,body --limit 5)

if [ -z "$ISSUES" ] || [ "$ISSUES" == "[]" ]; then
    echo "✅ Нет открытых issues с упавшими тестами!"
    exit 0
fi

# Показываем список
echo "❌ Найдены issues с упавшими тестами:"
echo ""

# Парсим каждый issue
echo "$ISSUES" | jq -r '.[] | "Issue #\(.number): \(.title)\nСоздан: \(.createdAt)\nURL: \(.url)\n"'

# Получаем последний issue
LAST_ISSUE_URL=$(echo "$ISSUES" | jq -r '.[0].url')
LAST_ISSUE_NUMBER=$(echo "$ISSUES" | jq -r '.[0].number')

echo "📋 Последний issue: #$LAST_ISSUE_NUMBER"
echo "🔗 Ссылка: $LAST_ISSUE_URL"
echo ""

# Копируем в буфер
echo "$LAST_ISSUE_URL" | pbcopy
echo "✅ Ссылка скопирована в буфер обмена!"
echo ""

# Показываем быструю команду для AI
echo "💡 Скопируйте и вставьте мне:"
echo "---"
echo "Вот issue с упавшими тестами: $LAST_ISSUE_URL"
echo "---" 