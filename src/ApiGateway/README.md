# API Gateway Module

## Описание

API Gateway - единая точка входа для всех запросов к микросервисам LMS. Обеспечивает централизованную аутентификацию, авторизацию, rate limiting и маршрутизацию запросов.

## Архитектура

### Domain Layer

#### Value Objects
- `JwtToken` - JWT токены (access и refresh)
- `RateLimitKey` - ключи для rate limiting
- `RateLimitResult` - результат проверки rate limit
- `HttpMethod` - HTTP методы (GET, POST, PUT, DELETE и т.д.)
- `ServiceEndpoint` - конечная точка микросервиса

#### Exceptions
- `InvalidTokenException` - ошибки валидации токенов
- `RateLimitExceededException` - превышен лимит запросов
- `RouteNotFoundException` - маршрут не найден
- `ServiceNotFoundException` - сервис не найден

#### Services (Interfaces)
- `JwtServiceInterface` - работа с JWT токенами
- `RateLimiterInterface` - rate limiting
- `ServiceRouterInterface` - маршрутизация к сервисам

### Application Layer

#### Middleware
- `AuthenticationMiddleware` - проверка JWT токенов
- `RateLimitMiddleware` - ограничение количества запросов

### Infrastructure Layer

#### JWT Implementation
- `FirebaseJwtService` - реализация JWT через Firebase JWT library
  - Генерация access и refresh токенов
  - Валидация токенов
  - Обновление токенов
  - Blacklist механизм

#### Rate Limiter
- `InMemoryRateLimiter` - in-memory реализация rate limiting
  - Token bucket алгоритм
  - Настраиваемые лимиты и окна
  - Поддержка разных типов ключей

#### Router
- `ServiceRouter` - маршрутизация запросов к микросервисам
  - Паттерн-матчинг для URL
  - Поддержка параметров в путях
  - Динамическая регистрация сервисов

### HTTP Layer

#### Controllers
- `GatewayController` - основной прокси-контроллер
  - Маршрутизация всех запросов
  - Обработка ошибок
  - Форвардинг заголовков
  
- `AuthController` - аутентификация
  - `/login` - вход в систему
  - `/logout` - выход из системы
  - `/refresh` - обновление токена
  - `/me` - информация о текущем пользователе

## Использование

### Конфигурация

```php
// config/api-gateway.php
return [
    'jwt' => [
        'secret' => env('JWT_SECRET'),
        'algorithm' => 'HS256',
        'access_ttl' => 3600, // 1 hour
        'refresh_ttl' => 604800 // 1 week
    ],
    
    'rate_limit' => [
        'default_limit' => 60,
        'window_seconds' => 60
    ],
    
    'services' => [
        'user' => env('USER_SERVICE_URL', 'http://user-service:8080'),
        'auth' => env('AUTH_SERVICE_URL', 'http://auth-service:8081'),
        'competency' => env('COMPETENCY_SERVICE_URL', 'http://competency-service:8082'),
        'learning' => env('LEARNING_SERVICE_URL', 'http://learning-service:8083'),
        'program' => env('PROGRAM_SERVICE_URL', 'http://program-service:8084'),
        'notification' => env('NOTIFICATION_SERVICE_URL', 'http://notification-service:8085')
    ]
];
```

### Маршруты

```php
// routes/api-gateway.php

// Public routes
Route::post('/api/v1/auth/login', [AuthController::class, 'login']);
Route::post('/api/v1/auth/refresh', [AuthController::class, 'refresh']);

// Protected routes
Route::middleware(['auth.jwt', 'rate.limit'])->group(function () {
    Route::post('/api/v1/auth/logout', [AuthController::class, 'logout']);
    Route::get('/api/v1/auth/me', [AuthController::class, 'me']);
    
    // All other requests proxied through gateway
    Route::any('{any}', [GatewayController::class, 'proxy'])->where('any', '.*');
});
```

### Примеры запросов

#### Аутентификация
```bash
# Login
curl -X POST http://api.example.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password"}'

# Response
{
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "role": "user"
    },
    "token": {
      "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
      "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
      "token_type": "Bearer",
      "expires_in": 3600
    }
  }
}
```

#### Использование токена
```bash
# Get users
curl -X GET http://api.example.com/api/v1/users \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..."

# Create course
curl -X POST http://api.example.com/api/v1/courses \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -H "Content-Type: application/json" \
  -d '{"title": "New Course", "description": "Course description"}'
```

## Тестирование

### Unit тесты
```bash
# Domain layer
./test-quick.sh tests/Unit/ApiGateway/Domain/

# Application layer
./test-quick.sh tests/Unit/ApiGateway/Application/

# Infrastructure layer
./test-quick.sh tests/Unit/ApiGateway/Infrastructure/
```

### Integration тесты
```bash
./test-quick.sh tests/Integration/ApiGateway/
```

## Безопасность

1. **JWT токены**
   - Используйте сильный секретный ключ
   - Храните refresh токены безопасно
   - Реализуйте blacklist для отозванных токенов

2. **Rate Limiting**
   - Настройте лимиты в соответствии с нагрузкой
   - Используйте разные лимиты для разных endpoints
   - Мониторьте превышения лимитов

3. **HTTPS**
   - Всегда используйте HTTPS в production
   - Проверяйте SSL сертификаты микросервисов

## Production рекомендации

1. **JWT Service**
   - Используйте Redis для blacklist токенов
   - Реализуйте ротацию ключей
   - Логируйте подозрительную активность

2. **Rate Limiter**
   - Используйте Redis вместо in-memory
   - Настройте алерты для аномальной активности
   - Реализуйте whitelist для доверенных IP

3. **Service Router**
   - Используйте service discovery (Consul, etcd)
   - Реализуйте health checks
   - Настройте circuit breakers

4. **Мониторинг**
   - Отслеживайте latency всех сервисов
   - Мониторьте rate limit violations
   - Настройте алерты для 5xx ошибок 