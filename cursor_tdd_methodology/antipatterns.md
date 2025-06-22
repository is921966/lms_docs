# TDD Антипаттерны - Как НЕ надо делать

## 🚫 Топ-10 антипаттернов TDD

### 1. ❌ "Напишу тесты потом"

**Как выглядит:**
```javascript
// Сначала пишем код
function calculatePrice(items) {
  let total = 0;
  items.forEach(item => {
    total += item.price * item.quantity;
    if (item.quantity > 10) {
      total *= 0.9; // скидка 10%
    }
  });
  return total;
}

// "Потом" никогда не наступает...
```

**Почему это плохо:**
- Тесты никогда не будут написаны
- Код не проектируется для тестируемости
- Нет уверенности, что код работает
- Сложно понять требования

**Как правильно:**
```javascript
// СНАЧАЛА тест
test('calculates price with bulk discount', () => {
  const items = [{ price: 10, quantity: 15 }];
  expect(calculatePrice(items)).toBe(135); // 150 - 10%
});

// ПОТОМ код
function calculatePrice(items) {
  // минимальная реализация
}
```

### 2. ❌ "Тесты для галочки"

**Как выглядит:**
```php
public function testUserExists()
{
    $this->assertTrue(true); // Всегда проходит!
}

public function testSomething()
{
    $user = new User();
    $this->assertNotNull($user); // Бессмысленный тест
}
```

**Почему это плохо:**
- Ложное чувство безопасности
- Не проверяет реальную функциональность
- Увеличивает "покрытие" без пользы

**Как правильно:**
```php
public function testUserCanBeCreatedWithValidData()
{
    $user = new User('John Doe', 'john@example.com');
    
    $this->assertEquals('John Doe', $user->getName());
    $this->assertEquals('john@example.com', $user->getEmail());
    $this->assertTrue($user->isActive());
}
```

### 3. ❌ "Один большой тест на всё"

**Как выглядит:**
```python
def test_everything():
    # 200 строк теста
    user = User("John", "john@example.com")
    assert user.name == "John"
    
    user.update_email("new@example.com")
    assert user.email == "new@example.com"
    
    order = Order(user)
    order.add_item(Item("Book", 10))
    assert order.total == 10
    
    # и так далее...
```

**Почему это плохо:**
- Сложно понять, что именно сломалось
- Нарушает принцип "один тест - одна проверка"
- Тесты зависят друг от друга
- Долго выполняется

**Как правильно:**
```python
def test_user_has_name():
    user = User("John", "john@example.com")
    assert user.name == "John"

def test_user_can_update_email():
    user = User("John", "john@example.com")
    user.update_email("new@example.com")
    assert user.email == "new@example.com"

def test_order_calculates_total():
    user = User("John", "john@example.com")
    order = Order(user)
    order.add_item(Item("Book", 10))
    assert order.total == 10
```

### 4. ❌ "Тестирование приватных методов"

**Как выглядит:**
```php
class Calculator
{
    private function validate($number)
    {
        return is_numeric($number);
    }
}

// Тест с рефлексией
public function testPrivateValidate()
{
    $calculator = new Calculator();
    $method = new ReflectionMethod($calculator, 'validate');
    $method->setAccessible(true);
    
    $this->assertTrue($method->invoke($calculator, 5));
}
```

**Почему это плохо:**
- Тесты привязаны к реализации, а не поведению
- Ломаются при рефакторинге
- Приватные методы - детали реализации

**Как правильно:**
```php
// Тестируйте через публичный интерфейс
public function testCalculatorRejectsInvalidInput()
{
    $calculator = new Calculator();
    
    $this->expectException(InvalidArgumentException::class);
    $calculator->add('not a number', 5);
}
```

### 5. ❌ "Избыточное использование моков"

