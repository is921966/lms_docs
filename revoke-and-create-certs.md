# Инструкция по отзыву старых сертификатов и созданию новых

## Шаг 1: Отзыв старых сертификатов

1. Перейдите на https://developer.apple.com/account/resources/certificates/list
2. Найдите все сертификаты типа "Apple Development" и "Apple Distribution" для вашего аккаунта
3. Для каждого сертификата:
   - Нажмите на него
   - Нажмите кнопку "Revoke" (Отозвать)
   - Подтвердите отзыв

## Шаг 2: Создание нового Distribution сертификата

1. На той же странице нажмите "+" для создания нового сертификата
2. Выберите "Apple Distribution" (для App Store и Ad Hoc)
3. Следуйте инструкциям:
   - Создайте Certificate Signing Request (CSR) через Keychain Access
   - Загрузите CSR
   - Скачайте новый сертификат
   - Дважды кликните на скачанный сертификат для установки в Keychain

## Шаг 3: Экспорт нового сертификата для CI/CD

1. Откройте Keychain Access
2. Найдите новый "Apple Distribution: Igor Shirokov" сертификат
3. Разверните его и выберите И сертификат И приватный ключ (оба должны быть выделены)
4. Правый клик → Export 2 items...
5. Сохраните как .p12 файл с паролем
6. Конвертируйте в base64:
   ```bash
   base64 -i certificates.p12 | pbcopy
   ```

## Шаг 4: Обновление GitHub Secrets

1. Перейдите в Settings → Secrets → Actions вашего репозитория
2. Обновите:
   - `BUILD_CERTIFICATE_BASE64` - вставьте новое base64 значение
   - `P12_PASSWORD` - пароль от нового .p12 файла

## Шаг 5: Обновление workflow

После создания новых сертификатов, нам нужно будет узнать ID нового сертификата:

```bash
security find-identity -v -p codesigning
```

И обновить в workflow если изменилось имя или ID.
