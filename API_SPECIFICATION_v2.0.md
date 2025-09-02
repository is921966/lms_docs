# API спецификация LMS "ЦУМ: Корпоративный университет"

**Версия**: 2.0  
**Дата**: 22 июля 2025  
**Формат**: OpenAPI 3.0  
**Базовый URL**: `https://api.lms.tsum.ru/v1`

## Содержание

1. [Общая информация](#1-общая-информация)
2. [Аутентификация](#2-аутентификация)
3. [API Endpoints](#3-api-endpoints)
4. [Модели данных](#4-модели-данных)
5. [Коды ошибок](#5-коды-ошибок)
6. [Примеры запросов](#6-примеры-запросов)

## 1. Общая информация

### 1.1. Базовые принципы

- **Протокол**: HTTPS only
- **Формат**: JSON
- **Кодировка**: UTF-8
- **Версионирование**: URL path (v1, v2)
- **Аутентификация**: Bearer JWT
- **Rate Limiting**: 1000 req/hour per user
- **Pagination**: Offset/Limit based
- **Timestamp**: ISO 8601

### 1.2. Общие headers

```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer <jwt_token>
X-Request-ID: <uuid>
Accept-Language: ru-RU,ru;q=0.9,en;q=0.8
```

### 1.3. Стандартный ответ

```json
{
  "success": true,
  "data": {},
  "meta": {
    "timestamp": "2025-07-22T10:00:00Z",
    "version": "1.0",
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

### 1.4. Ответ с ошибкой

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Неверный формат email",
    "details": {
      "field": "email",
      "value": "invalid-email"
    }
  },
  "meta": {
    "timestamp": "2025-07-22T10:00:00Z",
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

## 2. Аутентификация

### 2.1. POST /auth/login
Аутентификация пользователя

**Request:**
```json
{
  "email": "user@tsum.ru",
  "password": "SecurePassword123",
  "device_id": "iPhone-UUID",
  "remember_me": true
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@tsum.ru",
      "first_name": "Иван",
      "last_name": "Иванов",
      "role": "employee",
      "department": "Продажи"
    }
  }
}
```

### 2.2. POST /auth/refresh
Обновление токена

**Request:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600
  }
}
```

### 2.3. POST /auth/logout
Выход из системы

**Request:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "everywhere": false
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "message": "Вы успешно вышли из системы"
  }
}
```

## 3. API Endpoints

### 3.1. Users (Пользователи)

#### GET /users/me
Получить профиль текущего пользователя

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@tsum.ru",
    "first_name": "Иван",
    "last_name": "Иванов",
    "middle_name": "Петрович",
    "position": "Менеджер по продажам",
    "department": {
      "id": "dept-123",
      "name": "Отдел продаж"
    },
    "manager": {
      "id": "mgr-456",
      "name": "Петров П.П."
    },
    "avatar_url": "https://cdn.lms.tsum.ru/avatars/user-123.jpg",
    "hire_date": "2023-01-15",
    "created_at": "2023-01-15T09:00:00Z",
    "last_login": "2025-07-22T10:00:00Z"
  }
}
```

#### PUT /users/me
Обновить профиль

**Request:**
```json
{
  "first_name": "Иван",
  "last_name": "Иванов",
  "phone": "+7 (999) 123-45-67",
  "notification_settings": {
    "email": true,
    "push": true,
    "sms": false
  }
}
```

#### GET /users/{userId}
Получить профиль пользователя (требует права)

#### GET /users
Список пользователей (для админов)

**Query parameters:**
- `search` - поиск по имени/email
- `department_id` - фильтр по подразделению
- `role` - фильтр по роли
- `offset` - смещение (default: 0)
- `limit` - количество (default: 20, max: 100)

### 3.2. Courses (Курсы)

#### GET /courses
Список доступных курсов

**Query parameters:**
- `category` - категория курса
- `level` - уровень сложности (beginner, intermediate, advanced)
- `duration_min` - минимальная длительность (минуты)
- `duration_max` - максимальная длительность (минуты)
- `status` - статус (published, draft, archived)
- `competency_id` - связанная компетенция
- `search` - текстовый поиск
- `sort` - сортировка (popularity, date, rating)
- `offset` - смещение
- `limit` - количество

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "course-123",
        "title": "Excel для начинающих",
        "description": "Базовый курс по работе с электронными таблицами",
        "category": {
          "id": "cat-1",
          "name": "Офисные программы"
        },
        "level": "beginner",
        "duration_minutes": 180,
        "modules_count": 5,
        "lessons_count": 15,
        "cover_url": "https://cdn.lms.tsum.ru/courses/excel-basic.jpg",
        "rating": 4.5,
        "reviews_count": 234,
        "enrolled_count": 567,
        "is_mandatory": false,
        "competencies": ["comp-123", "comp-456"],
        "tags": ["excel", "таблицы", "формулы"],
        "created_at": "2025-01-15T10:00:00Z",
        "updated_at": "2025-07-01T10:00:00Z"
      }
    ],
    "total": 150,
    "offset": 0,
    "limit": 20
  }
}
```

#### GET /courses/{courseId}
Детальная информация о курсе

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "course-123",
    "title": "Excel для начинающих",
    "description": "Базовый курс по работе с электронными таблицами",
    "full_description": "Подробное описание...",
    "objectives": [
      "Научиться создавать таблицы",
      "Освоить базовые формулы",
      "Уметь строить графики"
    ],
    "requirements": [
      "Базовые навыки работы с компьютером"
    ],
    "target_audience": "Новые сотрудники без опыта работы с Excel",
    "modules": [
      {
        "id": "mod-1",
        "title": "Введение в Excel",
        "description": "Знакомство с интерфейсом",
        "duration_minutes": 30,
        "lessons_count": 3,
        "order": 1
      }
    ],
    "instructor": {
      "id": "inst-789",
      "name": "Сидоров С.С.",
      "title": "Эксперт по Excel",
      "avatar_url": "https://cdn.lms.tsum.ru/instructors/sidorov.jpg"
    },
    "enrollment": {
      "is_enrolled": true,
      "enrolled_at": "2025-07-01T10:00:00Z",
      "progress": 45,
      "completed_modules": 2,
      "current_module_id": "mod-3",
      "estimated_completion": "2025-07-25T10:00:00Z"
    }
  }
}
```