**Как выглядит:**
```javascript
test('user service test', () => {
  const mockUser = { id: 1, name: 'John' };
  const mockRepository = {
    find: jest.fn().mockReturnValue(mockUser),
    save: jest.fn().mockReturnValue(mockUser)
  };
  const mockLogger = {
    log: jest.fn()
  };
  const mockCache = {
    get: jest.fn(),
    set: jest.fn()
  };
  const mockEventBus = {
    emit: jest.fn()
  };
  
  const service = new UserService(
    mockRepository, 
    mockLogger, 
    mockCache, 
    mockEventBus
  );
  
  // Тест превращается в проверку моков
  service.getUser(1);
  
  expect(mockRepository.find).toHaveBeenCalledWith(1);
  expect(mockLogger.log).toHaveBeenCalled();
  expect(mockCache.get).toHaveBeenCalled();
  // И так далее...
});
```

**Почему это плохо:**
- Тестируется взаимодействие, а не поведение
- Хрупкие тесты
- Сложно понять, что тестируется

**Как правильно:**
```javascript
test('returns user by id', () => {
  const expectedUser = { id: 1, name: 'John' };
  const repository = new InMemoryUserRepository([expectedUser]);
  const service = new UserService(repository);
  
  const user = service.getUser(1);
  
  expect(user).toEqual(expectedUser);
});
```

### 6. ❌ "Зависимые тесты"

**Как выглядит:**
```python
class TestOrder:
    order = None
    
    def test_1_create_order(self):
        TestOrder.order = Order()
        TestOrder.order.add_item("Book", 10)
        assert TestOrder.order.total == 10
    
    def test_2_add_more_items(self):
        # Зависит от test_1!
        TestOrder.order.add_item("Pen", 5)
        assert TestOrder.order.total == 15
```

**Почему это плохо:**
- Тесты должны выполняться в любом порядке
- Сложно отлаживать
- Нельзя запустить один тест изолированно

**Как правильно:**
```python
class TestOrder:
    def setup_method(self):
        self.order = Order()
    
    def test_single_item_total(self):
        self.order.add_item("Book", 10)
        assert self.order.total == 10
    
    def test_multiple_items_total(self):
        self.order.add_item("Book", 10)
        self.order.add_item("Pen", 5)
        assert self.order.total == 15
```

### 7. ❌ "Игнорирование падающих тестов"

**Как выглядит:**
```javascript
test.skip('should calculate tax correctly', () => {
  // Этот тест падает, поэтому skip...
});

test('should process payment', () => {
  // try {
  //   processPayment(order);
  // } catch (e) {
  //   // Игнорируем ошибку
  // }
  expect(true).toBe(true); // Всегда проходит
});
```

**Почему это плохо:**
- Скрывает реальные проблемы
- Код может быть сломан
- Теряется доверие к тестам

**Как правильно:**
- Исправьте тест немедленно
- Если не можете исправить - удалите
- Используйте `test.todo()` для планируемых тестов

### 8. ❌ "Тестирование фреймворка"

**Как выглядит:**
```php
public function testLaravelRouteExists()
{
    $response = $this->get('/');
    $response->assertStatus(200); // Тестируем, что Laravel работает
}

public function testDatabaseConnection()
{
    $this->assertDatabaseHas('users', []); // Тестируем, что БД работает
}
```

**Почему это плохо:**
- Фреймворк уже протестирован
- Тратится время на бесполезные тесты
- Не тестируется ваша бизнес-логика

**Как правильно:**
```php
public function testHomePageShowsWelcomeMessage()
{
    $response = $this->get('/');
    
    $response->assertStatus(200);
    $response->assertSee('Welcome to our application');
    $response->assertViewHas('featured_products');
}
```

### 9. ❌ "Магические числа и строки"

**Как выглядит:**
```javascript
test('discount calculation', () => {
  const order = new Order();
  order.addItem({ price: 100, quantity: 5 });
  
  expect(order.getTotal()).toBe(450); // Откуда 450?
});
```

**Почему это плохо:**
- Непонятно, как получился результат
- Сложно поддерживать
- Легко сделать ошибку

**Как правильно:**
```javascript
test('applies 10% discount for orders over 5 items', () => {
  const ITEM_PRICE = 100;
  const QUANTITY = 5;
  const DISCOUNT_RATE = 0.1;
  const EXPECTED_TOTAL = ITEM_PRICE * QUANTITY * (1 - DISCOUNT_RATE);
  
  const order = new Order();
  order.addItem({ price: ITEM_PRICE, quantity: QUANTITY });
  
  expect(order.getTotal()).toBe(EXPECTED_TOTAL);
});
```

