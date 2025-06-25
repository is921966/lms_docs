# CI/CD без Fastlane - Нативный подход Apple

## Преимущества нативного подхода

После проблем с fastlane (invalid curve name, несовместимость версий Ruby/OpenSSL), мы перешли на использование нативных инструментов Apple:

### ✅ Преимущества:
1. **Стабильность** - нет зависимости от Ruby, Bundler, OpenSSL
2. **Простота** - используем только xcodebuild и xcrun
3. **Скорость** - нет необходимости устанавливать зависимости
4. **Надежность** - официальные инструменты Apple
5. **Меньше точек отказа** - нет проблем с версиями gems

### 🛠 Используемые инструменты:

1. **xcodebuild** - для сборки и тестирования
2. **xcpretty** - для красивого вывода (опционально)
3. **xcrun altool** - для загрузки в TestFlight
4. **security** - для работы с keychain

## Процесс сборки

### 1. Тестирование
```bash
xcodebuild test \
  -project LMS.xcodeproj \
  -scheme LMS \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

### 2. Создание архива
```bash
xcodebuild archive \
  -project LMS.xcodeproj \
  -scheme LMS \
  -configuration Release \
  -archivePath build/LMS.xcarchive \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM=N85286S93X
```

### 3. Экспорт IPA
```bash
xcodebuild -exportArchive \
  -archivePath build/LMS.xcarchive \
  -exportPath build \
  -exportOptionsPlist ExportOptions.plist \
  -allowProvisioningUpdates
```

### 4. Загрузка в TestFlight
```bash
xcrun altool --upload-app \
  --type ios \
  --file build/LMS.ipa \
  --apiKey $API_KEY_ID \
  --apiIssuer $API_KEY_ISSUER_ID
```

## Настройка GitHub Secrets

Те же самые секреты, что и раньше:

1. **BUILD_CERTIFICATE_BASE64** - сертификат разработчика (.p12)
2. **P12_PASSWORD** - пароль от сертификата
3. **KEYCHAIN_PASSWORD** - пароль для временного keychain
4. **APP_STORE_CONNECT_API_KEY_ID** - ID ключа API
5. **APP_STORE_CONNECT_API_KEY_ISSUER_ID** - Issuer ID
6. **APP_STORE_CONNECT_API_KEY_KEY** - содержимое .p8 файла

## Отличия от Fastlane

| Fastlane | Нативный подход |
|----------|-----------------|
| `fastlane test` | `xcodebuild test` |
| `fastlane gym` | `xcodebuild archive` + `xcodebuild -exportArchive` |
| `fastlane pilot` | `xcrun altool --upload-app` |
| `match` | Automatic signing с `-allowProvisioningUpdates` |

## Troubleshooting

### Проблема: "No certificate for team"
**Решение**: Убедитесь, что сертификат правильно импортирован в keychain

### Проблема: "No profiles for bundle identifier"
**Решение**: Используйте `-allowProvisioningUpdates` для автоматического создания профилей

### Проблема: "altool: command not found"
**Решение**: Используйте полный путь: `xcrun altool`

## Локальное тестирование

Для проверки CI/CD локально:

```bash
# Тестирование
./test-ci-local.sh

# Сборка
./build-ci-local.sh

# Полный цикл
./deploy-local.sh
```

## Заключение

Этот подход более надежный и предсказуемый, чем использование fastlane. Он не зависит от сторонних библиотек и использует только официальные инструменты Apple. 