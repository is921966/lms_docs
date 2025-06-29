# 🔒 Эталонные GitHub Actions Workflows

**Дата создания**: 2025-06-29
**Версия**: 1.0.0
**Статус**: ✅ ПРОВЕРЕНО И РАБОТАЕТ

## ⚠️ КРИТИЧЕСКИ ВАЖНО

Эта папка содержит **ЭТАЛОННЫЕ КОПИИ** рабочих GitHub Actions workflows, которые были протестированы и гарантированно работают.

## 📋 Список эталонных workflows

1. **quick-status.yml** - Быстрая проверка статуса проекта
2. **ios-test.yml** - Запуск iOS тестов
3. **ios-testflight-deploy.yml** - Автоматический деплой в TestFlight
4. **feedback-automation.yml** - Автоматизация обработки фидбека
5. **check-ios-secrets.yml** - Проверка секретов для iOS
6. **debug-secrets.yml** - Отладка секретов (использовать с осторожностью)

## 🛡️ Правила использования

### При необходимости восстановления:

```bash
# Восстановить один workflow
cp .github/workflows-golden-copy/ios-testflight-deploy.yml .github/workflows/

# Восстановить все workflows
cp .github/workflows-golden-copy/*.yml .github/workflows/
```

### При изменении workflows:

1. **ВСЕГДА** тестируйте изменения локально
2. **ОБЯЗАТЕЛЬНО** проверяйте работу в отдельной ветке
3. **ТОЛЬКО ПОСЛЕ** успешного выполнения обновляйте эталонную копию

### Обновление эталонной копии:

```bash
# После успешного тестирования нового workflow
cp .github/workflows/new-workflow.yml .github/workflows-golden-copy/

# Обновить версию в этом README
# Добавить запись в CHANGELOG
```

## 📊 Проверенная конфигурация

### Окружение:
- **macOS runner**: macos-latest
- **Xcode**: latest-stable
- **iOS target**: 18.0

### Критические переменные:
```yaml
env:
  WORKING_DIRECTORY: LMS_App/LMS
  SCHEME: LMS
  CONFIGURATION: Release
  BUNDLE_IDENTIFIER: ru.tsum.lms.igor
```

### Необходимые секреты:
- `BUILD_CERTIFICATE_BASE64`
- `P12_PASSWORD`
- `KEYCHAIN_PASSWORD`
- `BUILD_PROVISION_PROFILE_BASE64`
- `PROVISION_PROFILE_UUID`
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_KEY_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_KEY`

## 🚨 Что НЕ делать

1. **НЕ удаляйте** эту папку
2. **НЕ изменяйте** файлы в этой папке напрямую
3. **НЕ добавляйте** непроверенные workflows
4. **НЕ игнорируйте** ошибки при тестировании

## 📝 CHANGELOG

### v1.0.0 (2025-06-29)
- Первая эталонная версия после успешного запуска всех workflows
- Все 4 основных workflow работают без ошибок
- TestFlight деплой полностью автоматизирован 