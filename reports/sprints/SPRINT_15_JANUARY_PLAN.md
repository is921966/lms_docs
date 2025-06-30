# Sprint 15 Plan - Architecture Refactoring (January 2025)

**Sprint Goal**: Применить Clean Architecture и паттерны из Cursor Rules v1.8.0
**Duration**: 3 дня (31 января - 2 февраля 2025)
**Team**: AI Assistant + Human Developer
**Prerequisites**: Sprint 14 completed (Cursor Rules v1.8.0, SwiftLint, BDD)

## 🎯 Sprint Objectives

1. Рефакторинг существующего кода по Clean Architecture
2. Внедрение Value Objects и DTOs
3. Исправление оставшихся SwiftLint ошибок (8 production errors)
4. Создание reference implementation для команды

## 📋 User Stories

### Story 1: Implement Value Objects Pattern
**Описание**: Создать Value Objects для domain моделей согласно architecture.mdc
**Acceptance Criteria**:
```gherkin
Given примитивные типы в domain models
When я создаю Value Objects
Then каждый VO валидирует свои данные
And невозможно создать невалидный объект
And VO являются immutable
And VO поддерживают Equatable и Hashable
```
**Tasks**:
- [ ] Создать базовый протокол ValueObject
- [ ] CourseId, LessonId, TestId value objects
- [ ] Email, PhoneNumber для User domain
- [ ] Progress value object (0-100%)
- [ ] CompetencyLevel с валидацией
- [ ] Unit тесты для каждого VO
**Effort**: 5 story points

### Story 2: Create DTO Layer
**Описание**: Внедрить DTO паттерн для API коммуникации
**Acceptance Criteria**:
```gherkin
Given прямая работа с API responses
When я создаю DTO layer
Then API responses мапятся в DTO
And DTO мапятся в Domain models
And валидация происходит при маппинге
And ошибки маппинга обрабатываются gracefully
```
**Tasks**:
- [ ] Создать DTO структуры для /courses endpoint
- [ ] Создать DTO для /users endpoint
- [ ] Создать DTO для /competencies endpoint
- [ ] Реализовать двусторонние Mappers
- [ ] Добавить error handling в mappers
- [ ] Integration тесты для маппинга
**Effort**: 8 story points

### Story 3: Repository Pattern Implementation
**Описание**: Заменить прямые вызовы сервисов на Repository паттерн
**Acceptance Criteria**:
```gherkin
Given прямые вызовы к MockServices
When реализован Repository pattern
Then domain использует только protocol interfaces
And конкретные реализации инжектируются через DI
And легко создавать test doubles
And поддерживается caching strategy
```
**Tasks**:
- [ ] CourseRepositoryProtocol в Domain layer
- [ ] UserRepositoryProtocol в Domain layer
- [ ] Concrete implementations в Data layer
- [ ] Setup DI container (Resolver)
- [ ] Migrate 3 ViewModels на repositories
- [ ] Add caching layer
**Effort**: 8 story points

### Story 4: Fix SwiftLint Critical Errors
**Описание**: Исправить 8 оставшихся production ошибок
**Acceptance Criteria**:
```gherkin
Given 6 function_body_length и 2 large_tuple errors
When я рефакторю код
Then все функции < 80 строк
And все tuples заменены на named structures
And логика разделена на smaller functions
And читаемость улучшена
```
**Tasks**:
- [ ] Разбить AdminSettingsView функции
- [ ] Разбить TestDetailView функции
- [ ] Создать структуры для 2 больших tuples
- [ ] Обновить вызовы после рефакторинга
- [ ] Проверить что UI tests проходят
**Effort**: 3 story points

### Story 5: Create Architecture Examples
**Описание**: Создать reference implementation для команды
**Acceptance Criteria**:
```gherkin
Given новая Clean Architecture
When я создаю примеры
Then есть полный CRUD модуль как образец
And есть migration guide от старой архитектуры
And есть диаграммы архитектуры
And есть code snippets для частых случаев
```
**Tasks**:
- [ ] Полный пример News модуля с Clean Architecture
- [ ] PlantUML диаграммы слоев
- [ ] Migration checklist
- [ ] Common patterns catalog
- [ ] Презентация для команды (Keynote)
**Effort**: 5 story points

