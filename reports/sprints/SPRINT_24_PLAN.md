# Sprint 24 - Program Management Module

**Период**: 3-7 июля 2025 (5 дней)  
**Цель**: Реализовать модуль управления программами обучения  
**Приоритет**: Высокий

## 📋 Описание

Program Management Module позволяет создавать и управлять программами обучения - структурированными последовательностями курсов для достижения определенных целей обучения.

## 🎯 Цели спринта

1. **Domain Layer** - модели программ и треков
2. **Application Layer** - сервисы управления программами
3. **Infrastructure Layer** - репозитории и persistence
4. **HTTP Layer** - REST API endpoints
5. **100% test coverage** - TDD подход

## 📊 User Stories

### Story 1: Domain Models (8 SP)
**Как** архитектор системы  
**Я хочу** иметь domain модели для программ  
**Чтобы** представлять структуру обучения

#### Acceptance Criteria:
```gherkin
Given программа обучения
When создается новая программа
Then она имеет уникальный идентификатор и код

Given программа с треками
When добавляется новый трек
Then он сохраняется в правильном порядке

Given трек с курсами
When проверяется готовность
Then учитываются все обязательные курсы
```

### Story 2: Application Services (6 SP)
**Как** администратор  
**Я хочу** управлять программами через сервисы  
**Чтобы** создавать структурированное обучение

#### Tasks:
- ProgramService - CRUD операции
- TrackService - управление треками
- ProgramEnrollmentService - запись на программы
- DTO layer для всех сущностей

### Story 3: Infrastructure Layer (4 SP)
**Как** разработчик  
**Я хочу** сохранять программы в БД  
**Чтобы** обеспечить persistence

#### Tasks:
- InMemoryProgramRepository
- Database migrations
- Repository interfaces
- Query builders

### Story 4: HTTP API (3 SP)
**Как** frontend разработчик  
**Я хочу** использовать REST API  
**Чтобы** интегрировать с UI

#### Endpoints:
- GET /api/programs - список программ
- POST /api/programs - создание программы
- GET /api/programs/{id} - детали программы
- PUT /api/programs/{id} - обновление
- POST /api/programs/{id}/tracks - добавление трека

## 🔧 Технические детали

### Domain сущности:
- **Program** - программа обучения
- **Track** - трек внутри программы
- **ProgramEnrollment** - запись на программу
- **TrackProgress** - прогресс по треку

### Value Objects:
- ProgramId, ProgramCode
- TrackId, TrackOrder
- ProgramStatus (draft, active, archived)
- CompletionCriteria

### Бизнес-правила:
1. Программа должна иметь хотя бы один трек
2. Трек должен иметь хотя бы один курс
3. Порядок треков важен и должен сохраняться
4. Программа может быть опубликована только с треками

## 📈 Метрики успеха

- ✅ 100% test coverage
- ✅ Все тесты проходят
- ✅ API документация готова
- ✅ Интеграция с Learning модулем

## 🚀 План работы

### День 1 (3 июля):
- Domain models: Program, Track
- Value Objects
- Unit tests

### День 2 (4 июля):
- ProgramEnrollment, TrackProgress
- Business rules
- Domain events

### День 3 (5 июля):
- Application services
- DTO layer
- Service tests

### День 4 (6 июля):
- Infrastructure layer
- Repositories
- Integration tests

### День 5 (7 июля):
- HTTP controllers
- API documentation
- E2E tests

## ⚠️ Риски

1. **Сложность связей** - программы связаны с курсами из Learning модуля
2. **Бизнес-логика** - правила завершения программ могут быть сложными
3. **Производительность** - загрузка больших программ с треками

## 🎯 Definition of Done

- [ ] Все acceptance criteria выполнены
- [ ] Unit тесты написаны и проходят
- [ ] Integration тесты готовы
- [ ] API документация обновлена
- [ ] Code review пройден
- [ ] Нет критических issues

## 📝 Заметки

- Использовать опыт из Learning модуля
- Применить те же паттерны и структуру
- Следовать TDD с первого дня
- Не забывать про namespace (Program, не App\Program) 