# 🛡️ Руководство по защите GitHub Actions Workflows

**Версия**: 1.0.0
**Дата**: 2025-06-29
**Статус**: ✅ АКТИВНО

## 📋 Обзор

Это руководство описывает систему защиты эталонных GitHub Actions workflows, которые гарантированно работают и обеспечивают автоматический деплой в TestFlight.

## 🔒 Система защиты

### 1. Эталонные копии

**Расположение**: `.github/workflows-golden-copy/`

Содержит проверенные версии всех критических workflows:
- `ios-testflight-deploy.yml` - автоматический деплой в TestFlight
- `ios-test.yml` - запуск iOS тестов
- `quick-status.yml` - проверка статуса проекта
- `feedback-automation.yml` - обработка обратной связи

### 2. Автоматическая проверка целостности

**Скрипт**: `scripts/check-workflows-integrity.sh`

```bash
# Запустить проверку вручную
./scripts/check-workflows-integrity.sh

# Результат покажет:
# ✅ Соответствует эталону
# ❌ Отличается от эталона
# 🆕 Новый workflow
# ⚠️ Отсутствует в рабочей папке
```

### 3. Pre-commit защита

**Hook**: `.git/hooks/pre-commit`

Автоматически проверяет изменения в workflows перед коммитом:
- Сравнивает с эталонными копиями
- Предупреждает о критических изменениях
- Блокирует коммит при обнаружении проблем

### 4. Восстановление из эталонной копии

```bash
# Восстановить все workflows
cp .github/workflows-golden-copy/*.yml .github/workflows/

# Восстановить конкретный workflow
cp .github/workflows-golden-copy/ios-testflight-deploy.yml .github/workflows/

# Проверить результат
./scripts/check-workflows-integrity.sh
```

## 📊 Методология работы с workflows

### ✅ Правильный подход

1. **Перед изменением workflow**:
   ```bash
   # Создать ветку для тестирования
   git checkout -b test-workflow-changes
   
   # Внести изменения
   # Протестировать в ветке
   # Убедиться что все работает
   ```

2. **После успешного тестирования**:
   ```bash
   # Обновить эталонную копию
   cp .github/workflows/updated-workflow.yml .github/workflows-golden-copy/
   
   # Обновить версию в README
   # Задокументировать изменения
   ```

3. **При проблемах**:
   ```bash
   # Быстро восстановить рабочую версию
   cp .github/workflows-golden-copy/workflow.yml .github/workflows/
   ```

### ❌ Чего НЕ делать

1. **НЕ изменяйте** workflows напрямую в master без тестирования
2. **НЕ удаляйте** эталонные копии
3. **НЕ игнорируйте** предупреждения pre-commit hook
4. **НЕ забывайте** обновлять эталонные копии после успешных изменений

## 🚨 Критические настройки

### Переменные окружения (НЕ ИЗМЕНЯТЬ):
```yaml
env:
  WORKING_DIRECTORY: LMS_App/LMS
  SCHEME: LMS
  CONFIGURATION: Release
  BUNDLE_IDENTIFIER: ru.tsum.lms.igor
```

### Необходимые секреты GitHub:
- `BUILD_CERTIFICATE_BASE64`
- `P12_PASSWORD`
- `KEYCHAIN_PASSWORD`
- `BUILD_PROVISION_PROFILE_BASE64`
- `PROVISION_PROFILE_UUID`
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_KEY_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_KEY`

## 📝 Процедура экстренного восстановления

Если CI/CD перестал работать:

1. **Проверить статус**:
   ```bash
   ./scripts/check-workflows-integrity.sh
   ```

2. **Восстановить все workflows**:
   ```bash
   cp .github/workflows-golden-copy/*.yml .github/workflows/
   ```

3. **Проверить секреты**:
   ```bash
   # Запустить workflow проверки секретов
   gh workflow run check-ios-secrets.yml
   ```

4. **Протестировать**:
   ```bash
   # Сделать тестовый коммит
   git add .
   git commit -m "test: CI/CD recovery test"
   git push
   ```

## 🔄 Обновление эталонной конфигурации

### Когда обновлять:
- После успешного улучшения workflow
- При обновлении зависимостей (Xcode, macOS)
- При изменении процесса деплоя

### Как обновлять:
1. Тестировать в отдельной ветке
2. Убедиться в стабильной работе (минимум 3 успешных запуска)
3. Скопировать в эталонную папку
4. Обновить документацию
5. Создать git tag для версии

```bash
# Пример обновления
cp .github/workflows/ios-testflight-deploy.yml .github/workflows-golden-copy/
git add .github/workflows-golden-copy/
git commit -m "chore: Update golden copy of TestFlight deploy workflow v1.1.0"
git tag -a workflows-v1.1.0 -m "Updated TestFlight deploy workflow"
```

## 📊 История успешных запусков

### v1.0.0 (2025-06-29)
- Все 4 workflow успешно выполнены
- TestFlight деплой работает автоматически
- Время выполнения: 2-3 минуты
- Версия приложения 2.0.1 загружена

## 🆘 Поддержка

При возникновении проблем:
1. Проверьте этот документ
2. Запустите скрипт проверки целостности
3. Просмотрите логи GitHub Actions
4. Восстановите из эталонной копии если нужно

---

*Эта система защиты гарантирует стабильную работу CI/CD pipeline и быстрое восстановление в случае проблем.* 