# 🔐 Детальная инструкция по отзыву старых сертификатов и созданию новых для iOS CI/CD

## 📋 Предварительная подготовка

### Что вам понадобится:
- Mac с установленным Xcode
- Доступ к Apple Developer аккаунту
- Доступ к GitHub репозиторию
- Около 15-20 минут времени

### Важная информация:
- **Team ID**: N85286S93X
- **Bundle ID**: ru.tsum.lms.igor
- **Текущий сертификат**: Apple Distribution: Igor Shirokov (N85286S93X)

---

## 🗑️ Шаг 1: Отзыв всех старых сертификатов

### 1.1. Откройте Apple Developer Portal
1. Перейдите на https://developer.apple.com/account
2. Войдите с вашим Apple ID
3. Перейдите в раздел **Certificates, IDs & Profiles**

### 1.2. Перейдите в раздел Certificates
1. В левом меню выберите **Certificates**
2. Вы увидите список всех ваших сертификатов

### 1.3. Отзовите старые сертификаты
Для КАЖДОГО сертификата с вашим именем:

1. **Кликните на сертификат** чтобы открыть детали
2. **Запомните тип** (Development или Distribution)
3. **Нажмите кнопку "Revoke"** (красная кнопка)
4. **Подтвердите отзыв** во всплывающем окне
5. Сертификат будет помечен как "Revoked"

### 1.4. Проверьте Keychain на Mac
```bash
# Откройте Terminal и выполните
security find-identity -v -p codesigning

# Вы должны увидеть список сертификатов
# Запомните или сохраните этот список для сравнения
```

---

## 🆕 Шаг 2: Создание нового Distribution сертификата

### 2.1. Создайте Certificate Signing Request (CSR)

1. **Откройте Keychain Access** (Связка ключей)
   - Finder → Applications → Utilities → Keychain Access
   - Или через Spotlight: ⌘ + Space, введите "Keychain Access"

2. **В меню выберите**:
   - Keychain Access → Certificate Assistant → Request a Certificate From a Certificate Authority...

3. **Заполните форму**:
   - **User Email Address**: ваш email (тот же, что в Apple Developer)
   - **Common Name**: Igor Shirokov
   - **CA Email Address**: оставьте пустым
   - **Выберите**: "Saved to disk"
   - **Отметьте**: "Let me specify key pair information"
   - Нажмите **Continue**

4. **Настройте ключ**:
   - **Key Size**: 2048 bits
   - **Algorithm**: RSA
   - Нажмите **Continue**

5. **Сохраните CSR файл**:
   - Имя файла: `CertificateSigningRequest.certSigningRequest`
   - Сохраните на Desktop для удобства
   - Нажмите **Save**

### 2.2. Создайте сертификат на Apple Developer Portal

1. **Вернитесь на https://developer.apple.com/account**
2. **Certificates → нажмите "+" (Create a New Certificate)**

3. **Выберите тип сертификата**:
   - В разделе "Software" выберите **Apple Distribution**
   - Описание: "For submission to the App Store and for Ad Hoc distribution"
   - Нажмите **Continue**

4. **Загрузите CSR**:
   - Нажмите **Choose File**
   - Выберите файл `CertificateSigningRequest.certSigningRequest` с Desktop
   - Нажмите **Continue**

5. **Скачайте сертификат**:
   - Нажмите **Download**
   - Файл `distribution.cer` будет сохранен в Downloads

6. **Установите сертификат**:
   - Дважды кликните на скачанный `distribution.cer`
   - Keychain Access откроется автоматически
   - Сертификат будет добавлен в вашу связку ключей

---

## 📤 Шаг 3: Экспорт сертификата для CI/CD

### 3.1. Найдите сертификат в Keychain

1. **В Keychain Access**:
   - В левой панели выберите **login** keychain
   - В категориях выберите **My Certificates**

2. **Найдите новый сертификат**:
   - Ищите: "Apple Distribution: Igor Shirokov (N85286S93X)"
   - Он должен иметь стрелку слева (можно развернуть)

### 3.2. Экспортируйте сертификат с приватным ключом

1. **ВАЖНО: Разверните сертификат** кликнув на стрелку
2. **Выделите ОБА элемента**:
   - Сам сертификат "Apple Distribution: Igor Shirokov"
   - Приватный ключ под ним (обычно называется как ваше имя)
   - Используйте Cmd+клик для выбора обоих

3. **Правый клик на выделенном** → **Export 2 items...**

