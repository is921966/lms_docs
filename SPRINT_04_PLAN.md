# Sprint 4: Position Management Service - План

## 📅 Период: 04.02.2025 - 12.02.2025 (9 дней)

## 🎯 Цель спринта
Создать модуль управления должностями (Position Management) с применением всех уроков Sprint 3: TDD с первого дня, чистая DDD архитектура, простые решения.

## 📋 Scope

### Основные функции:
1. **Управление должностями**
   - CRUD операции для должностей
   - Иерархия должностей (подчинение)
   - Категории должностей (технические, управленческие, вспомогательные)
   - Уровни должностей (junior, middle, senior, lead, principal)

2. **Профили должностей**
   - Требуемые компетенции для должности
   - Минимальные уровни компетенций
   - Желаемые (nice-to-have) компетенции
   - Ответственности и обязанности

3. **Карьерные пути**
   - Возможные переходы между должностями
   - Требования для перехода
   - Карьерные лестницы по направлениям

4. **Соответствие сотрудников**
   - Расчет соответствия сотрудника должности
   - Gap-анализ компетенций
   - Рекомендации по развитию

## 🏗️ Архитектура

### Domain Layer
- **Entities**: Position, PositionProfile, CareerPath
- **Value Objects**: PositionId, PositionCode, PositionLevel, Department
- **Domain Events**: PositionCreated, ProfileUpdated, CareerPathDefined
- **Domain Services**: PositionMatchingService

### Application Layer
- **Services**: PositionService, ProfileService, CareerPathService
- **DTOs**: PositionDTO, ProfileDTO, CareerPathDTO, MatchingResultDTO

### Infrastructure Layer
- **Repositories**: InMemory implementations
- **HTTP Controllers**: PositionController, ProfileController, CareerPathController
- **Routes & API Documentation**

## 📅 План по дням

### День 1 (04.02.2025) - Domain Models
- [ ] Position aggregate
- [ ] PositionProfile entity
- [ ] CareerPath entity
- [ ] Domain Events
- **Цель**: 30+ тестов

### День 2 (05.02.2025) - Value Objects
- [ ] PositionId
- [ ] PositionCode
- [ ] PositionLevel
- [ ] Department
- [ ] SeniorityLevel
- **Цель**: 30+ тестов

### День 3 (06.02.2025) - Domain Services & Interfaces
- [ ] Repository interfaces (3)
- [ ] PositionMatchingService
- [ ] CareerProgressionService
- **Цель**: 10+ тестов

### День 4 (07.02.2025) - Infrastructure Repositories
- [ ] InMemoryPositionRepository
- [ ] InMemoryProfileRepository
- [ ] InMemoryCareerPathRepository
- **Цель**: 35+ тестов

### День 5 (08.02.2025) - Application DTOs
- [ ] PositionDTO
- [ ] ProfileDTO
- [ ] CareerPathDTO
- [ ] MatchingResultDTO
- **Цель**: 15+ тестов

### День 6 (09.02.2025) - PositionService
- [ ] CRUD операции
- [ ] Иерархия должностей
- [ ] Поиск и фильтрация
- **Цель**: 15+ тестов

### День 7 (10.02.2025) - ProfileService & CareerPathService
- [ ] ProfileService (управление профилями)
- [ ] CareerPathService (карьерные пути)
- [ ] MatchingService (соответствие)
- **Цель**: 20+ тестов

### День 8 (11.02.2025) - HTTP Controllers
- [ ] PositionController
- [ ] ProfileController
- [ ] CareerPathController
- **Цель**: 15+ тестов

### День 9 (12.02.2025) - Routes & Documentation
- [ ] API routes configuration
- [ ] OpenAPI documentation
- [ ] README для модуля
- [ ] Integration testing
- **Цель**: 10+ тестов

## 🎯 Целевые метрики

- **Тестов**: 180+
- **Покрытие**: 100%
- **Файлов**: ~35
- **Строк кода**: ~3,500
- **API endpoints**: 12+

## 🔑 Ключевые принципы

1. **TDD с первого дня**
   - Пишем тест → запускаем → видим RED
   - Пишем код → запускаем → видим GREEN
   - Рефакторим → запускаем → остается GREEN

2. **Простота превыше всего**
   - In-memory repositories
   - Минимум абстракций
   - YAGNI принцип

3. **Размер файлов**
   - Оптимально: 50-150 строк
   - Максимум: 300 строк
   - Разбиваем большие файлы

4. **Документация сразу**
   - Комментарии в коде
   - README обновляется каждый день
   - OpenAPI spec с примерами

## 🚀 Definition of Done

Для каждого дня:
- [ ] Все запланированные файлы созданы
- [ ] Все тесты написаны и запущены
- [ ] 100% тестов проходят
- [ ] Код задокументирован
- [ ] Нет файлов больше 300 строк

Для всего спринта:
- [ ] Модуль полностью функционален
- [ ] API документация готова
- [ ] README с примерами использования
- [ ] Готов к production

## 📝 Уроки из Sprint 3

1. **Запускать тесты сразу** - не откладывать
2. **Value Objects упрощают код** - использовать активно
3. **In-memory достаточно** - для MVP и тестирования
4. **Документация = код** - писать одновременно

---

**Sprint 4 начинается!** 🚀 