# Position Management API - Примеры запросов

## Positions

### Создание должности

**Request:**
```http
POST /api/v1/positions
Content-Type: application/json

{
  "code": "DEV-003",
  "title": "Senior Backend Developer",
  "department": "IT",
  "level": 3,
  "description": "Опытный разработчик backend-систем",
  "parentId": "pos-002"
}
```

**Response (201 Created):**
```json
{
  "status": "success",
  "data": {
    "id": "pos-003",
    "code": "DEV-003",
    "title": "Senior Backend Developer",
    "department": "IT",
    "level": 3,
    "levelName": "Senior",
    "description": "Опытный разработчик backend-систем",
    "parentId": "pos-002",
    "isActive": true,
    "createdAt": "2025-02-10T10:30:00Z",
    "updatedAt": "2025-02-10T10:30:00Z"
  }
}
```

**Validation Error (400 Bad Request):**
```json
{
  "status": "error",
  "message": "Validation failed",
  "errors": {
    "code": "Invalid code format. Expected: 2-5 uppercase letters, hyphen, 3-5 digits",
    "title": "Title is required"
  }
}
```

### Получение списка активных должностей

**Request:**
```http
GET /api/v1/positions
```

**Response (200 OK):**
```json
{
  "status": "success",
  "data": [
    {
      "id": "pos-001",
      "code": "DEV-001",
      "title": "Junior Developer",
      "department": "IT",
      "level": 1,
      "levelName": "Junior",
      "description": "Начинающий разработчик",
      "parentId": null,
      "isActive": true,
      "createdAt": "2025-01-15T08:00:00Z",
      "updatedAt": "2025-01-15T08:00:00Z"
    },
    {
      "id": "pos-002",
      "code": "DEV-002",
      "title": "Middle Developer",
      "department": "IT",
      "level": 2,
      "levelName": "Middle",
      "description": "Разработчик среднего уровня",
      "parentId": null,
      "isActive": true,
      "createdAt": "2025-01-15T08:30:00Z",
      "updatedAt": "2025-01-15T08:30:00Z"
    }
  ]
}
```

### Обновление должности

**Request:**
```http
PUT /api/v1/positions/pos-003
Content-Type: application/json

{
  "title": "Senior Full-Stack Developer",
  "description": "Опытный разработчик full-stack приложений",
  "level": 3
}
```

**Response (200 OK):**
```json
{
  "status": "success",
  "data": {
    "id": "pos-003",
    "code": "DEV-003",
    "title": "Senior Full-Stack Developer",
    "department": "IT",
    "level": 3,
    "levelName": "Senior",
    "description": "Опытный разработчик full-stack приложений",
    "parentId": "pos-002",
    "isActive": true,
    "createdAt": "2025-02-10T10:30:00Z",
    "updatedAt": "2025-02-10T11:00:00Z"
  }
}
```

### Архивирование должности

**Request:**
```http
POST /api/v1/positions/pos-003/archive
```

**Response (200 OK):**
```json
{
  "status": "success",
  "message": "Position archived successfully"
}
```

## Profiles

### Создание профиля компетенций

**Request:**
```http
POST /api/v1/profiles
Content-Type: application/json

{
  "positionId": "pos-003",
  "responsibilities": [
    "Разработка и поддержка backend-сервисов",
    "Проектирование архитектуры приложений",
    "Code review и менторинг junior разработчиков",
    "Участие в планировании спринтов"
  ],
  "requirements": [
    "Опыт разработки на PHP 5+ лет",
    "Знание принципов SOLID, DDD, TDD",
    "Опыт работы с микросервисной архитектурой",
    "Английский язык уровня B2+"
  ]
}
```

**Response (201 Created):**
```json
{
  "status": "success",
  "data": {
    "positionId": "pos-003",
    "responsibilities": [
      "Разработка и поддержка backend-сервисов",
      "Проектирование архитектуры приложений",
      "Code review и менторинг junior разработчиков",
      "Участие в планировании спринтов"
    ],
    "requirements": [
      "Опыт разработки на PHP 5+ лет",
      "Знание принципов SOLID, DDD, TDD",
      "Опыт работы с микросервисной архитектурой",
      "Английский язык уровня B2+"
    ],
    "requiredCompetencies": [],
    "desiredCompetencies": [],
    "createdAt": "2025-02-10T11:15:00Z",
    "updatedAt": "2025-02-10T11:15:00Z"
  }
}
```

### Добавление требований к компетенциям

**Request:**
```http
POST /api/v1/positions/pos-003/profile/competencies
Content-Type: application/json

{
  "competencyId": "comp-001",
  "minimumLevel": 4,
  "isRequired": true
}
```

**Response (200 OK):**
```json
{
  "status": "success",
  "message": "Competency requirement added successfully"
}
```

### Получение профиля должности

**Request:**
```http
GET /api/v1/positions/pos-003/profile
```

