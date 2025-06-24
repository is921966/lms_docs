# 🔧 Исправление проблемы с Xcode проектом

## Проблема
Файл `project.pbxproj` отсутствует в `LMS.xcodeproj`, что делает проект неоткрываемым.

## Решение

У вас есть **3 варианта** решения:

### Вариант 1: Использовать Swift Package напрямую (РЕКОМЕНДУЕТСЯ)

В современных версиях Xcode можно работать напрямую с Swift Package:

```bash
cd /Users/ishirokov/lms_docs/ios/LMS
open Package.swift
```

Xcode откроет проект как Swift Package. Для настройки подписи:
1. В Xcode выберите схему **LMS** (вверху рядом с кнопкой запуска)
2. Product → Scheme → Edit Scheme
3. Run → Options → вкладка Signing

### Вариант 2: Создать новый iOS проект в Xcode

1. Откройте **Xcode**
2. **File → New → Project**
3. Выберите **iOS → App**
4. Заполните:
   - **Product Name**: LMS
   - **Team**: N85286S93X - Igor Shirokov
   - **Organization Identifier**: ru.tsum
   - **Bundle Identifier**: ru.tsum.lms (сгенерируется автоматически)
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Use Core Data**: ❌
   - **Include Tests**: ✅
5. **Next** → выберите папку `/Users/ishirokov/lms_docs/ios/`
6. **Create**

После создания:
- Скопируйте файлы из `Sources/LMS/` в новый проект
- Настройте Signing & Capabilities

### Вариант 3: Создать минимальный project.pbxproj

Если нужен именно `.xcodeproj`, можно создать его вручную:

```bash
# Создаём минимальную структуру
cd /Users/ishirokov/lms_docs/ios/LMS
mkdir -p LMS.xcodeproj
touch LMS.xcodeproj/project.pbxproj

# Затем откройте Xcode и создайте новый проект
# File → New → Project, но сохраните его с заменой существующего
```

## 🚀 Быстрое решение

**Самый простой способ** - использовать вариант 1:

```bash
cd /Users/ishirokov/lms_docs/ios/LMS
open Package.swift
```

Это откроет проект в Xcode, и вы сможете:
- Настроить Team и подпись
- Собрать приложение
- Запустить на устройстве или симуляторе

## 📝 Для настройки подписи в Swift Package

1. Откройте `Package.swift` в Xcode
2. Выберите target **LMS** в списке слева
3. В главном окне выберите вкладку **Signing & Capabilities**
4. Включите **Automatically manage signing**
5. Выберите ваш Team

## ⚠️ Важно

- Swift Package - это современный способ работы с iOS проектами
- `.xcodeproj` файлы больше не обязательны для разработки
- Fastlane и другие инструменты поддерживают Swift Packages

## 🆘 Если ничего не работает

Создайте проект заново через Xcode (Вариант 2) - это гарантированно работает и займёт 2 минуты. 