# GitHub Actions CI/CD Pipeline 🚀

## Автоматизированная сборка и деплой iOS приложения

### 📋 Workflows

#### 1. `ios-deploy.yml` - Деплой в TestFlight
- **Запускается**: При push в `main` или `master` ветку
- **Функции**:
  - ✅ Запуск тестов
  - ✅ Сборка Release версии
  - ✅ Создание IPA файла
  - ✅ Загрузка в TestFlight
  - ✅ Генерация changelog из коммитов
- **Время выполнения**: ~15-20 минут

#### 2. `ios-ui-tests.yml` - UI тестирование
- **Запускается**: При любом PR в `master`
- **Функции**:
  - ✅ Создание симулятора iPhone 16
  - ✅ Запуск всех UI тестов
  - ✅ Генерация отчетов
  - ✅ Сохранение артефактов
- **Время выполнения**: ~10-15 минут

#### 3. `ios-test.yml` - Unit тесты
- **Запускается**: При push в любую ветку
- **Функции**:
  - ✅ Запуск unit тестов
  - ✅ Проверка компиляции
  - ✅ Code coverage отчеты

### 🔐 Необходимые секреты

| Secret Name | Описание | Как получить |
|------------|----------|--------------|
| `BUILD_CERTIFICATE_BASE64` | Distribution сертификат | Экспорт из Keychain → base64 |
| `P12_PASSWORD` | Пароль сертификата | Задается при экспорте |
| `KEYCHAIN_PASSWORD` | Пароль для CI keychain | Любой (например: `temp123`) |
| `BUILD_PROVISION_PROFILE_BASE64` | Provisioning profile | Скачать с Apple Developer → base64 |
| `PROVISION_PROFILE_UUID` | UUID профиля | См. инструкцию ниже |
| `APP_STORE_CONNECT_API_KEY_ID` | ID ключа API | App Store Connect → Keys |
| `APP_STORE_CONNECT_API_KEY_ISSUER_ID` | Issuer ID | App Store Connect → Keys |
| `APP_STORE_CONNECT_API_KEY_KEY` | Содержимое .p8 файла | Скачать с App Store Connect |

### 🚀 Быстрый старт

1. **Проверьте секреты**:
   ```bash
   ./check-github-secrets.sh
   ```

2. **Подготовьте деплой**:
   ```bash
   ./prepare-github-deploy.sh
   ```

3. **Запустите деплой**:
   ```bash
   git push origin main
   ```

### 📊 Мониторинг

- **Статус сборок**: ![Build Status](https://github.com/ishirokov/lms_docs/actions/workflows/ios-deploy.yml/badge.svg)
- **Логи**: https://github.com/ishirokov/lms_docs/actions
- **Артефакты**: Доступны 90 дней после сборки

### 🛠 Отладка

#### Проблема: "Certificate not found"
```bash
# Проверьте сертификат
security find-identity -v -p codesigning

# Экспортируйте правильный сертификат
# Ищите "Apple Distribution: Your Name (TEAMID)"
```

#### Проблема: "Invalid provisioning profile"
```bash
# Получите UUID профиля
/usr/libexec/PlistBuddy -c "Print :UUID" /dev/stdin <<< $(security cms -D -i YourProfile.mobileprovision)
```

#### Проблема: "API key error"
```bash
# Проверьте формат ключа
cat AuthKey_XXXXX.p8
# Должен начинаться с -----BEGIN PRIVATE KEY-----
```

### 📈 Метрики

- **Среднее время сборки**: 15 минут
- **Успешность**: ~95%
- **Стоимость**: Бесплатно (2000 минут/месяц)

### 🔄 Обновление workflows

При изменении workflows:
1. Создайте PR с изменениями
2. Протестируйте в feature ветке
3. Merge в main после review

### 📞 Поддержка

- **Документация Actions**: https://docs.github.com/actions
- **Fastlane docs**: https://docs.fastlane.tools
- **Apple Developer**: https://developer.apple.com

---

*Последнее обновление: Июнь 2025* 