### 10. ❌ "Медленные тесты"

**Как выглядит:**
```python
def test_email_sent_after_delay():
    user = User("john@example.com")
    
    user.schedule_welcome_email()
    time.sleep(60)  # Ждём минуту!
    
    assert email_was_sent(user.email)

def test_api_integration():
    # Реальный HTTP запрос
    response = requests.get("https://api.example.com/users")
    assert response.status_code == 200
```

**Почему это плохо:**
- Тесты выполняются долго
- Разработчики перестают их запускать
- CI/CD pipeline замедляется

**Как правильно:**
```python
def test_email_scheduled(mock_scheduler):
    user = User("john@example.com")
    
    user.schedule_welcome_email()
    
    mock_scheduler.assert_called_with(
        send_welcome_email, 
        args=[user.email],
        delay=60
    )

def test_api_client(mock_requests):
    mock_requests.get.return_value.status_code = 200
    mock_requests.get.return_value.json.return_value = {"users": []}
    
    client = ApiClient()
    users = client.get_users()
    
    assert users == []
```

## Как избежать антипаттернов

### 1. Следуйте циклу Red-Green-Refactor
- Пишите тест первым
- Видите его падение
- Пишите минимальный код
- Рефакторите

### 2. Принципы хороших тестов
- **F**ast - быстрые
- **I**ndependent - независимые
- **R**epeatable - воспроизводимые
- **S**elf-validating - самопроверяющиеся
- **T**imely - своевременные

### 3. Код-ревью для тестов
- Проверяйте тесты так же тщательно, как код
- Ищите антипаттерны
- Требуйте понятные имена тестов

### 4. Метрики
- Следите не только за покрытием
- Измеряйте время выполнения
- Считайте количество моков

## Чек-лист для самопроверки

- [ ] Тест написан ДО кода?
- [ ] Тест проверяет одну вещь?
- [ ] Тест независим от других?
- [ ] Тест выполняется быстро (< 100ms)?
- [ ] Тест понятен без изучения кода?
- [ ] Тест не использует приватные методы?
- [ ] Тест проверяет поведение, а не реализацию?
- [ ] В тесте нет магических чисел?
- [ ] Тест не пропущен (skip)?
- [ ] Тест действительно может упасть?

Если хотя бы один пункт - "нет", пересмотрите подход!

# Антипаттерны разработки LMS

## 1. Написание тестов без их запуска ❌

**Проблема**: Написание большого количества тестов без их немедленного запуска создает иллюзию прогресса, но на самом деле приводит к накоплению нерабочего кода.

**Симптомы**:
- Тесты написаны, но никогда не запускались
- Множественные синтаксические ошибки в коде
- Неверные предположения о API и интерфейсах
- Ложное чувство безопасности ("у нас есть тесты!")

**Последствия**:
- Реальное покрытие тестами: 0%
- Время потрачено на написание нерабочего кода
- Необходимость переписывать большие объемы кода
- Потеря доверия к процессу TDD

**Правильный подход**:
```bash
# Написали тест
vim tests/Unit/UserTest.php

# СРАЗУ запустили
docker run --rm -v $(pwd):/app php:8.2-cli php vendor/bin/phpunit tests/Unit/UserTest.php

# Увидели ошибку - исправили
# Запустили снова
# И так до зеленого статуса
```

**Правило**: Код без запущенных тестов = код не существует

## 2. Игнорирование инфраструктуры тестирования ❌

**Проблема**: Попытка писать тесты без настроенного окружения.

**Симптомы**:
- Docker контейнеры не запущены
- Зависимости не установлены
- База данных не создана
- Конфигурация отсутствует

**Последствия**:
- Тесты физически не могут запуститься
- Разработчики избегают TDD
- Накопление технического долга

**Правильный подход**:
```bash
# Первый день проекта:
make setup-test-env
make test-simple  # Убедиться что хоть что-то работает
```

## 3. Создание объектов через приватные конструкторы ❌

**Проблема**: Попытка использовать `new Entity()` когда конструктор приватный.

**Симптомы**:
```php
// Неправильно
$user = new User($id, $email, $name);  // Error: Call to private constructor

// Правильно
$user = User::create($email, $firstName, $lastName);
```

