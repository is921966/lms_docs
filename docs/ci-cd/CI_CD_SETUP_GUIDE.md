# 🚀 CI/CD Setup Guide для iOS приложения LMS

Это руководство поможет настроить автоматическую сборку и публикацию iOS приложения в TestFlight через GitHub Actions.

## 📋 Что нужно подготовить

### 1. App Store Connect API Key
Это самый надежный способ аутентификации для CI/CD.

1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Перейдите в **Users and Access** → **Keys**
3. Нажмите **+** для создания нового ключа
4. Заполните:
   - **Name**: `GitHub Actions CI`
   - **Access**: `App Manager`
5. Скачайте `.p8` файл (он скачается только один раз!)
6. Запомните:
   - **Key ID** (10 символов)
   - **Issuer ID** (UUID формата)

### 2. Сертификаты и Provisioning Profile

#### Экспорт сертификата:
1. Откройте **Keychain Access** на Mac
2. Найдите **Apple Distribution: Igor Shirokov**
3. Правый клик → **Export**
4. Сохраните как `.p12` файл с паролем
5. Запомните пароль!

#### Получение Provisioning Profile:
1. В Xcode: **Preferences** → **Accounts** → **Download Manual Profiles**
2. Или скачайте с [developer.apple.com](https://developer.apple.com)
3. Найдите Distribution profile для `ru.tsum.lms.igor`

### 3. Конвертация в Base64

```bash
# Конвертируем сертификат
base64 -i certificate.p12 -o certificate_base64.txt

# Конвертируем provisioning profile
base64 -i profile.mobileprovision -o profile_base64.txt

# Конвертируем API key
base64 -i AuthKey_XXXXXXXXXX.p8 -o apikey_base64.txt
```

## 🔐 Настройка GitHub Secrets

В вашем репозитории на GitHub:
1. Перейдите в **Settings** → **Secrets and variables** → **Actions**
2. Добавьте следующие секреты:

| Secret Name | Description | Как получить |
|-------------|-------------|--------------|
| `APP_STORE_CONNECT_API_KEY_ID` | ID ключа API | Из App Store Connect (10 символов) |
| `APP_STORE_CONNECT_API_KEY_ISSUER_ID` | Issuer ID | Из App Store Connect (UUID) |
| `APP_STORE_CONNECT_API_KEY_KEY` | Содержимое .p8 файла в base64 | `base64 -i AuthKey_XXX.p8` |
| `BUILD_CERTIFICATE_BASE64` | Distribution сертификат в base64 | `base64 -i certificate.p12` |
| `P12_PASSWORD` | Пароль от .p12 файла | Тот, что вы задали при экспорте |
| `BUILD_PROVISION_PROFILE_BASE64` | Provisioning profile в base64 | `base64 -i profile.mobileprovision` |
| `KEYCHAIN_PASSWORD` | Любой пароль для временного keychain | Например: `temp_ci_keychain_pwd` |
| `SLACK_WEBHOOK` | (Опционально) Webhook для уведомлений | Из Slack App |

## 🔧 Обновление Fastfile

Fastfile уже обновлен для работы с CI/CD. Основные изменения:
- Добавлена поддержка App Store Connect API
- Условная логика для CI окружения
- Автоматическое получение последнего build number

## 📁 Структура файлов

```
.github/
└── workflows/
    └── ios-deploy.yml    # Конфигурация GitHub Actions

LMS_App/
└── LMS/
    ├── fastlane/
    │   ├── Fastfile     # Обновлен для CI/CD
    │   └── Appfile      # Конфигурация приложения
    └── Gemfile          # Ruby зависимости
```

## 🚀 Как это работает

### При push в main:
1. Запускаются тесты
2. Если тесты прошли - создается сборка
3. Build number автоматически увеличивается
4. Приложение загружается в TestFlight
5. Отправляется уведомление (если настроен Slack)

### При push в develop:
1. Только запускаются тесты
2. Сборка не создается

### При Pull Request:
1. Запускаются тесты
2. Результаты отображаются в PR

## 🧪 Тестирование CI/CD

### Локальная проверка:
```bash
# Проверьте, что Fastlane работает локально
cd LMS_App/LMS
bundle exec fastlane test
bundle exec fastlane build
```

### Первый запуск в GitHub:
1. Создайте все секреты
2. Сделайте небольшое изменение
3. Создайте Pull Request в main
4. Проверьте, что тесты запустились
5. После merge проверьте полный pipeline

## ⚠️ Частые проблемы

### "No signing certificate"
- Проверьте, что сертификат правильно экспортирован
- Убедитесь, что используется Distribution сертификат

### "Invalid provisioning profile"
- Profile должен быть для App Store distribution
- Bundle ID должен совпадать

### "API key not found"
- Проверьте правильность base64 кодирования
- Убедитесь, что не добавили лишние переносы строк

## 📈 Мониторинг

### GitHub Actions:
- Перейдите в **Actions** tab в репозитории
- Смотрите логи выполнения
- Проверяйте время выполнения

### TestFlight:
- Новые сборки появятся автоматически
- Build numbers будут последовательными
- Changelog будет указывать на CI сборку

## 🔄 Обновление сертификатов

Сертификаты истекают через год. Для обновления:
1. Создайте новые сертификаты
2. Экспортируйте и конвертируйте в base64
3. Обновите GitHub Secrets
4. Коммит не требуется - изменения применятся автоматически

## 💡 Дополнительные возможности

### Автоматические скриншоты:
Добавьте в workflow:
```yaml
- name: Capture screenshots
  run: bundle exec fastlane snapshot
```

### Автоматический changelog:
Используйте conventional commits:
```
feat: новая функция
fix: исправление бага
```

### Версионирование:
Добавьте автоматическое обновление версии на основе тегов:
```yaml
- name: Bump version
  run: bundle exec fastlane bump_version tag:${{ github.ref }}
```

---

**Готово!** После настройки всех секретов, каждый push в main будет автоматически создавать новую сборку в TestFlight. 🎉

# This file contains the fastlane.tools configuration
# You can find the documentation at https://docs.fastlane.tools
#
# For a list of all available actions, check out
#
#     https://docs.fastlane.tools/actions
#
# For a list of all available plugins, check out
#
#     https://docs.fastlane.tools/plugins/available-plugins
#

# Uncomment the line if you want fastlane to automatically update itself
# update_fastlane

default_platform(:ios)

platform :ios do
  before_all do
    # Set up App Store Connect API if running in CI
    if ENV['CI']
      app_store_connect_api_key(
        key_id: ENV['APP_STORE_CONNECT_API_KEY_ID'],
        issuer_id: ENV['APP_STORE_CONNECT_API_KEY_ISSUER_ID'],
        key_content: ENV['APP_STORE_CONNECT_API_KEY_KEY'],
        is_key_content_base64: true,
        in_house: false
      )
    end
  end

  desc "Run tests"
  lane :test do
    run_tests(
      scheme: "LMS",
      clean: true,
      devices: ["iPhone 15"],
      skip_build: false,
      code_coverage: true
    )
  end

  desc "Build and upload to TestFlight"
  lane :beta do
    # Don't check git status in CI
    unless ENV['CI']
      ensure_git_status_clean
    end
    
    # Get latest build number from TestFlight
    latest_build = latest_testflight_build_number(
      app_identifier: "ru.tsum.lms.igor",
      initial_build_number: 0
    )
    
    # Increment build number
    increment_build_number(
      build_number: latest_build + 1
    )
    
    # Build the app
    build_app(
      scheme: "LMS",
      clean: true,
      export_method: "app-store",
      output_directory: "./build",
      output_name: "LMS.ipa",
      skip_profile_detection: ENV['CI'] ? true : false,
      export_options: ENV['CI'] ? {
        provisioningProfiles: {
          "ru.tsum.lms.igor" => "match AppStore ru.tsum.lms.igor"
        }
      } : nil
    )
    
    # Upload to TestFlight
    upload_to_testflight(
      skip_waiting_for_build_processing: true,
      changelog: ENV['CI'] ? "Automated build from CI" : "Bug fixes and improvements",
      distribute_external: false,
      notify_external_testers: false
    )
    
    # Commit the version bump only if not in CI
    unless ENV['CI']
      commit_version_bump(
        message: "Version Bump",
        xcodeproj: "LMS.xcodeproj"
      )
    end
  end

  desc "Deploy to App Store"
  lane :release do
    # Build the app
    build_app(
      scheme: "LMS",
      clean: true,
      export_method: "app-store"
    )
    
    # Upload to App Store
    upload_to_app_store(
      skip_metadata: false,
      skip_screenshots: false,
      submit_for_review: false,
      force: true,
      precheck_include_in_app_purchases: false
    )
  end

  desc "Create a new build without uploading"
  lane :build do
    build_app(
      scheme: "LMS",
      clean: true,
      export_method: "app-store",
      output_directory: "./build",
      output_name: "LMS.ipa"
    )
  end
end 