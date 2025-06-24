# 📱 Загрузка в TestFlight через Xcode

## Шаги:

1. **Откройте Xcode Organizer**:
   - В Xcode: **Window** → **Organizer** (или Shift+Cmd+O)
   - Или в меню: **Product** → **Archive** (если архив еще не создан)

2. **Найдите созданный архив**:
   - В списке слева выберите **LMS**
   - Вы увидите архив с датой "Jun 24, 2025, 17:43"

3. **Загрузите в App Store Connect**:
   - Выберите архив
   - Нажмите **Distribute App**
   - Выберите **App Store Connect**
   - Выберите **Upload**
   - **Next**

4. **Настройки загрузки**:
   - ✅ Include bitcode for iOS content
   - ✅ Upload your app's symbols
   - **Next**

5. **Автоматическая подпись**:
   - Выберите **Automatically manage signing**
   - Xcode создаст Distribution certificate и profile
   - **Next**

6. **Проверка и загрузка**:
   - Проверьте информацию
   - **Upload**

## После загрузки:

1. Зайдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Откройте ваше приложение
3. Перейдите в **TestFlight**
4. Подождите 5-10 минут для обработки
5. Заполните **Test Information** (при первой загрузке)

## Важно:

- При первой загрузке Xcode автоматически создаст все необходимые Distribution сертификаты
- Это самый простой способ для первого раза
- После этого Fastlane сможет использовать созданные профили 