## 📅 Sprint Schedule

### Day 1 (31 января) - Foundation
**Morning (3h)**:
- Story 1: Value Objects implementation
- Создание базовых VO для всех domain entities

**Afternoon (2h)**:
- Story 4: SwiftLint fixes
- Рефакторинг длинных функций и tuples

**Goal**: Базовые паттерны внедрены, код соответствует стандартам

### Day 2 (1 февраля) - Architecture
**Morning (3h)**:
- Story 2: DTO Layer creation
- Mappers и error handling

**Afternoon (3h)**:
- Story 3: Repository Pattern (начало)
- Protocols и первые implementations

**Goal**: API слой переработан, repositories готовы

### Day 3 (2 февраля) - Integration
**Morning (2h)**:
- Story 3: Repository Pattern (завершение)
- DI setup и migration

**Afternoon (3h)**:
- Story 5: Examples & Documentation
- Диаграммы и презентация

**Goal**: Все готово для команды, примеры документированы

## 🎯 Definition of Done

### Code Quality
- [ ] Zero SwiftLint errors в production коде
- [ ] 90%+ test coverage для новых компонентов
- [ ] Все публичные API задокументированы
- [ ] Соответствие Cursor Rules v1.8.0

### Architecture
- [ ] Четкое разделение слоев (Presentation/Domain/Data)
- [ ] Dependency rule соблюдается (внутрь only)
- [ ] Domain layer не зависит от фреймворков
- [ ] DI container настроен и используется

### Testing
- [ ] Unit tests для всех Value Objects
- [ ] Integration tests для repositories
- [ ] Mapper tests с edge cases
- [ ] UI tests продолжают проходить

### Documentation
- [ ] Architecture diagrams созданы
- [ ] Migration guide написан
- [ ] Code examples подготовлены
- [ ] README обновлен

## 📊 Success Metrics

1. **Code Quality Score**: 
   - SwiftLint violations < 2000 (target: 1800)
   - Production errors: 0

2. **Architecture Compliance**: 
   - 100% новых компонентов следуют Clean Architecture
   - 3+ модуля мигрированы

3. **Test Coverage**: 
   - Domain layer: > 95%
   - Data layer: > 85%
   - Overall: > 80%

4. **Performance**:
   - Build time increase < 10%
   - App launch time не изменился

## 🚫 Риски и митигация

| Риск | Вероятность | Влияние | Митигация |
|------|-------------|---------|-----------|
| Большой объем рефакторинга | Высокая | Высокое | Фокус на 3 критических модулях |
| Breaking changes в API | Средняя | Высокое | Версионирование и backward compatibility |
| Сложность для junior developers | Средняя | Среднее | Подробные примеры и документация |
| Performance degradation | Низкая | Высокое | Profiling после каждого изменения |

## 📚 Материалы для изучения

### Cursor Rules (обязательно):
1. `.cursor/rules/architecture.mdc` - Clean Architecture patterns
2. `.cursor/rules/client-server-integration.mdc` - DTO и networking
3. `.cursor/rules/naming-and-structure.mdc` - Naming conventions

### External Resources:
1. [Clean Architecture in iOS](https://tech.olx.com/clean-architecture-and-mvvm-on-ios-c9d167d9f5b3)
2. [Value Objects in Swift](https://www.swiftbysundell.com/articles/value-objects-in-swift/)
3. [Repository Pattern](https://www.raywenderlich.com/7181-repository-pattern-tutorial)

## 🎉 Ожидаемые результаты

После Sprint 15:
1. **Better testability**: Бизнес логика тестируется изолированно
2. **Flexibility**: Легко менять UI или data sources  
3. **Type safety**: Value Objects предотвращают ошибки
4. **Team alignment**: Все следуют единой архитектуре
5. **Future ready**: Готовы к микросервисной миграции

## 📝 Notes

- Приоритет на практическую применимость, не over-engineering
- Каждое решение должно быть обосновано реальной потребностью
- Фокус на модулях, которые часто меняются
- Документация важнее идеальной реализации

---
*Sprint 15 создан на основе результатов Sprint 14 и Cursor Rules v1.8.0*
*Next: Sprint 16 - Performance Optimization & Metrics* 