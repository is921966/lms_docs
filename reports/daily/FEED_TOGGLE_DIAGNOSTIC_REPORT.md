# Отчет по диагностике переключения новой ленты новостей

## Проблема
Пользователь включил переключатель "Новый дизайн ленты" в настройках, но новая лента не появляется даже после перезапуска приложения.

## Выполненные действия

### 1. Добавлено детальное логирование

#### MainTabView.swift:
- Логирование при инициализации view
- Логирование изменений `@AppStorage` переменной
- Логирование при появлении каждой ленты
- Подписка на уведомления об изменении UserDefaults

#### SettingsView.swift:
- Логирование при изменении переключателя
- Принудительная синхронизация UserDefaults
- Проверка значения до и после изменения

#### TelegramFeedView.swift и FeedView.swift:
- Логирование при инициализации
- Логирование при рендеринге

### 2. Создан диагностический инструмент

**FeedDesignDiagnosticView** - специальный экран для диагностики:
- Отображение текущего состояния `@AppStorage` и UserDefaults
- Кнопки для тестирования различных сценариев
- Мониторинг рассинхронизации значений
- Детальные логи всех операций

Доступ: Настройки → Поддержка → "Диагностика ленты" 🩺

### 3. Тестовый скрипт

Создан `test_feed_toggle.swift` для проверки UserDefaults вне приложения.

## Ожидаемые логи в консоли

При запуске приложения:
```
📱 MainTabView init - useNewFeedDesign: false
📜 Classic FeedView init
📰 Classic FeedView appeared
   - useNewFeedDesign: false
   - UserDefaults value: false
```

При включении переключателя:
```
⚙️ Settings: useNewFeedDesign changed from false to true
   - UserDefaults value: true
   - After sync: true
🔄 useNewFeedDesign changed to: true
⚡ UserDefaults changed notification received
   - useNewFeedDesign: true
   - UserDefaults value: true
🚀 TelegramFeedView init
🆕 TelegramFeedView appeared
   - useNewFeedDesign: true
   - UserDefaults value: true
```

## Возможные причины проблемы

1. **Кеширование view** - SwiftUI может кешировать NavigationStack
2. **Проблемы с @AppStorage** - возможна рассинхронизация с UserDefaults
3. **Bundle ID** - UserDefaults может использовать неправильный контейнер

## Рекомендации для пользователя

1. **Используйте диагностический экран**:
   - Ещё → Настройки → Поддержка → "Диагностика ленты"
   - Проверьте состояние переменных
   - Попробуйте кнопку "Toggle Feed Design"
   - Проверьте логи на наличие ошибок

2. **Проверьте консоль Xcode** при переключении

3. **Если ничего не помогает**:
   - Удалите папку DerivedData
   - Переустановите приложение
   - Используйте кнопку "Direct UserDefaults Update" в диагностике

## Технические детали

- Добавлен `.id(useNewFeedDesign)` для принудительного пересоздания view
- Используется `Group` для обертки условного рендеринга
- Добавлена принудительная синхронизация UserDefaults
- Все изменения логируются для отладки 