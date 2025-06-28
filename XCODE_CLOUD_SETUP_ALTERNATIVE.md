# 🚀 Альтернативные способы настройки Xcode Cloud

**Дата**: 2025-06-28  
**Проблема**: Не видно меню Product → Xcode Cloud

## 🔧 Способ 1: Через Report Navigator (⌘+9)

1. **Откройте Xcode** с проектом LMS
2. **Нажмите ⌘+9** (Command + 9) - откроется Report Navigator
3. **Вверху окна** найдите вкладки: Build | Tests | **Cloud**
4. **Кликните на Cloud**
5. Если видите **"Get Started"** или **"Create Workflow"** - нажмите

## 🌐 Способ 2: Через App Store Connect

1. Откройте https://appstoreconnect.apple.com
2. Войдите с вашим Apple ID
3. Перейдите в **Apps**
4. Если приложения нет - создайте:
   - New App → iOS
   - Bundle ID: `ru.tsum.lms.igor`
   - SKU: `LMS2025`
5. После создания перейдите в **Xcode Cloud** в левом меню
6. Нажмите **"Set Up Xcode Cloud"**

## 💻 Способ 3: Через терминал + Xcode

```bash
# 1. Убедитесь что вошли в Xcode
open -a Xcode
# Xcode → Settings → Accounts → проверьте Apple ID

# 2. Откройте проект
open LMS.xcodeproj

# 3. Попробуйте через схему
# Product → Scheme → Edit Scheme
# Слева найдите "Cloud" или "Archive"
```

## 🔄 Способ 4: Обновить интеграцию

1. В Xcode: **Window → Organizer** (⌘+⇧+O)
2. Выберите вкладку **Cloud**
3. Если есть кнопка **"Get Started"** - нажмите

## 📱 Способ 5: Создать Workflow через конфигурацию

Давайте создадим базовую конфигурацию Xcode Cloud: 