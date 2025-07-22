# 🌩️ Cloud Deployment для LMS Log Server

## 🎯 Обзор

Развертывание log сервера в облаке решает проблему с динамическими IP адресами при использовании VPN. Сервер будет доступен по постоянному URL.

## 🚀 Вариант 1: Render.com (Бесплатно)

### Шаг 1: Подготовка файлов

```bash
cd /Users/ishirokov/lms_docs/scripts

# Создайте requirements.txt
cat > requirements.txt << EOF
Flask==2.3.2
flask-cors==4.0.0
gunicorn==21.2.0
EOF

# Создайте Procfile для Render
cat > render.yaml << EOF
services:
  - type: web
    name: lms-log-server
    env: python
    buildCommand: pip install -r requirements.txt
    startCommand: gunicorn log_server_cloud:app
    envVars:
      - key: PORT
        value: 10000
      - key: MAX_LOGS
        value: 10000
EOF
```

### Шаг 2: Деплой на Render

1. Создайте аккаунт на [render.com](https://render.com)
2. Создайте новый Web Service
3. Подключите GitHub репозиторий
4. Укажите:
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `gunicorn log_server_cloud:app`
5. Deploy!

### Шаг 3: Получите URL

После деплоя вы получите URL вида:
```
https://lms-log-server.onrender.com
```

## 🚀 Вариант 2: Railway.app

### Шаг 1: Установка Railway CLI

```bash
# macOS
brew install railway

# Или через npm
npm install -g @railway/cli
```

### Шаг 2: Деплой

```bash
cd /Users/ishirokov/lms_docs/scripts

# Логин
railway login

# Инициализация проекта
railway init

# Деплой
railway up

# Получить URL
railway domain
```

## 🚀 Вариант 3: Fly.io

### Шаг 1: Установка Fly CLI

```bash
# macOS
brew install flyctl

# Или
curl -L https://fly.io/install.sh | sh
```

### Шаг 2: Подготовка

```bash
cd /Users/ishirokov/lms_docs/scripts

# Создайте fly.toml
fly launch

# Выберите:
# - App name: lms-log-server
# - Region: ближайший к вам
# - Postgres: No
# - Redis: No
```

### Шаг 3: Деплой

```bash
fly deploy
```

## 📱 Обновление iOS приложения

После развертывания обновите URL в `LogUploader.swift`:

```swift
// Замените на ваш cloud URL
#if targetEnvironment(simulator)
    private let serverEndpoint = "https://lms-log-server.onrender.com/api/logs"
#else
    private let serverEndpoint = "https://lms-log-server.onrender.com/api/logs"
#endif
```

## 🔧 Настройка для Production

### 1. Ограничение CORS (опционально)

В `log_server_cloud.py`:
```python
# Только для вашего домена
CORS(app, origins=['https://your-domain.com', 'app://lms'])
```

### 2. Аутентификация (рекомендуется)

Добавьте API ключ:
```python
API_KEY = os.getenv('API_KEY', '')

@app.route('/api/logs', methods=['POST'])
def receive_logs():
    # Проверка API ключа
    if request.headers.get('X-API-Key') != API_KEY:
        return jsonify({'error': 'Unauthorized'}), 401
    # ... остальной код
```

В iOS:
```swift
request.setValue("your-api-key", forHTTPHeaderField: "X-API-Key")
```

### 3. Persistent Storage (опционально)

Для сохранения логов между рестартами используйте:
- PostgreSQL (Render предоставляет бесплатно)
- Redis (для кэширования)
- S3 (для долгосрочного хранения)

## 📊 Мониторинг

### Health Check
```bash
curl https://lms-log-server.onrender.com/health
```

### Просмотр логов
```
https://lms-log-server.onrender.com
```

### Тест отправки
```bash
curl -X POST https://lms-log-server.onrender.com/api/logs \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "test-device",
    "logs": [{
      "category": "test",
      "level": "info",
      "event": "Test log from curl"
    }]
  }'
```

## 🎯 Преимущества Cloud решения

1. **Постоянный URL** - не зависит от VPN или IP
2. **Доступность** - работает 24/7
3. **Масштабируемость** - автоматическое масштабирование
4. **HTTPS** - безопасное соединение
5. **Мониторинг** - встроенные метрики

## 🚨 Troubleshooting

### Сервер недоступен
- Проверьте статус на dashboard провайдера
- Проверьте логи: `railway logs` или в веб-интерфейсе

### Логи не отправляются
- Проверьте URL в iOS приложении
- Проверьте CORS настройки
- Проверьте сетевое соединение

### Логи теряются при рестарте
- Используйте persistent storage
- Увеличьте MAX_LOGS
- Настройте автосохранение

## ✅ Готово!

Теперь ваш log сервер доступен из любой точки мира по постоянному URL! 