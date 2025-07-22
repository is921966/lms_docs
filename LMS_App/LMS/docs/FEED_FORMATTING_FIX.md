# Исправление форматирования текста в Feed

## Проблема

В ленте новостей сообщения отображались с текстовыми звездочками (**) вместо правильного форматирования жирного текста.

## Решение

### 1. Улучшена проверка HTML контента
**Файл**: `PostContentView.swift`

- Удалено лишнее приведение типа в проверке metadata
- Добавлена дополнительная проверка на наличие HTML тегов в контенте
- Исправлена логика определения HTML контента

### 2. Добавлена поддержка Markdown-style форматирования
**Файл**: `PostContentView.swift`

Реализована обработка **bold** текста через AttributedString:
- Использует NSRegularExpression для поиска паттернов `**текст**`
- Заменяет текст между звездочками на жирный шрифт
- Обрабатывает в обратном порядке для сохранения индексов

### 3. Обновлен контент релизных новостей
**Файл**: `MockFeedService.swift`

- Обновлен HTML контент для более красивого отображения
- Использована правильная структура с тегами `<strong>`
- Добавлены стили для корректного отображения

## Технические детали

### HTML Detection Logic:
```swift
private var isHTMLContent: Bool {
    // Проверяем metadata для типа контента
    if let contentType = post.metadata?["contentType"],
       contentType == "html" {
        return true
    }
    // Также проверяем по тегам и типу
    if let tags = post.tags,
       tags.contains("release") || tags.contains("#release"),
       let type = post.metadata?["type"],
       type == "app_release" {
        return true
    }
    // Также проверяем, содержит ли контент HTML теги
    if post.content.contains("<div") || post.content.contains("<h1") || post.content.contains("<h2") {
        return true
    }
    return false
}
```

### Text Formatting:
```swift
private var formattedContent: AttributedString {
    var attributedString = AttributedString(displayedContent)
    
    // Обработка **bold** текста
    do {
        let pattern = try NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*", options: [])
        let matches = pattern.matches(in: displayedContent, options: [], range: NSRange(location: 0, length: displayedContent.count))
        
        // Обрабатываем в обратном порядке, чтобы не нарушить индексы
        for match in matches.reversed() {
            if let range = Range(match.range, in: displayedContent) {
                let boldText = String(displayedContent[range].dropFirst(2).dropLast(2))
                
                if let attributedRange = attributedString.range(of: String(displayedContent[range])) {
                    attributedString.replaceSubrange(attributedRange, with: AttributedString(boldText))
                    if let newRange = attributedString.range(of: boldText) {
                        attributedString[newRange].font = .body.bold()
                    }
                }
            }
        }
    } catch {
        // Если не удалось обработать, возвращаем как есть
        return attributedString
    }
    
    return attributedString
}
```

## Результат

- HTML контент (релизные новости) теперь корректно отображается через HTMLContentView
- Обычный текст с **markdown** форматированием преобразуется в жирный текст
- Сохранена обратная совместимость с существующим контентом

## Дальнейшие улучшения

1. Добавить поддержку других markdown элементов:
   - *italic* текст
   - [ссылки](url)
   - `код`
   - # Заголовки

2. Улучшить HTMLContentView для динамического размера

3. Добавить темную тему для HTML контента

---

**Sprint 47, День 151**  
**Статус**: ✅ Исправлено  
**BUILD SUCCEEDED** 