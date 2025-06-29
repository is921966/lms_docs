# 🔐 GitHub Secrets Setup для TestFlight Deploy

## ✅ **Секреты уже настроены и работают!**

Все необходимые секреты уже были настроены ранее для workflow `ios-deploy.yml` и используются в новом `ios-testflight-deploy.yml`.

## 📋 **Используемые Secrets:**

### 1. **BUILD_CERTIFICATE_BASE64**
- **Описание**: Distribution Certificate в base64 формате
- **Статус**: ✅ Настроен
- **Используется для**: Подписи приложения

### 2. **P12_PASSWORD**
- **Описание**: Пароль для p12 сертификата
- **Статус**: ✅ Настроен
- **Используется для**: Импорта сертификата

### 3. **KEYCHAIN_PASSWORD**
- **Описание**: Пароль для временной keychain
- **Статус**: ✅ Настроен
- **Используется для**: Создания безопасного хранилища сертификатов

### 4. **BUILD_PROVISION_PROFILE_BASE64**
- **Описание**: Provisioning Profile в base64 формате
- **Статус**: ✅ Настроен
- **Используется для**: Настройки профиля провизии

### 5. **PROVISION_PROFILE_UUID**
- **Описание**: UUID provisioning профиля
- **Статус**: ✅ Настроен
- **Используется для**: Идентификации профиля

### 6. **APP_STORE_CONNECT_API_KEY_ID**
- **Описание**: Key ID из App Store Connect
- **Статус**: ✅ Настроен
- **Формат**: 10 символов (например: `XXXXXXXXXX`)

### 7. **APP_STORE_CONNECT_API_KEY_ISSUER_ID**
- **Описание**: Issuer ID из App Store Connect
- **Статус**: ✅ Настроен
- **Формат**: UUID (например: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)

### 8. **APP_STORE_CONNECT_API_KEY_KEY**
- **Описание**: Private Key (.p8 файл) из App Store Connect
- **Статус**: ✅ Настроен
- **Формат**: Содержимое .p8 файла (включая BEGIN/END PRIVATE KEY)

## 🚀 **Как запустить TestFlight Deploy:**

1. **Автоматически** - при push в `master` branch:
   ```bash
   git push origin master
   ```

2. **Вручную** через GitHub Actions:
   - Перейдите в Actions → iOS TestFlight Deploy
   - Нажмите "Run workflow"
   - Выберите branch: `master`
   - Нажмите "Run workflow"

## 📱 **После успешного деплоя:**

1. Подождите 5-10 минут для обработки в App Store Connect
2. Проверьте TestFlight: https://appstoreconnect.apple.com
3. Билд появится в разделе TestFlight → iOS
4. Если нужно, добавьте тестировщиков

## 🆘 **Если что-то не работает:**

### Проверьте логи в GitHub Actions:
1. Перейдите в Actions
2. Найдите последний запуск workflow
3. Проверьте какой шаг завершился с ошибкой

### Частые проблемы:
- **"Certificate not found"** - проверьте срок действия сертификата
- **"Profile not found"** - обновите provisioning profile
- **"Invalid API key"** - проверьте срок действия API ключа

### Debug workflow:
Запустите `Debug Secrets and Environment` workflow для проверки наличия всех секретов.

## 📄 **Обновление секретов (если потребуется):**

Если нужно обновить какой-то секрет:
1. Settings → Secrets and variables → Actions
2. Найдите нужный секрет
3. Нажмите "Update"
4. Вставьте новое значение
5. Сохраните

**ВАЖНО**: При обновлении сертификата или профиля обновите все связанные секреты! 