#### POST /courses/{courseId}/enroll
Записаться на курс

**Request:**
```json
{
  "reason": "Необходимо для работы",
  "manager_approved": true
}
```

#### GET /courses/{courseId}/modules/{moduleId}
Получить модуль курса

#### POST /courses/{courseId}/progress
Обновить прогресс

**Request:**
```json
{
  "module_id": "mod-123",
  "lesson_id": "lesson-456",
  "status": "completed",
  "duration_seconds": 1250,
  "score": 85,
  "answers": {
    "q1": "a",
    "q2": ["b", "c"],
    "q3": "Текстовый ответ"
  }
}
```

### 3.3. Competencies (Компетенции)

#### GET /competencies
Дерево компетенций

**Response 200:**
```json
{
  "success": true,
  "data": {
    "tree": [
      {
        "id": "comp-1",
        "name": "Корпоративные компетенции",
        "type": "category",
        "children": [
          {
            "id": "comp-11",
            "name": "Клиентоориентированность",
            "type": "competency",
            "description": "Способность понимать потребности клиента",
            "levels": [
              {
                "level": 1,
                "name": "Начальный",
                "description": "Понимает важность клиента"
              },
              {
                "level": 2,
                "name": "Базовый",
                "description": "Активно слушает клиента"
              }
            ]
          }
        ]
      }
    ]
  }
}
```

#### GET /competencies/my
Мои компетенции

**Response 200:**
```json
{
  "success": true,
  "data": {
    "competencies": [
      {
        "id": "comp-11",
        "name": "Клиентоориентированность",
        "current_level": 3,
        "target_level": 4,
        "self_assessment": 3,
        "manager_assessment": 3,
        "last_assessment_date": "2025-06-01T10:00:00Z",
        "development_courses": ["course-123", "course-456"],
        "progress_percentage": 75
      }
    ],
    "overall_score": 3.2,
    "next_assessment_date": "2025-09-01T10:00:00Z"
  }
}
```

#### POST /competencies/assess
Оценить компетенции

