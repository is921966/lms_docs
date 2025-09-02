# План День 157 - Sprint 49 День 4: HTTP/Presentation слой

**Дата**: 16 июля 2025  
**Спринт**: 49 - Модуль "Оргструктура"  
**Цель дня**: Реализация HTTP контроллеров, API endpoints и DTO для импорта оргструктуры

## 📋 Задачи на день

### 1. HTTP контроллеры (TDD)
- [ ] EmployeeController - CRUD операции для сотрудников
- [ ] DepartmentController - управление подразделениями
- [ ] PositionController - управление должностями
- [ ] ImportController - импорт CSV файлов

### 2. Request/Response DTOs
- [ ] EmployeeRequest/Response
- [ ] DepartmentRequest/Response
- [ ] PositionRequest/Response
- [ ] ImportRequest/Response
- [ ] BulkOperationRequest

### 3. Маршруты и конфигурация
- [ ] routes/orgstructure.yaml - настройка маршрутов
- [ ] Middleware для валидации
- [ ] Обработка файловых загрузок

### 4. Валидация и безопасность
- [ ] Валидация CSV файлов
- [ ] Проверка прав доступа
- [ ] Rate limiting для импорта
- [ ] Санитизация данных

## 🎯 Ожидаемые результаты
- 30-35 тестов для контроллеров
- Полностью функциональное API
- OpenAPI документация
- ~95% покрытие тестами

## ⏱️ Оценка времени
- HTTP контроллеры: ~90 минут
- DTOs и маппинг: ~30 минут
- Маршруты и middleware: ~20 минут
- Тесты и документация: ~40 минут
- **Итого**: ~3 часа 