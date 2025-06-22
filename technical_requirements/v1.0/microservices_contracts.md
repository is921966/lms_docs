# Детальные контракты микросервисов

## Принципы проектирования для LLM

1. **Маленькие endpoint'ы** - один endpoint = одна операция
2. **Явные контракты** - все параметры типизированы
3. **Версионирование** - /v1/ в URL для будущих изменений
4. **Единообразие** - одинаковая структура ответов

## User Management Service

### Endpoints

#### POST /v1/auth/login
```json
// Request
{
  "username": "string",  // AD username
  "password": "string"
}

// Response 200
{
  "token": {
    "access_token": "string",
    "refresh_token": "string",
    "expires_in": 3600
  },
  "user": {
    "id": 1,
    "username": "string",
    "email": "string",
    "first_name": "string",
    "last_name": "string",
    "roles": ["student", "manager"]
  }
}

// Response 401
{
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Неверный логин или пароль"
  }
}
```

#### POST /v1/auth/refresh
```json
// Request
{
  "refresh_token": "string"
}

// Response 200
{
  "access_token": "string",
  "expires_in": 3600
}
```

#### GET /v1/users/me
```json
// Headers: Authorization: Bearer {token}

// Response 200
{
  "id": 1,
  "username": "string",
  "email": "string",
  "first_name": "string",
  "last_name": "string",
  "department": "string",
  "position": {
    "id": 1,
    "name": "string"
  },
  "manager": {
    "id": 2,
    "name": "string",
    "email": "string"
  },
  "created_at": "2025-01-01T10:00:00Z",
  "last_login": "2025-01-20T15:30:00Z"
}
```

#### GET /v1/users
```json
// Query params: ?page=1&per_page=20&search=john&department=IT

// Response 200
{
  "data": [
    {
      "id": 1,
      "username": "string",
      "email": "string",
      "first_name": "string",
      "last_name": "string",
      "department": "string",
      "is_active": true
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total": 150,
    "last_page": 8
  }
}
```

## Competency Service

### Endpoints

#### GET /v1/competencies
```json
// Query params: ?category=technical&page=1

// Response 200
{
  "data": [
    {
      "id": 1,
      "name": "Управление проектами",
      "description": "string",
      "color": "blue",
      "category": {
        "id": 1,
        "name": "Управленческие"
      },
      "levels": [
        {
          "level": 1,
          "name": "Начальный",
          "description": "Базовые знания"
        },
        {
          "level": 2,
          "name": "Базовый",
          "description": "Может выполнять под руководством"
        }
      ]
    }
  ],
  "meta": {
    "current_page": 1,
    "total": 45
  }
}
```

#### POST /v1/competencies
```json
// Request
{
  "name": "string",
  "description": "string",
  "color": "blue", // blue, green, red, yellow, purple
  "category_id": 1,
  "levels": [
    {
      "level": 1,
      "description": "string"
    }
  ]
}

// Response 201
{
  "id": 10,
  "name": "string",
  "created_at": "2025-01-20T10:00:00Z"
}
```

#### GET /v1/positions/{id}/competencies
```json
// Response 200
{
  "position": {
    "id": 1,
    "name": "Разработчик Middle"
  },
  "competencies": [
    {
      "id": 1,
      "name": "PHP",
      "required_level": 3,
      "color": "blue"
    },
    {
      "id": 2,
      "name": "SQL",
      "required_level": 2,
      "color": "blue"
    }
  ]
}
```

#### POST /v1/positions/{id}/competencies
```json
// Request
{
  "competencies": [
    {
      "competency_id": 1,
      "required_level": 3
    },
    {
      "competency_id": 2,
      "required_level": 2
    }
  ]
}

// Response 200
{
  "message": "Компетенции успешно привязаны",
  "count": 2
}
```

## Learning Service

### Endpoints

