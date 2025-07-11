# Инструкции для создания TestFlight Build 206

## ⚠️ Важно: У вас есть два архива с Build 205

Мы обновили номер билда до **206**, чтобы избежать конфликта.

## 📱 Текущие параметры
- **Версия**: 2.1.1
- **Build**: 206 (обновлен!)
- **Bundle ID**: ru.tsum.lms.igor

## 🔧 Создание архива через Xcode

### 1. Откройте проект
```bash
cd /Users/ishirokov/lms_docs/LMS_App/LMS
open LMS.xcodeproj
```

### 2. Настройте схему
- Выберите схему **LMS** в верхней панели
- Выберите устройство **Any iOS Device (arm64)**

### 3. Проверьте подпись
- Откройте настройки проекта (кликните на LMS в навигаторе)
- Выберите target **LMS**
- Вкладка **Signing & Capabilities**
- Убедитесь что:
  - ✅ Automatically manage signing включено
  - ✅ Team: **8Y7XSRU6LB**
  - ✅ Bundle Identifier: **ru.tsum.lms.igor**

### 4. Создайте архив
- **Product → Archive** (или ⌘⇧I)
- Дождитесь завершения (5-10 минут)

### 5. Загрузите в TestFlight
После создания архива Xcode автоматически откроет Organizer:

1. Выберите архив **LMS 2.1.1 (206)**
2. Нажмите **Distribute App**
3. Выберите **App Store Connect**
4. **Upload**
5. **Automatically manage signing**
6. **Upload**

## 📝 Release Notes для TestFlight

Используйте текст из файла:
```
/Users/ishirokov/lms_docs/docs/releases/TESTFLIGHT_RELEASE_v2.1.1_build206.md
```

## ✅ Чек-лист перед загрузкой

- [ ] Номер билда 206 (не 205!)
- [ ] Версия 2.1.1
- [ ] Все тесты прошли успешно
- [ ] Release Notes готовы
- [ ] Provisioning profile актуален

## 🚨 Если возникли проблемы

### Ошибка provisioning profile:
1. Xcode → Preferences → Accounts
2. Выберите ваш Apple ID
3. Download Manual Profiles
4. Попробуйте создать архив снова

### Дубликат билда:
- Убедитесь что используете Build 206, не 205
- В App Store Connect старый билд 205 можно expire

## 📊 После загрузки

1. Дождитесь обработки (5-30 минут)
2. Откройте App Store Connect → TestFlight
3. Найдите Build 206
4. Добавьте What to Test
5. Активируйте для тестировщиков

---

**Успешной загрузки!** 