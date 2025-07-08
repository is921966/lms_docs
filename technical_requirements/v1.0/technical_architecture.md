# Technical Architecture - v1.0

## Микросервисная декомпозиция

### User Management Service
- **Bounded Context:** Identity & Access
- **Core Responsibility:** Аутентификация через Microsoft AD, авторизация, управление сессиями
- **Data Ownership:** users, roles, permissions, sessions, tokens
- **Dependencies:** Microsoft AD (LDAP/SAML), внутренняя БД для ролей
- **Technology:** PHP 8.1, JWT tokens, Redis для сессий, php-ldap/SimpleSAMLphp

### Competency Service  
- **Bounded Context:** Skills & Competencies
- **Core Responsibility:** Управление компетенциями, уровнями, связями с должностями
- **Data Ownership:** competencies, levels, position_competencies, competency_categories
- **Dependencies:** User Management Service
- **Technology:** PHP 8.1, PostgreSQL, Elasticsearch для поиска

### Learning Service
- **Bounded Context:** Educational Content
- **Core Responsibility:** Курсы, материалы, тесты, прогресс обучения
- **Data Ownership:** courses, modules, materials, tests, user_progress, certificates
- **Dependencies:** User Management Service, File Storage Service
- **Technology:** PHP 8.1, PostgreSQL, S3 для файлов

### Program Service
- **Bounded Context:** Development Programs  
- **Core Responsibility:** Программы развития, онбординг, карьерные треки
- **Data Ownership:** programs, templates, assignments, milestones, schedules
- **Dependencies:** User Management Service, Learning Service, Competency Service
- **Technology:** PHP 8.1, PostgreSQL, RabbitMQ для событий

### Notification Service
- **Bounded Context:** Communications
- **Core Responsibility:** Отправка уведомлений через email и in-app каналы
- **Data Ownership:** notification_templates, notification_queue, delivery_status
- **Dependencies:** Все сервисы (consumer), SMTP сервер
- **Technology:** PHP 8.1, RabbitMQ, Redis для очередей, SwiftMailer/Symfony Mailer

### Analytics Service
- **Bounded Context:** Reporting & Analytics
- **Core Responsibility:** Сбор метрик, генерация отчетов, дашборды
- **Data Ownership:** metrics, reports, aggregated_data
- **Dependencies:** Все сервисы (read-only)
- **Technology:** PHP 8.1, ClickHouse, Redis для кеширования

### xAPI Service (расширение v1.2.0)
- **Bounded Context:** Experience Tracking
- **Core Responsibility:** Learning Record Store (LRS) для хранения xAPI statements, поддержка Cmi5
- **Data Ownership:** xapi_statements, actors, activities, state_data, cmi5_packages
- **Dependencies:** Learning Service, Analytics Service
- **Technology:** PHP 8.1, MongoDB/PostgreSQL для LRS, JWT для auth
- **Note:** Добавляется для поддержки стандарта Cmi5 и расширенной аналитики обучения

## API Contracts (OpenAPI)

### Competency Service API
```yaml
openapi: 3.0.0
info:
  title: Competency Service API
  version: 1.0.0
servers:
  - url: https://api.lms.company.ru/v1
paths:
  /competencies:
    get:
      summary: Получить список компетенций
      parameters:
        - name: category
          in: query
          schema:
            type: string
        - name: page
          in: query
          schema:
            type: integer
            default: 1
      responses:
        '200':
          description: Список компетенций
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/Competency'
                  meta:
                    $ref: '#/components/schemas/Pagination'
    
    post:
      summary: Создать новую компетенцию
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CompetencyRequest'
      responses:
        '201':
          description: Компетенция создана
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Competency'
        '400':
          $ref: '#/components/responses/BadRequest'
        '409':
          $ref: '#/components/responses/Conflict'

  /competencies/{id}:
    put:
      summary: Обновить компетенцию
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CompetencyRequest'
      responses:
        '200':
          description: Компетенция обновлена
        '404':
          $ref: '#/components/responses/NotFound'

components:
  schemas:
    Competency:
      type: object
      properties:
        id:
          type: integer
        name:
          type: string
        description:
          type: string
        color:
          type: string
          enum: [blue, green, red, yellow, purple]
        levels:
          type: array
          items:
            $ref: '#/components/schemas/CompetencyLevel'
        created_at:
          type: string
          format: date-time
    
    CompetencyLevel:
      type: object
      properties:
        level:
          type: integer
          minimum: 1
          maximum: 5
        description:
          type: string
        requirements:
          type: array
          items:
            type: string
```

### Learning Service API
```yaml
paths:
  /courses:
    post:
      summary: Создать новый курс
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [title, category_id, description]
              properties:
                title:
                  type: string
                  maxLength: 255
                category_id:
                  type: integer
                description:
                  type: string
                duration_hours:
                  type: integer
                competencies:
                  type: array
                  items:
                    type: integer
      responses:
        '201':
          description: Курс создан
          headers:
            Location:
              description: URL созданного курса
              schema:
                type: string

  /courses/{id}/modules:
    post:
      summary: Добавить модуль к курсу
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
      requestBody:
        required: true
        content:
          multipart/form-data:
            schema:
              type: object
              properties:
                title:
                  type: string
                order:
                  type: integer
                video:
                  type: string
                  format: binary
                presentation:
                  type: string
                  format: binary
                materials:
                  type: array
                  items:
                    type: string
                    format: binary

  /courses/{id}/progress:
    get:
      summary: Получить прогресс пользователя по курсу
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Прогресс по курсу
          content:
            application/json:
              schema:
                type: object
                properties:
                  course_id:
                    type: integer
                  user_id:
                    type: integer
                  completed_modules:
                    type: array
                    items:
                      type: integer
                  total_modules:
                    type: integer
                  percentage:
                    type: number
                  status:
                    type: string
                    enum: [not_started, in_progress, completed]
                  test_score:
                    type: number
                    nullable: true
```