**Request:**
```json
{
  "assessments": [
    {
      "competency_id": "comp-11",
      "level": 3,
      "examples": "Пример ситуации, демонстрирующей компетенцию",
      "development_plan": "План развития"
    }
  ],
  "type": "self",
  "period": "2025-Q2"
}
```

### 3.4. Learning Paths (Траектории обучения)

#### GET /learning-paths/my
Моя траектория обучения

**Response 200:**
```json
{
  "success": true,
  "data": {
    "paths": [
      {
        "id": "path-123",
        "name": "Развитие менеджера по продажам",
        "description": "Программа развития для вашей должности",
        "type": "position_based",
        "status": "in_progress",
        "progress": 60,
        "stages": [
          {
            "id": "stage-1",
            "name": "Базовые навыки",
            "courses": ["course-1", "course-2"],
            "status": "completed",
            "completed_at": "2025-06-15T10:00:00Z"
          },
          {
            "id": "stage-2",
            "name": "Продвинутые техники",
            "courses": ["course-3", "course-4"],
            "status": "in_progress",
            "deadline": "2025-08-01T10:00:00Z"
          }
        ],
        "estimated_completion": "2025-10-01T10:00:00Z",
        "certificate_available": false
      }
    ]
  }
}
```

### 3.5. Assignments (Назначения)

#### GET /assignments
Мои назначения

**Query parameters:**
- `status` - фильтр по статусу (pending, in_progress, completed, overdue)
- `type` - тип (mandatory, optional, development)
- `from_date` - начальная дата
- `to_date` - конечная дата

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "assign-123",
        "course": {
          "id": "course-456",
          "title": "Тайм-менеджмент"
        },
        "assigned_by": {
          "id": "user-789",
          "name": "Петров П.П.",
          "role": "manager"
        },
        "assigned_at": "2025-07-01T10:00:00Z",
        "deadline": "2025-07-31T23:59:59Z",
        "status": "in_progress",
        "progress": 30,
        "is_mandatory": true,
        "comment": "Необходимо пройти до конца месяца",
        "reminder_sent": true
      }
    ],
    "summary": {
      "total": 5,
      "pending": 1,
      "in_progress": 2,
      "completed": 1,
      "overdue": 1
    }
  }
}
```

### 3.6. Certificates (Сертификаты)

#### GET /certificates
Мои сертификаты

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "cert-123",
        "number": "LMS-2025-0001234",
        "course": {
          "id": "course-123",
          "title": "Excel для начинающих"
        },
        "issued_at": "2025-06-15T10:00:00Z",
        "valid_until": "2027-06-15T10:00:00Z",
        "score": 92,
        "grade": "Отлично",
        "download_url": "https://api.lms.tsum.ru/v1/certificates/cert-123/download",
        "verification_url": "https://lms.tsum.ru/verify/LMS-2025-0001234",
        "competencies": ["comp-123", "comp-456"]
      }
    ]
  }
}
```

#### GET /certificates/{certificateId}/download
Скачать сертификат (PDF)

### 3.7. Reports (Отчеты)

#### GET /reports/my/summary
Сводка по моему обучению

**Query parameters:**
- `period` - период (month, quarter, year, custom)
- `from_date` - начальная дата (для custom)
- `to_date` - конечная дата (для custom)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "period": {
      "type": "quarter",
      "name": "Q2 2025",
      "from": "2025-04-01",
      "to": "2025-06-30"
    },
    "summary": {
      "courses_completed": 5,
      "courses_in_progress": 2,
      "total_hours": 24.5,
      "average_score": 87,
      "certificates_earned": 3,
      "competencies_improved": 4
    },
    "courses": [
      {
        "id": "course-123",
        "title": "Excel для начинающих",
        "completed_at": "2025-05-15T10:00:00Z",
        "duration_hours": 3,
        "score": 92
      }
    ],
    "competency_growth": [
      {
        "id": "comp-11",
        "name": "Клиентоориентированность",
        "level_before": 2,
        "level_after": 3,
        "growth": 1
      }
    ]
  }
}
```

#### GET /reports/team
Отчет по команде (для руководителей)

**Query parameters:**
- `team_id` - ID команды/подразделения
- `period` - период
- `metrics` - выбор метрик (completion_rate, average_score, time_spent)

### 3.8. Notifications (Уведомления)

#### GET /notifications
Список уведомлений

**Query parameters:**
- `status` - фильтр (unread, read, all)
- `type` - тип (assignment, reminder, achievement, news)
- `from_date` - начальная дата
- `limit` - количество

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "notif-123",
        "type": "assignment",
        "title": "Новое назначение",
        "message": "Вам назначен курс 'Тайм-менеджмент'",
        "data": {
          "course_id": "course-456",
          "deadline": "2025-07-31T23:59:59Z"
        },
        "is_read": false,
        "created_at": "2025-07-22T10:00:00Z",
        "action_url": "/courses/course-456"
      }
    ],
    "unread_count": 3
  }
}
```

