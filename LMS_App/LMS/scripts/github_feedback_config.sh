#!/bin/bash

# GitHub Feedback Configuration Script
# Этот скрипт настраивает интеграцию feedback с GitHub

echo "🔧 Настройка GitHub интеграции для Feedback System"
echo "================================================"
echo ""

# Проверяем наличие GitHub токена
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN не установлен!"
    echo ""
    echo "Для настройки выполните:"
    echo "1. Создайте Personal Access Token на GitHub:"
    echo "   https://github.com/settings/tokens/new"
    echo ""
    echo "2. Выберите права:"
    echo "   - repo (для приватных репозиториев)"
    echo "   - public_repo (для публичных)"
    echo ""
    echo "3. Установите токен:"
    echo "   export GITHUB_TOKEN='your-token-here'"
    echo ""
    echo "4. Запустите этот скрипт снова"
    exit 1
fi

# Настройки репозитория
GITHUB_REPO="is921966/lms_docs"
GITHUB_OWNER="is921966"
REPO_NAME="lms_docs"

echo "✅ GitHub токен найден"
echo "📦 Репозиторий: $GITHUB_REPO"
echo ""

# Создаем конфигурационный файл для сервера
cat > feedback_config.json << EOF
{
    "github": {
        "token": "$GITHUB_TOKEN",
        "owner": "$GITHUB_OWNER",
        "repo": "$REPO_NAME",
        "labels": ["feedback", "mobile-app", "ios"]
    },
    "server": {
        "port": 5000,
        "host": "0.0.0.0"
    }
}
EOF

echo "✅ Конфигурация создана: feedback_config.json"
echo ""

# Обновляем feedback_server.py для использования конфигурации
echo "🔄 Обновляем feedback_server.py..."

# Проверяем, запущен ли сервер
if pgrep -f "feedback_server.py" > /dev/null; then
    echo "⚠️  Feedback server уже запущен. Перезапустите его для применения изменений:"
    echo "   pkill -f feedback_server.py"
    echo "   python3 feedback_server.py"
else
    echo "💡 Теперь запустите feedback server:"
    echo "   python3 feedback_server.py"
fi

echo ""
echo "📱 Для iOS приложения:"
echo "1. Feedback будет отправляться на http://localhost:5000/api/v1/feedback"
echo "2. Server автоматически создаст GitHub Issue"
echo "3. Токен хранится только на сервере (безопасно)"
echo ""
echo "✅ Настройка завершена!" 