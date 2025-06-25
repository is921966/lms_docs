# 🚀 Следующие шаги после создания проекта

## ✅ Что у нас есть
- Новый iOS проект создан в `/LMS_App/LMS/`
- Базовая структура SwiftUI приложения готова

## 📋 Что нужно сделать сейчас

### 1️⃣ Запустите проект для создания сертификатов (2 минуты)

**ВАЖНО**: Xcode создаст сертификаты только при первом запуске!

1. В Xcode убедитесь, что:
   - Выбран проект LMS в навигаторе
   - На вкладке **Signing & Capabilities** включен **Automatically manage signing**
   - Team выбран правильно

2. **Запустите приложение**:
   - Вверху выберите симулятор (например, iPhone 15)
   - Нажмите **Run** (▶️)
   - Дождитесь, пока приложение запустится в симуляторе

3. **Что произойдет**:
   - Xcode автоматически создаст Development Certificate
   - Создаст Provisioning Profile
   - Настроит все необходимое для разработки

### 2️⃣ Создайте приложение в App Store Connect (5 минут)

1. Перейдите на [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **My Apps** → **+** → **New App**
3. Заполните:
   - **Platform**: iOS
   - **Name**: ЦУМ: Корпоративный университет
   - **Primary Language**: Russian
   - **Bundle ID**: ru.tsum.LMS (выберите из выпадающего списка)
   - **SKU**: tsum-lms-2025
   - **User Access**: Full Access

### 3️⃣ Добавьте иконку приложения (5 минут)

1. В Xcode откройте `Assets.xcassets`
2. Выберите `AppIcon`
3. Добавьте иконку 1024x1024 для App Store
4. Опционально: добавьте иконки других размеров

### 4️⃣ Настройте Fastlane (10 минут)

```bash
# Перейдите в папку проекта
cd /Users/ishirokov/lms_docs/LMS_App/LMS

# Создайте Gemfile
cat > Gemfile << 'EOF'
source "https://rubygems.org"
gem "fastlane"
EOF

# Установите зависимости
bundle install

# Инициализируйте Fastlane
bundle exec fastlane init
```

При инициализации выберите опцию **2** (Automate beta distribution to TestFlight).

### 5️⃣ Настройте файлы Fastlane

Скопируйте настройки из старого проекта:
```bash
cp /Users/ishirokov/lms_docs/ios/LMS/fastlane/Appfile fastlane/
cp /Users/ishirokov/lms_docs/ios/LMS/fastlane/Fastfile fastlane/
```

### 6️⃣ Первая сборка для TestFlight (15 минут)

```bash
# Проверьте, что все работает
bundle exec fastlane test

# Загрузите в TestFlight
bundle exec fastlane beta
```

## 📱 Проверка готовности

Перед загрузкой в TestFlight убедитесь:
- [ ] Приложение запускается в симуляторе
- [ ] Иконка добавлена (хотя бы 1024x1024)
- [ ] Bundle ID совпадает с App Store Connect
- [ ] Версия приложения корректная (1.0.0)

## 🎯 План на ближайший час

1. **Сейчас**: Запустите приложение в симуляторе (2 мин)
2. **+5 мин**: Создайте приложение в App Store Connect
3. **+10 мин**: Добавьте иконку
4. **+20 мин**: Настройте Fastlane
5. **+40 мин**: Сделайте первую сборку для TestFlight

## ⚠️ Частые проблемы

### "No signing certificate"
- Убедитесь, что выбран Team
- Запустите приложение хотя бы раз

### "App Store Connect не видит Bundle ID"
- Подождите 5-10 минут после создания в Xcode
- Обновите страницу в браузере

### "Fastlane не может найти проект"
- Убедитесь, что вы в правильной директории
- Должен быть файл `LMS.xcodeproj` в текущей папке

---

**Начните с запуска приложения в симуляторе** - это создаст все необходимые сертификаты! 