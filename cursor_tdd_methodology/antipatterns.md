# TDD Антипаттерны - Как НЕ надо делать

**Версия:** 1.1.0  
**Дата обновления:** 2025-07-04  
**Статус:** ОБЯЗАТЕЛЬНО К ИЗУЧЕНИЮ

**Что нового в версии 1.1.0:**
- Добавлен раздел "Антипаттерны продвинутых методологий"
- Test Builders антипаттерны
- Параметризованные тесты антипаттерны
- Mutation Testing ловушки
- Property-Based Testing ошибки
- Contract Testing проблемы
- Snapshot Testing подводные камни

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

**Правильный подход**:
- Мокируйте внешние зависимости (БД, API, Email)
- Используйте in-memory реализации для репозиториев
- Не мокируйте Value Objects и Domain сущности

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

# Антипаттерны разработки с LLM

## 1. ❌ Написание кода без запуска тестов

**Проблема**: Написание большого количества кода и тестов без их выполнения приводит к накоплению ошибок.

**Пример из проекта**: 143 теста были написаны, но ни разу не запущены, что привело к:
- Синтаксическим ошибкам (использование `::` с `new`)
- Неверным предположениям об API
- 3 дням исправлений

**Решение**: 
- Запускать каждый тест сразу после написания
- Использовать `./test-quick.sh` для быстрой обратной связи
- Следовать циклу RED-GREEN-REFACTOR

## 2. ❌ Игнорирование размера файлов

**Проблема**: Создание файлов с 500+ строками кода затрудняет работу LLM.

**Пример**: 
- User.php (677 строк) → разбит на трейты (182 строки)
- AuthService.php (584 строки) → разделен на специализированные сервисы

**Решение**:
- Оптимальный размер: 50-150 строк
- Максимум: 300 строк
- Использовать композицию и трейты

## 3. ❌ Сложные абстракции с самого начала

**Проблема**: Создание избыточных абстракций без реальной необходимости.

**Пример**: HasDomainEvents трейт вместо простого массива событий в классе.

**Решение**: Начинать с простого, усложнять по необходимости.

## 4. ❌ Отсутствие немедленной валидации

**Проблема**: Предположения о работе кода без проверки.

**Пример**: Предположение о существовании приватных конструкторов в Value Objects.

**Решение**: Проверять каждое предположение запуском кода.

## 5. ❌ Пропуск фазы рефакторинга

**Проблема**: Оставление "грязного" кода после прохождения тестов.

**Решение**: Обязательный рефакторинг после GREEN фазы.

## 6. ❌ Написание тестов "задним числом"

**Проблема**: Создание тестов после написания кода приводит к плохому покрытию.

**Решение**: Строго TDD - тест первый, всегда.

## 7. ❌ Игнорирование failing тестов

**Проблема**: Продолжение разработки с непроходящими тестами.

**Решение**: Все тесты должны быть зелеными перед продолжением.

## 8. ❌ Копирование кода без понимания

**Проблема**: LLM может копировать паттерны без понимания контекста.

**Решение**: Каждый скопированный блок должен быть адаптирован.

## 9. ❌ Использование heredoc для создания файлов

**Проблема**: Команды `cat << EOF` часто зависают или прерываются при создании PHP файлов.

**Пример**:
```bash
# ❌ Часто зависает
cat > file.php << 'EOF'
<?php
class Test {
    private $var = "value";
}
EOF
```

