# Спринт 1: Базовая инфраструктура

## Обзор спринта
- **Даты:** Недели 1-2 (14 дней)
- **Цель:** Создать фундамент приложения и общие компоненты
- **Результат:** Работающее Docker окружение с базовой структурой

## День 1-2: Интерфейсы и базовые классы

### Задача 1.1: Создание базовых интерфейсов
**Файлы для создания:**
1. `src/Common/Interfaces/RepositoryInterface.php`
2. `src/Common/Interfaces/ServiceInterface.php`
3. `src/Common/Interfaces/ValidatorInterface.php`

**Промпт для LLM:**
```
Контекст: Создаем LMS систему "ЦУМ: Корпоративный университет"
Текущая фаза: Базовая инфраструктура
Задача: Создать интерфейс RepositoryInterface

Требования:
1. Файл: src/Common/Interfaces/RepositoryInterface.php
2. Namespace: App\Common\Interfaces
3. Методы: find, findAll, save, update, delete
4. Использовать PHP 8.1 типизацию
5. Добавить PHPDoc
6. Максимум 30 строк

Дополнительно:
- Методы должны быть generic для любых сущностей
- Учесть пагинацию для findAll
```

### Задача 1.2: Создание базовых классов
**Файлы для создания:**
1. `src/Common/Base/BaseRepository.php`
2. `src/Common/Base/BaseService.php`

**Промпт для LLM:**
```
Контекст: Продолжаем создание базовой инфраструктуры
Предыдущие компоненты: RepositoryInterface, ServiceInterface

Задача: Создать абстрактный класс BaseRepository

Требования:
1. Файл: src/Common/Base/BaseRepository.php
2. Implements: RepositoryInterface
3. Использовать Doctrine ORM
4. Добавить protected свойство entityClass
5. Реализовать базовые методы
6. Максимум 100 строк

Особенности:
- Использовать EntityManagerInterface
- Добавить метод createQueryBuilder
- Обработка исключений
```

## День 3-4: Трейты и утилиты

### Задача 2.1: Создание трейтов
**Файлы для создания:**
1. `src/Common/Traits/HasTimestamps.php`
2. `src/Common/Traits/Cacheable.php`
3. `src/Common/Traits/Loggable.php`

**Промпт для LLM:**
```
Задача: Создать трейт HasTimestamps

Требования:
1. Файл: src/Common/Traits/HasTimestamps.php
2. Свойства: createdAt, updatedAt (DateTime)
3. Методы: updateTimestamps, getCreatedAt, getUpdatedAt
4. Doctrine аннотации для ORM
5. PrePersist и PreUpdate callbacks
6. Максимум 50 строк
```

### Задача 2.2: Создание утилит
**Файлы для создания:**
1. `src/Common/Utils/DateHelper.php`
2. `src/Common/Utils/StringHelper.php`

**Промпт для LLM:**
```
Задача: Создать класс DateHelper с статическими методами

Требования:
1. Файл: src/Common/Utils/DateHelper.php
2. Методы: formatForApi, parseFromApi, diffInDays, isWorkday
3. Поддержка timezone (Moscow)
4. Использовать Carbon/CarbonImmutable
5. Максимум 80 строк
```

## День 5: Исключения и обработка ошибок

### Задача 3.1: Создание исключений
**Файлы для создания:**
1. `src/Common/Exceptions/ValidationException.php`
2. `src/Common/Exceptions/NotFoundException.php`
3. `src/Common/Exceptions/AuthorizationException.php`
4. `src/Common/Exceptions/BusinessLogicException.php`

**Промпт для LLM:**
```
Задача: Создать ValidationException с поддержкой множественных ошибок

Требования:
1. Файл: src/Common/Exceptions/ValidationException.php
2. Extends: \Exception
3. Свойство errors: array
4. Методы: getErrors, addError, hasErrors
5. Поддержка field-specific ошибок
6. JSON serializable
7. Максимум 60 строк
```

### Задача 3.2: Создание обработчика ошибок
**Файлы для создания:**
1. `src/Common/Http/ErrorHandler.php`

**Промпт для LLM:**
```
Задача: Создать ErrorHandler для обработки всех типов исключений

Требования:
1. Файл: src/Common/Http/ErrorHandler.php
2. Метод handle(Throwable $e): JsonResponse
3. Разные форматы для разных исключений
4. Логирование критических ошибок
5. Скрытие деталей в production
6. HTTP status codes mapping
7. Максимум 100 строк
```

## День 6-7: Конфигурация

### Задача 4.1: Создание конфигурационных файлов
**Файлы для создания:**
1. `config/app.php`
2. `config/database.php`
3. `config/auth.php`
4. `config/services.php`
5. `.env.example`

