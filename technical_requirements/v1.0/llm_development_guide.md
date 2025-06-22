# Руководство по разработке с помощью LLM

## Принципы организации кода для LLM

### 1. Размер файлов
- **Максимум 150 строк** на файл (оптимально 50-100)
- **Один класс = один файл**
- **Одна функция/метод** не более 30 строк
- Разделение конфигурации, логики и представления

### 2. Модульность
- Каждый модуль в отдельной папке
- Четкое разделение ответственности
- Минимальные зависимости между модулями
- Dependency Injection для связей

### 3. Именование
- Описательные имена файлов
- Согласованная структура папок
- Префиксы для типов файлов (interface_, abstract_, trait_)

## 🚨 ОБЯЗАТЕЛЬНО: Test-Driven Development (TDD)

### Правила разработки с тестами

1. **НИКОГДА не пишите код без тестов**
   ```bash
   # Правильный процесс:
   1. Написать тест
   2. Запустить: docker run --rm -v $(pwd):/app -w /app php:8.2-cli ./vendor/bin/phpunit tests/YourTest.php
   3. Увидеть ошибку (тест должен упасть!)
   4. Написать минимальный код для прохождения теста
   5. Запустить тест снова - увидеть зеленый результат
   6. Рефакторинг (если нужно)
   7. Запустить тест еще раз
   ```

2. **Каждая функция = минимум один тест**
   ```php
   // Если написали функцию:
   public function calculateDiscount(float $price, float $percentage): float
   {
       return $price * (1 - $percentage / 100);
   }
   
   // СРАЗУ пишите тест:
   public function testCalculateDiscount(): void
   {
       $result = $this->service->calculateDiscount(100, 20);
       $this->assertEquals(80.0, $result);
   }
   ```

3. **Запуск тестов - часть определения "готово"**
   - Код без запущенных тестов = незавершенный код
   - PR без прохождения тестов = незавершенный PR
   - "Запущу потом" = "не запущу никогда"

4. **Используйте быстрые команды**
   ```bash
   # Для одного теста:
   make test-specific TEST=tests/Unit/User/UserTest.php
   
   # Или напрямую:
   docker run --rm -v $(pwd):/app -w /app php:8.2-cli ./vendor/bin/phpunit --no-configuration tests/YourTest.php
   ```

### Структура теста

```php
<?php

namespace Tests\Unit\Service;

use PHPUnit\Framework\TestCase;
use App\Service\YourService;

class YourServiceTest extends TestCase
{
    private YourService $service;
    
    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new YourService();
    }
    
    /**
     * @test
     */
    public function it_does_something_specific(): void
    {
        // Arrange
        $input = 'test data';
        
        // Act
        $result = $this->service->doSomething($input);
        
        // Assert
        $this->assertEquals('expected result', $result);
    }
}
```

### Контрольный чек-лист для каждой сессии разработки

- [ ] Тест написан ДО кода
- [ ] Тест запущен и упал (красный)
- [ ] Код написан
- [ ] Тест запущен и прошел (зеленый)
- [ ] Рефакторинг выполнен (если нужно)
- [ ] Тест запущен после рефакторинга
- [ ] Все тесты в модуле прошли
- [ ] Коммит сделан

## Детальная структура проекта

