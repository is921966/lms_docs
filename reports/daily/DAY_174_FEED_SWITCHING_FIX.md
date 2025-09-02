# Исправление переключения между классической и Telegram лентой

**Дата**: 18 июля 2025  
**День**: 174  
**Sprint**: 53  

## 🎯 Проблема

Пользователь не мог переключиться на новую ленту в стиле Telegram, несмотря на то что:
- UserDefaults правильно сохранял значение `useNewFeedDesign = true`
- FeedDesignManager показывал правильное значение
- Кнопка "Попробовать новую ленту" была доступна

## 🔍 Анализ проблемы

1. **Race condition** - MainTabView создавал `@StateObject` для FeedDesignManager, но проверка условия происходила до полной инициализации
2. **Двойное управление состоянием** - FeedDesignManager как синглтон и @StateObject создавали конфликт
3. **Отсутствие реактивности** - изменения в FeedDesignManager не вызывали перерисовку UI

## ✅ Решение

### 1. Прямое использование @AppStorage

**MainTabView.swift**:
```swift
// Было:
@StateObject private var feedDesignManager = FeedDesignManager.shared

// Стало:
@AppStorage("useNewFeedDesign") private var useNewFeedDesign = false
```

Теперь MainTabView напрямую читает из UserDefaults через @AppStorage, что гарантирует:
- Мгновенную реакцию на изменения
- Отсутствие race conditions
- Автоматическую перерисовку UI

### 2. Обновление условия выбора ленты

```swift
// Было:
if feedDesignManager.useNewDesign {
    TelegramFeedView()
} else {
    FeedView()
}

// Стало:
if useNewFeedDesign {
    TelegramFeedView()
} else {
    FeedView()
}
```

### 3. Улучшение переключения в FeedView

```swift
Button(action: {
    // Напрямую меняем UserDefaults
    withAnimation {
        useNewFeedDesign = true
        
        // Также обновляем FeedDesignManager для синхронизации
        FeedDesignManager.shared.setDesign(true)
    }
})
```

### 4. Добавление возможности вернуться к классической ленте

В **TelegramFeedView** добавлена кнопка в toolbar:
```swift
ToolbarItem(placement: .navigationBarLeading) {
    Button(action: { 
        UserDefaults.standard.set(false, forKey: "useNewFeedDesign")
        FeedDesignManager.shared.setDesign(false)
    }) {
        Label("Классическая лента", systemImage: "newspaper")
    }
}
```

## 🐛 Дополнительные исправления

1. **NavigationTracker** - исправлен синтаксис вызова:
   ```swift
   // Было: trackScreen(view, module: module)
   // Стало: trackScreen(view, metadata: ["module": module])
   ```

2. **UIEventLogger** - обновлен для совместимости с новым NavigationTracker

3. **LoginView** - исправлен вызов trackScreen

## 📊 Результат

Теперь переключение между лентами работает корректно:
1. ✅ Нажатие на "Попробовать новую ленту" мгновенно переключает на TelegramFeedView
2. ✅ Изменения сохраняются и применяются сразу
3. ✅ Можно вернуться к классической ленте через кнопку в навбаре
4. ✅ Состояние сохраняется между запусками приложения

## 🔑 Ключевые уроки

1. **@AppStorage vs Singleton** - для UI состояний лучше использовать @AppStorage напрямую
2. **Race conditions** - важно учитывать порядок инициализации компонентов
3. **SwiftUI реактивность** - использовать встроенные механизмы SwiftUI для автоматических обновлений

## 📈 Метрики

- Время на диагностику: ~30 минут
- Время на исправление: ~20 минут
- Измененных файлов: 5
- Строк кода изменено: ~50

## Заключение

Проблема была вызвана архитектурным конфликтом между паттерном Singleton и SwiftUI property wrappers. Решение через прямое использование @AppStorage устранило race condition и обеспечило надежное переключение между версиями ленты. 