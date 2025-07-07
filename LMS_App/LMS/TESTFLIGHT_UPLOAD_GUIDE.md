# 📱 Руководство по загрузке в TestFlight

## 🎯 Текущий статус
- **Готовый билд**: LMS.ipa (Build 104)
- **Расположение**: `build/LMS-TestFlight/LMS.ipa`
- **Размер**: 5.02 MB
- **Дата создания**: 2025-07-06

## 📤 Способы загрузки в TestFlight

### Вариант 1: Через Xcode Organizer (Рекомендуется)

1. **Откройте Xcode**
2. **Window → Organizer** (или ⌥⌘⇧O)
3. **Вкладка Archives**
4. **Выберите последний архив LMS**
5. **Нажмите "Distribute App"**
6. **Выберите "App Store Connect"**
7. **Upload** → Next → Automatic signing → Upload

### Вариант 2: Через Transporter

1. **Скачайте Transporter** из Mac App Store (бесплатно)
2. **Откройте Transporter**
3. **Войдите с Apple ID** (тот же, что для Developer Account)
4. **Перетащите** `LMS.ipa` в окно Transporter
5. **Нажмите "Deliver"**

### Вариант 3: Через командную строку (xcrun altool)

```bash
# Загрузка IPA
xcrun altool --upload-app \
    -f build/LMS-TestFlight/LMS.ipa \
    -t ios \
    -u YOUR_APPLE_ID \
    -p YOUR_APP_SPECIFIC_PASSWORD
```

## 🧹 Управление билдами в TestFlight

### Деактивация старых билдов:

1. **Откройте App Store Connect**
   - https://appstoreconnect.apple.com

2. **My Apps → LMS**

3. **TestFlight вкладка**

4. **Для каждого старого билда:**
   - Нажмите на номер билда
   - "Expire Build" или снимите галочку "Test"
   - Это сделает билд недоступным для тестировщиков

### Активация нового билда:

1. **После загрузки подождите 5-30 минут** для обработки

2. **Обновите страницу TestFlight**

3. **Найдите Build 104**

4. **Нажмите на билд**

5. **Заполните:**
   - What to Test (из testflight_notes.txt)
   - Test Information

6. **Добавьте в группы тестировщиков:**
   - Internal Testing (автоматически)
   - External Testing (если есть)

## 📝 Информация для TestFlight (Build 104)

```
🏆 Sprint 34 Completed Successfully!

🎯 Achievements:
• Code coverage doubled: 11.57% (from 5.60%)
• 1051 tests total in project
• 258 ViewModels tests created
• Components migration completed

📊 Coverage Stats:
• 8,853 lines covered
• 76,515 total lines
• Major growth in test suite

✅ All tests passing
🚀 Build #104
```

## ⚡ Быстрые команды

### Проверка статуса загрузки:
```bash
# Если использовали xcrun altool
xcrun altool --list-apps -u YOUR_APPLE_ID -p YOUR_APP_SPECIFIC_PASSWORD
```

### Автоматизация через Fastlane (если установлен):
```bash
# Установка Fastlane
sudo gem install fastlane

# Инициализация
fastlane init

# Загрузка
fastlane pilot upload
```

## 🔍 Проверка после загрузки

1. **Email уведомление** придет на Apple ID
2. **Processing время**: обычно 5-30 минут
3. **Статусы**:
   - Processing - обрабатывается
   - Ready to Test - готов к тестированию
   - Invalid - есть проблемы

## ❓ Частые проблемы

### "Missing Compliance"
- В App Store Connect → выберите "No" для encryption

### "Invalid Binary"
- Проверьте provisioning profile
- Убедитесь в правильной подписи

### "Processing застрял"
- Подождите до 24 часов
- Проверьте email на предмет ошибок

## 📱 Для тестировщиков

После активации билда:
1. Откройте TestFlight на iPhone/iPad
2. Обновите список билдов (потяните вниз)
3. Установите Build 104
4. Тестируйте новый функционал!

---
*Последнее обновление: 2025-07-06* 