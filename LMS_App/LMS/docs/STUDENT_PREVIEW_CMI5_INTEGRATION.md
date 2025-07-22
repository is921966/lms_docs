# Student Course Preview - Cmi5 Integration Documentation

## Описание обновления
В режиме "Просмотреть как студент" теперь отображается реальный Cmi5 контент вместо симуляции. Администраторы могут увидеть фактические интерактивные курсы, которые будут доступны студентам.

## Внесенные изменения

### 1. Обновление Cmi5ModulePreview
- Добавлена загрузка реальных Cmi5 активностей из импортированных пакетов
- Поиск активностей по activityId в загруженных Cmi5 пакетах
- Приоритетный поиск в пакете, связанном с курсом через cmi5PackageId
- Fallback на симуляцию если реальный контент недоступен

### 2. Cmi5FullContentView
- Новый компонент для отображения полноценного Cmi5 контента
- Использует Cmi5PlayerView для воспроизведения интерактивного контента
- Поддержка xAPI statements для отслеживания прогресса
- Режим предпросмотра с ограниченными функциями

### 3. Cmi5SimulationView
- Резервный вариант для случаев когда реальный контент недоступен
- Симуляция интерактивных слайдов
- Визуальная индикация что показывается симуляция

### 4. Интеграция с CourseManagement
- Передача cmi5PackageId через всю цепочку компонентов
- StudentCoursePreviewView → ModuleContentPreviewView → Cmi5ModulePreview
- Автоматическая загрузка Cmi5Service при открытии предпросмотра

## Технические детали

### Поиск активностей
```swift
private func findActivityInBlock(_ block: Cmi5Block, activityId: String, packageId: UUID) -> Cmi5Activity? {
    // Проверяем активности в текущем блоке
    for activity in block.activities {
        if activity.activityId == activityId {
            return activity
        }
    }
    
    // Рекурсивно проверяем вложенные блоки
    for subBlock in block.blocks {
        if let activity = findActivityInBlock(subBlock, activityId: activityId, packageId: packageId) {
            return activity
        }
    }
    
    return nil
}
```

### Связь модулей с активностями
- ManagedCourseModule.contentUrl содержит activityId
- ManagedCourse.cmi5PackageId указывает на конкретный Cmi5Package
- Cmi5Package содержит манифест со структурой блоков и активностей

## Поток данных
1. Администратор открывает курс с Cmi5 контентом
2. Нажимает "Предпросмотр курса" → "Просмотреть как студент"
3. При открытии Cmi5 модуля:
   - Загружается activityId из module.contentUrl
   - Ищется соответствующая Cmi5Activity в пакете
   - Если найдена - показывается реальный контент через Cmi5PlayerView
   - Если не найдена - показывается симуляция

## Преимущества
- **Реалистичный предпросмотр** - администраторы видят настоящий контент
- **Проверка работоспособности** - можно убедиться что курс загружается правильно
- **Отладка** - легко выявить проблемы с импортированным контентом
- **UX тестирование** - понимание студенческого опыта

## Ограничения в режиме предпросмотра
- xAPI statements не сохраняются в LRS
- Прогресс не записывается в базу данных
- Некоторые функции могут быть ограничены
- Используется тестовый пользователь "preview_user"

## Будущие улучшения
1. Кэширование загруженных активностей
2. Предзагрузка Cmi5 контента для быстрого доступа
3. Отображение реального прогресса из LRS
4. Поддержка оффлайн режима для предпросмотра 

## Troubleshooting

### Issue: "ID активности не указан" Error
**Symptom**: When previewing Cmi5 modules, error message appears saying activity ID is not provided.

**Cause**: The `contentUrl` field in `ManagedCourseModule` was not being populated during Cmi5 course conversion.

**Solution**: Updated `Cmi5CourseConverter.swift` to use the correct activity ID:
```swift
// Before (incorrect):
let firstActivityId = block.activities.first?.id  // UUID type

// After (correct):
let firstActivityId = block.activities.first?.activityId  // String type
```

This ensures that each Cmi5 module has a proper reference to its corresponding activity ID, allowing the content to be loaded correctly.

### Build Instructions
To build the project:
```bash
cd /Users/ishirokov/lms_docs/LMS_App/LMS
xcodebuild -scheme LMS -destination 'platform=iOS Simulator,name=iPhone 16' -configuration Debug clean build CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""
```

Note: Use available simulator names (check with `xcodebuild -showdestinations`). 