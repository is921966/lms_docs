# ✅ Railway Deployment Checklist

## 🚀 Quick Deploy Steps (15-20 минут)

### 1. Railway Setup (5 мин)
- [ ] Создать аккаунт на [railway.app](https://railway.app)
- [ ] Создать новый проект "LMS Backend"
- [ ] Добавить PostgreSQL service (+ New → Database → PostgreSQL)
- [ ] Подключить GitHub репозиторий

### 2. Environment Variables (5 мин)
В настройках сервиса добавить переменные:

```env
APP_NAME=LMS Corporate University
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:YOUR_KEY_HERE
APP_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}
JWT_SECRET=YOUR_SECRET_HERE
JWT_ALGO=HS256
JWT_TTL=60
CORS_ALLOWED_ORIGINS=*
CACHE_DRIVER=database
SESSION_DRIVER=database
```

### 3. Generate Keys (2 мин)
```bash
# В терминале локально:
php artisan key:generate --show  # копировать в APP_KEY
openssl rand -base64 32          # копировать в JWT_SECRET
```

### 4. Deploy (5 мин)
```bash
git push origin main  # Railway автоматически начнет деплой
```

### 5. Initialize Database (3 мин)
После успешного деплоя:
```bash
# Установить Railway CLI
npm install -g @railway/cli

# Войти в Railway
railway login

# Выбрать проект
railway link

# Запустить миграции
railway run php artisan migrate --force
railway run php artisan db:seed --class=ProductionSeeder --force
```

## 🔍 Проверка работоспособности

### API Health Check:
```bash
curl https://YOUR-APP.up.railway.app/api/v1/auth/health
# Должен вернуть: {"status":"ok","service":"auth","timestamp":"..."}
```

### Test Login:
```bash
curl -X POST https://YOUR-APP.up.railway.app/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@lms.company.ru","password":"Admin123!"}'
```

## 📱 iOS App Update

### 1. Обновить URL в AppConfig.swift:
```swift
// Заменить на ваш Railway URL
return "https://lms-backend-production.up.railway.app/api/v1"
```

### 2. Создать новый TestFlight build:
```bash
cd LMS_App/LMS
./scripts/build-testflight.sh
```

## ⚠️ Troubleshooting

### Если деплой не работает:
1. Проверьте логи в Railway dashboard
2. Убедитесь что APP_KEY установлен
3. Проверьте что PostgreSQL подключен

### Если API возвращает 500:
1. Проверьте миграции: `railway run php artisan migrate:status`
2. Проверьте логи: `railway logs`
3. Убедитесь в правильности переменных окружения

### Если iOS app не подключается:
1. Проверьте CORS_ALLOWED_ORIGINS
2. Убедитесь что URL правильный (с https://)
3. Проверьте Info.plist разрешения

## 📞 Поддержка

- Railway Discord: [discord.gg/railway](https://discord.gg/railway)
- GitHub Issues: [github.com/is921966/lms_docs/issues](https://github.com/is921966/lms_docs/issues)
- Railway Status: [status.railway.app](https://status.railway.app)

---

**Время на весь процесс: ~20 минут** ⏱️ 