4. **Сохраните как .p12**:
   - Имя файла: `ios_distribution.p12`
   - Место: Desktop
   - Нажмите **Save**

5. **Установите пароль**:
   - Введите надежный пароль (например: `YourSecureP12Password2024`)
   - Подтвердите пароль
   - **ВАЖНО**: Сохраните этот пароль - он понадобится для GitHub Secrets
   - Нажмите **OK**

6. **Введите пароль Mac** для подтверждения экспорта

### 3.3. Конвертируйте в Base64

```bash
# В Terminal выполните:
cd ~/Desktop
base64 -i ios_distribution.p12 -o ios_distribution_base64.txt

# Скопируйте содержимое в буфер обмена:
cat ios_distribution_base64.txt | pbcopy

echo "✅ Base64 сертификат скопирован в буфер обмена!"
```

---

## 🔄 Шаг 4: Обновление GitHub Secrets

### 4.1. Откройте настройки репозитория
1. Перейдите на https://github.com/is921966/lms_docs
2. Нажмите **Settings** (в верхнем меню репозитория)
3. В левом меню найдите **Security** → **Secrets and variables** → **Actions**

### 4.2. Обновите BUILD_CERTIFICATE_BASE64
1. Найдите secret **BUILD_CERTIFICATE_BASE64**
2. Нажмите на иконку карандаша (Edit)
3. **Удалите старое значение**
4. **Вставьте новое** (Cmd+V) - то, что скопировали в буфер
5. Нажмите **Update secret**

### 4.3. Обновите P12_PASSWORD
1. Найдите secret **P12_PASSWORD**
2. Нажмите на иконку карандаша (Edit)
3. **Введите пароль**, который установили при экспорте .p12
4. Нажмите **Update secret**

---

## 🧹 Шаг 5: Очистка Provisioning Profiles

### 5.1. На Apple Developer Portal
1. Перейдите в **Profiles** в левом меню
2. Удалите все старые профили для `ru.tsum.lms.igor`:
   - Выберите профиль
   - Нажмите **Delete**
   - Подтвердите удаление

### 5.2. На вашем Mac (опционально)
```bash
# Удалите локальные provisioning profiles
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*

# Xcode пересоздаст их при необходимости
```

---

## ✅ Шаг 6: Проверка

### 6.1. Проверьте сертификат локально
```bash
# Найдите новый сертификат
security find-identity -v -p codesigning | grep "Apple Distribution"

# Вы должны увидеть что-то вроде:
# 1) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX "Apple Distribution: Igor Shirokov (N85286S93X)"
```

### 6.2. Запишите ID сертификата
ID сертификата (длинная строка из букв и цифр) может понадобиться позже.

### 6.3. Обновите workflow если нужно
Если имя сертификата изменилось, обновите в `.github/workflows/ios-deploy.yml`:
```yaml
CODE_SIGN_IDENTITY="Apple Distribution: Igor Shirokov (N85286S93X)"
```

---

## 🚀 Шаг 7: Запуск CI/CD

### 7.1. Сделайте тестовый коммит
```bash
cd /path/to/lms_docs
git add .
git commit -m "test: Проверка новых сертификатов"
git push origin master
```

### 7.2. Проверьте GitHub Actions
1. Перейдите на вкладку **Actions** в репозитории
2. Следите за выполнением workflow
3. Если есть ошибки - проверьте логи

---

## 🆘 Возможные проблемы и решения

### Проблема: "No profiles for 'ru.tsum.lms.igor' were found"
**Решение**: Xcode создаст профиль автоматически через API. Убедитесь, что API ключи настроены правильно.

### Проблема: "Certificate not found in keychain"
**Решение**: Проверьте, что сертификат установлен в правильную keychain (login, не System).

### Проблема: "The private key is not installed"
**Решение**: При экспорте убедитесь, что выбрали И сертификат И приватный ключ.

---

## 📝 Чек-лист

- [ ] Отозваны все старые сертификаты
- [ ] Создан новый Distribution сертификат
- [ ] Сертификат экспортирован с приватным ключом
- [ ] GitHub Secrets обновлены
- [ ] Старые Provisioning Profiles удалены
- [ ] Проведен тестовый запуск CI/CD

---

## 🎉 Готово!

После выполнения всех шагов, ваш CI/CD должен успешно:
1. Архивировать приложение
2. Подписать его новым сертификатом
3. Создать IPA файл
4. Загрузить в TestFlight

Удачи с развертыванием! 🚀 