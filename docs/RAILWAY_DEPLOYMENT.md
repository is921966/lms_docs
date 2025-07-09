# Развертывание LMS на Railway

## 🚀 Быстрый старт

### 1. Подготовка репозитория

```bash
# Убедитесь что все изменения закоммичены
git add .
git commit -m "feat: Prepare for Railway deployment"
git push origin feature/cmi5-support
```

### 2. Создание проекта на Railway

1. Зайдите на [railway.app](https://railway.app)
2. Создайте новый проект
3. Выберите "Deploy from GitHub repo"
4. Подключите репозиторий `is921966/lms_docs`

### 3. Добавление PostgreSQL

1. В проекте Railway нажмите "+ New"
2. Выберите "Database" → "Add PostgreSQL"
3. Railway автоматически создаст переменные:
   - `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`

### 4. Настройка переменных окружения

В настройках сервиса добавьте следующие переменные:

```env
# Основные настройки
APP_NAME="LMS Corporate University"
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:YOUR_GENERATED_KEY_HERE
APP_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}

# JWT для авторизации
JWT_SECRET=YOUR_RANDOM_SECRET_HERE
JWT_ALGO=HS256
JWT_TTL=60
JWT_REFRESH_TTL=20160

# CORS для iOS приложения
CORS_ALLOWED_ORIGINS=*
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=Content-Type,Authorization,X-Requested-With

# Настройки кеша
CACHE_DRIVER=database
SESSION_DRIVER=database
```

### 5. Генерация APP_KEY

```bash
# Локально выполните:
php artisan key:generate --show

# Скопируйте полученный ключ в переменную APP_KEY на Railway
```

### 6. Запуск миграций

После деплоя выполните миграции через Railway CLI или веб-консоль:

```bash
php artisan migrate --force
php artisan db:seed --force
```

## 📱 Настройка iOS приложения

### 1. Обновите базовый URL в iOS приложении:

```swift
// LMS_App/LMS/LMS/Config/AppConfig.swift
struct AppConfig {
    #if DEBUG
    static let baseURL = "http://localhost:8000/api/v1"
    #else
    static let baseURL = "https://YOUR-APP-NAME.up.railway.app/api/v1"
    #endif
}
```

### 2. Добавьте production URL в Info.plist:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>YOUR-APP-NAME.up.railway.app</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

## 🔧 Дополнительные сервисы

### Redis (опционально)

1. Добавьте Redis в проект Railway
2. Обновите переменные:
   ```env
   REDIS_HOST=${{REDIS_HOST}}
   REDIS_PORT=${{REDIS_PORT}}
   REDIS_PASSWORD=${{REDIS_PASSWORD}}
   CACHE_DRIVER=redis
   SESSION_DRIVER=redis
   ```

### Мониторинг

1. Включите Railway metrics
2. Добавьте Sentry для отслеживания ошибок:
   ```env
   SENTRY_LARAVEL_DSN=YOUR_SENTRY_DSN
   ```

## 📊 Проверка работоспособности

### 1. API Health Check

```bash
curl https://YOUR-APP-NAME.up.railway.app/api/v1/health
```

### 2. Тестовые endpoints

```bash
# Получить список курсов
curl https://YOUR-APP-NAME.up.railway.app/api/v1/courses

# Авторизация
curl -X POST https://YOUR-APP-NAME.up.railway.app/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"password"}'
```

## 🚨 Troubleshooting

### Ошибка 500

1. Проверьте логи в Railway dashboard
2. Убедитесь что APP_KEY установлен
3. Проверьте подключение к БД

### Ошибка CORS

1. Проверьте CORS_ALLOWED_ORIGINS
2. Добавьте ваш домен в список разрешенных

### Проблемы с миграциями

1. Подключитесь к БД через Railway CLI
2. Выполните миграции вручную
3. Проверьте права доступа к БД

## 📈 Масштабирование

Railway автоматически масштабирует приложение. Для настройки:

1. Перейдите в Settings → Scaling
2. Настройте минимум и максимум инстансов
3. Включите автомасштабирование по CPU/Memory

## 🔒 Безопасность

1. Используйте HTTPS (Railway предоставляет автоматически)
2. Настройте Rate Limiting
3. Включите CORS только для нужных доменов
4. Регулярно обновляйте зависимости

---

**Поддержка**: Создайте issue в GitHub репозитории при возникновении проблем. 