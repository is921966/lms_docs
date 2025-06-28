# 🚀 Feedback System - Быстрый старт (2 минуты)

## Шаг 1: Интеграция в приложение

Откройте `LMSApp.swift` и добавьте одну строку:

```swift
WindowGroup {
    ContentView()
        .feedbackEnabled() // ← Добавьте эту строку
}
```

## Шаг 2: Запустите сервер (для тестирования)

```bash
cd /Users/ishirokov/lms_docs/LMS_App/LMS/scripts
python3 feedback_server.py
```

Откройте http://localhost:5000 в браузере

## Шаг 3: Готово! 

### Как использовать:
- **Потрясите устройство** → откроется форма отзыва
- **Нажмите плавающую кнопку** → в правом нижнем углу
- **Нарисуйте на скриншоте** → выделите проблему
- **Отправьте** → работает даже offline

### Что вы получаете:
- ✅ Все отзывы в веб-интерфейсе
- ✅ Скриншоты с аннотациями
- ✅ Полная информация об устройстве
- ✅ Автоматические GitHub issues (если настроено)

## Для production:

1. Измените URL в `FeedbackService.swift`:
```swift
private let baseURL = "https://your-api.com/api/v1"
private let useMockEndpoint = false
```

2. Разверните сервер на Heroku/VPS

## Вот и всё! 🎉

Теперь у вас есть система feedback лучше чем в TestFlight! 