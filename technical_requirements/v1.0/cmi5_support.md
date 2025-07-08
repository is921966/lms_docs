# Техническое задание: Поддержка стандарта Cmi5

**Версия:** 1.0.0  
**Дата:** 2025-01-08  
**Статус:** Новое требование  
**Приоритет:** Высокий

## Обзор

Cmi5 (Computer Managed Instruction 5) - современный стандарт электронного обучения, объединяющий лучшие практики SCORM и xAPI. Этот документ описывает техническую реализацию поддержки Cmi5 в LMS "ЦУМ: Корпоративный университет".

## Цели интеграции

1. **Расширенное отслеживание обучения** - сбор данных о всех учебных активностях
2. **Офлайн обучение** - возможность работы без постоянного подключения
3. **Мобильное обучение** - полноценная поддержка мобильных устройств
4. **Внешние активности** - отслеживание обучения вне LMS
5. **Детальная аналитика** - расширенные отчеты о прогрессе обучения

## Архитектура решения

### 1. Новый микросервис: xAPI Service

```yaml
xAPI Service:
  Bounded Context: Experience Tracking
  Core Responsibility: Обработка и хранение xAPI statements
  Data Ownership: statements, actors, activities, state_data
  Dependencies: Learning Service, Analytics Service
  Technology: PHP 8.1, MongoDB/PostgreSQL для LRS
```

### 2. Расширение Learning Service

Добавление новых компонентов в существующий Learning Service:

```
Learning/
├── Domain/
│   ├── Cmi5/
│   │   ├── Cmi5Package.php         # Aggregate для Cmi5 пакета
│   │   ├── Cmi5Activity.php        # Активность в пакете
│   │   ├── Cmi5Registration.php    # Регистрация пользователя
│   │   └── Cmi5Session.php         # Сессия обучения
│   └── ValueObjects/
│       ├── Cmi5PackageId.php
│       ├── ActivityId.php
│       └── RegistrationId.php
├── Application/
│   ├── Services/
│   │   ├── Cmi5ImportService.php   # Импорт пакетов
│   │   ├── Cmi5LaunchService.php   # Запуск активностей
│   │   └── Cmi5ProgressService.php # Отслеживание прогресса
│   └── Commands/
│       ├── ImportCmi5PackageCommand.php
│       └── LaunchCmi5ActivityCommand.php
└── Infrastructure/
    ├── Cmi5/
    │   ├── PackageParser.php        # Парсер cmi5.xml
    │   ├── ManifestValidator.php    # Валидация манифеста
    │   └── ContentExtractor.php     # Извлечение контента
    └── xAPI/
        ├── StatementBuilder.php     # Создание xAPI statements
        └── LRSClient.php            # Клиент для LRS
```

## Модель данных

### Новые таблицы

