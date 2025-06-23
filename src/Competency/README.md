# Competency Management Module

## Описание

Модуль управления компетенциями предоставляет функциональность для:
- Создания и управления компетенциями организации
- Оценки компетенций сотрудников
- Отслеживания прогресса развития компетенций
- Построения матрицы компетенций

## Архитектура

Модуль построен по принципам Domain-Driven Design (DDD) и состоит из трех слоев:

### Domain Layer
- **Entities**: Competency, UserCompetency, CompetencyAssessment
- **Value Objects**: CompetencyId, CompetencyCode, CompetencyLevel, CompetencyCategory, AssessmentScore
- **Domain Events**: CompetencyCreated, AssessmentConfirmed и др.
- **Domain Services**: CompetencyAssessmentService

### Application Layer
- **Services**: CompetencyService, AssessmentService
- **DTOs**: CompetencyDTO, AssessmentDTO

### Infrastructure Layer
- **Repositories**: InMemoryCompetencyRepository, InMemoryAssessmentRepository, InMemoryUserCompetencyRepository
- **HTTP Controllers**: CompetencyController, AssessmentController
- **Routes**: competency_routes.php

## API Endpoints

### Competencies

#### GET /api/v1/competencies
Получить список компетенций с фильтрацией.

**Query Parameters:**
- `category` - фильтр по категории (technical, soft, managerial, business)
- `active` - только активные компетенции (default: true)
- `search` - поиск по названию или описанию

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "code": "TECH-001",
      "name": "PHP Development",
      "description": "Навыки разработки на PHP",
      "category": "technical",
      "parent_id": null,
      "is_active": true,
      "created_at": "2025-02-03T10:00:00Z",
      "updated_at": "2025-02-03T10:00:00Z"
    }
  ]
}
```

#### POST /api/v1/competencies
Создать новую компетенцию.

**Request Body:**
```json
{
  "code": "TECH-001",
  "name": "PHP Development",
  "description": "Навыки разработки на PHP",
  "category": "technical",
  "parent_id": null
}
```

#### GET /api/v1/competencies/{id}
Получить компетенцию по ID.

#### PUT /api/v1/competencies/{id}
Обновить компетенцию.

#### DELETE /api/v1/competencies/{id}
Деактивировать компетенцию.

### Assessments

#### POST /api/v1/assessments
Создать оценку компетенции.

**Request Body:**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440001",
  "competency_id": "550e8400-e29b-41d4-a716-446655440000",
  "assessor_id": "550e8400-e29b-41d4-a716-446655440002",
  "level": "intermediate",
  "score": 75,
  "comment": "Хороший прогресс"
}
```

#### GET /api/v1/users/{userId}/assessments
Получить все оценки пользователя.

#### PUT /api/v1/assessments/{id}
Обновить оценку (только неподтвержденные).

#### POST /api/v1/assessments/{id}/confirm
Подтвердить оценку.

#### GET /api/v1/users/{userId}/competencies/{competencyId}/assessments
Получить историю оценок по конкретной компетенции.

## Уровни компетенций

1. **Beginner (Начинающий)** - базовые знания
2. **Elementary (Элементарный)** - может выполнять простые задачи под контролем
3. **Intermediate (Средний)** - может выполнять типовые задачи самостоятельно
4. **Advanced (Продвинутый)** - может выполнять сложные задачи, менторить других
5. **Expert (Эксперт)** - признанный эксперт, устанавливает стандарты

## Использование

### Создание компетенции
```php
$competencyService = $container->get(CompetencyService::class);

$result = $competencyService->createCompetency(
    code: 'TECH-001',
    name: 'PHP Development',
    description: 'Навыки разработки на PHP',
    category: 'technical'
);
```

### Оценка компетенции
```php
$assessmentService = $container->get(AssessmentService::class);

$result = $assessmentService->createAssessment(
    userId: '550e8400-e29b-41d4-a716-446655440001',
    competencyId: '550e8400-e29b-41d4-a716-446655440000',
    assessorId: '550e8400-e29b-41d4-a716-446655440002',
    level: 'intermediate',
    score: 75,
    comment: 'Хороший прогресс'
);
```

## Тестирование

Модуль имеет 100% покрытие тестами. Для запуска тестов:

```bash
# Запустить все тесты модуля
./test-quick.sh tests/Unit/Competency/

# Запустить тесты конкретного слоя
./test-quick.sh tests/Unit/Competency/Domain/
./test-quick.sh tests/Unit/Competency/Application/
./test-quick.sh tests/Unit/Competency/Infrastructure/
```

## Структура директорий

```
src/Competency/
├── Domain/
│   ├── Competency.php
│   ├── UserCompetency.php
│   ├── CompetencyAssessment.php
│   ├── Events/
│   ├── ValueObjects/
│   ├── Repository/
│   └── Service/
├── Application/
│   ├── DTO/
│   └── Service/
└── Infrastructure/
    ├── Repository/
    └── Http/
        ├── CompetencyController.php
        ├── AssessmentController.php
        └── Routes/
```

## Расширение функциональности

### Добавление новой категории компетенций
1. Обновить enum в `CompetencyCategory` value object
2. Обновить валидацию в `CompetencyService`
3. Обновить OpenAPI документацию

### Добавление нового уровня компетенций
1. Обновить `CompetencyLevel` value object
2. Обновить валидацию в `AssessmentService`
3. Обновить документацию

## Безопасность

- Все ID используют UUID для предотвращения перебора
- Валидация входных данных на всех уровнях
- Проверка прав доступа (требует интеграции с User модулем)

## Производительность

- In-memory репозитории для быстрого прототипирования
- Готовность к миграции на Doctrine ORM
- Оптимизированные запросы для массовых операций 