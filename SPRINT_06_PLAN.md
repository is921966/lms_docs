# План Sprint 6: Integration Layer

## 📋 Информация о спринте
- **Номер спринта**: 6
- **Название**: Integration & Database Layer
- **Планируемая длительность**: 5-7 дней
- **Планируемое количество тестов**: ~150
- **Основная цель**: Интеграция всех сервисов и реальная персистентность

## 🎯 Цели спринта

### 1. Database Repositories
Реализовать Doctrine репозитории для всех сервисов:
- [ ] UserRepository
- [ ] RoleRepository
- [ ] CompetencyRepository
- [ ] PositionRepository
- [ ] CourseRepository
- [ ] EnrollmentRepository
- [ ] ProgressRepository
- [ ] CertificateRepository

### 2. Database Migrations
Создать миграции для всех таблиц:
- [ ] Основные таблицы сущностей
- [ ] Связующие таблицы (many-to-many)
- [ ] Индексы для производительности
- [ ] Начальные данные (seeders)

### 3. Event Bus
Реализовать систему событий:
- [ ] EventBus интерфейс
- [ ] In-Memory implementation
- [ ] Symfony Messenger integration
- [ ] Domain event handlers

### 4. API Gateway
Создать единую точку входа:
- [ ] Routing configuration
- [ ] Request/Response middleware
- [ ] Error handling
- [ ] CORS configuration

### 5. Integration Tests
Полноценные интеграционные тесты:
- [ ] Database transaction tests
- [ ] API endpoint tests
- [ ] Event propagation tests
- [ ] Cross-service scenarios

## 📊 Планируемая декомпозиция по дням

### День 1: Database Repositories (User & Auth)
- Doctrine configuration
- UserRepository implementation
- RoleRepository implementation
- PermissionRepository implementation
- Тесты: ~20

### День 2: Database Repositories (Competency & Position)
- CompetencyRepository implementation
- UserCompetencyRepository implementation
- PositionRepository implementation
- CareerPathRepository implementation
- Тесты: ~25

### День 3: Database Repositories (Learning)
- CourseRepository implementation
- EnrollmentRepository implementation
- ProgressRepository implementation
- CertificateRepository implementation
- Тесты: ~30

### День 4: Migrations & Seeders
- Создание всех миграций
- Оптимизация индексов
- Создание seeders для тестовых данных
- Тесты миграций
- Тесты: ~15

### День 5: Event Bus & Middleware
- EventBus implementation
- Event handlers для всех сервисов
- Middleware для API
- Тесты: ~20

### День 6: API Gateway & Integration
- API Gateway configuration
- Cross-service integration
- Error handling
- Тесты: ~20

### День 7: Full Integration Tests
- End-to-end scenarios
- Performance tests
- Load tests
- Тесты: ~20

## 🏗️ Технические решения

### Database
```yaml
ORM: Doctrine 2
База_данных: PostgreSQL
Миграции: Doctrine Migrations
Тестирование: SQLite in-memory для скорости
```

### Event System
```yaml
Шина_событий: Symfony Messenger
Транспорт: In-memory для тестов, AMQP для production
Сериализация: JSON
Retry_strategy: Exponential backoff
```

### API Gateway
```yaml
Framework: Symfony 6
Routing: Атрибуты PHP 8
Документация: OpenAPI 3.0
Аутентификация: JWT tokens
```

## 📈 Метрики успеха

### Обязательные:
- [ ] Все тесты проходят (100%)
- [ ] Покрытие кода > 80%
- [ ] Все миграции выполняются и откатываются
- [ ] API документация сгенерирована

### Желательные:
- [ ] Производительность API < 100ms
- [ ] Нет N+1 запросов
- [ ] События обрабатываются асинхронно
- [ ] Graceful degradation при недоступности сервисов

## ⚠️ Риски и митигация

### Риск 1: Сложность интеграции
**Митигация**: Начать с простых случаев, постепенно усложнять

### Риск 2: Производительность БД
**Митигация**: Профилирование запросов, оптимизация индексов

### Риск 3: Циклические зависимости
**Митигация**: Строгое следование DDD boundaries

## 📋 Definition of Done

Для каждой задачи:
- [ ] Код написан через TDD
- [ ] Все тесты проходят
- [ ] Документация обновлена
- [ ] Код review пройден
- [ ] Интеграционные тесты созданы

Для спринта:
- [ ] Все сервисы интегрированы
- [ ] База данных работает
- [ ] События распространяются
- [ ] API задокументирован
- [ ] Производительность приемлемая

## 🎯 Ожидаемые результаты

К концу спринта:
1. **Полностью рабочее приложение** с реальной БД
2. **Event-driven архитектура** для слабой связности
3. **API Gateway** для внешних интеграций
4. **Готовность к production** (кроме масштабирования)

---

**Старт спринта**: После утверждения плана  
**Методология**: TDD, постоянная интеграция  
**Приоритет**: Сначала критичные сервисы (User, Auth) 