```
lms/
├── config/                      # Конфигурационные файлы (< 50 строк каждый)
│   ├── app.php                 # Основные настройки приложения
│   ├── database.php            # Настройки БД
│   ├── auth.php                # Настройки аутентификации
│   ├── services.php            # Регистрация сервисов
│   └── routes/                 # Роутинг разбит по модулям
│       ├── api.php
│       ├── web.php
│       └── admin.php
│
├── src/                        # Исходный код
│   ├── Common/                 # Общие компоненты
│   │   ├── Interfaces/         # Интерфейсы (< 30 строк)
│   │   │   ├── RepositoryInterface.php
│   │   │   ├── ServiceInterface.php
│   │   │   └── ValidatorInterface.php
│   │   ├── Traits/             # Переиспользуемые трейты
│   │   │   ├── HasTimestamps.php
│   │   │   ├── Cacheable.php
│   │   │   └── Loggable.php
│   │   └── Exceptions/         # Кастомные исключения
│   │       ├── ValidationException.php
│   │       ├── NotFoundException.php
│   │       └── AuthorizationException.php
│   │
│   ├── User/                   # User Management Service
│   │   ├── Domain/             # Доменная логика
│   │   │   ├── User.php        # Сущность (< 100 строк)
│   │   │   ├── Role.php        # Сущность (< 50 строк)
│   │   │   └── Permission.php  # Сущность (< 50 строк)
│   │   ├── Repository/         # Репозитории
│   │   │   ├── UserRepositoryInterface.php
│   │   │   ├── UserRepository.php
│   │   │   └── RoleRepository.php
│   │   ├── Service/            # Бизнес-логика
│   │   │   ├── AuthenticationService.php
│   │   │   ├── UserService.php
│   │   │   ├── LdapService.php
│   │   │   └── TokenService.php
│   │   ├── Controller/         # HTTP контроллеры
│   │   │   ├── AuthController.php
│   │   │   ├── UserController.php
│   │   │   └── ProfileController.php
│   │   ├── Request/            # Request классы
│   │   │   ├── LoginRequest.php
│   │   │   ├── CreateUserRequest.php
│   │   │   └── UpdateProfileRequest.php
│   │   ├── Response/           # Response классы
│   │   │   ├── UserResponse.php
│   │   │   ├── TokenResponse.php
│   │   │   └── ProfileResponse.php
│   │   └── Event/              # События
│   │       ├── UserCreated.php
│   │       ├── UserLoggedIn.php
│   │       └── PasswordChanged.php
│   │
│   ├── Competency/             # Competency Service
│   │   ├── Domain/
│   │   │   ├── Competency.php
│   │   │   ├── CompetencyLevel.php
│   │   │   └── CompetencyCategory.php
│   │   ├── Repository/
│   │   │   ├── CompetencyRepositoryInterface.php
│   │   │   ├── CompetencyRepository.php
│   │   │   └── CompetencySearchRepository.php
│   │   ├── Service/
│   │   │   ├── CompetencyService.php
│   │   │   ├── CompetencyMappingService.php
│   │   │   └── CompetencyValidationService.php
│   │   ├── Controller/
│   │   │   ├── CompetencyController.php
│   │   │   ├── CompetencyCategoryController.php
│   │   │   └── CompetencyLevelController.php
│   │   └── ValueObject/
│   │       ├── CompetencyColor.php
│   │       └── CompetencyLevel.php
│   │
│   ├── Learning/               # Learning Service
│   │   ├── Domain/
│   │   │   ├── Course/
│   │   │   │   ├── Course.php
│   │   │   │   ├── CourseModule.php
│   │   │   │   └── CourseCategory.php
│   │   │   ├── Test/
│   │   │   │   ├── Test.php
│   │   │   │   ├── Question.php
│   │   │   │   └── Answer.php
│   │   │   └── Progress/
│   │   │       ├── UserProgress.php
│   │   │       └── ModuleProgress.php
│   │   ├── Repository/
│   │   │   ├── CourseRepository.php
│   │   │   ├── TestRepository.php
│   │   │   └── ProgressRepository.php
│   │   ├── Service/
│   │   │   ├── CourseService.php
│   │   │   ├── TestService.php
│   │   │   ├── CertificateService.php
│   │   │   └── ProgressTrackingService.php
│   │   └── Controller/
│   │       ├── CourseController.php
│   │       ├── ModuleController.php
│   │       └── TestController.php
│   │
│   ├── Program/                # Program Service
│   │   ├── Domain/
│   │   │   ├── Program.php
│   │   │   ├── ProgramTemplate.php
│   │   │   └── ProgramStage.php
│   │   ├── Service/
│   │   │   ├── OnboardingService.php
│   │   │   ├── ProgramAssignmentService.php
│   │   │   └── ProgramProgressService.php
│   │   └── Controller/
│   │       ├── ProgramController.php
│   │       └── OnboardingController.php
│   │
│   └── Notification/           # Notification Service
│       ├── Domain/
│       │   ├── Notification.php
│       │   └── NotificationTemplate.php
│       ├── Service/
│       │   ├── EmailService.php
│       │   ├── InAppNotificationService.php
│       │   └── NotificationQueueService.php
│       └── Channel/            # Каналы отправки
│           ├── ChannelInterface.php
│           ├── EmailChannel.php
│           └── DatabaseChannel.php
│
├── database/
│   ├── migrations/             # Миграции (одна таблица = один файл)
│   │   ├── 001_create_users_table.sql
│   │   ├── 002_create_roles_table.sql
│   │   ├── 003_create_competencies_table.sql
│   │   └── ...
│   ├── seeds/                  # Начальные данные
│   │   ├── UserSeeder.php
│   │   ├── RoleSeeder.php
│   │   └── CompetencySeeder.php
│   └── factories/              # Фабрики для тестов
│       ├── UserFactory.php
│       └── CourseFactory.php
│
├── tests/                      # Тесты (зеркалируют структуру src/)
│   ├── Unit/
│   │   ├── User/
│   │   │   ├── UserTest.php
│   │   │   └── AuthenticationServiceTest.php
│   │   └── Competency/
│   │       └── CompetencyTest.php
│   ├── Feature/
│   │   ├── AuthenticationTest.php
│   │   └── CourseEnrollmentTest.php
│   └── Integration/
│       ├── LdapIntegrationTest.php
│       └── NotificationTest.php
│
├── resources/
│   ├── views/                  # Шаблоны (если используется SSR)
│   │   ├── layouts/
│   │   │   └── app.blade.php
│   │   └── components/         # Маленькие компоненты
│   │       ├── alert.blade.php
│   │       └── button.blade.php
│   └── lang/                   # Локализация
│       └── ru/
│           ├── auth.php
│           ├── validation.php
│           └── messages.php
│
└── frontend/                   # Frontend (если SPA)
    ├── src/
    │   ├── components/         # Vue/React компоненты (< 100 строк)
    │   │   ├── common/
    │   │   │   ├── Button.vue
    │   │   │   ├── Input.vue
    │   │   │   └── Modal.vue
    │   │   ├── user/
    │   │   │   ├── UserCard.vue
    │   │   │   └── UserList.vue
    │   │   └── course/
    │   │       ├── CourseCard.vue
    │   │       └── CourseProgress.vue
    │   ├── services/           # API клиенты
    │   │   ├── api.js
    │   │   ├── auth.service.js
    │   │   └── course.service.js
    │   ├── store/              # State management
    │   │   ├── modules/
    │   │   │   ├── auth.js
    │   │   │   └── course.js
    │   │   └── index.js
    │   └── pages/              # Страницы/контейнеры
    │       ├── Login.vue
    │       ├── Dashboard.vue
    │       └── Course/
    │           ├── List.vue
    │           └── Detail.vue
```