**Response (200 OK):**
```json
{
  "status": "success",
  "data": {
    "positionId": "pos-003",
    "responsibilities": [
      "Разработка и поддержка backend-сервисов",
      "Проектирование архитектуры приложений",
      "Code review и менторинг junior разработчиков",
      "Участие в планировании спринтов"
    ],
    "requirements": [
      "Опыт разработки на PHP 5+ лет",
      "Знание принципов SOLID, DDD, TDD",
      "Опыт работы с микросервисной архитектурой",
      "Английский язык уровня B2+"
    ],
    "requiredCompetencies": [
      {
        "competencyId": "comp-001",
        "minimumLevel": 4,
        "isRequired": true
      }
    ],
    "desiredCompetencies": [
      {
        "competencyId": "comp-002",
        "minimumLevel": 3,
        "isRequired": false
      }
    ],
    "createdAt": "2025-02-10T11:15:00Z",
    "updatedAt": "2025-02-10T11:20:00Z"
  }
}
```

## Career Paths

### Создание карьерного пути

**Request:**
```http
POST /api/v1/career-paths
Content-Type: application/json

{
  "fromPositionId": "pos-001",
  "toPositionId": "pos-002",
  "requirements": [
    "Минимум 2 года опыта на позиции Junior Developer",
    "Успешное прохождение внутренней сертификации",
    "Выполнение минимум 3 проектов среднего уровня сложности"
  ],
  "estimatedDuration": 24
}
```

**Response (201 Created):**
```json
{
  "status": "success",
  "data": {
    "id": "path-001",
    "fromPositionId": "pos-001",
    "toPositionId": "pos-002",
    "requirements": [
      "Минимум 2 года опыта на позиции Junior Developer",
      "Успешное прохождение внутренней сертификации",
      "Выполнение минимум 3 проектов среднего уровня сложности"
    ],
    "estimatedDuration": 24,
    "isActive": true,
    "milestones": [],
    "createdAt": "2025-02-10T12:00:00Z",
    "updatedAt": "2025-02-10T12:00:00Z"
  }
}
```

### Добавление milestone к карьерному пути

**Request:**
```http
POST /api/v1/career-paths/path-001/milestones
Content-Type: application/json

{
  "title": "Базовая сертификация",
  "description": "Прохождение внутренних курсов по основам разработки",
  "monthsFromStart": 6
}
```

**Response (200 OK):**
```json
{
  "status": "success",
  "message": "Milestone added successfully"
}
```

### Получение прогресса по карьерному пути

**Request:**
```http
GET /api/v1/career-paths/pos-001/pos-002/progress?employeeId=emp-123&monthsCompleted=12
```

**Response (200 OK):**
```json
{
  "status": "success",
  "data": {
    "employeeId": "emp-123",
    "fromPositionId": "pos-001",
    "toPositionId": "pos-002",
    "monthsCompleted": 12,
    "progressPercentage": 50,
    "remainingMonths": 12,
    "isEligibleForPromotion": false,
    "completedMilestones": [
      {
        "title": "Базовая сертификация",
        "description": "Прохождение внутренних курсов по основам разработки",
        "monthsFromStart": 6
      }
    ],
    "nextMilestone": {
      "title": "Проектная практика",
      "description": "Успешное выполнение 2 проектов среднего уровня",
      "monthsFromStart": 18
    },
    "requirements": [
      "Минимум 2 года опыта на позиции Junior Developer",
      "Успешное прохождение внутренней сертификации",
      "Выполнение минимум 3 проектов среднего уровня сложности"
    ],
    "estimatedCompletionDate": "2026-02-10T12:00:00Z"
  }
}
```

### Получение активных карьерных путей

**Request:**
```http
GET /api/v1/career-paths/active
```

**Response (200 OK):**
```json
{
  "status": "success",
  "data": [
    {
      "id": "path-001",
      "fromPositionId": "pos-001",
      "toPositionId": "pos-002",
      "requirements": [
        "Минимум 2 года опыта на позиции Junior Developer",
        "Успешное прохождение внутренней сертификации",
        "Выполнение минимум 3 проектов среднего уровня сложности"
      ],
      "estimatedDuration": 24,
      "isActive": true,
      "milestones": [
        {
          "title": "Базовая сертификация",
          "description": "Прохождение внутренних курсов по основам разработки",
          "monthsFromStart": 6
        },
        {
          "title": "Проектная практика",
          "description": "Успешное выполнение 2 проектов среднего уровня",
          "monthsFromStart": 18
        }
      ],
      "createdAt": "2025-02-10T12:00:00Z",
      "updatedAt": "2025-02-10T12:30:00Z"
    }
  ]
}
```

## Error Responses

### 404 Not Found
```json
{
  "status": "error",
  "message": "Position not found"
}
```

### 400 Bad Request (Validation Error)
```json
{
  "status": "error",
  "message": "Validation failed",
  "errors": {
    "code": "Invalid code format. Expected: 2-5 uppercase letters, hyphen, 3-5 digits",
    "level": "Level must be between 1 and 6"
  }
}
```

### 500 Internal Server Error
```json
{
  "status": "error",
  "message": "Internal server error occurred"
}
``` 