**Причины**:
- Специальные символы PHP ($, \, ", ') интерпретируются shell
- Проблемы с многострочным вводом
- Неправильное расположение EOF маркера
- Проблемы с буферизацией

**Решение**:
```python
# ✅ Используйте edit_file
edit_file(
    target_file="file.php",
    instructions="Create PHP class",
    code_edit="<?php\n\nclass Test {\n    private \$var = \"value\";\n}"
)
```

Альтернативы:
- `touch file.php` + `edit_file` для добавления содержимого
- `echo '...' > file.php` для коротких файлов
- Использование helper скрипта `create-file.sh`

## Обновлено: 2025-01-19
- Добавлен антипаттерн #9 о использовании heredoc

# Антипаттерны продвинутых методологий тестирования

### 1. ❌ Test Builders: Переусложнение

**Как выглядит:**
```php
// ПЛОХО: Builder для простого объекта
class EmailBuilder {
    private $value;
    
    public function withValue($value) {
        $this->value = $value;
        return $this;
    }
    
    public function build() {
        return new Email($this->value);
    }
}

// Использование
$email = (new EmailBuilder())->withValue('test@test.com')->build();
// Вместо простого: new Email('test@test.com')
```

**Почему это плохо:**
- Излишняя сложность для простых объектов
- Больше кода для поддержки
- Снижение читаемости

**Как правильно:**
```php
// Используйте builders только для сложных объектов
class UserBuilder {
    private $attributes = [
        'role' => 'user',
        'isActive' => true,
        'permissions' => []
    ];
    
    public function asAdmin() {
        $this->attributes['role'] = 'admin';
        $this->attributes['permissions'] = ['all'];
        return $this;
    }
    
    public function inactive() {
        $this->attributes['isActive'] = false;
        return $this;
    }
    
    public function build() {
        // Создание сложного объекта с множеством параметров
        return new User(...$this->attributes);
    }
}
```

### 2. ❌ Test Builders: Мутабельность

**Как выглядит:**
```php
// ПЛОХО: Изменяемый builder
$builder = new UserBuilder();
$admin = $builder->asAdmin()->build();
$user = $builder->build(); // Неожиданно: тоже admin!
```

**Как правильно:**
```php
// Каждый метод возвращает новый экземпляр
public function asAdmin() {
    $clone = clone $this;
    $clone->attributes['role'] = 'admin';
    return $clone;
}
```

### 3. ❌ Параметризованные тесты: Неясные данные

**Как выглядит:**
```php
/**
 * @dataProvider emailProvider
 */
public function testEmail($input, $expected) {
    // Что тестируется? Непонятно из данных
}

public static function emailProvider() {
    return [
        ['test@test.com', true],      // Что true означает?
        ['invalid', false],            // Почему invalid?
        ['user@domain', false],        // В чем проблема?
        ['', false],                   // Пустая строка?
        ['a@b.c', true],              // Минимальный валидный?
    ];
}
```

**Как правильно:**
```php
public static function emailProvider() {
    return [
        'valid email' => ['test@test.com', true],
        'missing @ symbol' => ['invalid', false],
        'missing TLD' => ['user@domain', false],
        'empty string' => ['', false],
        'minimal valid' => ['a@b.c', true],
    ];
}
```

### 4. ❌ Параметризованные тесты: Смешивание сценариев

**Как выглядит:**
```php
/**
 * @dataProvider userDataProvider
 */
public function testUserOperations($operation, $data, $expected) {
    // Один тест для всего - create, update, delete
    switch($operation) {
        case 'create':
            // ...
        case 'update':
            // ...
        case 'delete':
            // ...
    }
}
```

**Как правильно:**
```php
// Отдельные тесты для разных операций
/**
 * @dataProvider createUserProvider
 */
public function testCreateUser($email, $name, $shouldSucceed) {
    // Только создание
}

/**
 * @dataProvider updateUserProvider  
 */
public function testUpdateUser($field, $value, $shouldSucceed) {
    // Только обновление
}
```

### 5. ❌ Mutation Testing: Игнорирование результатов

**Как выглядит:**
```bash
# Запустили mutation testing
vendor/bin/infection

# Результат: 60% MSI (Mutation Score Indicator)
# Реакция: "Ну и ладно, главное что тесты есть"
```

**Почему это плохо:**
- Низкий MSI означает слабые тесты
- Тесты не ловят изменения в логике
- Ложное чувство безопасности

**Как правильно:**
```php
// Анализируйте выжившие мутанты
// Например, мутант изменил > на >=
if ($age > 18) { // Мутант: if ($age >= 18)
    return true;
}

// Добавьте граничный тест
public function testExactly18YearsOld() {
    $this->assertFalse(isAdult(18));
}
```

### 6. ❌ Mutation Testing: Тестирование тривиального кода

**Как выглядит:**
```php
// Гоняем mutation testing на геттерах/сеттерах
public function getName() {
    return $this->name; // Мутации здесь бессмысленны
}
```

**Как правильно:**
- Исключите тривиальный код из mutation testing
- Фокусируйтесь на бизнес-логике
- Используйте `@infection-ignore-all` для простого кода

### 7. ❌ Property-Based Testing: Слабые свойства

**Как выглядит:**
```php
// ПЛОХО: Тестируем очевидное
public function testStringLength() {
    $this->forAll(Generator\string())
        ->then(function($str) {
            $this->assertGreaterThanOrEqual(0, strlen($str));
            // Строка всегда >= 0, бесполезный тест
        });
}
```

**Как правильно:**
```php
// Тестируем инварианты бизнес-логики
public function testDiscountNeverExceedsPrice() {
    $this->forAll(
        Generator\float(0.01, 1000000),  // price
        Generator\float(0, 100)           // discount %
    )->then(function($price, $discount) {
        $finalPrice = applyDiscount($price, $discount);
        
        $this->assertLessThanOrEqual($price, $finalPrice);
        $this->assertGreaterThanOrEqual(0, $finalPrice);
        
        // Проверяем обратимость
        if ($discount == 0) {
            $this->assertEquals($price, $finalPrice);
        }
    });
}
```

### 8. ❌ Property-Based Testing: Неправильные генераторы

**Как выглядит:**
```php
// ПЛОХО: Генерируем невалидные данные
$this->forAll(
    Generator\string() // Может сгенерировать любую строку
)->then(function($email) {
    $user = new User($email); // Упадет на невалидном email
});
```

**Как правильно:**
```php
// Создайте специализированные генераторы
public static function emailGenerator() {
    return Generator\map(
        function($name, $domain) {
            return $name . '@' . $domain . '.com';
        },
        Generator\regex('[a-z]{3,10}'),
        Generator\regex('[a-z]{3,10}')
    );
}
```

### 9. ❌ Contract Testing: Дублирование контрактов

**Как выглядит:**
```php
// Backend contract test
public function testUserApiContract() {
    $this->assertJsonStructure([
        'id', 'email', 'name'
    ], $response);
}

// Frontend contract (отдельно)
interface UserResponse {
    id: string;
    email: string;
    fullName: string; // Ой, другое имя поля!
}
```

**Как правильно:**
```yaml
# Единый источник правды - OpenAPI spec
components:
  schemas:
    User:
      type: object
      required: [id, email, name]
      properties:
        id:
          type: string
        email:
          type: string
        name:
          type: string
```

### 10. ❌ Contract Testing: Версионирование

**Как выглядит:**
```php
// Меняем контракт без версионирования
// Было: { "name": "John Doe" }
// Стало: { "firstName": "John", "lastName": "Doe" }
// Результат: Все клиенты сломались
```

**Как правильно:**
```php
// Версионированные endpoints
// v1: /api/v1/users - старый формат
// v2: /api/v2/users - новый формат

// Или поддержка обоих форматов
public function toArray() {
    return [
        'name' => $this->getFullName(),          // deprecated
        'firstName' => $this->firstName,         // new
        'lastName' => $this->lastName,           // new
    ];
}
```

### 11. ❌ Snapshot Testing: Слепое обновление

**Как выглядит:**
```bash
# Тест упал после изменения
npm test
# Snapshot не совпадает!

# Реакция: обновить не глядя
npm test -- -u
# ✅ Все тесты прошли!
```

**Почему это плохо:**
- Можно пропустить регрессию
- Snapshot становится бессмысленным
- Теряется защита от изменений

**Как правильно:**
```bash
# 1. Посмотрите diff
npm test -- --no-coverage

# 2. Проанализируйте изменения
# - Ожидаемые ли это изменения?
# - Не сломалось ли что-то?

# 3. Только потом обновляйте
npm test -- -u
```

### 12. ❌ Snapshot Testing: Огромные снапшоты

**Как выглядит:**
```javascript
// Снапшот всей страницы (5000 строк)
expect(renderPage()).toMatchSnapshot();
```

**Как правильно:**
```javascript
// Снапшоты критических частей
expect(renderHeader()).toMatchSnapshot('header');
expect(renderPriceBlock()).toMatchSnapshot('pricing');
expect(renderCTA()).toMatchSnapshot('call-to-action');
```

### 13. ❌ BDD: Технические сценарии

**Как выглядит:**
```gherkin
Feature: Database operations
  Scenario: Insert user into database
    Given database connection is established
    When I execute INSERT INTO users VALUES (...)
    Then user record exists in users table
```

**Как правильно:**
```gherkin
Feature: User registration
  Scenario: New user creates account
    Given I am on the registration page
    When I fill in my details and submit
    Then I should see a welcome message
    And I should receive a confirmation email
```

### 14. ❌ BDD: Переиспользование шагов

**Как выглядит:**
```gherkin
Scenario: Complex workflow
  Given I am logged in as admin with test data set up and permissions configured
  # Слишком много в одном шаге!
```

**Как правильно:**
```gherkin
Scenario: Admin manages users
  Given I am logged in as an admin
  And there are existing users in the system
  When I navigate to user management
  Then I should see the list of users
```

## Чек-лист правильного использования продвинутых методологий

### Test Builders
- [ ] Используются только для сложных объектов
- [ ] Иммутабельные (каждый метод возвращает новый экземпляр)
- [ ] Есть преднастроенные конфигурации (asAdmin, asGuest)
- [ ] Понятные имена методов

### Параметризованные тесты
- [ ] Каждый набор данных имеет описательное имя
- [ ] Тестируется одна функциональность
- [ ] Данные легко читаются и понимаются
- [ ] Нет смешивания разных сценариев

### Mutation Testing
- [ ] MSI > 80% для критического кода
- [ ] Анализируются выжившие мутанты
- [ ] Исключен тривиальный код
- [ ] Регулярный запуск в CI

### Property-Based Testing
- [ ] Тестируются бизнес-инварианты
- [ ] Правильные генераторы данных
- [ ] Понятные свойства
- [ ] Разумное количество итераций

### Contract Testing
- [ ] Единый источник правды (OpenAPI)
- [ ] Версионирование API
- [ ] Автоматическая генерация тестов
- [ ] Синхронизация frontend/backend

### Snapshot Testing
- [ ] Осознанное обновление снапшотов
- [ ] Небольшие, сфокусированные снапшоты
- [ ] Регулярная очистка устаревших
- [ ] Понятные имена снапшотов

### BDD
- [ ] Бизнес-язык, не технический
- [ ] Атомарные шаги
- [ ] Переиспользуемые шаги
- [ ] Фокус на поведении, не на реализации

## Золотые правила

1. **Не усложняйте там, где можно сделать просто**
2. **Методология должна помогать, а не мешать**
3. **Если тест сложнее кода - что-то не так**
4. **Качество тестов важнее количества**
5. **Понятность важнее краткости**

Помните: продвинутые методологии - это инструменты. Используйте правильный инструмент для правильной задачи! 