#### PUT /notifications/{notificationId}/read
Отметить как прочитанное

#### POST /notifications/mark-all-read
Отметить все как прочитанные

### 3.9. Feed (Лента новостей)

#### GET /feed/posts
Получить посты ленты

**Query parameters:**
- `channel` - канал (all, hr, learning, releases, methodology)
- `search` - поиск по тексту
- `from_date` - начальная дата
- `to_date` - конечная дата
- `offset` - смещение
- `limit` - количество

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "post-123",
        "channel": {
          "id": "hr",
          "name": "HR новости",
          "icon": "megaphone.fill"
        },
        "title": "Новые правила обучения",
        "content": "С 1 августа вводятся новые правила...",
        "content_format": "markdown",
        "author": {
          "id": "user-456",
          "name": "HR департамент"
        },
        "attachments": [
          {
            "type": "document",
            "name": "Правила.pdf",
            "url": "https://cdn.lms.tsum.ru/attachments/rules.pdf",
            "size_bytes": 1048576
          }
        ],
        "is_pinned": true,
        "is_read": false,
        "created_at": "2025-07-22T10:00:00Z",
        "updated_at": "2025-07-22T10:00:00Z"
      }
    ],
    "total": 150,
    "unread_count": 12
  }
}
```

#### PUT /feed/posts/{postId}/read
Отметить пост как прочитанный

### 3.10. Search (Поиск)

#### GET /search
Глобальный поиск

**Query parameters:**
- `q` - поисковый запрос (минимум 3 символа)
- `type` - тип (all, courses, users, competencies, posts)
- `filters` - дополнительные фильтры (JSON)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "results": [
      {
        "type": "course",
        "id": "course-123",
        "title": "Excel для начинающих",
        "description": "Базовый курс...",
        "url": "/courses/course-123",
        "relevance_score": 0.95
      },
      {
        "type": "user",
        "id": "user-456",
        "name": "Иванов Иван",
        "position": "Менеджер",
        "url": "/users/user-456",
        "relevance_score": 0.85
      }
    ],
    "facets": {
      "type": {
        "course": 15,
        "user": 8,
        "competency": 3
      }
    },
    "total": 26,
    "query_time_ms": 125
  }
}
```

## 4. Модели данных

### 4.1. User
```typescript
interface User {
  id: string;
  email: string;
  first_name: string;
  last_name: string;
  middle_name?: string;
  position: string;
  department: Department;
  manager?: User;
  avatar_url?: string;
  hire_date: string;
  created_at: string;
  last_login: string;
  is_active: boolean;
  roles: Role[];
}
```

### 4.2. Course
```typescript
interface Course {
  id: string;
  title: string;
  description: string;
  category: Category;
  level: 'beginner' | 'intermediate' | 'advanced';
  duration_minutes: number;
  modules: Module[];
  instructor?: Instructor;
  competencies: string[];
  tags: string[];
  rating: number;
  status: 'draft' | 'published' | 'archived';
  created_at: string;
  updated_at: string;
}
```

### 4.3. Competency
```typescript
interface Competency {
  id: string;
  name: string;
  description: string;
  type: 'corporate' | 'professional' | 'managerial';
  levels: CompetencyLevel[];
  parent_id?: string;
  required_for_positions: string[];
}
```