#### cmi5_packages
```sql
CREATE TABLE cmi5_packages (
    id UUID PRIMARY KEY,
    course_id UUID REFERENCES courses(id),
    package_name VARCHAR(255) NOT NULL,
    package_version VARCHAR(50),
    publisher VARCHAR(255),
    manifest_data JSONB NOT NULL,
    entry_point VARCHAR(500),
    move_on VARCHAR(50), -- Passed, Completed, CompletedAndPassed, CompletedOrPassed, NotApplicable
    mastery_score DECIMAL(5,2),
    launch_method VARCHAR(20), -- OwnWindow, AnyWindow
    launch_parameters TEXT,
    status VARCHAR(50) DEFAULT 'active',
    imported_at TIMESTAMP NOT NULL,
    imported_by UUID REFERENCES users(id),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### cmi5_activities
```sql
CREATE TABLE cmi5_activities (
    id UUID PRIMARY KEY,
    package_id UUID REFERENCES cmi5_packages(id),
    activity_id VARCHAR(500) NOT NULL, -- IRI format
    activity_type VARCHAR(100),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    launch_url VARCHAR(500),
    move_on VARCHAR(50),
    mastery_score DECIMAL(5,2),
    launch_parameters TEXT,
    order_index INTEGER,
    parent_activity_id UUID REFERENCES cmi5_activities(id),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### cmi5_registrations
```sql
CREATE TABLE cmi5_registrations (
    id UUID PRIMARY KEY,
    registration_id VARCHAR(255) UNIQUE NOT NULL,
    user_id UUID REFERENCES users(id),
    package_id UUID REFERENCES cmi5_packages(id),
    actor_account JSONB NOT NULL, -- xAPI Actor format
    launch_mode VARCHAR(50), -- Normal, Browse, Review
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, package_id)
);
```

#### cmi5_sessions
```sql
CREATE TABLE cmi5_sessions (
    id UUID PRIMARY KEY,
    session_id VARCHAR(255) UNIQUE NOT NULL,
    registration_id UUID REFERENCES cmi5_registrations(id),
    activity_id UUID REFERENCES cmi5_activities(id),
    launch_token VARCHAR(500) UNIQUE,
    launch_url TEXT,
    return_url TEXT,
    status VARCHAR(50), -- launched, initialized, terminated, abandoned
    started_at TIMESTAMP,
    ended_at TIMESTAMP,
    duration_seconds INTEGER,
    score DECIMAL(5,2),
    success BOOLEAN,
    completion BOOLEAN,
    progress_measure DECIMAL(5,2),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### xapi_statements (в xAPI Service)
```sql
CREATE TABLE xapi_statements (
    id UUID PRIMARY KEY,
    statement_id UUID UNIQUE NOT NULL,
    actor JSONB NOT NULL,
    verb JSONB NOT NULL,
    object JSONB NOT NULL,
    result JSONB,
    context JSONB,
    timestamp TIMESTAMP NOT NULL,
    stored TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    authority JSONB,
    version VARCHAR(10) DEFAULT '1.0.3',
    attachments JSONB[],
    registration_id VARCHAR(255),
    session_id VARCHAR(255),
    metadata JSONB
);
```

## API Endpoints

### Cmi5 Management API

#### POST /v1/courses/{courseId}/cmi5/import
Импорт Cmi5 пакета
```json
// Request (multipart/form-data)
{
  "package": "<zip file>",
  "course_id": "uuid",
  "replace_existing": false
}

// Response 201
{
  "package_id": "uuid",
  "activities_count": 5,
  "entry_point": "index.html",
  "manifest": {
    "course": {
      "id": "https://example.com/course/123",
      "title": "Курс по безопасности",
      "description": "..."
    },
    "activities": [...]
  }
}
```

#### GET /v1/cmi5/packages/{packageId}
Получение информации о пакете
```json
// Response 200
{
  "id": "uuid",
  "course_id": "uuid",
  "package_name": "Safety Course",
  "version": "1.0",
  "activities": [
    {
      "id": "uuid",
      "activity_id": "https://example.com/activity/1",
      "title": "Module 1: Introduction",
      "type": "lesson",
      "launch_url": "content/module1/index.html"
    }
  ],
  "launch_settings": {
    "move_on": "CompletedAndPassed",
    "mastery_score": 80,
    "launch_method": "OwnWindow"
  }
}
```

#### POST /v1/cmi5/launch
Запуск Cmi5 активности
```json
// Request
{
  "user_id": "uuid",
  "activity_id": "uuid",
  "launch_mode": "Normal", // Normal, Browse, Review
  "return_url": "https://lms.example.com/courses/123"
}

// Response 200
{
  "launch_url": "https://content.example.com/course/index.html?endpoint=...",
  "session_id": "uuid",
  "launch_token": "jwt_token",
  "parameters": {
    "endpoint": "https://lrs.example.com/xapi/",
    "fetch": "https://lms.example.com/api/v1/cmi5/fetch/token123",
    "registration": "uuid",
    "activityId": "https://example.com/activity/1",
    "actor": {
      "account": {
        "homePage": "https://lms.example.com",
        "name": "user123"
      }
    }
  }
}
```

### xAPI Endpoints (LRS)

#### PUT /xapi/statements
Сохранение xAPI statement
```json
// Request
{
  "id": "uuid",
  "actor": {
    "account": {
      "homePage": "https://lms.example.com",
      "name": "user123"
    }
  },
  "verb": {
    "id": "http://adlnet.gov/expapi/verbs/completed",
    "display": {"en-US": "completed"}
  },
  "object": {
    "id": "https://example.com/activity/1",
    "objectType": "Activity"
  },
  "result": {
    "score": {
      "scaled": 0.85,
      "raw": 85,
      "min": 0,
      "max": 100
    },
    "success": true,
    "completion": true,
    "duration": "PT30M"
  },
  "context": {
    "registration": "uuid",
    "contextActivities": {
      "parent": [{
        "id": "https://example.com/course/123"
      }]
    },
    "extensions": {
      "https://w3id.org/xapi/cmi5/context/extensions/sessionid": "session_uuid"
    }
  }
}

// Response 204 No Content
```

#### GET /xapi/statements
Получение statements
```json
// Query params: ?agent=...&verb=...&activity=...&registration=...

// Response 200
{
  "statements": [...],
  "more": "/xapi/statements?since=..."
}
```

## Процесс работы с Cmi5

### 1. Импорт пакета
1. Администратор загружает .zip файл с Cmi5 пакетом
2. Система валидирует cmi5.xml манифест
3. Извлекает и сохраняет контент в хранилище
4. Создает записи в БД для пакета и активностей
5. Связывает пакет с курсом в LMS

### 2. Запуск обучения
1. Пользователь открывает курс с Cmi5 контентом
2. Система создает registration для пользователя
3. При клике "Начать" создается session
4. Генерируется launch URL с параметрами
5. Контент открывается в новом окне/iframe

### 3. Отслеживание прогресса
1. Cmi5 контент отправляет xAPI statements
2. LRS сохраняет statements
3. Система обрабатывает ключевые глаголы:
   - initialized - начало сессии
   - progressed - обновление прогресса
   - completed - завершение активности
   - passed/failed - результат оценки
   - terminated - конец сессии
4. Обновляется прогресс в основной системе

### 4. Синхронизация с LMS
- xAPI statements транслируются в события LMS
- Обновляется прогресс курса
- Генерируются сертификаты при успешном завершении
- Данные доступны в общей аналитике

## Требования к реализации

### Безопасность
1. **Аутентификация LRS** - OAuth 2.0 для API
2. **Launch tokens** - одноразовые JWT токены
3. **CORS политики** - для кросс-доменных запросов
4. **Валидация statements** - проверка подписей

### Производительность
1. **Асинхронная обработка** - statements через очередь
2. **Кеширование** - метаданные пакетов
3. **Batch операции** - групповая отправка statements
4. **Оптимизация запросов** - индексы для registration, session

### Совместимость
1. **xAPI версии** - поддержка 1.0.3
2. **Cmi5 спецификация** - версия 1.0
3. **Браузеры** - Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
4. **Мобильные** - iOS 14+, Android 10+

## Интеграция с существующими модулями

### Learning Service
- Cmi5 пакеты как альтернативный тип контента
- Единый интерфейс для всех типов курсов
- Общая система прогресса и сертификации

### Analytics Service
- xAPI statements как источник данных
- Расширенные отчеты по Cmi5 активностям
- Визуализация learning paths

### Notification Service
- Уведомления о завершении Cmi5 модулей
- Напоминания о незавершенных сессиях

## План миграции

### Фаза 1: Базовая поддержка (Sprint 40-41)
- [ ] Создание xAPI Service
- [ ] Реализация LRS endpoints
- [ ] Импорт Cmi5 пакетов
- [ ] Базовый launch механизм

### Фаза 2: Полная интеграция (Sprint 42-43)
- [ ] Отслеживание прогресса
- [ ] Синхронизация с LMS
- [ ] Офлайн поддержка
- [ ] Мобильная оптимизация

### Фаза 3: Расширенные функции (Sprint 44-45)
- [ ] Продвинутая аналитика
- [ ] Внешние активности
- [ ] Социальное обучение
- [ ] AI-рекомендации на основе xAPI

## Метрики успеха

1. **Технические метрики**
   - Время импорта пакета < 30 секунд
   - Latency LRS API < 100ms (p95)
   - Statement processing < 50ms
   - Доступность LRS > 99.9%

2. **Бизнес метрики**
   - Увеличение вовлеченности на 25%
   - Детализация отчетов +300%
   - Поддержка офлайн обучения
   - Расширение на мобильные платформы

## Риски и митигация

1. **Сложность стандарта**
   - Риск: Неполная реализация спецификации
   - Митигация: Использование готовых библиотек, тестирование с эталонными пакетами

2. **Производительность LRS**
   - Риск: Большой объем statements
   - Митигация: Масштабируемая архитектура, очереди, партиционирование

3. **Совместимость контента**
   - Риск: Проблемы с существующим контентом
   - Митигация: Тестирование популярных авторских инструментов

## Заключение

Интеграция Cmi5 позволит LMS "ЦУМ" выйти на новый уровень отслеживания и аналитики обучения, обеспечив поддержку современных форматов контента и расширенных сценариев обучения. Это критически важно для конкурентоспособности системы на рынке корпоративного обучения. 