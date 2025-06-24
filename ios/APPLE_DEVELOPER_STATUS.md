# 📊 Статус настройки Apple Developer для LMS

**Дата проверки**: 2025-01-20

## ✅ Что уже настроено

### 1. Xcode и инструменты разработки
- ✅ **Xcode установлен**: версия 16.4 (Build 16F6)
- ✅ **Command Line Tools**: установлены и настроены
- ✅ **Путь к Developer Tools**: `/Applications/Xcode.app/Contents/Developer`

### 2. Конфигурация проекта
- ✅ **Bundle ID**: `ru.tsum.lms`
- ✅ **Team ID**: `N85286S93X`
- ✅ **Apple ID**: `igor.shirokov@mac.com`
- ✅ **Configuration.xcconfig**: создан и настроен
- ✅ **Fastlane Appfile**: создан и настроен

## ❌ Что нужно сделать

### 1. Сертификаты для подписи кода
- ❌ **Development Certificate**: не установлен
- ❌ **Distribution Certificate**: не установлен

**Действия**:
1. Войдите в [developer.apple.com](https://developer.apple.com)
2. Перейдите в **Certificates, Identifiers & Profiles**
3. Создайте и скачайте сертификаты
4. Дважды кликните для установки

### 2. Provisioning Profiles
- ❌ **Development Profile**: не установлен
- ❌ **App Store Profile**: не установлен

**Действия**:
1. Создайте профили в Apple Developer Portal
2. Скачайте `.mobileprovision` файлы
3. Дважды кликните для установки

### 3. Fastlane зависимости
- ❌ **Ruby gems**: не установлены

**Действия**:
```bash
cd ios/LMS
bundle install
```

## 🔧 Быстрые действия для завершения настройки

### Шаг 1: Установите зависимости Fastlane
```bash
cd /Users/ishirokov/lms_docs/ios/LMS
bundle install
```

### Шаг 2: Автоматическая настройка через Xcode
Самый простой способ - позволить Xcode всё настроить автоматически:

```bash
open /Users/ishirokov/lms_docs/ios/LMS/LMS.xcodeproj
```

В Xcode:
1. Выберите проект **LMS** в навигаторе
2. Перейдите на вкладку **Signing & Capabilities**
3. Поставьте галочку **☑️ Automatically manage signing**
4. Выберите Team: **Igor Shirokov (Personal Team)**
5. Xcode автоматически создаст и установит все сертификаты и профили

### Шаг 3: Проверка App Store Connect
1. Войдите в [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Создайте новое приложение:
   - Name: **ЦУМ LMS**
   - Bundle ID: **ru.tsum.lms**
   - SKU: **tsum-lms**

## 📋 Чек-лист готовности к публикации

- [x] Apple Developer Account активен
- [x] Team ID получен
- [x] Bundle ID определен
- [x] Конфигурационные файлы созданы
- [ ] Development Certificate установлен
- [ ] Distribution Certificate установлен
- [ ] Provisioning Profiles установлены
- [ ] Fastlane настроен
- [ ] Приложение создано в App Store Connect
- [ ] Первая сборка загружена в TestFlight

## 🚀 Следующие шаги

1. **Сейчас**: Установите Fastlane зависимости
2. **Далее**: Откройте проект в Xcode и включите автоматическое управление подписью
3. **После**: Создайте приложение в App Store Connect
4. **Финал**: Запустите `fastlane beta` для загрузки в TestFlight

## 💡 Рекомендации

- Используйте **Automatically manage signing** для начала - это проще
- Создайте App Store Connect API key для автоматизации
- Настройте CI/CD через GitHub Actions после первой успешной сборки

## 📞 Поддержка

Если возникнут проблемы:
1. Проверьте этот статус: `cat ios/APPLE_DEVELOPER_STATUS.md`
2. Запустите проверку: `./ios/check-provisioning.sh`
3. Обратитесь в Apple Developer Support 