## Пример структуры файла

### Service класс (50-100 строк)
```php
// src/User/Service/AuthenticationService.php
<?php

namespace App\User\Service;

use App\User\Domain\User;
use App\User\Repository\UserRepositoryInterface;
use App\User\Service\LdapService;
use App\User\Service\TokenService;
use App\User\Event\UserLoggedIn;
use App\Common\Traits\Loggable;
use Symfony\Component\EventDispatcher\EventDispatcherInterface;

class AuthenticationService
{
    use Loggable;
    
    public function __construct(
        private UserRepositoryInterface $userRepository,
        private LdapService $ldapService,
        private TokenService $tokenService,
        private EventDispatcherInterface $events
    ) {}
    
    public function authenticate(string $username, string $password): ?array
    {
        // Проверка в AD
        $adUser = $this->ldapService->authenticate($username, $password);
        if (!$adUser) {
            $this->logWarning('Failed AD authentication', ['username' => $username]);
            return null;
        }
        
        // Получение или создание пользователя
        $user = $this->findOrCreateUser($adUser);
        
        // Генерация токена
        $token = $this->tokenService->generateToken($user);
        
        // Событие
        $this->events->dispatch(new UserLoggedIn($user));
        
        return [
            'user' => $user,
            'token' => $token
        ];
    }
    
    private function findOrCreateUser(array $adUser): User
    {
        $user = $this->userRepository->findByUsername($adUser['username']);
        
        if (!$user) {
            $user = User::createFromAd($adUser);
            $this->userRepository->save($user);
        } else {
            $user->updateFromAd($adUser);
            $this->userRepository->update($user);
        }
        
        return $user;
    }
}
```

