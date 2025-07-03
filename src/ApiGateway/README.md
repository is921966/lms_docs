# API Gateway Module

## Описание

API Gateway служит единой точкой входа для всех микросервисов LMS системы. Обеспечивает:
- Аутентификацию и авторизацию через JWT
- Маршрутизацию запросов к соответствующим сервисам
- Rate limiting и защиту от DDoS
- Агрегацию ответов от нескольких сервисов
- Кеширование и оптимизацию производительности

## Архитектура

```
Client Request
     ↓
API Gateway
     ├── Authentication (JWT)
     ├── Authorization (Roles/Permissions)
     ├── Rate Limiting
     ├── Request Routing
     └── Response Aggregation
            ↓
     Microservices
     ├── User Service
     ├── Learning Service
     ├── Program Service
     ├── Competency Service
     └── Notification Service
```

## Основные компоненты

### 1. Authentication Middleware
- Проверка JWT токенов
- Refresh token механизм
- Blacklist для отозванных токенов

### 2. Authorization Middleware
- Role-based access control (RBAC)
- Permission checking
- Resource-level authorization

### 3. Rate Limiter
- Per-user rate limiting
- IP-based rate limiting
- Configurable limits per endpoint

### 4. Request Router
- Dynamic routing based on service registry
- Load balancing
- Circuit breaker pattern

### 5. Response Aggregator
- Parallel service calls
- Response merging
- Error handling and fallbacks

## Конфигурация

```yaml
# config/api_gateway.yaml
api_gateway:
    jwt:
        secret_key: '%env(JWT_SECRET_KEY)%'
        ttl: 3600 # 1 hour
        refresh_ttl: 604800 # 1 week
    
    rate_limiting:
        default_limit: 100
        window: 60 # seconds
        
    services:
        user:
            base_url: '%env(USER_SERVICE_URL)%'
            timeout: 5
        learning:
            base_url: '%env(LEARNING_SERVICE_URL)%'
            timeout: 10
        # ... other services
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Refresh JWT token
- `POST /api/auth/logout` - Logout and invalidate token

### Service Proxies
- `/api/users/*` → User Service
- `/api/learning/*` → Learning Service
- `/api/programs/*` → Program Service
- `/api/competencies/*` → Competency Service
- `/api/notifications/*` → Notification Service

## Использование

### Пример запроса
```bash
# Login
curl -X POST http://api.lms.local/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password"}'

# Use JWT token for authenticated requests
curl -X GET http://api.lms.local/api/users/profile \
  -H "Authorization: Bearer <jwt_token>"
```

### Пример агрегированного запроса
```bash
# Get user dashboard (aggregates data from multiple services)
curl -X GET http://api.lms.local/api/dashboard \
  -H "Authorization: Bearer <jwt_token>"

# Response includes:
# - User profile (User Service)
# - Enrolled courses (Learning Service)
# - Active programs (Program Service)
# - Recent notifications (Notification Service)
```

## Тестирование

```bash
# Unit tests
./test-quick.sh tests/Unit/ApiGateway/

# Integration tests
./test-quick.sh tests/Integration/ApiGateway/

# Load tests
./scripts/load-test-api-gateway.sh
```

## Мониторинг

- Prometheus metrics на `/metrics`
- Health check на `/health`
- Readiness check на `/ready`

## Security

- JWT токены подписываются с использованием RS256
- Все внешние запросы проходят через HTTPS
- Rate limiting предотвращает brute force атаки
- CORS настроен для разрешенных доменов
- SQL injection защита через параметризованные запросы 