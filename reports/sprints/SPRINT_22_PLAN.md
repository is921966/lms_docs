# Sprint 22: Competency Management

**Sprint**: 22  
**Название**: Competency Management Module  
**Планируемые даты**: День 101-105 (условные)  
**Цель**: Реализовать систему управления компетенциями с TDD

## 🎯 Цели спринта

Создать полноценный модуль управления компетенциями для отслеживания навыков и развития сотрудников.

### Основные компоненты:
1. **Competency Domain** - модель компетенций
2. **Skill Levels** - уровни владения навыками
3. **Assessment System** - система оценки
4. **Progress Tracking** - отслеживание прогресса
5. **Competency Matrix** - матрица компетенций

## 📋 User Stories

### 1. Управление компетенциями (13 SP)
**Как** администратор  
**Я хочу** создавать и управлять компетенциями  
**Чтобы** определить требуемые навыки для должностей

**Acceptance Criteria:**
- Создание компетенции с названием и описанием
- Категоризация компетенций (технические, soft skills, etc.)
- Определение уровней владения (1-5)
- Связь компетенций с должностями

### 2. Оценка компетенций (8 SP)
**Как** руководитель  
**Я хочу** оценивать компетенции сотрудников  
**Чтобы** понимать их уровень и потребности в развитии

**Acceptance Criteria:**
- Создание оценки для сотрудника
- Выбор компетенции и уровня
- Добавление комментариев
- История оценок

### 3. Матрица компетенций (5 SP)
**Как** HR специалист  
**Я хочу** видеть матрицу компетенций  
**Чтобы** анализировать навыки в организации

**Acceptance Criteria:**
- Визуализация компетенций по сотрудникам
- Фильтрация по подразделениям
- Экспорт данных
- Gap анализ

### 4. Личный профиль компетенций (5 SP)
**Как** сотрудник  
**Я хочу** видеть свои компетенции  
**Чтобы** понимать направления развития

**Acceptance Criteria:**
- Просмотр своих оценок
- История изменений
- Сравнение с требованиями должности
- Рекомендации по развитию

### 5. API и интеграция (3 SP)
**Как** разработчик  
**Я хочу** использовать API компетенций  
**Чтобы** интегрировать с другими системами

**Acceptance Criteria:**
- RESTful API endpoints
- OpenAPI документация
- Аутентификация и авторизация
- Пагинация и фильтрация

**Всего Story Points**: 34

## 🏗️ Техническая архитектура

### Domain Layer:
```
Competency/
├── Domain/
│   ├── Entities/
│   │   ├── Competency.php
│   │   ├── CompetencyCategory.php
│   │   └── Assessment.php
│   ├── ValueObjects/
│   │   ├── CompetencyId.php
│   │   ├── SkillLevel.php
│   │   └── AssessmentPeriod.php
│   ├── Repositories/
│   │   ├── CompetencyRepositoryInterface.php
│   │   └── AssessmentRepositoryInterface.php
│   └── Services/
│       ├── CompetencyService.php
│       └── AssessmentService.php
```

### Application Layer:
```
├── Application/
│   ├── Commands/
│   │   ├── CreateCompetencyCommand.php
│   │   ├── AssessCompetencyCommand.php
│   │   └── UpdateAssessmentCommand.php
│   ├── Queries/
│   │   ├── GetCompetencyMatrixQuery.php
│   │   └── GetUserCompetenciesQuery.php
│   └── Handlers/
│       ├── CreateCompetencyHandler.php
│       └── AssessCompetencyHandler.php
```

## 📅 План по дням

### День 101 (Domain Layer):
- [ ] Competency entity с тестами
- [ ] CompetencyCategory entity
- [ ] Value Objects (CompetencyId, SkillLevel)
- [ ] Repository interfaces
- [ ] Domain services

### День 102 (Application Layer):
- [ ] Commands и DTOs
- [ ] Command handlers
- [ ] Queries и Query handlers
- [ ] Business logic
- [ ] Validation

### День 103 (Infrastructure Layer):
- [ ] MySQLCompetencyRepository
- [ ] MySQLAssessmentRepository
- [ ] Database migrations
- [ ] Integration tests

### День 104 (HTTP Layer):
- [ ] CompetencyController
- [ ] AssessmentController
- [ ] Request validation
- [ ] API routes
- [ ] OpenAPI documentation

### День 105 (Integration & Polish):
- [ ] End-to-end tests
- [ ] Performance optimization
- [ ] Documentation
- [ ] Code review
- [ ] Sprint retrospective

## 🎯 Definition of Done

- [ ] Все user stories реализованы
- [ ] 100+ тестов написано и проходят
- [ ] Code coverage >90%
- [ ] API документация готова
- [ ] Migrations протестированы
- [ ] Performance benchmarks пройдены
- [ ] Security review пройден
- [ ] Код готов к production

## 📊 Метрики успеха

- Время создания компетенции < 100ms
- Время загрузки матрицы < 500ms
- 0 критических багов
- 100% тестов проходят
- Документация покрывает все endpoints

## 🚧 Риски

1. **Сложность модели** - компетенции могут иметь иерархию
2. **Performance** - матрица может быть большой
3. **Интеграция** - связь с User и Position модулями

## 💡 Технические решения

1. **Уровни компетенций**: Enum с описаниями
2. **Категории**: Отдельная entity для гибкости
3. **История оценок**: Event sourcing подход
4. **Кеширование**: Для матрицы компетенций
5. **Batch operations**: Для массовых оценок

---

**Sprint 22 начинается с большими амбициями после рекордного Sprint 21!** 