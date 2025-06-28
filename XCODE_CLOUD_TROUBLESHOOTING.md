# 🔧 Решение проблем с Xcode Cloud

## Проблема: Не видно меню Product → Xcode Cloud

### Решение 1: Report Navigator
1. Нажмите **⌘+9** (Report Navigator)
2. Найдите вкладку **Cloud** в верхней части
3. Нажмите **"Create Workflow"**

![Cloud Tab](cloud-tab-location.png)

### Решение 2: Интеграция через проект
1. Выберите корень проекта в Navigator
2. Editor → Add Package Dependencies...
3. В появившемся окне может быть опция Xcode Cloud

### Решение 3: Проверка аккаунта
```bash
# Проверить статус аккаунта
xcrun altool --list-providers -u "your-apple-id@email.com" -p "app-specific-password"
```

### Решение 4: Прямая ссылка
Откройте в браузере:
https://appstoreconnect.apple.com/teams/[YOUR-TEAM-ID]/apps/[YOUR-APP-ID]/xcode-cloud

### Решение 5: Обновить интеграцию
1. Xcode → Settings → Accounts
2. Удалите и заново добавьте Apple ID
3. Перезапустите Xcode

## Если ничего не помогает:

### Вариант A: Использовать существующий GitHub Actions
Продолжить с GitHub Actions - он уже настроен и работает

### Вариант B: Настроить через App Store Connect
1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Apps → Ваше приложение → Xcode Cloud
3. Настройте workflow через веб-интерфейс

### Вариант C: Создать новый проект
Иногда помогает создать новый тестовый проект и проверить, появляется ли там Xcode Cloud

## Проверочный чеклист:
- [ ] Apple Developer Program активен
- [ ] Вошли в Xcode с правильным Apple ID
- [ ] Приняты условия Xcode Cloud
- [ ] Проект имеет Bundle ID
- [ ] Схема сделана Shared 