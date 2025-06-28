# Собственная система Feedback для LMS App

## 🎯 Что мы создали

Полноценную систему обратной связи, которая:
- ✅ Работает лучше TestFlight feedback
- ✅ Поддерживает скриншоты с аннотациями
- ✅ Автоматически создает GitHub issues
- ✅ Работает offline (сохраняет локально)
- ✅ Имеет веб-интерфейс для просмотра

## 📱 iOS компоненты

### Созданные файлы:
```
LMS/Features/Feedback/
├── FeedbackView.swift          # Основная форма отзыва
├── ScreenshotEditorView.swift  # Редактор скриншотов
├── FeedbackModel.swift         # Модель данных
├── FeedbackService.swift       # Сервис отправки
└── FeedbackManager.swift       # Менеджер интеграции
```

## 🚀 Быстрая интеграция (5 минут)

### Шаг 1: Добавьте в LMSApp.swift

```swift
import SwiftUI

@main
struct LMSApp: App {
    init() {
        setupFeedback() // Добавьте эту строку
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .feedbackEnabled() // И эту
        }
    }
}
```

### Шаг 2: Shake для feedback

Приложение уже настроено на shake gesture! Просто потрясите устройство, и откроется форма отзыва.

### Шаг 3: Плавающая кнопка

Автоматически появляется в правом нижнем углу. Можно скрыть:
```swift
FeedbackManager.shared.feedbackButtonVisible = false
```

## 🖥️ Backend сервер

### Запуск тестового сервера:

```bash
cd /Users/ishirokov/lms_docs/LMS_App/LMS/scripts

# Установка зависимостей
pip3 install flask flask-cors

# Запуск
python3 feedback_server.py
```

Сервер запустится на http://localhost:5000

### Endpoints:
- `POST /api/v1/feedback` - Прием отзывов
- `GET /` - Веб-интерфейс для просмотра
- `GET /api/v1/feedback/list` - JSON список

## 🔧 Настройка для production

### 1. Измените URL в FeedbackService.swift:

```swift
private let baseURL = "https://your-api.com/api/v1" 
private let useMockEndpoint = false // Выключите mock
```

### 2. Настройте GitHub интеграцию:

```bash
export GITHUB_TOKEN=your-github-token
export GITHUB_REPO=your-org/your-repo
```

### 3. Деплой сервера:

Вариант 1 - Heroku:
```bash
# Создайте requirements.txt
echo "flask\nflask-cors\nrequests" > requirements.txt

# Создайте Procfile
echo "web: python feedback_server.py" > Procfile

# Деплой
heroku create your-feedback-server
git push heroku main
```

Вариант 2 - VPS с nginx:
```nginx
location /api/feedback {
    proxy_pass http://localhost:5000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

## 📊 Функциональность

### Что может пользователь:
1. **Shake gesture** - потрясти устройство
2. **Floating button** - нажать на кнопку
3. **Выбрать тип** - Ошибка/Предложение/Улучшение/Вопрос
4. **Написать текст** - подробное описание
5. **Редактировать скриншот** - рисовать, выделять проблемные места
6. **Отправить** - работает даже offline

### Что получаете вы:
1. **Instant feedback** - мгновенные уведомления
2. **GitHub issues** - автоматическое создание для багов
3. **Веб-интерфейс** - удобный просмотр всех отзывов
4. **Полная информация** - устройство, версия, скриншот
5. **Offline support** - не теряются отзывы

## 🎨 Кастомизация

### Изменение цветов и стилей:

```swift
// В FeedbackView.swift
enum FeedbackType {
    var color: Color {
        switch self {
        case .bug: return .red         // Измените цвета
        case .feature: return .blue
        case .improvement: return .orange
        case .question: return .purple
        }
    }
}
```

### Добавление полей:

```swift
// В FeedbackModel.swift добавьте новые поля
struct FeedbackModel {
    // ... существующие поля
    let priority: Int?
    let affectedFeature: String?
}
```

## 🔍 Debug меню

В debug сборках автоматически добавляется вкладка Debug:
- Показать форму feedback
- Включить/выключить кнопку
- Отправить тестовый отзыв
- Просмотреть локальные отзывы

## 📈 Преимущества над TestFlight

| Функция | TestFlight | Наше решение |
|---------|------------|--------------|
| API доступ | ❌ | ✅ |
| Скриншоты | ✅ | ✅ |
| Аннотации | ✅ | ✅ |
| Offline | ❌ | ✅ |
| GitHub интеграция | ❌ | ✅ |
| Веб-интерфейс | ❌ | ✅ |
| Кастомизация | ❌ | ✅ |
| Мгновенные уведомления | ❌ | ✅ |

## 🚨 Troubleshooting

**Проблема**: Shake gesture не работает
**Решение**: Убедитесь что вызван `setupFeedback()` в `LMSApp.init()`

**Проблема**: Скриншоты не отправляются
**Решение**: Проверьте размер - base64 может быть большим. Можно сжимать:
```swift
let compressedData = screenshot.jpegData(compressionQuality: 0.7)
```

**Проблема**: GitHub issues не создаются
**Решение**: Проверьте GITHUB_TOKEN и права доступа

## 🎉 Готово!

Теперь у вас есть полноценная система feedback, которая:
1. Работает из коробки
2. Не зависит от Apple API
3. Полностью под вашим контролем
4. Бесплатная

Запустите приложение, потрясите устройство и попробуйте! 