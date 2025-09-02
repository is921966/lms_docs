# 🛠 Developer Tools Guide

## 📱 Встроенные инструменты разработчика

В приложении LMS теперь встроен полный набор инструментов для мониторинга и отладки облачных серверов прямо из приложения!

## 🚀 Как получить доступ

### В Debug режиме:
1. Откройте приложение
2. Перейдите в **Настройки** (вкладка "Ещё")
3. Найдите секцию **🛠 Developer Tools**

### Доступные инструменты:

#### 1. 🌐 Cloud Servers
Просмотр dashboards прямо в приложении:
- **Log Dashboard** - все логи приложения в реальном времени
- **Feedback Dashboard** - отзывы пользователей
- Переключение между серверами свайпом
- Возможность открыть в Safari
- Настройка URL серверов

#### 2. 📊 Server Status
Мониторинг состояния серверов:
- Статус online/offline для каждого сервера
- Количество логов и отзывов
- Автоматическая проверка каждые 30 секунд
- Ручное обновление pull-to-refresh
- Тест соединения одной кнопкой

#### 3. 📝 Log Testing
Тестирование системы логирования:
- Отправка тестовых логов
- Просмотр локальных логов
- Проверка работы ComprehensiveLogger

#### 4. 🔧 Debug Menu
Дополнительные инструменты:
- Feature Flags управление
- Feedback Debug информация
- Очистка кэша
- Статус модулей

## ⚙️ Настройка серверов

### Изменение URL серверов:

1. **Через UI:**
   - Cloud Servers → Menu (⋯) → Настройки серверов
   - Введите новые URL
   - Нажмите "Сохранить"

2. **Программно:**
   ```swift
   CloudServerManager.shared.updateURLs(
       logServer: "https://your-log-server.com",
       feedbackServer: "https://your-feedback-server.com"
   )
   ```

### Значения по умолчанию:
- **Log Server**: `https://lms-log-server-production.up.railway.app`
- **Feedback Server**: `https://lms-feedback-server-production.up.railway.app`

## 🔍 Использование

### Просмотр логов в реальном времени:

1. Откройте **Cloud Servers**
2. Выберите **Log Dashboard**
3. Используйте фильтры:
   - По категории (UI, Network, Data, etc.)
   - По уровню (Info, Warning, Error)
   - Поиск по тексту

### Просмотр отзывов:

1. Откройте **Cloud Servers**
2. Выберите **Feedback Dashboard**
3. Просматривайте:
   - Текст отзыва
   - Тип (bug, feature, improvement)
   - Информацию об устройстве
   - Ссылку на GitHub issue

### Проверка соединения:

1. Откройте **Server Status**
2. Нажмите **Test Connections**
3. Проверьте:
   - Отправился ли тестовый лог
   - Появился ли он в dashboard

## 🚨 Troubleshooting

### Сервер показывает Offline:

1. Проверьте интернет-соединение
2. Попробуйте открыть URL в Safari
3. Проверьте правильность URL в настройках
4. Убедитесь что сервер развернут на Railway/Render

### Dashboard не загружается:

1. Проверьте статус сервера
2. Pull-to-refresh для обновления
3. Откройте в Safari для диагностики

### Логи не отправляются:

1. Проверьте Server Status
2. Убедитесь что LogUploader запущен
3. Проверьте URL в CloudServerManager

## 💡 Советы

1. **Автоматическое переключение** между локальными и облачными серверами через настройки

2. **Быстрая диагностика** - используйте Server Status для проверки всех компонентов

3. **Отладка на устройстве** - Developer Tools работают и в TestFlight сборках

4. **Экспорт данных** - открывайте dashboards в Safari для сохранения/экспорта

## 🔐 Безопасность

- Developer Tools доступны только в Debug режиме
- URL серверов хранятся в UserDefaults
- Токены не передаются через приложение
- Используется HTTPS для облачных серверов

## 📱 Интеграция в ваш код

### Логирование:
```swift
ComprehensiveLogger.shared.log(.network, .info, "API request", details: [
    "endpoint": "/api/users",
    "method": "GET"
])
```

### Отправка feedback:
```swift
// Автоматически через shake gesture
// Или программно:
FeedbackManager.shared.presentFeedback()
```

### Проверка статуса:
```swift
CloudServerManager.shared.checkServerHealth { logHealthy, feedbackHealthy in
    print("Servers status - Log: \(logHealthy), Feedback: \(feedbackHealthy)")
}
```

---

🎉 Теперь у вас есть полный контроль над облачными серверами прямо из приложения! 