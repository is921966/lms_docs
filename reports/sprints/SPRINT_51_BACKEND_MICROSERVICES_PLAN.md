# Sprint 51: План миграции Backend на микросервисы

## Дата: 17 июля 2025 (День 166)

### 📋 Текущая архитектура (монолит)

```
src/
├── Auth/           # Аутентификация и авторизация
├── User/           # Управление пользователями
├── Competency/     # Компетенции
├── Learning/       # Обучение и курсы
├── Program/        # Учебные программы
├── Notification/   # Уведомления
├── OrgStructure/   # Организационная структура
└── Position/       # Должности
```

### 🎯 Целевая архитектура микросервисов

```yaml
Микросервисы:
  1. AuthService:
     - JWT токены
     - OAuth2/OpenID Connect
     - Управление сессиями
     - Rate limiting
     
  2. UserService:
     - CRUD пользователей
     - Профили
     - Роли и права
     - Интеграция с AD/LDAP
     
  3. CourseService:
     - Управление курсами
     - CMI5 интеграция
     - Прогресс обучения
     - Сертификаты
     
  4. CompetencyService:
     - Управление компетенциями
     - Матрицы компетенций
     - Оценка компетенций
     - Gap-анализ
     
  5. NotificationService:
     - Email уведомления
     - Push уведомления
     - SMS
     - WebSocket real-time
     
  6. OrgStructureService:
     - Департаменты
     - Должности
     - Иерархия
     - Синхронизация с HR
```

### 🔧 Технологический стек

```yaml
Инфраструктура:
  - Контейнеризация: Docker
  - Оркестрация: Kubernetes
  - API Gateway: Kong/Traefik
  - Service Mesh: Istio (опционально)
  - Message Queue: RabbitMQ/Kafka
  - Cache: Redis
  - Monitoring: Prometheus + Grafana
  - Tracing: Jaeger
  - Logs: ELK Stack

Для каждого сервиса:
  - Framework: Symfony 6.x
  - API: RESTful + GraphQL (где нужно)
  - DB: PostgreSQL (основная) + MongoDB (где нужно)
  - ORM: Doctrine
  - Testing: PHPUnit + Behat
  - API Docs: OpenAPI 3.0
```

### 📊 План миграции

#### Фаза 1: Подготовка (День 166)
- [x] Анализ зависимостей между модулями
- [ ] Создание API Gateway
- [ ] Настройка Docker окружения
- [ ] Создание базовой структуры микросервисов

#### Фаза 2: AuthService (День 166-167)
- [ ] Выделение Auth модуля в отдельный сервис
- [ ] Реализация JWT authentication
- [ ] Настройка API Gateway routing
- [ ] Integration tests

#### Фаза 3: UserService (День 167)
- [ ] Выделение User модуля
- [ ] Реализация межсервисного взаимодействия
- [ ] Синхронизация с AuthService
- [ ] Performance tests

#### Фаза 4: CourseService (День 167-168)
- [ ] Выделение Learning модуля
- [ ] Интеграция с UserService
- [ ] CMI5 функциональность
- [ ] Load testing

#### Фаза 5: Остальные сервисы (День 168)
- [ ] CompetencyService
- [ ] NotificationService
- [ ] OrgStructureService
- [ ] End-to-end testing

### 🏗️ Архитектурные решения

#### 1. Inter-Service Communication
```yaml
Синхронное:
  - REST API для CRUD операций
  - GraphQL для сложных запросов
  
Асинхронное:
  - RabbitMQ для событий
  - Паттерн Event Sourcing для аудита
```

#### 2. Data Management
```yaml
Паттерны:
  - Database per Service
  - CQRS для чтения/записи
  - Event Sourcing для истории
  - Saga Pattern для транзакций
```

#### 3. Security
```yaml
Меры безопасности:
  - mTLS между сервисами
  - API Gateway authentication
  - Rate limiting
  - OWASP best practices
```

#### 4. Resilience
```yaml
Паттерны отказоустойчивости:
  - Circuit Breaker
  - Retry with exponential backoff
  - Bulkhead isolation
  - Timeout handling
```

### 📈 Метрики успеха

```yaml
Performance:
  - API response time < 100ms (p95)
  - Service startup < 30s
  - Memory usage < 512MB per service
  
Reliability:
  - Uptime > 99.9%
  - Zero data loss
  - Graceful degradation
  
Scalability:
  - Horizontal scaling
  - Auto-scaling based on load
  - Support 10k concurrent users
```

### 🚀 Приоритеты

1. **КРИТИЧНО**: AuthService - без него ничего не работает
2. **ВАЖНО**: UserService - core функциональность
3. **ВАЖНО**: CourseService - основной бизнес-функционал
4. **СРЕДНЕ**: CompetencyService - может работать в монолите
5. **НИЗКО**: NotificationService - можно мигрировать позже

### ⚠️ Риски и митигация

```yaml
Риски:
  1. Сложность распределенных транзакций
     Митигация: Saga Pattern, eventual consistency
     
  2. Увеличение latency
     Митигация: Кэширование, оптимизация запросов
     
  3. Debugging сложнее
     Митигация: Distributed tracing, centralized logging
     
  4. Дублирование кода
     Митигация: Shared libraries, code generation
```

### 📝 Следующие шаги

1. Создать Docker-compose для локальной разработки
2. Настроить API Gateway (Kong)
3. Начать с AuthService как proof of concept
4. Документировать все API в OpenAPI формате 