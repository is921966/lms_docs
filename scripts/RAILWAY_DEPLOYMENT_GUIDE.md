# 🚂 Развертывание на Railway - Пошаговая инструкция

## 📋 Подготовка

### 1. Проверьте Railway CLI
```bash
railway --version
```

Если не установлен:
```bash
brew install railway
```

### 2. Войдите в Railway
```bash
railway login
```

## 🚀 Деплой Log Server

### Шаг 1: Создайте временную папку
```bash
cd /tmp
mkdir lms-log-server && cd lms-log-server
```

### Шаг 2: Скопируйте файлы
```bash
cp /Users/ishirokov/lms_docs/scripts/log_server_cloud.py .
cp /Users/ishirokov/lms_docs/scripts/requirements.txt .
```

### Шаг 3: Создайте Procfile
```bash
cat > Procfile << 'EOF'
web: gunicorn log_server_cloud:app --bind 0.0.0.0:$PORT
EOF
```

### Шаг 4: Инициализируйте проект
```bash
railway init
# Выберите "Empty project"
# Введите имя: lms-log-server
```

### Шаг 5: Деплой
```bash
railway up
```

### Шаг 6: Получите URL
```bash
railway domain
```

Запишите URL (например: `lms-log-server-production.up.railway.app`)

## 🚀 Деплой Feedback Server

### Шаг 1: Создайте папку
```bash
cd /tmp
mkdir lms-feedback-server && cd lms-feedback-server
```

### Шаг 2: Скопируйте файлы
```bash
cp /Users/ishirokov/lms_docs/scripts/feedback_server.py .
cp /Users/ishirokov/lms_docs/scripts/requirements.txt .
```

### Шаг 3: Создайте Procfile
```bash
cat > Procfile << 'EOF'
web: gunicorn feedback_server:app --bind 0.0.0.0:$PORT
EOF
```

### Шаг 4: Инициализируйте проект
```bash
railway init
# Выберите "Empty project"
# Введите имя: lms-feedback-server
```

### Шаг 5: Добавьте переменные окружения
```bash
# Откройте dashboard Railway в браузере
railway open

# Или через CLI (замените на ваш токен):
railway variables set GITHUB_TOKEN=ghp_ваш_токен_здесь
railway variables set GITHUB_OWNER=is921966
railway variables set GITHUB_REPO=lms_docs
```

### Шаг 6: Деплой
```bash
railway up
```

### Шаг 7: Получите URL
```bash
railway domain
```

## 📱 Обновление iOS приложения

### 1. Обновите LogUploader.swift

Откройте `/Users/ishirokov/lms_docs/LMS_App/LMS/LMS/Services/Logging/LogUploader.swift`

Замените:
```swift
private let serverEndpoint = "https://lms-log-server-production.up.railway.app/api/logs"
```

### 2. Обновите ServerFeedbackService.swift

Откройте `/Users/ishirokov/lms_docs/LMS_App/LMS/LMS/Services/Feedback/ServerFeedbackService.swift`

Замените:
```swift
private let serverURL = "https://lms-feedback-server-production.up.railway.app/api/v1/feedback"
```

## ✅ Проверка

### 1. Проверьте dashboards
- Log Server: `https://ваш-log-server.railway.app`
- Feedback Server: `https://ваш-feedback-server.railway.app`

### 2. Тест Log Server
```bash
curl -X POST https://ваш-log-server.railway.app/api/logs \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "test",
    "logs": [{
      "category": "test",
      "level": "info",
      "event": "Test from curl"
    }]
  }'
```

### 3. Тест Feedback Server
```bash
curl -X POST https://ваш-feedback-server.railway.app/api/v1/feedback \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Test feedback",
    "type": "test"
  }'
```

## 🔧 Управление

### Просмотр логов
```bash
railway logs
```

### Перезапуск
```bash
railway restart
```

### Обновление
```bash
# В папке проекта
railway up
```

### Dashboard
```bash
railway open
```

## 💡 Советы

1. **Бесплатный план Railway** включает:
   - $5 кредитов в месяц
   - 500 часов работы
   - Достаточно для тестирования

2. **Для production** рекомендуется:
   - Добавить custom domain
   - Настроить автоматический деплой из GitHub
   - Включить автоматический рестарт

3. **Мониторинг**:
   - Railway предоставляет метрики
   - Можно настроить алерты
   - Интеграция с Discord/Slack

## 🚨 Troubleshooting

### "Command not found: gunicorn"
Убедитесь что `requirements.txt` содержит `gunicorn`

### "Port binding failed"
Railway автоматически предоставляет $PORT, не указывайте его явно

### "Module not found"
Проверьте что все файлы скопированы правильно

### Сервер не отвечает
- Проверьте логи: `railway logs`
- Убедитесь что Procfile правильный
- Проверьте health endpoint 