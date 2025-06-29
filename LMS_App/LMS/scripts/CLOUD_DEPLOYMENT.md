# 🚀 Развертывание Feedback Server в облаке

## 📋 Подготовка

### Необходимые файлы:
- `feedback_server_cloud.py` - облачная версия сервера
- `requirements.txt` - зависимости Python
- `Procfile` - для Heroku/Railway
- `.env` или переменные окружения с GitHub токеном

### Переменные окружения:
```bash
GITHUB_TOKEN=your_github_token_here
GITHUB_OWNER=is921966
GITHUB_REPO=lms_docs
PORT=5001  # Обычно устанавливается автоматически
```

## 🚄 Вариант 1: Railway (Рекомендуется)

Railway - современная платформа с простым развертыванием и бесплатным планом.

### Шаги:
1. Зарегистрируйтесь на [Railway.app](https://railway.app)
2. Установите Railway CLI:
   ```bash
   brew install railway
   ```

3. В папке `LMS_App/LMS/scripts` выполните:
   ```bash
   # Переименуем файл для Railway
   cp feedback_server_cloud.py feedback_server.py
   
   # Инициализация проекта
   railway login
   railway init
   
   # Установка переменных
   railway variables set GITHUB_TOKEN="your_github_token_here"
   railway variables set GITHUB_OWNER="is921966"
   railway variables set GITHUB_REPO="lms_docs"
   
   # Развертывание
   railway up
   ```

4. Получите URL вашего сервиса:
   ```bash
   railway domain
   ```

### Преимущества Railway:
- ✅ $5 бесплатных кредитов каждый месяц
- ✅ Автоматический HTTPS
- ✅ Простое управление через CLI
- ✅ Автодеплой при изменениях

## 🎯 Вариант 2: Render

Render - еще одна современная платформа с хорошим бесплатным планом.

### Шаги:
1. Создайте аккаунт на [Render.com](https://render.com)
2. Создайте новый Web Service
3. Подключите GitHub репозиторий
4. Настройте:
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn feedback_server:app`
   - **Environment Variables**: добавьте GITHUB_TOKEN и другие

### Преимущества Render:
- ✅ 750 часов бесплатно в месяц
- ✅ Автоматический HTTPS
- ✅ Автодеплой из GitHub
- ✅ Простой веб-интерфейс

## 🌊 Вариант 3: Google Cloud Run

Serverless решение - платите только за использование.

### Шаги:
```bash
# Установите gcloud CLI
# https://cloud.google.com/sdk/docs/install

# Создайте Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY feedback_server_cloud.py feedback_server.py

CMD exec gunicorn --bind :$PORT feedback_server:app
EOF

# Деплой
gcloud run deploy feedback-server \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars="GITHUB_TOKEN=your_github_token_here,GITHUB_OWNER=is921966,GITHUB_REPO=lms_docs"
```

### Преимущества Cloud Run:
- ✅ Платите только за запросы
- ✅ Автомасштабирование
- ✅ 2 миллиона запросов бесплатно в месяц
- ✅ Высокая надежность Google

## 🎈 Вариант 4: Fly.io

Современная платформа с edge-deployment.

### Шаги:
```bash
# Установите flyctl
brew install flyctl

# В папке scripts
fly launch

# Установите переменные
fly secrets set GITHUB_TOKEN="your_github_token_here"
fly secrets set GITHUB_OWNER="is921966"
fly secrets set GITHUB_REPO="lms_docs"

# Деплой
fly deploy
```

## 📱 Обновление iOS приложения

После развертывания обновите URL в `ServerFeedbackService.swift`:

```swift
// Замените на ваш cloud URL
private let serverURL = "https://your-app.railway.app/api/v1/feedback"
// или
private let serverURL = "https://your-app.onrender.com/api/v1/feedback"
// или  
private let serverURL = "https://feedback-server-xxxxx.a.run.app/api/v1/feedback"
```

## 🔒 Безопасность

1. **Никогда не коммитьте токены в репозиторий**
2. Используйте переменные окружения
3. Ограничьте CORS при необходимости:
   ```python
   CORS(app, origins=['https://your-domain.com'])
   ```

## 📊 Мониторинг

### Проверка работоспособности:
```bash
# Health check
curl https://your-app.railway.app/health

# Dashboard
open https://your-app.railway.app

# Тест отправки
curl -X POST https://your-app.railway.app/api/v1/feedback \
  -H "Content-Type: application/json" \
  -d '{"text":"Test from cloud","type":"test"}'
```

## 🚨 Troubleshooting

### Ошибка 503 Service Unavailable
- Проверьте логи: `railway logs`
- Убедитесь что Procfile правильный
- Проверьте что все зависимости установлены

### GitHub Issues не создаются
- Проверьте переменную GITHUB_TOKEN
- Убедитесь что токен имеет права `repo`
- Проверьте логи на наличие ошибок

### Сервер не запускается
- Проверьте что PORT берется из переменных окружения
- Убедитесь что используется gunicorn
- Проверьте requirements.txt

## 💡 Советы

1. **Начните с Railway** - самый простой вариант
2. **Используйте GitHub Actions** для автодеплоя
3. **Настройте алерты** при ошибках
4. **Регулярно проверяйте логи**
5. **Делайте бэкапы** feedback данных

---

После развертывания ваш feedback сервер будет доступен 24/7 для всех тестировщиков! 🎉 