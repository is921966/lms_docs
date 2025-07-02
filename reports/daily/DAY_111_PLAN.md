# День 111 - Sprint 23 Day 4 - Doctrine Repositories & Cache

**Дата**: 1 июля 2025  
**Sprint**: 23 (Learning Management Module)  
**Цель дня**: Завершить Infrastructure Layer с Doctrine и кэшированием  

## 📋 План на день

### 1. Doctrine Persistence Mappings (5 файлов)
- [ ] Course.orm.yml - маппинг для курсов
- [ ] Module.orm.yml - маппинг для модулей
- [ ] Lesson.orm.yml - маппинг для уроков
- [ ] Enrollment.orm.yml - маппинг для записей
- [ ] Progress.orm.yml - маппинг для прогресса

### 2. DoctrineCourseRepository (10 тестов)
- [ ] save с транзакциями
- [ ] findById с lazy loading
- [ ] findByCourseCode с индексами
- [ ] findAll с пагинацией
- [ ] findBy с QueryBuilder
- [ ] delete с soft deletes
- [ ] findPublished специфичный метод
- [ ] findByInstructor
- [ ] countByStatus
- [ ] Оптимистичная блокировка

### 3. DoctrineEnrollmentRepository (10 тестов)
- [ ] save enrollment
- [ ] findById
- [ ] findByUserAndCourse (unique constraint)
- [ ] findActiveEnrollments
- [ ] findExpiredEnrollments
- [ ] updateProgress
- [ ] completeEnrollment
- [ ] cancelEnrollment
- [ ] getEnrollmentStatistics
- [ ] findByCompletionDateRange

### 4. Cache Layer (10 тестов)
- [ ] CourseCache с Redis
- [ ] Cache warming при старте
- [ ] Cache invalidation при изменениях
- [ ] Tagged cache для групповой очистки
- [ ] TTL стратегии
- [ ] Cache-aside pattern
- [ ] Null object pattern для miss
- [ ] Статистика hit/miss
- [ ] Async cache refresh
- [ ] Circuit breaker для Redis

### 5. Integration Tests (5 тестов)
- [ ] Repository с реальной БД
- [ ] Event propagation E2E
- [ ] Cache integration
- [ ] Transaction rollback
- [ ] Performance benchmarks

## 🎯 Ожидаемый результат

К концу дня:
- 35+ новых тестов написано и проходят
- Doctrine полностью настроен
- Cache layer оптимизирует производительность
- Infrastructure Layer 100% готов
- Learning Module готов к HTTP слою

## 🏗️ Архитектура

```
Infrastructure/
├── Persistence/
│   ├── Doctrine/
│   │   ├── DoctrineCourseRepository.php
│   │   ├── DoctrineEnrollmentRepository.php
│   │   ├── Types/
│   │   │   ├── CourseIdType.php
│   │   │   └── CourseStatusType.php
│   │   └── Mappings/
│   │       ├── Course.orm.yml
│   │       └── Enrollment.orm.yml
│   └── InMemory/ (✅ done)
├── Events/ (✅ done)
└── Cache/
    ├── CourseCache.php
    ├── CacheKeyGenerator.php
    ├── RedisAdapter.php
    └── NullCache.php
```

## 💡 Технические решения

1. **Doctrine Custom Types** - для ValueObjects
2. **Read/Write splitting** - мастер для записи, реплики для чтения
3. **Query hints** - для оптимизации запросов
4. **Second level cache** - Doctrine cache + Redis
5. **Event listeners** - для cache invalidation

## ⚡ Быстрый старт

```bash
# Создание Doctrine mapping
mkdir -p src/Learning/Infrastructure/Persistence/Doctrine/Mappings
touch src/Learning/Infrastructure/Persistence/Doctrine/Mappings/Course.orm.yml

# Создание теста для Doctrine репозитория
mkdir -p tests/Unit/Learning/Infrastructure/Persistence/Doctrine
touch tests/Unit/Learning/Infrastructure/Persistence/Doctrine/DoctrineCourseRepositoryTest.php

# Запуск теста
./test-quick.sh tests/Unit/Learning/Infrastructure/Persistence/Doctrine/DoctrineCourseRepositoryTest.php
```

## 🔍 Особое внимание

1. **Производительность** - использовать EXPLAIN для запросов
2. **N+1 проблема** - eager loading где нужно
3. **Cache coherence** - синхронизация кэша при изменениях
4. **Deadlocks** - правильный порядок блокировок
5. **Memory leaks** - clear EntityManager в batch операциях

Начинаем с Doctrine mappings! 🚀 