**Промпт для LLM:**
```
Задача: Создать config/database.php для PostgreSQL и Redis

Требования:
1. Поддержка multiple connections
2. Read/write splitting ready
3. Connection pooling параметры
4. Redis для кеша и сессий
5. Миграции настройки
6. Максимум 80 строк

Структура:
return [
    'default' => env('DB_CONNECTION', 'pgsql'),
    'connections' => [...],
    'redis' => [...]
];
```

### Задача 4.2: Environment файл
**Промпт для LLM:**
```
Задача: Создать .env.example с полным набором переменных

Секции:
1. App (name, env, debug, url)
2. Database (PostgreSQL)
3. Redis
4. Auth (JWT settings)
5. LDAP/AD settings
6. Mail (SMTP)
7. Storage (S3/local)
8. Queue (RabbitMQ)

Добавить комментарии для каждой секции
```

## День 8-9: Роутинг и middleware

### Задача 5.1: Настройка роутинга
**Файлы для создания:**
1. `config/routes/api.php`
2. `config/routes/web.php`

**Промпт для LLM:**
```
Задача: Создать config/routes/api.php с версионированием

Требования:
1. Группа /api/v1
2. Заготовки для всех сервисов:
   - /auth/* (login, logout, refresh)
   - /users/*
   - /competencies/*
   - /courses/*
   - /programs/*
3. RESTful соглашения
4. Middleware hints в комментариях
```

### Задача 5.2: Создание middleware
**Файлы для создания:**
1. `src/Common/Middleware/AuthMiddleware.php`
2. `src/Common/Middleware/CorsMiddleware.php`
3. `src/Common/Middleware/LoggingMiddleware.php`

**Промпт для LLM:**
```
Задача: Создать AuthMiddleware для JWT проверки

Требования:
1. Файл: src/Common/Middleware/AuthMiddleware.php
2. Проверка Bearer token
3. Декодирование JWT
4. Установка текущего пользователя
5. Обработка истекших токенов
6. Whitelist для публичных роутов
7. Максимум 80 строк
```

## День 10: Docker и инфраструктура

### Задача 6.1: Docker конфигурация
**Файлы для создания:**
1. `docker-compose.yml`
2. `Dockerfile`
3. `docker/nginx/default.conf`
4. `docker/php/php.ini`

**Промпт для LLM:**
```
Задача: Создать docker-compose.yml для разработки

Сервисы:
1. app (PHP 8.1-fpm)
2. nginx
3. postgres (15)
4. redis
5. rabbitmq (с management UI)
6. mailhog (для тестирования email)

Требования:
- Volumes для hot reload
- Networks isolation
- Health checks
- Restart policies
- Environment файлы
```

### Задача 6.2: Начальная структура БД
**Файлы для создания:**
1. `database/migrations/000_create_extensions.sql`
2. `database/structure.sql`

**Промпт для LLM:**
```
Задача: Создать начальную миграцию для PostgreSQL extensions

Включить:
1. uuid-ossp (для UUID)
2. pg_trgm (для fuzzy search)
3. unaccent (для поиска)
4. Создание схемы 'app'
5. Базовые настройки
```

## Чек-лист завершения спринта

### Инфраструктура
- [ ] Docker окружение запускается одной командой
- [ ] Все сервисы доступны и работают
- [ ] Базовая структура проекта создана
- [ ] Автозагрузка настроена (PSR-4)

### Код
- [ ] Все интерфейсы созданы
- [ ] Базовые классы готовы
- [ ] Трейты работают
- [ ] Исключения структурированы
- [ ] Middleware тестированы

### Конфигурация
- [ ] Все config файлы на месте
- [ ] Environment настроен
- [ ] Роутинг сконфигурирован
- [ ] Логирование работает

### Документация
- [ ] README.md обновлен
- [ ] CONTRIBUTING.md создан
- [ ] Установка описана
- [ ] Структура проекта документирована

## Команды для быстрого старта

```bash
# Клонирование и setup
git clone [repo]
cd lms
cp .env.example .env

# Запуск окружения
docker-compose up -d

# Установка зависимостей
docker-compose exec app composer install

# Проверка
docker-compose exec app php artisan serve
```

## Метрики спринта
- **Файлов создано:** ~25
- **Строк кода:** ~1500
- **Покрытие тестами:** N/A (инфраструктура)
- **Время на review:** 2-3 часа

## Риски и проблемы
1. **Docker на разных ОС** - подготовить инструкции
2. **Версии зависимостей** - зафиксировать в composer.lock
3. **Права доступа** - настроить в Dockerfile
4. **Производительность на Mac** - использовать mutagen

## Следующие шаги (Спринт 2)
После завершения базовой инфраструктуры:
1. Начать с User domain модели
2. Реализовать базовую аутентификацию
3. Создать первые API endpoints
4. Написать первые интеграционные тесты 