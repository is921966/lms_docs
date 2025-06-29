# Sprint 12: Исправление ошибок системы обратной связи

**Дата**: 2025-06-29
**Статус**: 🔧 В РАБОТЕ

## 🐛 Обнаруженные проблемы

### 1. ❌ Скриншоты не сохраняются в GitHub Issues
**Проблема**: Скриншоты делаются в приложении, но не передаются на сервер и не появляются в GitHub Issues.
**Причина**: 
- В `GitHubFeedbackService.createIssueData()` скриншот не включается в body issue
- Сервер не обрабатывает base64 изображения для загрузки в GitHub

### 2. ❌ Неправильный тип обращения
**Проблема**: Тип обращения (bug/feature/improvement/question) не корректно передается в GitHub.
**Причина**:
- В `FeedbackView` используется локальный enum `FeedbackType`
- В `FeedbackModel` тип сохраняется как строка
- Несоответствие между типами в разных частях системы

### 3. ❌ Скриншот текущего экрана вместо предыдущего
**Проблема**: При открытии формы обратной связи делается скриншот самой формы, а не экрана, с которого она была вызвана.
**Причина**:
- `takeScreenshot()` вызывается в `onAppear` FeedbackView
- Скриншот делается после показа формы, а не до

## 📋 План исправлений

### Исправление 1: Сохранение скриншотов в GitHub

1. **Обновить серверную часть** для загрузки изображений в GitHub:
   - Использовать GitHub API для загрузки изображений как attachments
   - Или загружать на image hosting (imgur/cloudinary) и вставлять ссылку

2. **Обновить `GitHubFeedbackService`**:
   - Добавить обработку скриншотов в `createIssueData()`
   - Включить ссылку на изображение в body issue

### Исправление 2: Унификация типов обращений

1. **Создать единый enum `FeedbackType`** в общем месте
2. **Обновить все компоненты** для использования единого типа
3. **Добавить маппинг** для GitHub labels

### Исправление 3: Правильный захват скриншота

1. **Изменить логику захвата**:
   - Делать скриншот ДО показа формы обратной связи
   - Сохранять скриншот в FeedbackManager
   - Передавать готовый скриншот в FeedbackView

2. **Обновить FeedbackManager**:
   - Добавить метод `captureScreenshot()`
   - Вызывать его перед `presentFeedback()`

## 🚀 Реализация

### Шаг 1: Унификация FeedbackType
```swift
// Создать в Common/Models/FeedbackType.swift
enum FeedbackType: String, CaseIterable, Codable {
    case bug = "bug"
    case feature = "feature"
    case improvement = "improvement"
    case question = "question"
    
    var title: String {
        switch self {
        case .bug: return "Ошибка"
        case .feature: return "Предложение"
        case .improvement: return "Улучшение"
        case .question: return "Вопрос"
        }
    }
    
    var icon: String {
        switch self {
        case .bug: return "ladybug"
        case .feature: return "lightbulb"
        case .improvement: return "wand.and.stars"
        case .question: return "questionmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .bug: return .red
        case .feature: return .blue
        case .improvement: return .orange
        case .question: return .purple
        }
    }
    
    var githubLabel: String {
        switch self {
        case .bug: return "bug"
        case .feature: return "enhancement"
        case .improvement: return "improvement"
        case .question: return "question"
        }
    }
}
```

### Шаг 2: Исправление захвата скриншота
```swift
// В FeedbackManager
func captureScreenBeforeFeedback() {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return }
    
    let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
    let image = renderer.image { context in
        window.layer.render(in: context.cgContext)
    }
    
    self.screenshot = image
}

func presentFeedback() {
    captureScreenBeforeFeedback()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.isShowingFeedback = true
    }
}
```

### Шаг 3: Обработка скриншотов на сервере
```python
# В feedback_server.py добавить загрузку изображений
async def upload_screenshot_to_imgur(base64_image):
    """Загружает скриншот на Imgur и возвращает URL"""
    # Реализация загрузки на Imgur
    pass

async def create_github_issue_with_screenshot(feedback_data):
    """Создает GitHub issue со скриншотом"""
    screenshot_url = None
    if feedback_data.get('screenshot'):
        screenshot_url = await upload_screenshot_to_imgur(feedback_data['screenshot'])
    
    # Добавить screenshot_url в body issue
    if screenshot_url:
        body += f"\n\n## 📸 Скриншот\n![Screenshot]({screenshot_url})"
```

## ✅ Ожидаемый результат

1. **Скриншоты в GitHub Issues**: Каждый отзыв с скриншотом будет содержать изображение в issue
2. **Правильные типы**: Типы обращений будут корректно отображаться и использоваться для labels
3. **Корректный скриншот**: Будет захватываться экран, с которого вызвана обратная связь

## 📊 Метрики успеха

- 100% скриншотов сохраняются в GitHub Issues
- 100% корректных типов обращений
- 0% скриншотов формы обратной связи (только предыдущий экран) 