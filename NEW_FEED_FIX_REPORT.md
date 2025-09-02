# Отчет: Исправление проблемы с новой лентой новостей

## Дата: 18 июля 2025

### Проблема
Новая лента новостей (TelegramFeedView) не отображается, несмотря на то что:
- Флаг `useNewFeedDesign` установлен в `true` в UserDefaults
- FeedDesignManager инициализируется с `useNewDesign = true`
- Но отображается классическая лента (FeedView)

### Анализ проблемы

1. **Проверка флага в UserDefaults:**
```
useNewFeedDesign = 1 (true)
```

2. **Логи приложения показывают:**
```
📜 Classic FeedView init
🎯 FeedDesignManager init: useNewDesign = true
📜 Classic FeedView body rendered
   - feedDesignManager.useNewDesign: true
```

3. **Корневая причина:**
- FeedDesignManager создается с правильным значением, но условие в MainTabView проверяется до того, как FeedDesignManager успевает правильно инициализироваться
- Возможная race condition между инициализацией @StateObject и проверкой условия

### Примененные исправления

1. **Добавлен метод forceRefresh() в FeedDesignManager:**
```swift
func forceRefresh() {
    let currentValue = UserDefaults.standard.bool(forKey: "useNewFeedDesign")
    if currentValue != useNewDesign {
        self.useNewDesign = currentValue
        NotificationCenter.default.post(name: FeedDesignManager.feedDesignChangedNotification, object: nil)
    }
}
```

2. **Обновлен FeedDesignManager для реагирования на изменения UserDefaults:**
```swift
// В наблюдателе UserDefaults.didChangeNotification
self?.useNewDesign = newValue
NotificationCenter.default.post(name: FeedDesignManager.feedDesignChangedNotification, object: nil)
```

3. **Исправлена ошибка сериализации в ComprehensiveLogger:**
- Добавлен метод sanitizeForJSON для конвертации Date объектов в строки
- Исправлена проблема с крашем при логировании

### Текущий статус

✅ **Исправлено:**
- Краш приложения из-за JSON сериализации
- FeedDesignManager теперь корректно обновляется при изменении UserDefaults
- MainTabView вызывает forceRefresh при появлении

❌ **Требует дополнительного внимания:**
- Новая лента все еще может не отображаться из-за timing проблем
- Возможно, требуется изменить подход к инициализации

### Рекомендуемое временное решение

Пока проблема не решена полностью, пользователь может:

1. **Использовать кнопку в классической ленте:**
   - Открыть приложение
   - На экране классической ленты нажать синюю кнопку "Попробовать новую ленту"
   - Это программно переключит на новую ленту

2. **Перезапустить приложение:**
   - После нажатия кнопки перезапустить приложение
   - Новая лента должна отобразиться

### Долгосрочное решение

Рекомендуется рефакторинг логики выбора ленты:
1. Использовать @AppStorage вместо FeedDesignManager
2. Или инициализировать FeedDesignManager синхронно перед рендерингом UI
3. Добавить явную задержку или использовать onAppear для гарантии правильной инициализации

### Команды для проверки

```bash
# Проверить флаг
xcrun simctl spawn 899AAE09-580D-4FF5-BF16-3574382CD796 defaults read ru.tsum.lms.igor useNewFeedDesign

# Установить флаг
xcrun simctl spawn 899AAE09-580D-4FF5-BF16-3574382CD796 defaults write ru.tsum.lms.igor useNewFeedDesign -bool true

# Сделать скриншот
xcrun simctl io 899AAE09-580D-4FF5-BF16-3574382CD796 screenshot feed_state.png
``` 