**Последствия**:
- Тесты не компилируются
- Нарушение инкапсуляции
- Невозможность контролировать инварианты

**Правильный подход**:
- Всегда использовать фабричные методы
- Документировать доступные способы создания объектов
- Проверять в тестах все фабричные методы

## 4. Создание слишком больших файлов ❌

**Проблема**: Файлы размером более 500 строк становятся критически сложными для анализа LLM и человека.

**Симптомы**:
- Файлы по 600-700+ строк кода
- Множество ответственностей в одном классе
- LLM с трудом анализирует весь контекст
- Долгая генерация и частые ошибки

**Последствия**:
- Снижение продуктивности при работе с LLM
- Нарушение принципа единой ответственности
- Сложность поддержки и тестирования
- Увеличение когнитивной нагрузки

**Реальный пример из проекта**:
```
User.php: 677 строк → рефакторинг → 182 строки
AuthService.php: 584 строки → рефакторинг → 289 строк
LdapService.php: 654 строки → рефакторинг → 290 строк
```

**Правильный подход**:
```
Оптимально: 50-150 строк
Приемлемо: 150-300 строк
Требует рефакторинга: > 300 строк
Критично: > 500 строк
```

**Техники рефакторинга**:
1. **Извлечение трейтов** для группировки связанной функциональности
2. **Создание специализированных сервисов** (TokenService, TwoFactorService)
3. **Использование композиции** вместо наследования
4. **Разделение по bounded contexts** в микросервисной архитектуре

## 5. Передача неправильного количества аргументов в события ❌

**Проблема**: Domain events создаются с неправильным количеством параметров.

**Симптомы**:
```php
// Event ожидает 4 параметра
public function __construct(UserId $id, Email $email, string $firstName, string $lastName)

// Но вызывается с 2
$this->recordEvent(new UserCreated($this->id, $this->email)); // Error!
```

**Последствия**:
- Тесты падают с ArgumentCountError
- События не записываются
- Event sourcing ломается

**Правильный подход**:
```php
// Всегда проверяйте сигнатуру конструктора события
$this->recordEvent(new UserCreated(
    $this->id, 
    $this->email, 
    $this->firstName, 
    $this->lastName
));
```

## 6. Игнорирование результатов рефакторинга в тестах ❌

**Проблема**: После рефакторинга большого класса тесты не запускаются для проверки.

**Симптомы**:
- Класс разбит на несколько файлов
- Тесты "должны работать"
- Но никто не проверил

**Последствия**:
- Сломанная функциональность
- Потерянные методы
- Неработающие зависимости

**Правильный подход**:
```bash
# После КАЖДОГО рефакторинга:
make test-unit  # Убедиться что все тесты проходят
git add .
git commit -m "Refactor: split large class, all tests passing"
```

## 7. Создание "рефакторенных" версий вместо замены ❌

**Проблема**: Создание RefactoredService.php вместо обновления оригинала.

**Симптомы**:
```bash
AuthService.php           # Старый
RefactoredAuthService.php # Новый (временный)
```

**Последствия**:
- Путаница в кодовой базе
- Дублирование кода
- Неясно, какую версию использовать

**Правильный подход**:
```bash
# Создать резервную копию
mv AuthService.php AuthService.php.bak

# Работать с основным файлом
mv RefactoredAuthService.php AuthService.php

# После проверки удалить бэкап
rm AuthService.php.bak
```

## 8. Непроверка размера файлов во время разработки ❌

**Проблема**: Файлы растут незаметно до критических размеров.

**Симптомы**:
- "Просто добавлю еще один метод"
- "Это логически связано, пусть будет здесь"
- Через месяц: 700+ строк

**Правильный подход**:
```bash
# Добавить в Makefile
check-file-sizes:
	@echo "Files larger than 300 lines:"
	@find src -name "*.php" -exec wc -l {} \; | awk '$$1 > 300 {print}'

# Запускать регулярно
make check-file-sizes
```

## Чек-лист для работы с большими файлами

