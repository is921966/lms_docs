# Руководство по созданию TestFlight сборки

## 🚀 Быстрый старт

```bash
# Из корня проекта
./scripts/prepare-testflight-build.sh
```

## 📋 Предварительные требования

1. **Xcode** установлен и настроен
2. **Apple Developer Account** с доступом к TestFlight
3. **Provisioning Profile** для App Store distribution
4. **Signing Certificate** установлен в Keychain

## 🔧 Пошаговая инструкция

### Шаг 1: Подготовка проекта

```bash
# Очистка старых сборок
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*

# Проверка компиляции
cd LMS_App/LMS
xcodebuild -scheme LMS -destination 'generic/platform=iOS' clean build CODE_SIGNING_REQUIRED=NO
```

### Шаг 2: Обновление версии

1. Откройте `LMS/Info.plist`
2. Обновите:
   - `CFBundleShortVersionString` - версия (например, 2.1.1)
   - `CFBundleVersion` - номер сборки (например, 206)

### Шаг 3: Создание Release Notes

Создайте файл `/docs/releases/TESTFLIGHT_RELEASE_vX.X.X_buildXXX.md`:

```markdown
# TestFlight Release vX.X.X

**Build**: XXX
**Date**: YYYY-MM-DD

## 🎯 Основные изменения

### ✨ Новые функции
- Функция 1
- Функция 2

### 🔧 Улучшения
- Улучшение 1
- Улучшение 2

### 🐛 Исправления
- Исправление 1
- Исправление 2

## 📋 Что нового для тестировщиков

### Проверьте следующие функции:
- Сценарий 1
- Сценарий 2

## 🐛 Известные проблемы
- Проблема 1
```

### Шаг 4: Создание архива в Xcode

1. Откройте `LMS.xcodeproj` в Xcode
2. Выберите схему `LMS`
3. Выберите устройство `Any iOS Device (arm64)`
4. Product → Archive
5. Дождитесь завершения (5-10 минут)

### Шаг 5: Загрузка в TestFlight

1. В Organizer выберите созданный архив
2. Нажмите `Distribute App`
3. Выберите `TestFlight & App Store`
4. Следуйте мастеру:
   - Upload
   - Automatically manage signing
   - Upload

### Шаг 6: Настройка в App Store Connect

1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Выберите ваше приложение
3. TestFlight → Builds
4. Дождитесь обработки (15-30 минут)
5. Добавьте Release Notes
6. Добавьте тестировщиков

## 🛠️ Автоматизация с помощью скрипта

Скрипт `prepare-testflight-build.sh` автоматизирует:

- ✅ Очистку build папок
- ✅ Запуск тестов
- ✅ Обновление версии
- ✅ Генерацию release notes
- ✅ Создание архива
- ✅ Экспорт IPA (опционально)

### Использование:

```bash
./scripts/prepare-testflight-build.sh
```

### Параметры скрипта:

- Интерактивно запрашивает обновление версии
- Автоматически создает шаблон release notes
- Генерирует release news для приложения
- Создает архив с правильным именем

## 📱 Release News в приложении

При использовании скрипта автоматически:

1. Генерируются release notes для приложения
2. При первом запуске новой версии пользователи увидят:
   - In-app уведомление о новой версии
   - Новость в ленте с подробным описанием изменений

## ⚠️ Частые проблемы

### Проблема: "No signing certificate"

**Решение**: 
1. Откройте Xcode → Preferences → Accounts
2. Добавьте Apple ID
3. Download Manual Profiles

### Проблема: "Archive failed"

**Решение**:
1. Проверьте схему: Edit Scheme → Archive → Release configuration
2. Очистите DerivedData
3. Перезапустите Xcode

### Проблема: "Export failed"

**Решение**:
1. Обновите `ExportOptions.plist` с вашим Team ID
2. Проверьте provisioning profile
3. Используйте ручной экспорт через Xcode

## 📊 Чеклист перед релизом

- [ ] Все тесты проходят
- [ ] Версия обновлена
- [ ] Release notes написаны
- [ ] Архив создан успешно
- [ ] TestFlight build загружен
- [ ] Тестировщики добавлены
- [ ] Release notes в App Store Connect обновлены

## 🎯 Best Practices

1. **Версионирование**: Используйте семантическое версионирование (X.Y.Z)
2. **Build номера**: Всегда увеличивайте для каждой загрузки
3. **Release Notes**: Пишите понятно для тестировщиков
4. **Тестирование**: Всегда проверяйте критические пути перед загрузкой
5. **Feedback**: Включайте систему обратной связи в TestFlight сборки

## 📚 Дополнительные ресурсы

- [Apple TestFlight Documentation](https://developer.apple.com/testflight/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) 