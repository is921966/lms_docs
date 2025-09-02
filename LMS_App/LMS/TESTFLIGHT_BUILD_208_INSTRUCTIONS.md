# Инструкции для создания TestFlight Build 208

## 📋 Подготовка завершена

### ✅ Что сделано:
1. **Номер билда обновлен до 208** (было 207)
2. **Release notes созданы** в `/docs/releases/TESTFLIGHT_RELEASE_v2.1.1_build208.md`
3. **Исправлены все ошибки компиляции**:
   - Feed модуль - релизные новости
   - Cmi5 импорт - синхронизация данных
   - Course Management - редактирование курсов
4. **Код готов к архивированию**

### ⚠️ Проблемы, требующие ручного вмешательства:
1. **Info.plist дублирование** - требует ручного исправления в Xcode
2. **Provisioning profiles** - требует входа в Apple Developer аккаунт

## 🛠️ Шаги для создания архива в Xcode

### 1. Откройте проект
```bash
cd /Users/ishirokov/lms_docs/LMS_App/LMS
open LMS.xcodeproj
```

### 2. Исправьте Info.plist дублирование
1. В Xcode выберите проект LMS в навигаторе
2. Выберите target "LMS"
3. Перейдите во вкладку "Build Phases"
4. Раскройте секцию "Copy Bundle Resources"
5. Найдите и удалите `Info.plist` из списка (если есть)
6. Сохраните проект (Cmd+S)

### 3. Настройте подпись
1. Во вкладке "Signing & Capabilities"
2. Убедитесь, что выбран Team: "Igor Shirokov (8Y7XSRU6LB)"
3. Включите "Automatically manage signing"
4. Bundle Identifier: `ru.tsum.lms.igor`

### 4. Создайте архив
1. Выберите схему: **LMS**
2. Выберите устройство: **Any iOS Device (arm64)**
3. Меню: **Product → Archive**
4. Дождитесь завершения (5-10 минут)

### 5. Загрузите в TestFlight
1. В Organizer выберите созданный архив
2. Нажмите "Distribute App"
3. Выберите "App Store Connect"
4. Выберите "Upload"
5. Следуйте инструкциям мастера

## 📝 Информация о билде

- **Версия**: 2.1.1
- **Build**: 208
- **Bundle ID**: ru.tsum.lms.igor
- **Team ID**: 8Y7XSRU6LB
- **Минимальная iOS**: 17.0

## 🎯 Основные изменения в Build 208

1. **📰 Улучшения модуля Новости**
   - Релизные новости всегда первые
   - Сворачиваемые длинные посты
   - Детальный просмотр с комментариями

2. **📚 Исправления Cmi5**
   - iOS File Picker вместо drag & drop
   - Синхронизация импортированных пакетов

3. **📝 Исправления курсов**
   - Работающее редактирование курсов

4. **🎨 Начало Perplexity редизайна**
   - Темная тема
   - Новые UI компоненты

## ⏱️ Ожидаемое время

- Создание архива: 5-10 минут
- Загрузка в App Store Connect: 5-10 минут
- Обработка Apple: 10-30 минут
- **Общее время**: ~30-60 минут

## 🆘 Если возникли проблемы

1. **Provisioning profile error**:
   - Войдите в Xcode с Apple ID
   - Xcode → Settings → Accounts → Add Apple ID

2. **Info.plist duplicate error**:
   - Повторите шаг 2 выше
   - Очистите DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*`

3. **Archive failed**:
   - Проверьте консоль Xcode на ошибки
   - Попробуйте Product → Clean Build Folder
   - Перезапустите Xcode

## ✅ После успешной загрузки

1. Дождитесь обработки в App Store Connect (10-30 минут)
2. Добавьте внешних тестировщиков в TestFlight
3. Отправьте приглашения тестировщикам
4. Обновите статус в PROJECT_STATUS.md

---

**Удачи с релизом Build 208! 🚀** 