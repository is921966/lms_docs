# Руководство по ручной загрузке в TestFlight - Build 52

**Дата**: 2 июля 2025  
**Статус**: Проект открыт в Xcode

## 📱 Пошаговая инструкция

### Шаг 1: Подготовка в Xcode
1. ✅ Проект LMS.xcodeproj открыт
2. Выберите схему **LMS** (не LMS-CI)
3. Выберите **Any iOS Device (arm64)** как destination
4. Проверьте, что выбран **Release** configuration

### Шаг 2: Создание архива
1. В меню выберите **Product → Archive**
2. Дождитесь завершения сборки (3-5 минут)
3. Если появятся ошибки подписи:
   - Откройте **Signing & Capabilities**
   - Убедитесь что включен **Automatically manage signing**
   - Team: **Igor Shirokov (N85286S93X)**

### Шаг 3: Загрузка в TestFlight
1. После успешной сборки откроется **Organizer**
2. Выберите созданный архив
3. Нажмите **Distribute App**
4. Выберите **App Store Connect** → **Upload**
5. Следуйте инструкциям:
   - ✓ Upload your app's symbols
   - ✓ Manage Version and Build Number
   - Build Number: установите **202507021920**

### Шаг 4: Проверка в App Store Connect
1. Откройте [App Store Connect](https://appstoreconnect.apple.com)
2. Перейдите в **My Apps → LMS**
3. Выберите **TestFlight**
4. Дождитесь обработки (10-15 минут)
5. Build 52 появится в списке

## 🔧 Альтернативный метод - Transporter

Если Xcode не работает:
1. Скачайте **Transporter** из Mac App Store
2. Создайте IPA вручную:
   ```bash
   xcodebuild -exportArchive \
       -archivePath build/LMS.xcarchive \
       -exportPath build/export \
       -exportOptionsPlist ExportOptions.plist
   ```
3. Перетащите IPA в Transporter
4. Нажмите **Deliver**

## 📊 Информация о сборке

- **Version**: 2.0.1
- **Build**: 52 (202507021920)
- **Bundle ID**: ru.tsum.lms.igor
- **Team ID**: N85286S93X
- **Изменения**: 
  - Исправлены все ошибки компиляции
  - Обновлен backend (Learning + Program модули)

## ⚠️ Важные моменты

1. **Код подписи**: Используйте автоматическое управление
2. **Сертификаты**: Должны быть действующие iOS Distribution
3. **Provisioning**: App Store profile должен быть актуальным
4. **Время**: Обработка занимает 10-20 минут после загрузки

## 📝 После загрузки

1. Проверьте email на предмет ошибок от Apple
2. Дождитесь статуса "Ready to Test"
3. Добавьте тестировщиков в TestFlight
4. Создайте release notes для тестировщиков

---

**Статус на 19:15**: Ожидается ручная сборка через Xcode 