### 4.4. Assignment
```typescript
interface Assignment {
  id: string;
  course: Course;
  user: User;
  assigned_by: User;
  assigned_at: string;
  deadline?: string;
  status: 'pending' | 'in_progress' | 'completed' | 'overdue';
  progress: number;
  is_mandatory: boolean;
  comment?: string;
  completed_at?: string;
}
```

## 5. Коды ошибок

### 5.1. HTTP Status Codes

| Код | Описание | Когда используется |
|-----|----------|-------------------|
| 200 | OK | Успешный GET, PUT |
| 201 | Created | Успешный POST |
| 204 | No Content | Успешный DELETE |
| 400 | Bad Request | Неверные параметры |
| 401 | Unauthorized | Требуется аутентификация |
| 403 | Forbidden | Нет прав доступа |
| 404 | Not Found | Ресурс не найден |
| 409 | Conflict | Конфликт данных |
| 422 | Unprocessable Entity | Валидация не пройдена |
| 429 | Too Many Requests | Превышен rate limit |
| 500 | Internal Server Error | Ошибка сервера |
| 503 | Service Unavailable | Сервис недоступен |

### 5.2. Коды ошибок приложения

| Код | Описание |
|-----|----------|
| AUTH_INVALID_CREDENTIALS | Неверный логин или пароль |
| AUTH_TOKEN_EXPIRED | Токен истек |
| AUTH_TOKEN_INVALID | Невалидный токен |
| AUTH_ACCOUNT_LOCKED | Аккаунт заблокирован |
| VALIDATION_ERROR | Ошибка валидации |
| RESOURCE_NOT_FOUND | Ресурс не найден |
| PERMISSION_DENIED | Недостаточно прав |
| COURSE_ALREADY_ENROLLED | Уже записан на курс |
| COURSE_PREREQUISITES_NOT_MET | Не выполнены предусловия |
| ASSIGNMENT_OVERDUE | Назначение просрочено |
| CERTIFICATE_NOT_AVAILABLE | Сертификат недоступен |
| RATE_LIMIT_EXCEEDED | Превышен лимит запросов |

## 6. Примеры запросов

### 6.1. Полный flow аутентификации

```bash
# 1. Логин
curl -X POST https://api.lms.tsum.ru/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@tsum.ru",
    "password": "SecurePassword123"
  }'

# 2. Использование токена
curl -X GET https://api.lms.tsum.ru/v1/users/me \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# 3. Обновление токена
curl -X POST https://api.lms.tsum.ru/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }'
```

### 6.2. Работа с курсами

```bash
# Поиск курсов
curl -X GET "https://api.lms.tsum.ru/v1/courses?search=Excel&level=beginner" \
  -H "Authorization: Bearer TOKEN"

# Запись на курс
curl -X POST https://api.lms.tsum.ru/v1/courses/course-123/enroll \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Необходимо для работы"
  }'

# Обновление прогресса
curl -X POST https://api.lms.tsum.ru/v1/courses/course-123/progress \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "module_id": "mod-123",
    "lesson_id": "lesson-456",
    "status": "completed",
    "score": 85
  }'
```

### 6.3. WebSocket подключение

```javascript
// Подключение к WebSocket для real-time обновлений
const ws = new WebSocket('wss://api.lms.tsum.ru/v1/ws');

ws.onopen = () => {
  // Аутентификация через WebSocket
  ws.send(JSON.stringify({
    type: 'auth',
    token: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  }));
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  
  switch(data.type) {
    case 'notification':
      console.log('New notification:', data.payload);
      break;
    case 'progress_update':
      console.log('Progress updated:', data.payload);
      break;
  }
};
```

---

## Приложения

### Приложение A: Changelog

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0 | 01.07.2025 | Первая версия API |
| 1.1 | 15.07.2025 | Добавлен Feed API |
| 2.0 | 22.07.2025 | Добавлены Assignments, Search, WebSocket |

### Приложение B: SDK

Официальные SDK доступны для:
- iOS (Swift) - [GitHub](https://github.com/tsum/lms-ios-sdk)
- JavaScript - [NPM](https://www.npmjs.com/package/@tsum/lms-sdk)
- PHP - [Packagist](https://packagist.org/packages/tsum/lms-sdk)

---

**Конец документа** 