# Apple Developer Setup Guide для LMS

## 📋 Предварительные требования

- [ ] Apple Developer Account ($99/год)
- [ ] macOS с установленным Xcode (версия 14.0+)
- [ ] Установленные инструменты командной строки Xcode
- [ ] Fastlane (`sudo gem install fastlane`)

## 🔧 Шаг 1: Настройка Apple Developer Account

### 1.1 Получение Team ID
1. Войдите в [developer.apple.com](https://developer.apple.com)
2. Перейдите в **Account** → **Membership**
3. Скопируйте ваш **Team ID** (10 символов, например: `ABCDE12345`)

### 1.2 Создание App ID
1. Перейдите в **Certificates, Identifiers & Profiles**
2. Выберите **Identifiers** → **+**
3. Выберите **App IDs** → **Continue**
4. Выберите **App** → **Continue**
5. Заполните:
   - **Description**: LMS Corporate University
   - **Bundle ID**: Explicit → `com.yourcompany.lms`
   - **Capabilities**: Выберите необходимые (Push Notifications, Sign in with Apple и т.д.)
6. **Continue** → **Register**

### 1.3 Создание сертификатов

#### Development Certificate:
1. **Certificates** → **+**
2. Выберите **Apple Development** → **Continue**
3. Следуйте инструкциям для создания CSR
4. Загрузите сертификат и установите в Keychain

#### Distribution Certificate:
1. **Certificates** → **+**
2. Выберите **Apple Distribution** → **Continue**
3. Используйте тот же CSR или создайте новый
4. Загрузите и установите

### 1.4 Создание Provisioning Profiles

#### Development Profile:
1. **Profiles** → **+**
2. Выберите **iOS App Development** → **Continue**
3. Выберите ваш App ID → **Continue**
4. Выберите сертификаты → **Continue**
5. Выберите устройства для тестирования → **Continue**
6. Название: `LMS Development` → **Generate**
7. Скачайте и установите

#### App Store Profile:
1. **Profiles** → **+**
2. Выберите **App Store** → **Continue**
3. Выберите ваш App ID → **Continue**
4. Выберите Distribution сертификат → **Continue**
5. Название: `LMS App Store` → **Generate**
6. Скачайте

## 🏗️ Шаг 2: Настройка проекта

### 2.1 Обновите Configuration.xcconfig
```bash
cd ios/LMS
open Configuration.xcconfig
```

Замените:
- `YOUR_TEAM_ID` → ваш Team ID
- `com.yourcompany.lms` → ваш Bundle ID

### 2.2 Обновите Fastlane конфигурацию
```bash
cd ios/LMS
open fastlane/Appfile
```

Замените:
- `your-email@example.com` → ваш Apple ID email
- `YOUR_TEAM_ID` → ваш Team ID
- `com.yourcompany.lms` → ваш Bundle ID

### 2.3 Настройка Match (опционально, но рекомендуется)
Match синхронизирует сертификаты между членами команды:

```bash
cd ios/LMS
fastlane match init
```

Выберите `git` и укажите приватный репозиторий для хранения сертификатов.

## 📱 Шаг 3: Создание приложения в App Store Connect

1. Перейдите на [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **My Apps** → **+** → **New App**
3. Заполните:
   - **Platforms**: iOS
   - **Name**: LMS Corporate University (или ваше название)
   - **Primary Language**: Russian
   - **Bundle ID**: выберите созданный
   - **SKU**: `lms-corporate-university`
4. **Create**

## 🚀 Шаг 4: Первая сборка и загрузка

### 4.1 Подготовка
```bash
cd ios/LMS

# Установите зависимости
bundle install
pod install # если используете CocoaPods

# Проверьте настройки
fastlane run validate_build
```

### 4.2 Сборка для TestFlight
```bash
# Запустите тесты
fastlane test

# Соберите и загрузите в TestFlight
fastlane beta
```

### 4.3 Настройка TestFlight
1. В App Store Connect перейдите в ваше приложение
2. **TestFlight** → дождитесь обработки сборки
3. **Test Information** → заполните обязательные поля
4. **Internal Testing** → создайте группу
5. Добавьте тестировщиков

## 📝 Шаг 5: Подготовка к публикации

### 5.1 App Store информация
В App Store Connect заполните:
- **App Information**: категории, возрастной рейтинг
- **Pricing and Availability**: бесплатно/платно, страны
- **App Privacy**: политика конфиденциальности
- **Version Information**:
  - Screenshots (6.5", 5.5", iPad)
  - Description
  - Keywords
  - Support URL
  - Marketing URL

### 5.2 Скриншоты
Создайте скриншоты для всех требуемых размеров:
- iPhone 6.7" (1290 x 2796)
- iPhone 6.5" (1242 x 2688)
- iPhone 5.5" (1242 x 2208)
- iPad Pro 12.9" (2048 x 2732)

### 5.3 Финальная публикация
```bash
# Загрузка в App Store
fastlane release
```

В App Store Connect:
1. Выберите сборку
2. **Submit for Review**
3. Ответьте на вопросы о контенте
4. **Submit**

## 🛠️ Полезные команды

```bash
# Обновить сертификаты
fastlane certificates

# Создать push сертификаты
fastlane push

# Проверить окружение
fastlane env

# Обновить Fastlane
fastlane update_fastlane
```

## ⚠️ Частые проблемы

### "No code signing identity found"
```bash
# Переустановите сертификаты
fastlane match nuke distribution
fastlane match appstore
```

### "Invalid provisioning profile"
1. Удалите старые профили в Xcode
2. Перезагрузите через fastlane match

### "Version already exists"
Увеличьте версию в Configuration.xcconfig

## 📞 Поддержка

- [Apple Developer Forums](https://developer.apple.com/forums/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

## ✅ Чеклист перед публикацией

- [ ] Все тесты проходят
- [ ] Нет warning'ов в Xcode
- [ ] App Icon установлена для всех размеров
- [ ] Launch Screen настроен
- [ ] Privacy Policy URL указан
- [ ] Скриншоты загружены
- [ ] Описание на русском языке
- [ ] Ключевые слова оптимизированы
- [ ] TestFlight тестирование пройдено 