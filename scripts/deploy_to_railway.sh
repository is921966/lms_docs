#!/bin/bash

echo "🚂 Railway Deployment Script for LMS Servers"
echo "==========================================="
echo ""

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI не установлен"
    echo ""
    echo "Установите Railway CLI:"
    echo "  brew install railway"
    echo "или"
    echo "  npm install -g @railway/cli"
    exit 1
fi

# Check if user is logged in
if ! railway whoami &> /dev/null; then
    echo "📝 Необходимо войти в Railway"
    railway login
fi

echo ""
echo "🔧 Подготовка к деплою..."
echo ""

# Create temporary directory for deployment
DEPLOY_DIR="/tmp/lms-servers-deploy"
rm -rf $DEPLOY_DIR
mkdir -p $DEPLOY_DIR

# Copy necessary files
echo "📋 Копирование файлов..."
cp log_server_cloud.py $DEPLOY_DIR/
cp feedback_server.py $DEPLOY_DIR/
cp requirements.txt $DEPLOY_DIR/

# Create Procfile for Railway
cat > $DEPLOY_DIR/Procfile << EOF
web: gunicorn log_server_cloud:app --bind 0.0.0.0:\$PORT
EOF

# Deploy Log Server
echo ""
echo "🚀 Развертывание Log Server..."
echo ""
cd $DEPLOY_DIR

# Initialize new Railway project for log server
railway init --name "lms-log-server"

# Link to Railway
railway link

# Deploy
echo "📤 Загрузка на Railway..."
railway up

# Get the deployment URL
LOG_SERVER_URL=$(railway status --json | grep -o '"url":"[^"]*' | grep -o '[^"]*$' | head -1)

if [ -z "$LOG_SERVER_URL" ]; then
    echo "⏳ Ожидание URL..."
    sleep 10
    LOG_SERVER_URL=$(railway domain)
fi

echo ""
echo "✅ Log Server развернут!"
echo "   URL: https://$LOG_SERVER_URL"
echo ""

# Deploy Feedback Server
echo "🚀 Развертывание Feedback Server..."
echo ""

# Update Procfile for feedback server
cat > $DEPLOY_DIR/Procfile << EOF
web: gunicorn feedback_server:app --bind 0.0.0.0:\$PORT
EOF

# Create new project for feedback server
railway init --name "lms-feedback-server"
railway link

# Set environment variables for GitHub integration
echo "🔐 Настройка переменных окружения..."
echo ""
echo "Введите ваш GitHub Token (начинается с ghp_):"
read -s GITHUB_TOKEN
echo ""

railway variables set GITHUB_TOKEN="$GITHUB_TOKEN"
railway variables set GITHUB_OWNER="is921966"
railway variables set GITHUB_REPO="lms_docs"

# Deploy
echo "📤 Загрузка на Railway..."
railway up

# Get the deployment URL
FEEDBACK_SERVER_URL=$(railway status --json | grep -o '"url":"[^"]*' | grep -o '[^"]*$' | head -1)

if [ -z "$FEEDBACK_SERVER_URL" ]; then
    echo "⏳ Ожидание URL..."
    sleep 10
    FEEDBACK_SERVER_URL=$(railway domain)
fi

echo ""
echo "✅ Feedback Server развернут!"
echo "   URL: https://$FEEDBACK_SERVER_URL"
echo ""

# Update iOS configuration
echo "📱 Обновление конфигурации iOS..."
echo ""

# Go back to scripts directory
cd $(dirname "$0")

# Update LogUploader.swift
sed -i '' "s|https://lms-log-server.onrender.com|https://$LOG_SERVER_URL|g" ../LMS_App/LMS/LMS/Services/Logging/LogUploader.swift

# Update ServerFeedbackService.swift
sed -i '' "s|https://lms-feedback-server.onrender.com|https://$FEEDBACK_SERVER_URL|g" ../LMS_App/LMS/LMS/Services/Feedback/ServerFeedbackService.swift

# Clean up
rm -rf $DEPLOY_DIR

echo ""
echo "🎉 Деплой завершен!"
echo ""
echo "📊 Ваши серверы:"
echo "   Log Server:      https://$LOG_SERVER_URL"
echo "   Feedback Server: https://$FEEDBACK_SERVER_URL"
echo ""
echo "📱 iOS конфигурация обновлена"
echo ""
echo "🔧 Следующие шаги:"
echo "   1. Пересоберите iOS приложение в Xcode"
echo "   2. Проверьте работу серверов:"
echo "      - Log Dashboard:      https://$LOG_SERVER_URL"
echo "      - Feedback Dashboard: https://$FEEDBACK_SERVER_URL"
echo ""
echo "💡 Управление серверами:"
echo "   railway logs        - просмотр логов"
echo "   railway status      - статус деплоя"
echo "   railway variables   - управление переменными"
echo "" 