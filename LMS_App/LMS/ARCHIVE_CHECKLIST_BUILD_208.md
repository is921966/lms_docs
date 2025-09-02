# ✅ Чеклист для создания архива Build 208

## 🎯 Готовность к архивированию

### ✅ Технические параметры
- [x] **Версия**: 2.1.1
- [x] **Build**: 208  
- [x] **Bundle ID**: ru.tsum.lms.igor
- [x] **Team**: Igor Shirokov (8Y7XSRU6LB)
- [x] **Certificate**: Apple Development (N97MV6M5PR)
- [x] **Provisioning**: Xcode Managed Profile

### ✅ Исправленные проблемы
- [x] Feed модуль - релизные новости работают
- [x] Cmi5 импорт - синхронизация данных исправлена
- [x] Course Management - редактирование курсов работает
- [x] Info.plist дублирование - очищено скриптами

### ✅ Документация
- [x] Release notes созданы: `TESTFLIGHT_RELEASE_v2.1.1_build208.md`
- [x] Инструкции подготовлены: `TESTFLIGHT_BUILD_208_INSTRUCTIONS.md`

## 🚀 Шаги для создания архива

### В Xcode (уже открыт):

1. **[ ] Проверьте схему**
   - Должна быть выбрана: `LMS`

2. **[ ] Проверьте устройство**
   - Должно быть: `Any iOS Device (arm64)`

3. **[ ] Проверьте Build Phases**
   - Build Phases → Copy Bundle Resources
   - Убедитесь, что Info.plist НЕТ в списке

4. **[ ] Создайте архив**
   - Product → Archive (или Cmd+Shift+B)
   - Ожидание: 5-10 минут

5. **[ ] После создания архива**
   - Откроется Organizer
   - Выберите созданный архив
   - Нажмите "Distribute App"

6. **[ ] Загрузка в TestFlight**
   - Выберите "App Store Connect"
   - Выберите "Upload"
   - Next → Next → Upload

## 📊 Ожидаемые результаты

- **Архив**: LMS 2.1.1 (208)
- **Размер**: ~50-100 MB
- **Время создания**: 5-10 минут
- **Время загрузки**: 5-10 минут
- **Обработка Apple**: 10-30 минут

## 🆘 Если возникли проблемы

### "The Copy Bundle Resources build phase contains this target's Info.plist"
1. Build Phases → Copy Bundle Resources
2. Найдите Info.plist и удалите
3. Clean Build Folder (Shift+Cmd+K)
4. Попробуйте снова

### "No Account for Team"
1. Xcode → Settings → Accounts
2. Убедитесь, что вы вошли в Apple ID
3. Нажмите "Download Manual Profiles"

### Archive кнопка неактивна
1. Убедитесь, что выбрано "Any iOS Device"
2. Не должен быть выбран симулятор

## ✅ После успешной загрузки

1. **[ ] Проверьте App Store Connect**
   - https://appstoreconnect.apple.com
   - TestFlight → Builds
   - Должен появиться Build 208

2. **[ ] Добавьте тестировщиков**
   - Internal Testing → Add Testers
   - External Testing → Add Testers

3. **[ ] Обновите документацию**
   - PROJECT_STATUS.md
   - Добавьте запись о релизе

---

**🎉 Удачи с релизом Build 208!** 