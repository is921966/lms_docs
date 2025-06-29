#!/bin/bash

# Скрипт для обновления feedback сервера с поддержкой Imgur

echo "🚀 Обновление Feedback Server с поддержкой Imgur"
echo "=============================================="

# Проверяем, что мы в правильной директории
if [ ! -f "scripts/feedback_server.py" ]; then
    echo "❌ Ошибка: Запустите скрипт из директории LMS_App/LMS"
    exit 1
fi

# Проверяем наличие обновленной версии
if [ ! -f "scripts/feedback_server_updated.py" ]; then
    echo "❌ Ошибка: Файл feedback_server_updated.py не найден"
    exit 1
fi

echo "📋 Шаг 1: Создание резервной копии"
cp scripts/feedback_server.py scripts/feedback_server_backup_$(date +%Y%m%d_%H%M%S).py
echo "✅ Резервная копия создана"

echo ""
echo "📋 Шаг 2: Обновление feedback_server.py"
cp scripts/feedback_server_updated.py scripts/feedback_server.py
echo "✅ Файл обновлен"

echo ""
echo "📋 Шаг 3: Проверка изменений"
git diff scripts/feedback_server.py | head -20
echo "..."

echo ""
echo "📋 Шаг 4: Коммит и push"
read -p "Продолжить с коммитом? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git add scripts/feedback_server.py
    git commit -m "feat: Add Imgur support for screenshot uploads in feedback server

- Added upload_to_imgur() function for screenshot handling
- Updated create_github_issue_with_screenshot() to include image URLs
- Added IMGUR_CLIENT_ID environment variable support
- Screenshots now properly displayed in GitHub Issues"
    
    echo ""
    echo "🚀 Отправка изменений в GitHub..."
    git push origin master
    
    echo ""
    echo "✅ Готово! Изменения отправлены."
    echo ""
    echo "⏳ Render автоматически обновит сервер в течение 2-5 минут"
    echo ""
    echo "📝 Следующие шаги:"
    echo "1. Добавьте IMGUR_CLIENT_ID в Render Environment Variables"
    echo "2. Проверьте https://lms-feedback-server.onrender.com/health"
    echo "3. Отправьте тестовый отзыв со скриншотом"
else
    echo "❌ Отменено пользователем"
    exit 1
fi

echo ""
echo "💡 Подсказка: Проверьте статус деплоя на https://dashboard.render.com" 