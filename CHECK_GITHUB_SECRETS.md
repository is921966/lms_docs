# Проверка GitHub Secrets для iOS CI/CD

## ⚠️ Проблема
Ошибка `altool: option '--apiIssuer' is missing a required argument` означает, что один из секретов не настроен правильно.

## 📋 Необходимые секреты

Проверьте, что ВСЕ эти секреты настроены в GitHub:
1. Перейдите в Settings → Secrets and variables → Actions
2. Убедитесь, что есть ВСЕ секреты:

### 1. **APP_STORE_CONNECT_API_KEY_ID**
- Это ID вашего API ключа из App Store Connect
- Формат: буквенно-цифровой код (например, `ABC123DEF4`)
- Где найти: App Store Connect → Users and Access → Keys → Key ID

### 2. **APP_STORE_CONNECT_API_KEY_ISSUER_ID** ⚠️
- Это Issuer ID для вашей команды
- Формат: UUID (например, `69a6de70-03db-47e3-a82c-48967bba2ecb`)
- Где найти: App Store Connect → Users and Access → Keys → Issuer ID (вверху страницы)

### 3. **APP_STORE_CONNECT_API_KEY_KEY**
- Содержимое файла .p8 (приватный ключ)
- Должно начинаться с `-----BEGIN PRIVATE KEY-----`
- Должно заканчиваться на `-----END PRIVATE KEY-----`
- **ВАЖНО**: Копируйте ВСЁ содержимое файла, включая BEGIN/END строки

### 4. **BUILD_CERTIFICATE_BASE64**
- Сертификат разработчика в формате base64
- Получен из команды: `base64 -i certificate.p12`

### 5. **P12_PASSWORD**
- Пароль от сертификата .p12

### 6. **KEYCHAIN_PASSWORD**
- Любой пароль для временного keychain (например, `temp123`)

## 🔍 Как проверить

1. **Проверьте, что секрет существует**:
   - В списке секретов должен быть `APP_STORE_CONNECT_API_KEY_ISSUER_ID`
   - Если его нет - создайте

2. **Проверьте значение**:
   - Нажмите "Update" рядом с секретом
   - Убедитесь, что поле не пустое
   - Проверьте, что нет лишних пробелов в начале/конце

3. **Типичные ошибки**:
   - ❌ Пустое значение
   - ❌ Лишние пробелы или переносы строк
   - ❌ Перепутаны Key ID и Issuer ID
   - ❌ Скопирован не тот UUID

## 🛠 Где найти Issuer ID

1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Перейдите в **Users and Access**
3. Выберите вкладку **Keys**
4. **Issuer ID** отображается вверху страницы
5. Это UUID формата: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

## ✅ Проверочный чек-лист

- [ ] APP_STORE_CONNECT_API_KEY_ID настроен и не пустой
- [ ] APP_STORE_CONNECT_API_KEY_ISSUER_ID настроен и не пустой
- [ ] APP_STORE_CONNECT_API_KEY_KEY начинается с `-----BEGIN PRIVATE KEY-----`
- [ ] BUILD_CERTIFICATE_BASE64 - длинная base64 строка
- [ ] P12_PASSWORD настроен
- [ ] KEYCHAIN_PASSWORD настроен

## 🚀 После исправления

После добавления/исправления секретов:
1. Перезапустите workflow через Actions → Re-run all jobs
2. Проверьте логи - теперь должны отображаться значения API Key ID и Issuer ID 