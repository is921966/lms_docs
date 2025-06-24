# 🎯 Добавление App Target в Swift Package

Так как у вас чистый Swift Package без App target, нужно его добавить:

## Шаги:

1. **В Xcode в меню**:
   - `File` → `New` → `Target...`

2. **Выберите шаблон**:
   - Платформа: **iOS**
   - Тип: **App**
   - Нажмите **Next**

3. **Настройте параметры**:
   - Product Name: **LMS**
   - Team: **Выберите ваш Team** (N85286S93X)
   - Organization Identifier: **ru.tsum**
   - Bundle Identifier: **ru.tsum.lms**
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Нажмите **Finish**

4. **После создания**:
   - Xcode создаст новую папку `LMS` с App target
   - Теперь в левой панели появится target LMS с иконкой приложения
   - Кликните на него и увидите вкладку **Signing & Capabilities**

## Альтернатива: Создать новый проект

Если добавление target не работает, проще создать новый проект:

1. `File` → `New` → `Project`
2. iOS → App
3. Настройте как указано выше
4. Скопируйте ваши Swift файлы в новый проект 