### Controller (30-50 строк)
```php
// src/User/Controller/AuthController.php
<?php

namespace App\User\Controller;

use App\User\Service\AuthenticationService;
use App\User\Request\LoginRequest;
use App\User\Response\TokenResponse;
use Symfony\Component\HttpFoundation\JsonResponse;

class AuthController
{
    public function __construct(
        private AuthenticationService $authService
    ) {}
    
    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->authService->authenticate(
            $request->username(),
            $request->password()
        );
        
        if (!$result) {
            return new JsonResponse([
                'error' => 'Invalid credentials'
            ], 401);
        }
        
        return new JsonResponse(
            new TokenResponse($result['token'], $result['user'])
        );
    }
    
    public function logout(): JsonResponse
    {
        // Логика выхода
        return new JsonResponse(['message' => 'Logged out']);
    }
}
```

### Repository Interface (< 30 строк)
```php
// src/User/Repository/UserRepositoryInterface.php
<?php

namespace App\User\Repository;

use App\User\Domain\User;

interface UserRepositoryInterface
{
    public function find(int $id): ?User;
    
    public function findByUsername(string $username): ?User;
    
    public function findByEmail(string $email): ?User;
    
    public function save(User $user): void;
    
    public function update(User $user): void;
    
    public function delete(User $user): void;
    
    /** @return User[] */
    public function findActive(int $limit = 100, int $offset = 0): array;
    
    public function count(): int;
}
```

## Рекомендации для LLM-разработки

### 1. Начинайте с интерфейсов
- Сначала определите контракты
- Потом реализацию
- Это позволит LLM лучше понимать структуру

### 2. Используйте Type Hints
- Явные типы параметров и возвращаемых значений
- PHPDoc для сложных типов
- Это поможет LLM генерировать корректный код

### 3. Маленькие, сфокусированные PR
- Один PR = одна фича
- Максимум 10 файлов в PR
- Легче для review и понимания LLM

### 4. Тесты рядом с кодом
- Unit тесты в той же сессии
- Покрытие критического функционала
- Простые, понятные тесты

### 5. Документация в коде
```php
/**
 * Аутентифицирует пользователя через Active Directory
 * 
 * @param string $username AD username (sAMAccountName)
 * @param string $password Пароль пользователя
 * @return array{user: User, token: string}|null Null если аутентификация неудачна
 * @throws LdapException При проблемах с AD соединением
 */
public function authenticate(string $username, string $password): ?array
```

## Пример промпта для LLM

```
Создай сервис CompetencyMappingService в папке src/Competency/Service/.
Сервис должен:
1. Наследовать App\Common\Service\BaseService
2. Использовать CompetencyRepositoryInterface
3. Иметь метод mapToPosition(int $positionId, array $competencyIds): void
4. Метод должен быть не более 30 строк
5. Добавить PHPDoc документацию
6. Использовать транзакции для атомарности
```

Такая структура позволит LLM эффективно работать с кодом, понимая контекст и генерируя качественные решения. 