# Инструкция по загрузке TestFlight Build 215

## ✅ Build успешно создан!

**Версия**: 2.4.0  
**Build**: 215 (обновлен с 214)  
**Файл**: `/Users/ishirokov/lms_docs/LMS_App/LMS/build/Export/LMS.ipa`  
**Размер**: 24.4 MB  

## 🚨 Важно: Build 214 уже был использован

Build 214 уже существует в TestFlight, поэтому мы увеличили номер до 215.

## 📱 Способы загрузки в TestFlight

### Вариант 1: Transporter (Рекомендуется)

1. Откройте **Transporter** из Applications (уже открыт)
2. Войдите с вашим Apple ID (igor@testedium.com)
3. Перетащите файл `LMS.ipa` в окно Transporter
4. Нажмите **DELIVER**
5. Дождитесь завершения загрузки

### Вариант 2: Xcode Organizer

1. В Xcode: Window → Organizer
2. Выберите архив LMS (Version 2.4.0, Build 215)
3. Нажмите **Distribute App**
4. Выберите **TestFlight & App Store**
5. Следуйте инструкциям

### Вариант 3: Command Line (требует app-specific password)

```bash
# Сначала создайте app-specific password:
# 1. Зайдите на https://appleid.apple.com
# 2. Security → App-Specific Passwords → Generate
# 3. Скопируйте пароль

# Затем выполните:
xcrun altool --upload-app -f ./build/Export/LMS.ipa -t ios -u igor@testedium.com -p "YOUR-APP-SPECIFIC-PASSWORD"
```

## 📋 После загрузки

1. **Processing**: Apple обработает build (5-15 минут)
2. **Email**: Получите уведомление о готовности
3. **TestFlight**: Зайдите в App Store Connect
4. **Release Notes**: Добавьте release notes из `/docs/releases/TESTFLIGHT_RELEASE_v2.4.0_build215.md`
5. **Testers**: Выберите группы тестировщиков
6. **Submit**: Отправьте на тестирование

## 🎯 Release Notes (скопируйте в TestFlight)

```
Версия 2.4.0 (Build 215) - Полная миграция на Clean Architecture

✨ Новое:
• 100% Clean Architecture - улучшенная производительность
• Исправлено переключение дизайна ленты
• Интеграция микросервисов CourseService и CompetencyService
• Быстрый запуск < 0.4 секунды

🔧 Исправления:
• Устранено 120+ критических ошибок
• Исправлена синхронизация UserDefaults
• Оптимизирована работа с памятью

📱 Что тестировать:
• Переключение дизайна в Настройки → Лента
• Диагностика в Настройки → Для разработчиков
• Быстрый вход (зеленая/оранжевая кнопки)
• Общая производительность приложения

🆕 Build 215: Исправлен номер сборки для TestFlight
```

## ⚡ Quick Commands

```bash
# Открыть папку с IPA
open ./build/Export/

# Открыть Transporter
open -a Transporter

# Проверить детали IPA
xcrun altool --validate-app -f ./build/Export/LMS.ipa -t ios
```

---

**Build 215 готов к загрузке! Используйте Transporter для быстрой загрузки.** 🚀 