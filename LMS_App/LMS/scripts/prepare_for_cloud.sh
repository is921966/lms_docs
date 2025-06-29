#!/bin/bash

# Prepare for Cloud Deployment Script
# Подготавливает feedback server для развертывания в облаке

echo "🚀 Подготовка Feedback Server для облачного развертывания..."

# Проверяем наличие необходимых файлов
if [ ! -f "feedback_server.py" ]; then
    echo "❌ feedback_server.py не найден!"
    exit 1
fi

# Создаем облачную версию сервера
echo "📝 Создание облачной версии сервера..."
cp feedback_server.py feedback_server_cloud.py

# Модифицируем для облака
echo "🔧 Адаптация для облачного окружения..."

# Добавляем поддержку переменных окружения для порта
sed -i '' 's/port=5001/port=int(os.getenv("PORT", 5001))/' feedback_server_cloud.py

# Создаем requirements.txt если его нет
if [ ! -f "requirements.txt" ]; then
    echo "📦 Создание requirements.txt..."
    cat > requirements.txt << 'EOF'
Flask==3.0.0
flask-cors==4.0.0
requests==2.31.0
gunicorn==21.2.0
python-dotenv==1.0.0
EOF
fi

# Создаем Procfile для Heroku/Railway
echo "📄 Создание Procfile..."
cat > Procfile << 'EOF'
web: gunicorn feedback_server:app --bind 0.0.0.0:$PORT
EOF

# Создаем railway.json
echo "🚂 Создание railway.json..."
cat > railway.json << 'EOF'
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "numReplicas": 1,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
EOF

# Создаем .env.example
echo "🔐 Создание .env.example..."
cat > .env.example << 'EOF'
GITHUB_TOKEN=your_github_token_here
GITHUB_OWNER=is921966
GITHUB_REPO=lms_docs
PORT=5001
EOF

# Создаем README для облачного развертывания
echo "📚 Создание документации..."
cat > CLOUD_DEPLOYMENT.md << 'EOF'
# Развертывание Feedback Server в облаке

## Railway (Рекомендуется)

1. Установите Railway CLI:
   ```bash
   brew install railway
   ```

2. Войдите и создайте проект:
   ```bash
   railway login
   railway init
   ```

3. Установите переменные окружения:
   ```bash
   railway variables set GITHUB_TOKEN="your_token"
   railway variables set GITHUB_OWNER="is921966"
   railway variables set GITHUB_REPO="lms_docs"
   ```

4. Разверните:
   ```bash
   railway up
   ```

## Переменные окружения

Обязательные переменные:
   - GITHUB_TOKEN = your_github_token_here
   - GITHUB_OWNER = is921966  
   - GITHUB_REPO = lms_docs
EOF

echo "✅ Подготовка завершена!"
echo ""
echo "📋 Следующие шаги:"
echo "1. Установите переменные окружения в вашей облачной платформе"
echo "2. Разверните используя инструкции в CLOUD_DEPLOYMENT.md"
echo "3. Обновите URL в iOS приложении" 