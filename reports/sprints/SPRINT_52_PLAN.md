# Sprint 52: Microservices Development - Course & Competency Services

**Sprint**: 52  
**Даты**: 20-24 июля 2025 (Дни 169-173)  
**Цель**: Завершить разработку ключевых микросервисов и довести iOS до 100% Clean Architecture

## 🎯 Основные цели

1. **Разработать CourseService** - управление курсами с поддержкой CMI5
2. **Разработать CompetencyService** - матрица компетенций и оценка
3. **Завершить миграцию iOS** - оставшиеся 15% на Clean Architecture
4. **Kubernetes deployment** - манифесты для всех сервисов
5. **TestFlight 2.4.0** - новый релиз с микросервисами

## 📅 План по дням

### День 1 (169) - CourseService Domain & Application
- [ ] Domain entities: Course, Module, Lesson, Enrollment
- [ ] Value Objects: CourseId, CourseCode, Duration, Price
- [ ] Domain Events: CourseCreated, EnrollmentStarted, CourseCompleted
- [ ] Application Services: CourseService, EnrollmentService
- [ ] Repository interfaces и DTOs
- [ ] Unit tests (минимум 40)

### День 2 (170) - CourseService Infrastructure & CMI5
- [ ] PostgreSQL repositories
- [ ] CMI5 integration layer
- [ ] HTTP controllers и routing
- [ ] OpenAPI specification
- [ ] Integration tests
- [ ] Docker configuration

### День 3 (171) - CompetencyService Full Stack
- [ ] Domain: Competency, Level, Assessment, Matrix
- [ ] Application: CompetencyService, AssessmentService
- [ ] Infrastructure: Repositories, Controllers
- [ ] Competency matrix calculator
- [ ] API endpoints и документация
- [ ] Full test coverage

### День 4 (172) - iOS Clean Architecture Completion
- [ ] Миграция Feed модуля на MVVM-C
- [ ] Миграция Settings на Clean Architecture
- [ ] Обновление всех Coordinators
- [ ] Performance optimization до < 0.5s launch
- [ ] iPad layout fixes
- [ ] UI/Unit tests

### День 5 (173) - Integration & Release
- [ ] Kubernetes manifests для всех сервисов
- [ ] API Gateway routing update
- [ ] End-to-end integration tests
- [ ] Load testing с k6
- [ ] TestFlight 2.4.0 build & release
- [ ] Sprint retrospective

## 📊 Метрики успеха

| Метрика | Цель | Критично |
|---------|------|----------|
| Микросервисов готово | 4 из 6 | ✅ |
| iOS Clean Architecture | 100% | ✅ |
| Test coverage | >85% | ✅ |
| iOS launch time | <0.5s | ✅ |
| API response time | <100ms | ✅ |
| TestFlight release | v2.4.0 | ✅ |

## 🔧 Технический стек

### CourseService
- PHP 8.1 + Symfony 7.0
- PostgreSQL с JSONB для metadata
- Redis для кэширования
- RabbitMQ для событий

### CompetencyService
- То же + специализированные алгоритмы
- Graph database considerations (Neo4j)
- Матричные вычисления

### iOS Updates
- SwiftUI + Combine
- Clean Architecture patterns
- Dependency Injection
- Coordinator pattern

## 🚨 Риски и митигация

1. **CMI5 сложность** → Использовать готовую библиотеку
2. **Performance iOS** → Профилирование с Instruments
3. **Kubernetes сложность** → Начать с простых манифестов
4. **Интеграция сервисов** → Поэтапное тестирование

## 📝 Definition of Done

- [ ] Все тесты проходят (>85% coverage)
- [ ] Документация обновлена
- [ ] Code review пройден
- [ ] Performance метрики достигнуты
- [ ] TestFlight build загружен
- [ ] Kubernetes manifests готовы

## 🔗 Зависимости

- Результаты Sprint 51 (Auth, User services)
- CMI5 спецификация и примеры
- iOS Feature Registry обновлен
- API Gateway настроен

## 💡 Заметки

После Sprint 52 останется:
- NotificationService (Sprint 53)
- OrgStructureService (Sprint 53)
- Production deployment (Sprint 54)
- Security audit (Sprint 54)
- Go-live подготовка (Sprint 55)

---

**Sprint 52 - ключевой этап перед production release!** 🚀 