# Руководство по версионированию для LLM-разработки

## Принципы инкрементальной разработки

### 1. Маленькие итерации
- **Одна фича = одна сессия** с LLM
- Максимум 5-10 файлов за итерацию
- Завершайте каждую фичу полностью перед переходом к следующей

### 2. Версионирование компонентов
```
src/
├── User/
│   └── VERSION.md  # Версия: 1.0.0
├── Competency/
│   └── VERSION.md  # Версия: 1.0.0
└── Learning/
    └── VERSION.md  # Версия: 1.0.0
```

### 3. Порядок разработки

#### Фаза 1: Базовая инфраструктура (Sprint 1-2)
```
1. Common/Interfaces/
   - RepositoryInterface.php
   - ServiceInterface.php
   - ValidatorInterface.php

2. Common/Traits/
   - HasTimestamps.php
   - Cacheable.php
   - Loggable.php

3. Common/Exceptions/
   - ValidationException.php
   - NotFoundException.php
   - AuthorizationException.php
```

#### Фаза 2: User Management (Sprint 1-2)
```
1. Domain сущности:
   - User.php
   - Role.php
   - Permission.php

2. Репозитории:
   - UserRepositoryInterface.php
   - UserRepository.php

3. Сервисы:
   - AuthenticationService.php
   - LdapService.php
   - TokenService.php

4. Контроллеры:
   - AuthController.php
   - UserController.php

5. Миграции:
   - 001_create_users_table.sql
   - 002_create_roles_table.sql
```

#### Фаза 3: Competency Service (Sprint 3-4)
```
1. Domain:
   - Competency.php
   - CompetencyLevel.php
   - CompetencyCategory.php

2. Repository:
   - CompetencyRepositoryInterface.php
   - CompetencyRepository.php

3. Service:
   - CompetencyService.php
   - CompetencyMappingService.php

4. Controller:
   - CompetencyController.php

5. Миграции:
   - 003_create_competencies_table.sql
   - 004_create_competency_levels_table.sql
```

### 4. Шаблон промпта для каждой итерации

```
Контекст: Разрабатываем LMS систему "ЦУМ: Корпоративный университет"
Текущая фаза: [Название фазы]
Предыдущие компоненты: [Список готовых компонентов]

Задача: Создать [компонент] для [сервиса]

Требования:
1. Файл должен быть не более [X] строк
2. Использовать интерфейс [InterfaceName]
3. Следовать структуре проекта из llm_development_guide.md
4. Добавить PHPDoc документацию
5. Обработать основные edge cases

Дополнительный контекст:
- [Специфичные требования]
- [Зависимости от других компонентов]
```

### 5. Чек-лист для каждого компонента

#### Перед созданием:
- [ ] Определены зависимости
- [ ] Создан интерфейс (если нужен)
- [ ] Понятны входные/выходные данные

#### После создания:
- [ ] Код соответствует PSR-12
- [ ] Добавлена документация
- [ ] Размер файла < 150 строк
- [ ] Обработаны исключения
- [ ] Написаны базовые тесты

### 6. Управление зависимостями

```json
// composer.json для каждого сервиса
{
    "name": "lms/user-service",
    "version": "1.0.0",
    "require": {
        "php": "^8.1",
        "symfony/event-dispatcher": "^6.0",
        "symfony/http-foundation": "^6.0"
    },
    "autoload": {
        "psr-4": {
            "App\\User\\": "src/User/"
        }
    }
}
```

### 7. Примеры последовательной разработки

#### Пример 1: Создание AuthenticationService

**Шаг 1**: Создать интерфейс
```
Создай интерфейс AuthenticationServiceInterface в src/User/Service/.
Методы:
- authenticate(string $username, string $password): ?array
- logout(string $token): void
- refreshToken(string $refreshToken): ?string
```

**Шаг 2**: Создать реализацию
```
Создай AuthenticationService implementing AuthenticationServiceInterface.
Используй:
- UserRepositoryInterface для работы с пользователями
- LdapService для проверки в AD
- TokenService для генерации токенов
- EventDispatcher для событий
```

**Шаг 3**: Создать тесты
```
Создай unit тест AuthenticationServiceTest.
Покрыть сценарии:
- Успешная аутентификация
- Неверный пароль
- Пользователь не найден в AD
- Создание нового пользователя при первом входе
```

### 8. Версионирование API

```php
// Контроллеры версионируются через namespace
namespace App\User\Controller\V1;

// Роуты версионируются через префикс
// config/routes/api.php
$router->group(['prefix' => 'v1'], function ($router) {
    $router->post('/auth/login', 'AuthController@login');
});
```

### 9. Миграции и откаты

```sql
-- Прямая миграция: 001_create_users_table.up.sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    ad_username VARCHAR(255) UNIQUE NOT NULL,
    -- ...
);

-- Откат: 001_create_users_table.down.sql
DROP TABLE IF EXISTS users CASCADE;
```

### 10. Документирование прогресса

После каждой сессии обновляйте:
```markdown
# PROGRESS.md

## Completed Components

### User Service (v1.0.0)
- [x] User.php - Domain entity
- [x] UserRepositoryInterface.php
- [x] UserRepository.php
- [x] AuthenticationService.php
- [ ] UserService.php - In progress

### Next Steps
1. Complete UserService.php
2. Create AuthController.php
3. Write integration tests
```

Эта структура позволяет эффективно работать с LLM, сохраняя контроль над версиями и прогрессом разработки. 