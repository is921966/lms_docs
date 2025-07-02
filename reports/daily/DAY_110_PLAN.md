# День 110 - Sprint 23 Day 3 - Learning Management Infrastructure Layer

**Дата**: 1 июля 2025  
**Sprint**: 23 (Learning Management Module)  
**Цель дня**: Создать Infrastructure Layer с Doctrine repositories  

## 📋 План на день

### 1. Repository Implementations (20 тестов)
- [ ] DoctrineCourseRepository - полная реализация
- [ ] InMemoryCourseRepository для тестов
- [ ] DoctrineEnrollmentRepository
- [ ] InMemoryEnrollmentRepository

### 2. Event Infrastructure (10 тестов)
- [ ] SymfonyEventDispatcher адаптер
- [ ] EventStore для аудита
- [ ] DomainEventSubscriber
- [ ] EventSerializer

### 3. Database Migrations (5 файлов)
- [ ] 008_create_courses_table.php
- [ ] 009_create_modules_table.php
- [ ] 010_create_lessons_table.php
- [ ] 011_create_enrollments_table.php
- [ ] 012_create_progress_table.php

### 4. Persistence Mapping (5 файлов)
- [ ] Course.orm.yml
- [ ] Module.orm.yml
- [ ] Lesson.orm.yml
- [ ] Enrollment.orm.yml
- [ ] Progress.orm.yml

### 5. Cache Layer (5 тестов)
- [ ] CourseCache с Redis
- [ ] EnrollmentCache
- [ ] Cache invalidation стратегия

## 🎯 Ожидаемый результат

К концу дня:
- 40+ тестов написано и проходят
- Все repositories реализованы
- Миграции готовы к запуску
- Event infrastructure работает
- Cache layer настроен

## 🏗️ Архитектура

```
Learning/
├── Infrastructure/
│   ├── Persistence/
│   │   ├── Doctrine/
│   │   │   ├── DoctrineCourseRepository.php
│   │   │   ├── DoctrineEnrollmentRepository.php
│   │   │   └── Mappings/
│   │   │       ├── Course.orm.yml
│   │   │       └── Enrollment.orm.yml
│   │   └── InMemory/
│   │       ├── InMemoryCourseRepository.php
│   │       └── InMemoryEnrollmentRepository.php
│   ├── Events/
│   │   ├── SymfonyEventDispatcher.php
│   │   ├── EventStore.php
│   │   └── EventSerializer.php
│   └── Cache/
│       ├── CourseCache.php
│       └── RedisAdapter.php
```

## 💡 Технические решения

1. **Repository pattern** - изоляция от конкретной БД
2. **In-Memory implementations** - быстрые тесты
3. **Event Store** - аудит всех изменений
4. **Cache-aside pattern** - оптимизация чтения
5. **Doctrine mappings** - гибкая схема БД

## ⚡ Быстрый старт

```bash
# Создание теста для репозитория
cd tests/Unit/Learning/Infrastructure/Persistence
touch DoctrineCourseRepositoryTest.php

# Запуск теста
./test-quick.sh tests/Unit/Learning/Infrastructure/Persistence/DoctrineCourseRepositoryTest.php

# Создание миграции
touch database/migrations/008_create_courses_table.php
```

## 🔍 Особое внимание

1. **Транзакции** - все операции записи в транзакциях
2. **Lazy loading** - избегать N+1 запросов
3. **UUID** - использовать для всех ID
4. **Soft deletes** - для курсов и записей
5. **Версионирование** - для отслеживания изменений

Начинаем с TDD! 🚀 