### Program Service API
```yaml
paths:
  /programs/onboarding:
    post:
      summary: Создать программу онбординга
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [employee_id, template_id, start_date]
              properties:
                employee_id:
                  type: integer
                template_id:
                  type: integer
                start_date:
                  type: string
                  format: date
                custom_courses:
                  type: array
                  items:
                    type: integer
                mentor_id:
                  type: integer
                  nullable: true
      responses:
        '201':
          description: Программа создана и запущена
        '404':
          description: Шаблон или сотрудник не найден

  /programs/onboarding/{id}/progress:
    get:
      summary: Получить прогресс онбординга
      responses:
        '200':
          description: Детальный прогресс
          content:
            application/json:
              schema:
                type: object
                properties:
                  stages:
                    type: array
                    items:
                      type: object
                      properties:
                        name:
                          type: string
                        status:
                          type: string
                        completed_tasks:
                          type: integer
                        total_tasks:
                          type: integer
                        deadline:
                          type: string
                          format: date
```

## Database Schema

### Core Tables Structure

```sql
-- User Management Service
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    ad_username VARCHAR(255) UNIQUE NOT NULL, -- Active Directory username
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    position_id INTEGER,
    department_id INTEGER,
    department VARCHAR(255), -- Синхронизируется из AD
    manager_id INTEGER REFERENCES users(id),
    manager_email VARCHAR(255), -- Для синхронизации manager из AD
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    permissions JSONB NOT NULL
);

-- Competency Service
CREATE TABLE competencies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    color VARCHAR(20),
    category_id INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE competency_levels (
    id SERIAL PRIMARY KEY,
    competency_id INTEGER REFERENCES competencies(id),
    level INTEGER NOT NULL CHECK (level BETWEEN 1 AND 5),
    description TEXT,
    requirements JSONB
);

CREATE TABLE position_competencies (
    position_id INTEGER,
    competency_id INTEGER REFERENCES competencies(id),
    required_level INTEGER,
    PRIMARY KEY (position_id, competency_id)
);

-- Learning Service
CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category_id INTEGER,
    duration_hours INTEGER,
    passing_score INTEGER DEFAULT 80,
    is_published BOOLEAN DEFAULT false,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE course_modules (
    id SERIAL PRIMARY KEY,
    course_id INTEGER REFERENCES courses(id),
    title VARCHAR(255),
    order_index INTEGER,
    content JSONB,
    duration_minutes INTEGER
);

CREATE TABLE user_progress (
    user_id INTEGER REFERENCES users(id),
    course_id INTEGER REFERENCES courses(id),
    module_id INTEGER REFERENCES course_modules(id),
    completed_at TIMESTAMP,
    PRIMARY KEY (user_id, course_id, module_id)
);

-- Program Service
CREATE TABLE program_templates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    type VARCHAR(50), -- onboarding, development, career
    duration_days INTEGER,
    stages JSONB,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE program_assignments (
    id SERIAL PRIMARY KEY,
    template_id INTEGER REFERENCES program_templates(id),
    user_id INTEGER REFERENCES users(id),
    mentor_id INTEGER REFERENCES users(id),
    start_date DATE,
    end_date DATE,
    status VARCHAR(50),
    progress JSONB
);
```

### Migration Strategy
1. **Version Control:** Все миграции версионируются (001_initial_schema.sql)
2. **Rollback Scripts:** Каждая миграция имеет соответствующий rollback
3. **Data Migration:** Первичный импорт пользователей из Active Directory
4. **Zero Downtime:** Blue-green deployment для критических изменений

## Integration Points

### Synchronous Integrations
1. **Microsoft Active Directory**
   - LDAP для аутентификации и получения данных пользователей
   - SAML 2.0 для Single Sign-On
   - Периодическая синхронизация организационной структуры
   - Кеширование данных пользователей на 24 часа

2. **File Storage (Local/S3-compatible)**
   - Локальное хранилище или S3-compatible storage
   - Прямые ссылки для авторизованных пользователей
   - Automatic backup каждые 6 часов
   - Антивирусная проверка загружаемых файлов

### Asynchronous Communications
1. **RabbitMQ Events**
   - user.created
   - course.completed
   - program.started
   - notification.send

2. **Event Schema Example:**
```json
{
  "event_type": "course.completed",
  "timestamp": "2025-03-15T10:30:00Z",
  "data": {
    "user_id": 123,
    "course_id": 456,
    "score": 85,
    "duration_minutes": 120
  },
  "metadata": {
    "source": "learning-service",
    "version": "1.0"
  }
}
```

## Non-Functional Requirements

### Performance
- API Response Time: p95 < 200ms, p99 < 500ms
- Concurrent Users: 500 активных пользователей
- Database Queries: < 50ms для 95% запросов
- File Upload: до 100MB, streaming для больших файлов

### Scalability
- Horizontal scaling для всех сервисов
- Database read replicas для аналитики
- Caching strategy: Redis с TTL 5 минут
- CDN для статического контента

### Security
- JWT tokens с refresh mechanism
- API rate limiting per user
- SQL injection prevention через prepared statements
- XSS protection через Content Security Policy
- Шифрование sensitive данных в БД

### Monitoring & Observability
- Prometheus metrics для всех сервисов
- Grafana dashboards для визуализации
- ELK stack для централизованного логирования
- Distributed tracing через Jaeger
- Health checks для каждого сервиса

### Disaster Recovery
- RTO: 4 часа
- RPO: 1 час
- Automated backups каждые 6 часов
- Cross-region replication для критических данных
- Runbook для восстановления 