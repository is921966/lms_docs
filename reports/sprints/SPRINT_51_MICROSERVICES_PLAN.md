# Microservices Migration Plan - Sprint 51

**Sprint**: 51  
**День**: 166 (День 3/5)  
**Дата**: 18 июля 2025

## 📐 Архитектура микросервисов

### Текущая структура (монолит)
```
lms_backend/
├── src/
│   ├── Auth/
│   ├── User/
│   ├── Learning/
│   ├── Competency/
│   └── Notification/
└── database/
```

### Целевая структура (микросервисы)
```
lms_microservices/
├── services/
│   ├── auth-service/
│   ├── user-service/
│   ├── learning-service/
│   ├── competency-service/
│   └── notification-service/
├── api-gateway/
├── shared/
│   ├── contracts/
│   └── libraries/
└── infrastructure/
    ├── docker-compose.yml
    └── kubernetes/
```

## 🔄 План миграции по сервисам

### 1. Auth Service (День 3, утро)

#### Текущий функционал
- Аутентификация пользователей
- JWT токены
- Управление сессиями
- Интеграция с Microsoft AD

#### Миграция
```php
// Новая структура auth-service
auth-service/
├── src/
│   ├── Application/
│   │   ├── Commands/
│   │   │   ├── LoginCommand.php
│   │   │   └── RefreshTokenCommand.php
│   │   └── Queries/
│   │       └── ValidateTokenQuery.php
│   ├── Domain/
│   │   ├── Entities/
│   │   │   ├── User.php
│   │   │   └── Token.php
│   │   └── Services/
│   │       └── TokenService.php
│   └── Infrastructure/
│       ├── Controllers/
│       ├── Repositories/
│       └── ExternalServices/
├── tests/
└── Dockerfile
```

#### API контракты
```yaml
# auth-service-api.yaml
openapi: 3.0.0
info:
  title: Auth Service API
  version: 1.0.0

paths:
  /auth/login:
    post:
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                email:
                  type: string
                password:
                  type: string
      responses:
        200:
          content:
            application/json:
              schema:
                type: object
                properties:
                  access_token:
                    type: string
                  refresh_token:
                    type: string
                  expires_in:
                    type: integer
```

### 2. User Service (День 3, день)

#### Функционал
- Управление профилями
- Роли и права доступа
- Персональные данные

#### База данных
```sql
-- user-service database
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE user_roles (
    user_id UUID REFERENCES users(id),
    role_id UUID,
    assigned_at TIMESTAMP
);
```

### 3. Learning Service (День 3, вечер)

#### Функционал
- Управление курсами
- Прогресс обучения
- Тестирование
- Сертификаты

#### Event-driven архитектура
```php
// События для RabbitMQ
class CourseEnrolledEvent {
    public string $userId;
    public string $courseId;
    public DateTime $enrolledAt;
}

class CourseCompletedEvent {
    public string $userId;
    public string $courseId;
    public float $score;
    public DateTime $completedAt;
}
```

## 🔌 API Gateway Configuration

### Kong Gateway setup
```yaml
# kong.yml
services:
  - name: auth-service
    url: http://auth-service:3000
    routes:
      - name: auth-routes
        paths:
          - /api/auth
    plugins:
      - name: rate-limiting
        config:
          minute: 100
          
  - name: user-service
    url: http://user-service:3001
    routes:
      - name: user-routes
        paths:
          - /api/users
    plugins:
      - name: jwt
        config:
          key_claim_name: iss
```

## 🗄️ Распределенное кэширование

### Redis Configuration
```yaml
# redis-cluster.yml
redis:
  cluster:
    nodes:
      - redis-node1:6379
      - redis-node2:6379
      - redis-node3:6379
  cache_strategies:
    users:
      ttl: 3600
      pattern: "user:{id}"
    courses:
      ttl: 7200
      pattern: "course:{id}"
    sessions:
      ttl: 86400
      pattern: "session:{token}"
```

## 🔄 Message Queue Setup

### RabbitMQ Configuration
```yaml
# rabbitmq-config.yml
exchanges:
  - name: user-events
    type: topic
    durable: true
    
  - name: learning-events
    type: topic
    durable: true

queues:
  - name: notification-user-events
    exchange: user-events
    routing_key: user.*
    
  - name: analytics-learning-events
    exchange: learning-events
    routing_key: learning.*
```

## 📊 Мониторинг и логирование

### ELK Stack Configuration
```yaml
# docker-compose.monitoring.yml
services:
  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
      
  logstash:
    image: logstash:8.8.0
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
      
  kibana:
    image: kibana:8.8.0
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
```

### Prometheus Metrics
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'auth-service'
    static_configs:
      - targets: ['auth-service:9090']
      
  - job_name: 'user-service'
    static_configs:
      - targets: ['user-service:9091']
```

## 🐳 Docker Configuration

### Base Dockerfile для PHP сервисов
```dockerfile
# Dockerfile.base
FROM php:8.2-fpm-alpine

RUN apk add --no-cache \
    postgresql-dev \
    rabbitmq-c-dev \
    && docker-php-ext-install pdo pdo_pgsql

RUN pecl install redis amqp \
    && docker-php-ext-enable redis amqp

WORKDIR /app
```

### Service-specific Dockerfile
```dockerfile
# auth-service/Dockerfile
FROM lms/php-base:latest

COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

COPY . .

CMD ["php-fpm"]
``` 