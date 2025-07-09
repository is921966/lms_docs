# Production Deployment Backup

**Дата сохранения:** 13 января 2025  
**Цель:** Файлы для развертывания backend на Railway.app

## 📁 Содержимое

### Конфигурационные файлы Railway:
- `railway.json` - основная конфигурация Railway
- `nixpacks.toml` - настройки сборки PHP 8.2
- `railway-deploy.yml` - GitHub Actions для автодеплоя

### Документация:
- `RAILWAY_DEPLOYMENT.md` - полное руководство по деплою
- `RAILWAY_DEPLOYMENT_CHECKLIST.md` - быстрый чек-лист
- `PRODUCTION_DEPLOYMENT_READY.md` - отчет о готовности

### База данных:
- `init-production.sql` - SQL скрипт инициализации БД
- `ProductionSeeder.php` - Laravel seeder для тестовых данных

### Backend API:
- `AuthController.php` - контроллер аутентификации

### iOS изменения (папка `ios_changes/`):
- `AppConfig.swift` - конфигурация с production URL
- `APIClient.swift` - сетевой клиент для API
- `KeychainHelper.swift` - безопасное хранение токенов
- `AuthService.swift` - обновленный сервис авторизации

## 🚀 Как использовать

Когда будете готовы к production деплою:

1. Скопируйте файлы обратно в проект:
   ```bash
   cp railway.json nixpacks.toml ../../
   cp -r ios_changes/* ../../LMS_App/LMS/LMS/
   # и т.д.
   ```

2. Следуйте инструкциям из `RAILWAY_DEPLOYMENT_CHECKLIST.md`

3. Создайте проект на Railway и настройте переменные окружения

## 📝 Заметки

- Все файлы готовы к использованию
- Тестовые пользователи: admin@lms.company.ru / Admin123!
- iOS приложение требует обновления URL в AppConfig.swift
- GitHub Actions настроен для автодеплоя из ветки main/production 