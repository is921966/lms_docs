# Sprint 42 День 2: План работы

**Дата**: 9 июля 2025  
**Sprint**: 42, День 2  
**Цель дня**: Офлайн поддержка для xAPI statements

## 📋 Критические задачи

### 🔴 Первый час (09:00-10:00) - Запуск и отладка тестов
1. Запустить все 64 теста из Day 1
2. Исправить проблемы компиляции если есть
3. Убедиться что базовая инфраструктура работает

### 🟡 Основная работа (10:00-17:00) - Офлайн поддержка

#### Создать файлы:
- [ ] `LMS/Features/Cmi5/Services/OfflineStatementStore.swift`
- [ ] `LMS/Features/Cmi5/Services/SyncManager.swift`
- [ ] `LMS/Features/Cmi5/Services/ConflictResolver.swift`
- [ ] `LMS/Features/Cmi5/Models/CoreDataModels.xcdatamodeld`
- [ ] `LMSTests/Features/Cmi5/Services/OfflineStatementStoreTests.swift`
- [ ] `LMSTests/Features/Cmi5/Services/SyncManagerTests.swift`
- [ ] `LMSTests/Features/Cmi5/Services/ConflictResolverTests.swift`

#### Реализовать функциональность:
- [ ] Сохранение statements в CoreData при отсутствии сети
- [ ] Автоматическая синхронизация при восстановлении связи
- [ ] Background sync через BackgroundTasks framework
- [ ] Разрешение конфликтов (last-write-wins + merge)
- [ ] Очередь синхронизации с приоритетами
- [ ] Уведомления о статусе синхронизации
- [ ] Метрики офлайн/онлайн статистики

### 🟢 Завершение дня (17:00-18:00)
- [ ] Интеграционные тесты офлайн/онлайн
- [ ] Создать отчет дня
- [ ] Обновить SPRINT_42_PROGRESS.md
- [ ] Commit и push изменений

## ⚠️ Важные требования

1. **CoreData схема** должна поддерживать версионирование
2. **Синхронизация** не должна блокировать UI
3. **Конфликты** должны логироваться для анализа
4. **Background tasks** должны быть энергоэффективными

## 🎯 Определение успеха

День считается успешным если:
- ✅ Офлайн режим полностью функционален
- ✅ Автоматическая синхронизация работает
- ✅ Написано минимум 30 тестов
- ✅ Background sync настроен
- ✅ Все изменения в Git

## 🏗️ Архитектурные решения

### CoreData схема:
```
PendingStatement:
- id: UUID
- statementJSON: String
- priority: Int16
- createdAt: Date
- syncStatus: String
- retryCount: Int16
- lastError: String?
```

### Sync стратегия:
1. Immediate sync при наличии сети
2. Batch sync каждые 5 минут в background
3. Force sync при открытии приложения
4. Retry с exponential backoff

---

**Начало работы**: 09:00  
**Конец работы**: 18:00  
**Следующий день**: Аналитика и отчеты 