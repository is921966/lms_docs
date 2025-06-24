# 🎯 Следующие шаги для публикации LMS в App Store

## 📊 Текущий статус
- ✅ Xcode проект открывается (через Package.swift)
- ✅ Конфигурация настроена (Bundle ID, Team ID)
- ❌ Сертификаты не установлены
- ❌ Provisioning profiles не созданы
- ❌ Fastlane не установлен

## 🚀 План действий

### Шаг 1: Настройка автоматической подписи в Xcode (5 минут)

Это самый важный шаг - Xcode создаст все необходимые сертификаты автоматически:

1. **Откройте проект в Xcode**:
   ```bash
   cd /Users/ishirokov/lms_docs/ios/LMS
   open Package.swift
   ```

2. **В Xcode**:
   - Выберите **LMS** в списке targets слева
   - Перейдите на вкладку **Signing & Capabilities**
   - Поставьте галочку **☑️ Automatically manage signing**
   - В поле **Team** выберите: **Igor Shirokov (Personal Team)**
   - Xcode автоматически создаст:
     - Development Certificate
     - Provisioning Profile
     - Все необходимые настройки

3. **Проверьте, что все работает**:
   - Выберите симулятор iPhone
   - Нажмите **Run** (▶️)
   - Приложение должно запуститься в симуляторе

### Шаг 2: Создание приложения в App Store Connect (10 минут)

1. **Войдите в [App Store Connect](https://appstoreconnect.apple.com)**

2. **Создайте новое приложение**:
   - My Apps → **+** → **New App**
   - Platform: **iOS**
   - Name: **ЦУМ: Корпоративный университет**
   - Primary Language: **Russian**
   - Bundle ID: **ru.tsum.lms** (выберите из списка)
   - SKU: **tsum-lms-2025**
   - User Access: **Full Access**

3. **Заполните базовую информацию**:
   - Category: **Business** или **Education**
   - Content Rights: подтвердите права

### Шаг 3: Установка Fastlane (15 минут)

Для автоматизации сборки и публикации:

```bash
cd /Users/ishirokov/lms_docs/ios/LMS

# Установка Bundler и Fastlane
sudo gem install bundler
bundle init
echo 'gem "fastlane"' >> Gemfile
bundle install

# Инициализация Fastlane
bundle exec fastlane init
```

Выберите опцию **4** (Manual setup) при инициализации.

### Шаг 4: Первая сборка для TestFlight (20 минут)

1. **Подготовьте иконку приложения**:
   - Размер: 1024x1024 px
   - Формат: PNG без прозрачности
   - Добавьте в Assets.xcassets в Xcode

2. **Увеличьте версию** (если нужно):
   ```bash
   # В Configuration.xcconfig измените:
   CURRENT_PROJECT_VERSION = 2
   ```

3. **Запустите сборку**:
   ```bash
   cd /Users/ishirokov/lms_docs/ios/LMS
   bundle exec fastlane beta
   ```

### Шаг 5: Настройка TestFlight (5 минут)

1. В **App Store Connect** → ваше приложение → **TestFlight**
2. Дождитесь обработки сборки (обычно 5-10 минут)
3. Заполните **Test Information**:
   - What to Test
   - Test Instructions
   - Email и другие контакты
4. Создайте группу тестировщиков
5. Пригласите себя для тестирования

## ⏱️ Общее время: ~1 час

## 🎯 Приоритеты на сегодня

1. **Сейчас (5 мин)**: Настройте автоматическую подпись в Xcode - это разблокирует все остальное
2. **Далее (10 мин)**: Создайте приложение в App Store Connect
3. **Потом (15 мин)**: Установите Fastlane для автоматизации

## ❓ Частые вопросы

**Q: Нужно ли создавать сертификаты вручную?**
A: Нет! При включении "Automatically manage signing" Xcode создаст все автоматически.

**Q: Могу ли я тестировать без публикации?**
A: Да, можете запускать на симуляторе сразу. Для тестирования на реальном устройстве нужен Apple Developer аккаунт.

**Q: Что если Fastlane не устанавливается?**
A: Можно делать сборки вручную через Xcode: Product → Archive → Distribute App

## 🆘 Проблемы?

Если что-то не работает:
1. Убедитесь, что вошли в Xcode с вашим Apple ID
2. Проверьте интернет-соединение
3. Перезапустите Xcode
4. Обратитесь в поддержку Apple Developer

---

**Начните с Шага 1** - настройка автоматической подписи в Xcode. Это займет буквально 5 минут! 