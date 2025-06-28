# 🚀 Xcode Cloud Quick Start Guide

**Дата создания**: 2025-06-27  
**Время настройки**: ~30 минут  
**Требования**: Apple Developer аккаунт, Xcode 15+

## 📋 Шаг 1: Подключение к Xcode Cloud

### В Xcode:
1. Откройте проект `LMS_App/LMS/LMS.xcodeproj`
2. Меню: **Product → Xcode Cloud → Create Workflow**
3. Выберите **LMS** как primary app
4. Нажмите **Next**

### Авторизация:
1. Войдите в Apple ID с Developer аккаунтом
2. Выберите Team: **Igor Shirokov (Personal Team)**
3. Согласитесь с условиями использования

## 📱 Шаг 2: Создание базового Workflow

### Название и триггеры:
```
Workflow Name: Build and Test
Branch Changes: main, develop, feature/*
Pull Request Changes: ✅ Enabled
Tag Changes: ✅ Enabled (v*)
```

### Настройка Environment:
```
Xcode Version: Latest Release
macOS Version: Latest
Clean: ✅ Before Build
```

## 🧪 Шаг 3: Настройка Actions

### 1. Build Action:
```
Platform: iOS
Scheme: LMS
Configuration: Debug
Destination: Any iOS Device
```

### 2. Test Action:
```
Platform: iOS Simulator
Scheme: LMS
Test Plan: All Tests
Devices:
  - iPhone 16 Pro (Latest)
  - iPad Pro 12.9" (Latest)
Parallel Testing: ✅ Enabled
Code Coverage: ✅ Enabled
```

### 3. Archive Action (только для main):
```
Condition: Branch is main
Platform: iOS
Scheme: LMS
Configuration: Release
Distribution: TestFlight & App Store
```

## 📝 Шаг 4: Создание CI Scripts

### Структура папок:
```bash
mkdir -p LMS_App/LMS/ci_scripts
cd LMS_App/LMS/ci_scripts
```

### 1. Post-Clone Script:
```bash
# ci_scripts/ci_post_clone.sh
#!/bin/sh

set -e

echo "🚀 Running post-clone setup..."

cd "$CI_PRIMARY_REPOSITORY_PATH/LMS_App/LMS"

# Install dependencies
if [ -f "Gemfile" ]; then
    echo "💎 Installing bundler..."
    gem install bundler
    bundle install
fi

# Generate build number
echo "📝 Setting build number to $CI_BUILD_NUMBER"

echo "✅ Post-clone complete!"
```

### 2. Post-Build Script:
```bash
# ci_scripts/ci_post_xcodebuild.sh
#!/bin/sh

echo "📊 Build completed!"
echo "Build Number: $CI_BUILD_NUMBER"
echo "Product: $CI_PRODUCT"

# Upload dSYMs для crash reporting
if [ "$CI_XCODEBUILD_ACTION" = "archive" ]; then
    echo "📤 Uploading dSYMs..."
    # Здесь можно добавить загрузку в Crashlytics/Sentry
fi
```

### 3. Сделать скрипты исполняемыми:
```bash
chmod +x ci_scripts/*.sh
git add ci_scripts/
git commit -m "Add Xcode Cloud CI scripts"
git push
```

## 🔐 Шаг 5: Environment Variables

В Xcode Cloud настройках добавьте:

| Variable | Value | Secret |
|----------|-------|--------|
| API_BASE_URL | https://api.lms.example.com | ❌ |
| SLACK_WEBHOOK | https://hooks.slack.com/... | ✅ |
| SENTRY_DSN | https://sentry.io/... | ✅ |

## 📤 Шаг 6: Post-Actions

### TestFlight Distribution:
1. **What to Distribute**: TestFlight & App Store
2. **TestFlight Groups**: 
   - Internal Testers ✅
   - Beta Testers ❌ (пока)
3. **Release Notes**: From git commits

### Notifications:
1. **Email**: ✅ On failure
2. **Slack**: Configure webhook
3. **App Store Connect**: ✅ Auto

## ✅ Шаг 7: Первый запуск

### Запуск вручную:
1. В Xcode: **Product → Xcode Cloud → Manage Workflows**
2. Выберите workflow
3. Нажмите **Start Build**

### Проверка результатов:
1. Откройте Report Navigator (⌘9)
2. Выберите Cloud tab
3. Просмотрите:
   - ✅ Build status
   - 📊 Test results  
   - 📱 Artifacts
   - 📋 Logs

## 🚨 Решение проблем

### Ошибка: "No scheme found"
```bash
# Убедитесь что схема shared
1. Xcode → Product → Scheme → Manage Schemes
2. ✅ Shared для LMS scheme
3. Commit: LMS.xcodeproj/xcshareddata/
```

### Ошибка: "Signing failed"
```bash
# Xcode Cloud управляет подписью автоматически
1. Build Settings → Signing
2. Code Signing Style = Automatic
3. Development Team = N85286S93X
```

### Ошибка: "Test failed"
```bash
# Проверьте логи
1. Cloud Report → Test Results
2. Найдите failed test
3. View device logs
```

## 📊 Мониторинг использования

### Проверка лимитов:
1. [App Store Connect](https://appstoreconnect.apple.com)
2. Xcode Cloud → Usage
3. Текущее использование: X/25 часов

### Оптимизация:
- Используйте `Skip Build` для документации
- Отключите ненужные устройства в тестах
- Используйте incremental builds

## 🎯 Следующие шаги

1. **Добавить больше тестовых устройств**
2. **Настроить external testing groups**
3. **Добавить performance tests**
4. **Интегрировать с JIRA/Slack**
5. **Настроить branch policies**

## 📚 Полезные команды

```bash
# Просмотр всех workflows
xcodebuild -showCloudWorkflows

# Запуск build из командной строки
xcodebuild -runCloudWorkflow "Build and Test"

# Экспорт результатов
xcrun xcresulttool get --path Result.xcresult --format json
```

## 🔗 Ресурсы

- [Xcode Cloud Docs](https://developer.apple.com/documentation/xcode/xcode-cloud)
- [CI Environment Variables](https://developer.apple.com/documentation/xcode/environment-variable-reference)
- [Troubleshooting Guide](https://developer.apple.com/documentation/xcode/troubleshooting-common-xcode-cloud-issues) 