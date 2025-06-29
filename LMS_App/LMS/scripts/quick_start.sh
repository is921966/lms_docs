#!/bin/bash

echo "🚀 Quick Start Feedback Server"
echo "=============================="
echo ""

# Проверяем наличие токена как параметра
if [ -z "$1" ]; then
    echo "❌ Ошибка: токен не указан!"
    echo ""
    echo "Использование:"
    echo "  ./quick_start.sh ghp_ваш_токен_здесь"
    echo ""
    echo "Или установите переменную окружения:"
    echo "  export GITHUB_TOKEN='ghp_ваш_токен_здесь'"
    echo "  ./quick_start.sh"
    exit 1
fi

TOKEN=$1

# Создаем конфигурацию
echo "📝 Создаем конфигурацию..."
cat > feedback_config.json << EOF
{
    "github": {
        "token": "$TOKEN",
        "owner": "is921966",
        "repo": "lms_docs",
        "labels": ["feedback", "mobile-app", "ios"]
    },
    "server": {
        "port": 5001,
        "host": "0.0.0.0"
    }
}
EOF

echo "✅ Конфигурация создана"
echo ""

# Проверяем Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 не найден!"
    exit 1
fi

# Проверяем Flask
if ! python3 -c "import flask" &> /dev/null; then
    echo "📦 Устанавливаем Flask..."
    pip3 install flask flask-cors requests
fi

# Запускаем сервер
echo "🚀 Запускаем Feedback Server..."
echo "================================"
echo ""
    python3 feedback_server.py --port 5001 