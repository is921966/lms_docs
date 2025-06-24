# ✅ Чек-лист публикации в TestFlight

## Перед публикацией

### 1. Создайте приложение в App Store Connect

Если еще не создали:
1. Зайдите на [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **My Apps** → **+** → **New App**
3. Заполните:
   - Platform: **iOS**
   - Name: **LMS** (или "ЦУМ: Корпоративный университет")
   - Primary Language: **Russian** (ru)
   - Bundle ID: **ru.tsum.LMS**
   - SKU: **tsum-lms-2025** (или любой уникальный)
   - User Access: **Full Access**

### 2. Добавьте иконку приложения (обязательно!)

В Xcode:
1. Откройте `Assets.xcassets`
2. Выберите `AppIcon`
3. Перетащите изображение 1024x1024 в слот "App Store"
4. Сохраните (Cmd+S)

### 3. Проверьте настройки

В терминале:
```bash
# Проверьте, что git чистый
git status

# Если есть несохраненные изменения
git add .
git commit -m "Prepare for TestFlight"
```

## Публикация в TestFlight

### Вариант 1: Через Fastlane (рекомендуется)

```bash
# Сначала попробуйте собрать без загрузки
bundle exec fastlane build

# Если сборка прошла успешно, загрузите в TestFlight
bundle exec fastlane beta
```

### Вариант 2: Через Xcode (если Fastlane не работает)

1. В Xcode: **Product** → **Archive**
2. Дождитесь окончания архивации
3. В открывшемся окне Organizer:
   - Выберите архив
   - Нажмите **Distribute App**
   - Выберите **App Store Connect**
   - Выберите **Upload**
   - Следуйте инструкциям

## После загрузки

1. Зайдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Откройте ваше приложение
3. Перейдите в **TestFlight**
4. Дождитесь обработки билда (5-10 минут)
5. Заполните **Test Information** при первой загрузке
6. Добавьте тестировщиков

## Возможные ошибки

### "No signing certificate"
- Убедитесь, что Automatically manage signing включен
- Запустите приложение в симуляторе хотя бы раз

### "Missing compliance"
- В App Store Connect → TestFlight → заполните Export Compliance

### "Invalid icon"
- Иконка должна быть 1024x1024, PNG, без прозрачности

### "Bundle ID not found"
- Подождите 5-10 минут после создания в App Store Connect
- Обновите страницу 