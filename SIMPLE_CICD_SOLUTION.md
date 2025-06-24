# 🚀 Упрощенное решение для CI/CD

## Проблема
Не найден файл `profile_base64.txt` с provisioning profile.

## Решение: Используйте автоматическое управление! ✅

### Что делать:

1. **Запустите скрипт исправления:**
   ```bash
   ./fix-provisioning-profile.sh
   ```
   Выберите вариант 1 (пропустить)

2. **При добавлении секретов в GitHub:**
   
   Для секрета `BUILD_PROVISION_PROFILE_BASE64`:
   - **Name**: BUILD_PROVISION_PROFILE_BASE64
   - **Value**: skip
   
   (Просто напишите слово "skip" в значении)

3. **Все остальные секреты добавьте как обычно:**
   - APP_STORE_CONNECT_API_KEY_ID
   - APP_STORE_CONNECT_API_KEY_ISSUER_ID
   - APP_STORE_CONNECT_API_KEY_KEY (из файла api_key_base64.txt)
   - BUILD_CERTIFICATE_BASE64 (из файла cert_base64.txt)
   - P12_PASSWORD
   - KEYCHAIN_PASSWORD

## Почему это работает?

- GitHub Actions умеет автоматически создавать provisioning profiles
- Используя App Store Connect API, CI может сам управлять профилями
- Это даже лучше, чем ручное управление!

## Итого: 6 секретов вместо 7

Вам нужно добавить только:
1. ✅ APP_STORE_CONNECT_API_KEY_ID
2. ✅ APP_STORE_CONNECT_API_KEY_ISSUER_ID  
3. ✅ APP_STORE_CONNECT_API_KEY_KEY
4. ✅ BUILD_CERTIFICATE_BASE64
5. ✅ P12_PASSWORD
6. ✅ BUILD_PROVISION_PROFILE_BASE64 = "skip"
7. ✅ KEYCHAIN_PASSWORD

---

**Готово!** Это все что нужно для работы CI/CD! 🎉 