# Sprint 43: Bug Fixes & Improvements

**Период:** 15-19 июля 2025 (5 дней)  
**Цель:** Исправить критические баги и улучшить стабильность

## 🎯 Основные задачи

### 1. Исправить Notifications модуль (2 дня)
**Проблема:** Модуль отключен из-за ошибок компиляции

**Задачи:**
- [ ] Восстановить NotificationService с правильной архитектурой
- [ ] Исправить NotificationListView и связанные UI
- [ ] Реализовать локальные push-уведомления
- [ ] Добавить 50+ тестов для покрытия
- [ ] Интегрировать с Feature Registry

**Ожидаемый результат:**
- Работающие уведомления в приложении
- Push-уведомления для важных событий
- Настройки уведомлений в профиле

### 2. Native Excel Export (1.5 дня)
**Проблема:** Текущий экспорт только в CSV

**Задачи:**
- [ ] Найти/создать Swift библиотеку для Excel
- [ ] Реализовать ExcelExporter сервис
- [ ] Добавить форматирование (цвета, стили)
- [ ] Экспорт для всех отчетов
- [ ] Тесты для Excel генерации

**Поддерживаемые форматы:**
- .xlsx с несколькими листами
- Форматирование ячеек
- Формулы для итогов
- Графики (опционально)

### 3. Исправление известных багов (1 день)
**Список багов:**

1. **Info.plist дублирование**
   - Очистить дубликаты настроек
   - Консолидировать в один файл

2. **iPad оптимизация**
   - Адаптивные layouts
   - Split view поддержка
   - Улучшить navigation

3. **Dark mode улучшения**
   - Исправить контрасты
   - Обновить цвета графиков
   - Тестирование всех экранов

### 4. TestFlight Feedback (0.5 дня)
**Обработать отзывы от тестеров:**
- [ ] Собрать все отзывы
- [ ] Prioritize по важности
- [ ] Создать GitHub issues
- [ ] Quick fixes где возможно

## 📊 Метрики успеха

### Качество:
- ✅ 100% тестов проходят
- ✅ 0 критических багов
- ✅ Test coverage > 95%

### Функциональность:
- ✅ Notifications работают
- ✅ Excel export функционирует
- ✅ iPad experience улучшен

### Производительность:
- ✅ Сохранить текущие метрики
- ✅ Не увеличить размер app > 100MB
- ✅ Memory usage < 100MB

## 🚀 Deliverables

### Код:
1. Исправленный Notifications модуль
2. ExcelExporter сервис
3. Bug fixes для известных issues

### Документация:
1. Обновленный CHANGELOG
2. Notifications использование guide
3. Excel export документация

### Release:
1. **Version:** 2.1.1
2. **Build:** 203
3. **TestFlight:** 19 июля

## 📅 Daily План

### День 1 (15 июля):
- Анализ Notifications проблем
- Начать рефакторинг NotificationService
- Setup Excel библиотеки

### День 2 (16 июля):
- Завершить Notifications backend
- UI компоненты для уведомлений
- Начать Excel export

### День 3 (17 июля):
- Push notifications setup
- Завершить Excel export базовый функционал
- Начать bug fixes

### День 4 (18 июля):
- Notifications тестирование
- Excel форматирование и стили
- iPad оптимизация

### День 5 (19 июля):
- Final testing
- Bug fixes
- TestFlight release 2.1.1

## 🛠️ Технический подход

### Notifications Architecture:
```swift
protocol NotificationServiceProtocol {
    func scheduleNotification(_ notification: Notification)
    func cancelNotification(id: String)
    func requestAuthorization()
}

class NotificationService: NotificationServiceProtocol {
    // Local notifications
    // Push notifications setup
    // Settings management
}
```

### Excel Export:
```swift
protocol ExcelExportable {
    func toExcelData() -> ExcelData
}

class ExcelExporter {
    func export<T: ExcelExportable>(_ data: [T]) -> Data
    func exportMultiSheet(_ sheets: [ExcelSheet]) -> Data
}
```

## ⚠️ Риски

1. **Notifications сложность** - может занять больше времени
2. **Excel библиотека** - может не найтись готовая
3. **iPad testing** - нужны реальные устройства

## 📝 Notes

- Фокус на стабильности, не добавлять новые функции
- Все изменения должны быть backward compatible
- Подготовка к Admin Dashboard в Sprint 44

---

**Sprint 43 начинается 15 июля!** 🚀 