#### GET /v1/courses
```json
// Query params: ?category=1&status=published&page=1

// Response 200
{
  "data": [
    {
      "id": 1,
      "title": "Основы проектного управления",
      "description": "string",
      "duration_hours": 8,
      "modules_count": 5,
      "category": {
        "id": 1,
        "name": "Менеджмент"
      },
      "status": "published",
      "passing_score": 80,
      "thumbnail_url": "string"
    }
  ],
  "meta": {
    "current_page": 1,
    "total": 25
  }
}
```

#### GET /v1/courses/{id}
```json
// Response 200
{
  "id": 1,
  "title": "string",
  "description": "string",
  "duration_hours": 8,
  "passing_score": 80,
  "modules": [
    {
      "id": 1,
      "title": "Введение",
      "order": 1,
      "duration_minutes": 30,
      "type": "video",
      "is_completed": false
    },
    {
      "id": 2,
      "title": "Основные принципы",
      "order": 2,
      "duration_minutes": 45,
      "type": "presentation",
      "is_completed": false
    }
  ],
  "competencies": [
    {
      "id": 1,
      "name": "Управление проектами"
    }
  ],
  "progress": {
    "completed_modules": 0,
    "total_modules": 5,
    "percentage": 0,
    "status": "not_started"
  }
}
```

#### POST /v1/courses/{id}/enroll
```json
// Request (пустой body или с параметрами)
{}

// Response 200
{
  "message": "Вы записаны на курс",
  "course_id": 1,
  "start_date": "2025-01-20T00:00:00Z"
}
```

#### POST /v1/courses/{courseId}/modules/{moduleId}/complete
```json
// Request
{
  "time_spent": 1800, // секунды
  "completion_rate": 100 // процент просмотра
}

// Response 200
{
  "module_id": 1,
  "completed": true,
  "course_progress": {
    "completed_modules": 1,
    "total_modules": 5,
    "percentage": 20
  }
}
```

#### GET /v1/tests/{id}
```json
// Response 200
{
  "id": 1,
  "title": "Тест по управлению проектами",
  "description": "string",
  "time_limit": 1800, // секунды
  "passing_score": 80,
  "attempts_allowed": 2,
  "questions_count": 20,
  "user_attempts": [
    {
      "attempt": 1,
      "score": 75,
      "completed_at": "2025-01-15T10:00:00Z"
    }
  ]
}
```

#### POST /v1/tests/{id}/start
```json
// Response 200
{
  "session_id": "uuid",
  "questions": [
    {
      "id": 1,
      "question": "Что такое критический путь проекта?",
      "type": "single_choice",
      "options": [
        {
          "id": 1,
          "text": "Самая длинная последовательность задач"
        },
        {
          "id": 2,
          "text": "Самая короткая последовательность задач"
        }
      ]
    },
    {
      "id": 2,
      "question": "Выберите инструменты управления проектами",
      "type": "multiple_choice",
      "options": [
        {
          "id": 3,
          "text": "Jira"
        },
        {
          "id": 4,
          "text": "Photoshop"
        },
        {
          "id": 5,
          "text": "Trello"
        }
      ]
    }
  ],
  "started_at": "2025-01-20T10:00:00Z",
  "expires_at": "2025-01-20T10:30:00Z"
}
```

#### POST /v1/tests/{id}/submit
```json
// Request
{
  "session_id": "uuid",
  "answers": [
    {
      "question_id": 1,
      "answer_ids": [1]
    },
    {
      "question_id": 2,
      "answer_ids": [3, 5]
    }
  ]
}

// Response 200
{
  "score": 85,
  "passed": true,
  "correct_answers": 17,
  "total_questions": 20,
  "certificate_url": "https://...",
  "detailed_results": [
    {
      "question_id": 1,
      "correct": true
    },
    {
      "question_id": 2,
      "correct": false,
      "correct_answer_ids": [3]
    }
  ]
}
```

## Program Service

### Endpoints

#### GET /v1/programs/templates
```json
// Query params: ?type=onboarding

// Response 200
{
  "data": [
    {
      "id": 1,
      "name": "Онбординг разработчика",
      "type": "onboarding",
      "duration_days": 30,
      "stages_count": 3,
      "description": "string"
    }
  ]
}
```

