# 🚀 Быстрый старт CI/CD для iOS

## 1️⃣ Подготовка (15 минут)

### Создайте App Store Connect API Key:
1. Откройте [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access** → **Keys**
2. Создайте новый ключ с правами **App Manager**
3. Скачайте `.p8` файл (только один раз!)
4. Запомните **Key ID** и **Issuer ID**

### Экспортируйте сертификат:
1. Откройте **Keychain Access**
2. Найдите **Apple Distribution: Igor Shirokov**
3. Правый клик → **Export** → сохраните как `.p12` с паролем

### Скачайте Provisioning Profile:
1. В Xcode: **Settings** → **Accounts** → **Download Manual Profiles**
2. Найдите profile для `ru.tsum.lms.igor` в `~/Library/MobileDevice/Provisioning Profiles/`

## 2️⃣ Подготовка секретов (5 минут)

Запустите скрипт:
```bash
./prepare-ci-secrets.sh
```

Следуйте инструкциям и укажите пути к файлам.

## 3️⃣ Добавление в GitHub (10 минут)

1. Откройте ваш репозиторий на GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Добавьте каждый секрет из файла `ci-secrets/secrets_to_add.txt`

### Список секретов:
- `APP_STORE_CONNECT_API_KEY_ID` - из App Store Connect
- `APP_STORE_CONNECT_API_KEY_ISSUER_ID` - из App Store Connect  
- `APP_STORE_CONNECT_API_KEY_KEY` - содержимое `ci-secrets/apikey_base64.txt`
- `BUILD_CERTIFICATE_BASE64` - содержимое `ci-secrets/certificate_base64.txt`
- `P12_PASSWORD` - пароль от сертификата
- `BUILD_PROVISION_PROFILE_BASE64` - содержимое `ci-secrets/profile_base64.txt`
- `KEYCHAIN_PASSWORD` - любой пароль, например: `temp_ci_keychain_pwd`

## 4️⃣ Тестирование (5 минут)

1. Сделайте небольшое изменение в коде iOS приложения
2. Создайте commit и push:
```bash
git add .
git commit -m "Test CI/CD setup"
git push origin main
```
3. Откройте **Actions** tab на GitHub
4. Наблюдайте за процессом сборки

## ✅ Проверка результата

- В **GitHub Actions** должна быть зеленая галочка
- В **TestFlight** появится новая сборка
- Build number автоматически увеличится

## 🆘 Если что-то пошло не так

1. Проверьте логи в GitHub Actions
2. Убедитесь, что все секреты добавлены правильно
3. Проверьте, что сертификат не истек
4. Убедитесь, что provisioning profile актуален

## 📊 Статус CI/CD

После настройки вы можете добавить badge в README:
```markdown
![iOS CI/CD](https://github.com/YOUR_USERNAME/YOUR_REPO/workflows/iOS%20Deploy%20to%20TestFlight/badge.svg)
```

---

**Готово!** Теперь каждый push в `main` автоматически создаст новую сборку в TestFlight! 🎉 