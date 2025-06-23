# CI/CD Setup для LMS iOS

## 🔐 GitHub Secrets

Добавьте следующие секреты в Settings → Secrets → Actions:

### App Store Connect API
```yaml
APP_STORE_CONNECT_API_KEY_ID: <Ваш Key ID>
APP_STORE_CONNECT_API_ISSUER_ID: <Ваш Issuer ID>
APP_STORE_CONNECT_API_KEY_CONTENT: |
  -----BEGIN PRIVATE KEY-----
  <Содержимое .p8 файла>
  -----END PRIVATE KEY-----
```

### Match (для сертификатов)
```yaml
MATCH_PASSWORD: <Пароль для расшифровки сертификатов>
MATCH_GIT_BASIC_AUTHORIZATION: <base64(username:personal_access_token)>
```

## 🚀 Первоначальная настройка

### 1. Создайте App ID
В Apple Developer Portal:
- Identifiers → +
- Bundle ID: com.company.lms

### 2. Инициализируйте Match
```bash
cd ios/LMS
fastlane match init
```

### 3. Создайте приложение в App Store Connect
- My Apps → +
- Bundle ID: com.company.lms
- SKU: LMS001

## 📱 Локальное тестирование

```bash
# Тесты
fastlane test

# Сборка для TestFlight
fastlane beta
```
