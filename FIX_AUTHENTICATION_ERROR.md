# Исправление ошибки "Failure to authenticate" 

## 🔍 Возможные причины:

### 1. Неправильный формат API ключа
- Убедитесь, что скопировали **ВСЕ** содержимое .p8 файла
- Должно начинаться с: `-----BEGIN PRIVATE KEY-----`
- Должно заканчиваться на: `-----END PRIVATE KEY-----`
- Между BEGIN и END должны быть строки base64 кода

### 2. Недостаточные права доступа API ключа
Проверьте в App Store Connect → Users and Access → Keys:
- Ключ должен иметь роль **App Manager** или выше
- Должен быть активным (не revoked)

### 3. Неправильный Team ID или Bundle ID
- Team ID: N85286S93X
- Bundle ID: ru.tsum.lms.igor
- Убедитесь, что приложение с таким Bundle ID существует в App Store Connect

### 4. API ключ истек или был отозван
- Ключи не истекают, но могут быть отозваны
- Проверьте статус ключа в App Store Connect

## ✅ Пошаговая проверка:

### Шаг 1: Проверьте API ключ в App Store Connect
1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Users and Access → Keys
3. Найдите ваш ключ и проверьте:
   - Status: Active ✅
   - Access: App Manager или Admin ✅

### Шаг 2: Пересоздайте API ключ (если нужно)
1. Нажмите "+" для создания нового ключа
2. Выберите роль: **App Manager**
3. Скачайте .p8 файл
4. **ВАЖНО**: Файл можно скачать только ОДИН раз!

### Шаг 3: Обновите GitHub Secrets
1. Откройте .p8 файл в текстовом редакторе
2. Скопируйте ВСЁ содержимое
3. Обновите секреты:
   - `APP_STORE_CONNECT_API_KEY_ID` - новый ID ключа
   - `APP_STORE_CONNECT_API_KEY_KEY` - содержимое .p8

### Шаг 4: Проверьте приложение в App Store Connect
1. My Apps → найдите приложение
2. Убедитесь, что Bundle ID = `ru.tsum.lms.igor`
3. Если приложения нет - создайте его

## 🛠 Альтернативное решение - использовать пароль приложения:

Если API ключи не работают, можно использовать App-Specific Password:

1. Войдите в [appleid.apple.com](https://appleid.apple.com)
2. Sign-In and Security → App-Specific Passwords
3. Создайте новый пароль для "Xcode"
4. Используйте с вашим Apple ID:
   ```bash
   xcrun altool --upload-app \
     --type ios \
     --file build/LMS.ipa \
     --username YOUR_APPLE_ID@example.com \
     --password YOUR_APP_SPECIFIC_PASSWORD
   ```

## 📝 Проверочный чек-лист:
- [ ] API ключ активен в App Store Connect
- [ ] Роль ключа: App Manager или Admin
- [ ] .p8 файл содержит BEGIN/END PRIVATE KEY
- [ ] Приложение создано в App Store Connect
- [ ] Bundle ID совпадает: ru.tsum.lms.igor
- [ ] Team ID правильный: N85286S93X 