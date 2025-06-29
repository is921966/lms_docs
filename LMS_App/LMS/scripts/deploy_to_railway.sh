#!/bin/bash

echo "🚀 Развертывание Feedback Server в Railway"
echo "=========================================="
echo ""

# Проверяем наличие Railway CLI
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI не установлен!"
    echo "Установите его командой: brew install railway"
    echo "Или скачайте с: https://docs.railway.app/develop/cli"
    exit 1
fi

# Проверяем наличие файлов
if [ ! -f "feedback_server_cloud.py" ]; then
    echo "❌ Файл feedback_server_cloud.py не найден!"
    echo "Убедитесь, что вы находитесь в папке scripts"
    exit 1
fi

echo "📋 Подготовка файлов..."

# Копируем cloud версию как основную
cp feedback_server_cloud.py feedback_server.py

# Создаем railway.toml для конфигурации
cat > railway.toml << 'EOF'
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "gunicorn feedback_server:app --bind 0.0.0.0:$PORT"
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10
EOF

echo "✅ Файлы подготовлены"
echo ""

# Логин в Railway
echo "🔐 Вход в Railway..."
railway login

# Инициализация проекта
echo ""
echo "📦 Создание нового проекта Railway..."
echo "Введите имя проекта (например: lms-feedback-server):"
read -p "Имя проекта: " PROJECT_NAME

railway init -n "$PROJECT_NAME"

echo ""
echo "⚙️  Настройка переменных окружения..."

# GitHub Token
if [ -z "$1" ]; then
    echo "Введите ваш GitHub Token:"
    read -s GITHUB_TOKEN
else
    GITHUB_TOKEN=$1
fi

# Установка переменных
railway variables set GITHUB_TOKEN="$GITHUB_TOKEN"
railway variables set GITHUB_OWNER="is921966"
railway variables set GITHUB_REPO="lms_docs"

echo ""
echo "✅ Переменные установлены"

# Развертывание
echo ""
echo "🚀 Развертывание приложения..."
railway up

echo ""
echo "🌐 Получение URL..."
DOMAIN=$(railway domain)

if [ -z "$DOMAIN" ]; then
    echo ""
    echo "⚠️  Домен еще не назначен. Генерируем..."
    railway domain
    sleep 2
    DOMAIN=$(railway status --json | grep -o '"domain":"[^"]*' | cut -d'"' -f4)
fi

echo ""
echo "✅ Развертывание завершено!"
echo ""
echo "📱 Ваш Feedback Server доступен по адресу:"
echo "🔗 https://$DOMAIN"
echo ""
echo "📊 Dashboard: https://$DOMAIN"
echo "📡 API endpoint: https://$DOMAIN/api/v1/feedback"
echo "🏥 Health check: https://$DOMAIN/health"
echo ""
echo "📱 Обновите ServerFeedbackService.swift:"
echo "private let serverURL = \"https://$DOMAIN/api/v1/feedback\""
echo ""
echo "🔧 Управление:"
echo "- Просмотр логов: railway logs"
echo "- Открыть дашборд: railway open"
echo "- Остановить: railway down"
echo ""

# Сохраняем информацию
cat > cloud_deployment_info.txt << EOF
🚀 Railway Deployment Info
========================
Date: $(date)
Project: $PROJECT_NAME
URL: https://$DOMAIN
API: https://$DOMAIN/api/v1/feedback

Commands:
- View logs: railway logs
- Open dashboard: railway open
- Redeploy: railway up
- Stop: railway down
EOF

echo "💾 Информация сохранена в cloud_deployment_info.txt"

# Тестируем
echo ""
echo "🧪 Тестируем сервер..."
sleep 5

if curl -s -o /dev/null -w "%{http_code}" "https://$DOMAIN/health" | grep -q "200"; then
    echo "✅ Сервер работает!"
    
    # Показываем health status
    echo ""
    echo "Health status:"
    curl -s "https://$DOMAIN/health" | python3 -m json.tool
else
    echo "⚠️  Сервер еще запускается. Проверьте через минуту:"
    echo "curl https://$DOMAIN/health"
fi

echo ""
echo "🎉 Готово! Ваш feedback сервер работает в облаке!" 