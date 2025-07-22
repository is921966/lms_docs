# Competency Service

Микросервис для управления компетенциями, оценками и матрицами компетенций в LMS.

## 🚀 Возможности

- **Управление компетенциями**: создание, редактирование, активация/деактивация
- **Уровни компетенций**: поддержка до 10 уровней с критериями
- **Оценка компетенций**: создание и завершение оценок сотрудников
- **Матрицы компетенций**: расчет прогресса и анализ пробелов
- **Сравнение кандидатов**: ранжирование по соответствию позиции

## 🏗️ Архитектура

Domain-Driven Design с тремя слоями:
- **Domain**: сущности, value objects, события, интерфейсы репозиториев
- **Application**: сервисы, DTOs, бизнес-логика
- **Infrastructure**: репозитории, контроллеры, внешние сервисы

## 📦 Установка

### Docker (рекомендуется)

```bash
# Клонировать репозиторий
git clone <repository>
cd microservices/competency-service

# Запустить сервисы
docker-compose up -d

# Применить миграции
docker-compose exec competency-service php bin/console doctrine:migrations:migrate
```

### Локальная установка

```bash
# Установить зависимости
composer install

# Настроить БД
cp .env.example .env
# Отредактировать .env с вашими настройками БД

# Применить миграции
php bin/console doctrine:migrations:migrate
```

## 🧪 Тестирование

```bash
# Запустить все тесты
composer test

# Только unit тесты
composer test-unit

# Только integration тесты
composer test-integration

# С покрытием кода
composer test-coverage
```

## 📚 API Документация

OpenAPI документация доступна по адресу: http://localhost:8003/api/doc

### Основные endpoints:

#### Компетенции
- `GET /api/v1/competencies` - список компетенций
- `POST /api/v1/competencies` - создать компетенцию
- `GET /api/v1/competencies/{id}` - получить компетенцию
- `PUT /api/v1/competencies/{id}` - обновить компетенцию
- `POST /api/v1/competencies/{id}/activate` - активировать
- `POST /api/v1/competencies/{id}/deactivate` - деактивировать

#### Оценки
- `POST /api/v1/assessments` - создать оценку
- `GET /api/v1/assessments/{id}` - получить оценку
- `POST /api/v1/assessments/{id}/complete` - завершить оценку
- `POST /api/v1/assessments/{id}/cancel` - отменить оценку
- `GET /api/v1/assessments/user/{userId}` - оценки пользователя
- `GET /api/v1/assessments/user/{userId}/progress` - прогресс пользователя

#### Матрицы
- `GET /api/v1/matrix/user/{userId}/matrix/{matrixId}/progress` - прогресс по матрице
- `GET /api/v1/matrix/user/{userId}/matrix/{matrixId}/gaps` - анализ пробелов
- `POST /api/v1/matrix/position/{positionId}/compare` - сравнение кандидатов

## 🔧 Конфигурация

### Переменные окружения

- `DB_HOST` - хост PostgreSQL (default: postgres)
- `DB_PORT` - порт PostgreSQL (default: 5432)
- `DB_NAME` - имя базы данных
- `DB_USER` - пользователь БД
- `DB_PASSWORD` - пароль БД
- `REDIS_HOST` - хост Redis
- `RABBITMQ_HOST` - хост RabbitMQ

## 🏃 Производительность

- Кэширование компетенций в Redis
- Асинхронная обработка событий через RabbitMQ
- Оптимизированные запросы с индексами
- Connection pooling для БД

## 🔐 Безопасность

- Валидация всех входных данных
- UUID для всех идентификаторов
- Prepared statements для защиты от SQL injection
- Rate limiting на API endpoints

## 📈 Мониторинг

- Health check endpoint: `/health`
- Prometheus метрики: `/metrics`
- Structured logging в JSON формате
- Трейсинг через OpenTelemetry

## 🤝 Интеграция

Сервис интегрируется с:
- **User Service** - для получения информации о пользователях
- **Position Service** - для матриц компетенций по позициям
- **Notification Service** - для уведомлений об оценках

## 📝 Примеры использования

### Создание компетенции

```bash
curl -X POST http://localhost:8003/api/v1/competencies \
  -H "Content-Type: application/json" \
  -d '{
    "code": "TECH-001",
    "name": "Software Development",
    "description": "Ability to develop software applications",
    "category": "Technical",
    "levels": [
      {
        "level": 1,
        "name": "Beginner",
        "description": "Basic understanding",
        "criteria": ["Can write simple code", "Understands basic concepts"]
      }
    ]
  }'
```

### Создание оценки

```bash
curl -X POST http://localhost:8003/api/v1/assessments \
  -H "Content-Type: application/json" \
  -d '{
    "competency_id": "123e4567-e89b-12d3-a456-426614174000",
    "user_id": "user-123",
    "assessor_id": "assessor-456"
  }'
```

## 📄 Лицензия

Proprietary - LMS Team 