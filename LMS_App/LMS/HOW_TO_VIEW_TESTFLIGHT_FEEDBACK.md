# Как просматривать отзывы TestFlight

## ✅ Что у нас работает

**Fastlane успешно получает:**
- Список тестировщиков (7 человек)
- Список билдов (46 версий)
- Базовую информацию о тестировании

**Команда для запуска:**
```bash
cd /Users/ishirokov/lms_docs/LMS_App/LMS
fastlane fetch_feedback_v2
```

## ❌ Что недоступно через API

К сожалению, Apple не предоставляет публичный API для:
- Screenshot feedback (отзывы со скриншотами)
- Текстовые комментарии тестировщиков
- Crash reports из TestFlight

## 📱 Как просматривать отзывы

### Вариант 1: App Store Connect (рекомендуется)
1. Откройте https://appstoreconnect.apple.com
2. Выберите приложение "TSUM LMS"
3. Перейдите в TestFlight → Feedback
4. Там будут все отзывы со скриншотами

### Вариант 2: Email уведомления
1. В App Store Connect → Users and Access
2. Настройте email уведомления для TestFlight feedback
3. Будете получать отзывы на почту

### Вариант 3: Встроенный feedback в приложение
Рассмотрите интеграцию SDK для сбора отзывов:
- Instabug
- Shake
- Bugsnag
- Firebase Crashlytics

## 🚀 Что дальше?

1. **Для автоматизации базовой информации** - используйте созданный Fastlane action
2. **Для просмотра отзывов со скриншотами** - заходите в App Store Connect
3. **Для полной автоматизации** - рассмотрите сторонние сервисы или SDK

Правильный bundle ID вашего приложения: **ru.tsum.lms.igor** 