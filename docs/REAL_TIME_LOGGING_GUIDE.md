# Real-Time Logging System Guide

## 🚀 Быстрый старт

### 1. Запуск лог-сервера

```bash
# Из корня проекта
./scripts/start-log-server.sh
```

Сервер запустится на:
- **Локально**: http://localhost:5002
- **В сети**: http://YOUR_IP:5002

### 2. Просмотр логов

Откройте в браузере: http://localhost:5002

### 3. Тестирование в приложении

1. Запустите приложение в симуляторе
2. Перейдите в Settings → Developer Tools → Log Testing
3. Нажимайте кнопки для генерации разных типов логов

## 📊 Возможности веб-интерфейса

### Фильтрация по категориям
- **All** - все логи
- **UI** - взаимодействия с интерфейсом
- **Navigation** - переходы между экранами
- **Network** - сетевые запросы
- **Data** - изменения данных
- **Error** - ошибки
- **Auth** - авторизация

### Поиск
Используйте поле поиска для фильтрации по тексту события или деталям.

### Статистика
- Общее количество логов
- Количество отфильтрованных логов
- Время последнего обновления
- Текущий пользователь
- Текущий экран

### Auto-refresh
По умолчанию включено автообновление каждую секунду.

## 🛠 Настройка для реального устройства

### 1. Найдите IP адрес вашего Mac

```bash
ipconfig getifaddr en0
# или
ipconfig getifaddr en1
```

### 2. Обновите LogUploader.swift

```swift
#if targetEnvironment(simulator)
private let serverEndpoint = "http://localhost:5002/api/logs"
#else
// Замените на ваш IP
private let serverEndpoint = "http://192.168.1.100:5002/api/logs"
#endif
```

### 3. Убедитесь что устройства в одной сети

iPhone и Mac должны быть подключены к одной Wi-Fi сети.

## 📝 Использование в коде

### Базовое логирование

```swift
ComprehensiveLogger.shared.log(.ui, .info, "Button tapped", details: [
    "button": "Login",
    "screen": "LoginView"
])
```

### UI события

```swift
ComprehensiveLogger.shared.logUIEvent(
    "Form submitted",
    view: "RegistrationView",
    action: "submit",
    details: ["fields": 5]
)
```

### Навигация

```swift
ComprehensiveLogger.shared.logNavigation(
    from: "HomeView",
    to: "ProfileView",
    method: "tab_bar",
    details: ["tab_index": 3]
)
```

### Сетевые запросы

```swift
ComprehensiveLogger.shared.logNetworkRequest(
    request,
    response: response,
    data: responseData,
    error: error
)
```

### Ошибки

```swift
ComprehensiveLogger.shared.log(.error, .error, "Failed to load data", details: [
    "error": error.localizedDescription,
    "endpoint": "/api/courses"
])
```

## 🔍 Анализ проблем

### Проблема с новой лентой

1. Фильтруйте по категории "UI" или "Navigation"
2. Ищите "FeedView" или "TelegramFeedView"
3. Проверьте значение `useNewDesign` в логах
4. Смотрите последовательность инициализации

### Пример поиска проблемы

```
1. Поиск: "Feed design"
2. Фильтр: UI
3. Смотрим на timestamp для определения порядка событий
4. Проверяем details для значений переменных
```

## 🚨 Решение проблем

### Логи не отправляются

1. Проверьте что сервер запущен
2. Проверьте IP адрес в LogUploader
3. Убедитесь что нет ошибок сети в консоли Xcode

### Сервер не запускается

```bash
# Установите зависимости
pip3 install flask flask-cors

# Проверьте порт
lsof -i :5002
```

### Слишком много логов

1. Используйте фильтры
2. Очистите логи кнопкой Clear
3. Отключите auto-refresh при анализе

## 💡 Советы

1. **Цветовая кодировка** помогает быстро найти нужную категорию
2. **Timestamp** показывает точное время события
3. **Details** содержат JSON с дополнительной информацией
4. **Current Screen** показывает где сейчас находится пользователь
5. **Export** логов возможен через API endpoint `/api/logs`

## 📊 API Endpoints

### GET /api/logs
Получить логи с фильтрацией

Параметры:
- `category` - фильтр по категории
- `search` - поиск по тексту
- `after` - ID последнего полученного лога

### POST /api/logs
Отправка логов от приложения

### POST /api/logs/clear
Очистка всех логов

### GET /health
Проверка состояния сервера 