#### POST /v1/programs/assign
```json
// Request
{
  "template_id": 1,
  "user_id": 123,
  "start_date": "2025-02-01",
  "mentor_id": 456, // optional
  "custom_settings": {
    "skip_technical": false
  }
}

// Response 201
{
  "program_id": 789,
  "user_id": 123,
  "template_name": "Онбординг разработчика",
  "start_date": "2025-02-01",
  "end_date": "2025-03-03",
  "status": "scheduled"
}
```

#### GET /v1/programs/{id}/progress
```json
// Response 200
{
  "program": {
    "id": 789,
    "name": "Онбординг разработчика",
    "user": {
      "id": 123,
      "name": "Иван Петров"
    },
    "status": "in_progress",
    "start_date": "2025-02-01",
    "end_date": "2025-03-03"
  },
  "progress": {
    "overall_percentage": 35,
    "stages": [
      {
        "id": 1,
        "name": "Знакомство с компанией",
        "status": "completed",
        "completed_tasks": 5,
        "total_tasks": 5
      },
      {
        "id": 2,
        "name": "Техническое погружение",
        "status": "in_progress",
        "completed_tasks": 2,
        "total_tasks": 8,
        "current_task": {
          "name": "Изучить архитектуру проекта",
          "type": "course",
          "course_id": 15
        }
      },
      {
        "id": 3,
        "name": "Первые задачи",
        "status": "locked",
        "completed_tasks": 0,
        "total_tasks": 3
      }
    ]
  }
}
```

## Notification Service

### Events (через RabbitMQ)

#### user.created
```json
{
  "event_type": "user.created",
  "timestamp": "2025-01-20T10:00:00Z",
  "data": {
    "user_id": 123,
    "email": "user@company.com",
    "first_name": "Иван",
    "last_name": "Петров"
  }
}
```

#### course.completed
```json
{
  "event_type": "course.completed",
  "timestamp": "2025-01-20T15:00:00Z",
  "data": {
    "user_id": 123,
    "course_id": 456,
    "course_title": "Основы проектного управления",
    "score": 85,
    "certificate_id": "uuid"
  }
}
```

#### program.deadline_approaching
```json
{
  "event_type": "program.deadline_approaching",
  "timestamp": "2025-01-20T08:00:00Z",
  "data": {
    "program_id": 789,
    "user_id": 123,
    "days_left": 3,
    "incomplete_tasks": 5
  }
}
```

### API для отправки уведомлений

#### POST /v1/notifications/send
```json
// Request
{
  "recipients": [123, 456], // user IDs
  "template": "course_assigned",
  "channels": ["email", "in_app"],
  "data": {
    "course_name": "Основы проектного управления",
    "deadline": "2025-02-01"
  }
}

// Response 202
{
  "message": "Уведомления поставлены в очередь",
  "notification_ids": ["uuid1", "uuid2"]
}
```

## Общие принципы

### Структура ошибок
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Ошибка валидации данных",
    "details": {
      "field": "email",
      "reason": "Неверный формат email"
    }
  }
}
```

### Пагинация
```json
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total": 100,
    "last_page": 5
  },
  "links": {
    "first": "https://api.lms.com/v1/resource?page=1",
    "last": "https://api.lms.com/v1/resource?page=5",
    "prev": null,
    "next": "https://api.lms.com/v1/resource?page=2"
  }
}
```

### HTTP статусы
- 200 - OK
- 201 - Created
- 202 - Accepted (для асинхронных операций)
- 204 - No Content (для DELETE)
- 400 - Bad Request
- 401 - Unauthorized
- 403 - Forbidden
- 404 - Not Found
- 409 - Conflict
- 422 - Unprocessable Entity
- 500 - Internal Server Error

Эта структура позволяет LLM понимать точные контракты и генерировать корректный код для каждого сервиса. 