- [ ] Файл меньше 300 строк?
- [ ] Класс имеет единственную ответственность?
- [ ] Можно ли выделить трейты?
- [ ] Можно ли создать специализированные сервисы?
- [ ] Все тесты проходят после рефакторинга?
- [ ] Удалены временные "Refactored" версии?
- [ ] Обновлена документация?

## Правила для LLM-разработки

1. **Маленькие файлы** - LLM лучше работает с файлами 50-200 строк
2. **Четкая структура** - один класс = один файл = одна ответственность
3. **Немедленная проверка** - написал → запустил → исправил
4. **Регулярный рефакторинг** - не дожидайтесь 600+ строк

## 9. Неучет начальных событий домена ❌

**Проблема**: Ожидание только новых событий, игнорируя события создания.

**Симптомы**:
```php
// Неправильно
$user = User::create(...);
$events = $user->pullDomainEvents();
$this->assertCount(0, $events);  // Fail! UserCreated уже есть

// Правильно
$user = User::create(...);
$user->pullDomainEvents();  // Очистить начальные события
$user->doSomething();
$events = $user->pullDomainEvents();
$this->assertCount(1, $events);
```

**Последствия**:
- Неверные assertions в тестах
- Пропуск важных событий
- Неправильное понимание жизненного цикла объектов

**Правильный подход**:
```php
// Неправильно
$user = User::create(...);
$events = $user->pullDomainEvents();
$this->assertCount(0, $events);  // Fail! UserCreated уже есть

// Правильно
$user = User::create(...);
$user->pullDomainEvents();  // Очистить начальные события
$user->doSomething();
$events = $user->pullDomainEvents();
$this->assertCount(1, $events);
```

## 10. Массовое написание кода без итераций ❌

**Проблема**: Написание 11,500 строк кода за 2 дня без промежуточного тестирования.

**Симптомы**:
- Огромные PR/коммиты
- Отсутствие промежуточных проверок
- "Большой взрыв" в конце

**Последствия**:
- Невозможность локализовать проблемы
- Огромные затраты на отладку
- Демотивация команды

**Правильный подход**:
```
Итерация 1 (2 часа): Email ValueObject + тесты ✅
Итерация 2 (2 часа): Password ValueObject + тесты ✅
Итерация 3 (3 часа): User Entity базовая + тесты ✅
...
```

## 11. Использование моков без понимания интерфейсов ❌

**Проблема**: Создание моков для несуществующих или неправильных интерфейсов.

**Симптомы**:
```php
// Неправильно
$redis = $this->createMock(\Predis\Client::class);  // Класс не установлен

// Правильно
$redis = $this->createMock(\Redis::class);
```

**Последствия**:
- Runtime ошибки в тестах
- Невозможность создать моки
- Потеря времени на отладку

## 12. Игнорирование PHPUnit warnings ❌

**Проблема**: Запуск тестов с warnings и deprecations без их исправления.

**Симптомы**:
- "PHPUnit Deprecations: 1"
- "OK, but there were issues!"

**Последствия**:
- Будущие версии PHPUnit сломают тесты
- Скрытые проблемы в коде
- Технический долг

**Правильный подход**:
- Исправлять warnings сразу
- Обновлять PHPUnit регулярно
- Использовать строгий режим

## 13. Отсутствие быстрых команд для тестирования ❌

**Проблема**: Длинные команды docker run отпугивают от частого запуска тестов.

**Симптомы**:
```bash
docker run --rm -v $(pwd):/app -w /app --network lms_docs_lms_network php:8.2-cli php vendor/bin/phpunit tests/Unit/User/Domain/UserTest.php --stop-on-failure
```

**Последствия**:
- Разработчики избегают запускать тесты
- Копипаст команд с ошибками
- Потеря продуктивности

**Правильный подход**:
```bash
make test TEST=UserTest     # Простая команда
make test-watch            # Автоматический перезапуск
```

## Правила предотвращения антипаттернов

1. **Правило 5 минут**: Тест должен быть запущен в течение 5 минут после написания
2. **Правило зеленого статуса**: Не писать новый код пока текущие тесты не зеленые
3. **Правило малых итераций**: Максимум 2 часа между коммитами
4. **Правило документации**: Каждый нестандартный подход должен быть задокументирован
5. **Правило инфраструктуры**: Первый день = работающее тестовое окружение 