#!/bin/bash

# Deploy to Render Script
# Этот скрипт автоматически развертывает feedback server на Render

echo "🚀 Развертывание LMS Feedback Server на Render..."

# Проверяем наличие Render CLI
if ! command -v render &> /dev/null; then
    echo "❌ Render CLI не установлен. Установка..."
    brew tap render-oss/render
    brew install render
fi

# Проверяем наличие переменных окружения
if [ -z "$RENDER_API_KEY" ]; then
    echo "❌ RENDER_API_KEY не установлен!"
    echo "Получите API ключ на: https://dashboard.render.com/account/api-keys"
    echo "Затем выполните: export RENDER_API_KEY='your-api-key'"
    exit 1
fi

# Создаем временную директорию для развертывания
DEPLOY_DIR=$(mktemp -d)
echo "📁 Создана временная директория: $DEPLOY_DIR"

# Копируем файлы
cp -r render_deploy/* $DEPLOY_DIR/
cp render.yaml $DEPLOY_DIR/

# Переходим в директорию развертывания
cd $DEPLOY_DIR

# Инициализируем git репозиторий
git init
git add .
git commit -m "Initial deployment"

# Создаем сервис через Render API
echo "📤 Создание сервиса на Render..."

# Используем Render CLI для развертывания
render up

echo "✅ Развертывание завершено!"
echo ""
echo "⚠️  ВАЖНО: Не забудьте установить переменную окружения GITHUB_TOKEN в настройках сервиса!"
echo "1. Перейдите в dashboard.render.com"
echo "2. Откройте ваш сервис"
echo "3. Перейдите в Environment"
echo "4. Добавьте GITHUB_TOKEN с вашим токеном"

# Очищаем временную директорию
cd ..
rm -rf $DEPLOY_DIR 