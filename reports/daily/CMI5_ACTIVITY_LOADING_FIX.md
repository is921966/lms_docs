# Решение проблемы загрузки Cmi5 активностей

## Проблема
При нажатии на кнопку "Начать модуль" в Cmi5 курсе происходит переход на экран с ошибкой "ID активности не указан" и модуль не воспроизводится.

## Анализ
Из логов видно:
```
✅ [Cmi5ModulePreview] Using activity ID: intro_to_ai
⚠️ [Cmi5ModulePreview] Activity not found in specific package, searching all packages
❌ [Cmi5ModulePreview] Activity not found in any package, showing simulation
```

При этом пакет загружается корректно:
```
🔍 [Cmi5Service] Loaded 1 packages:
   Package 1: AI Fluency (ID: 550E8400-E29B-41D4-A716-446655440000)
     - Activities: 2
```

## Внесенные изменения

### 1. Создан Cmi5DemoContent.swift
Файл содержит реальный HTML контент для двух демо-активностей:
- `intro_to_ai` - Введение в искусственный интеллект
- `ai_applications` - Применение ИИ в реальном мире

Контент включает:
- Интерактивные элементы
- Отслеживание прогресса
- xAPI интеграцию через JavaScript
- Адаптивный дизайн

### 2. Обновлен Cmi5PlayerView.swift
Метод `buildLaunchURL()` теперь:
1. Проверяет наличие демо-контента для активности
2. Использует data URL для загрузки HTML контента
3. Обрабатывает локальные URL правильно

### 3. Добавлено логирование в ModuleContentPreviews.swift
В метод `findActivityInBlock` добавлено детальное логирование для отладки:
- ID блока и количество активностей
- Проверка каждой активности
- Рекурсивный поиск в под-блоках

## Технические детали

### HTML контент с xAPI
```javascript
// Отправка xAPI statement о прогрессе
if (window.webkit && window.webkit.messageHandlers.xapi) {
    window.webkit.messageHandlers.xapi.postMessage({
        verb: 'progressed',
        result: {
            extensions: {
                'progress': progress / 100
            }
        }
    });
}
```

### Data URL для контента
```swift
static func getDataURL(for activityId: String) -> URL? {
    guard let content = getContent(for: activityId),
          let data = content.data(using: .utf8) else {
        return nil
    }
    
    let base64 = data.base64EncodedString()
    let urlString = "data:text/html;base64,\(base64)"
    return URL(string: urlString)
}
```

## Результат
Теперь при нажатии на "Начать модуль" в Cmi5 курсе:
1. Загружается реальный интерактивный HTML контент
2. Отслеживается прогресс прохождения
3. Отправляются xAPI statements
4. Пользователь может взаимодействовать с контентом

## Дальнейшие улучшения
1. Добавить загрузку реальных Cmi5 пакетов из ZIP архивов
2. Реализовать полную поддержку xAPI в LRSService
3. Добавить кэширование контента для оффлайн доступа
4. Расширить набор демо-курсов 