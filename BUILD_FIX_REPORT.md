# Отчет об исправлении ошибок сборки LMS

## Дата: 18 июля 2025

### Проблема
При попытке очистить кэш и выполнить сборку приложения возникла ошибка:
```
Could not compute dependency graph: unable to load transferred PIF: 
The workspace contains multiple references with the same GUID 'PACKAGE:16PZWNA0Q07I02A4QD9E3M4A8AVJ9CW1I::MAINGROUP'
```

### Решение

1. **Очистка кэша и временных файлов:**
   - Удален DerivedData: `~/Library/Developer/Xcode/DerivedData/LMS-*`
   - Удалена локальная папка build
   - Удален Package.resolved
   - Очищен кэш Swift Package Manager

2. **Исправлены ошибки компиляции:**
   
   a) **LogUploader.swift:**
   - Добавлен import UIKit
   - Исправлен доступ к sessionId через публичный getter currentSessionId
   - Исправлена инициализация LogUploadData
   - Устранено предупреждение о nil coalescing

   b) **TelegramFeedView.swift:**
   - Разбита сложная структура body на отдельные компоненты
   - Добавлены недостающие параметры onDismiss для TelegramFeedSettingsView и FeedDetailView
   - Исправлено использование category (убран optional chaining)

   c) **TelegramFeedViewModel.swift:**
   - Добавлен метод markAsUnread

3. **Успешная сборка и запуск:**
   - Сборка выполнена с флагами: CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""
   - Приложение установлено в симулятор iPhone 16 Pro
   - Bundle ID: ru.tsum.lms.igor
   - Process ID: 38039

### Результат
✅ **BUILD SUCCEEDED**
✅ Приложение успешно запущено в симуляторе
✅ Симулятор открыт для визуальной проверки

### Команды для повторной сборки
```bash
# Очистка
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*
rm -rf build

# Сборка
xcodebuild -scheme LMS -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -configuration Debug build CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""

# Установка и запуск
xcrun simctl install <DEVICE_ID> <PATH_TO_APP>
xcrun simctl launch <DEVICE_ID> ru.tsum.lms.igor
``` 