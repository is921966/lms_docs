# Руководство по запуску и проверке тестов

## 🚨 КРИТИЧЕСКИ ВАЖНО

**Код без запущенных тестов = КОД НЕ СУЩЕСТВУЕТ**

См. [ОБЯЗАТЕЛЬНОЕ РУКОВОДСТВО ПО TDD](technical_requirements/TDD_MANDATORY_GUIDE.md) для полного понимания процесса разработки.

## ⚠️ Важное предупреждение о текущем состоянии

**Тесты были написаны, но НЕ запускались!** Это антипаттерн, который мы исправляем. Данное руководство поможет настроить окружение и запустить тесты.

## Новое правило разработки

С этого момента:
1. **Сначала тест** → запуск → ошибка
2. **Затем код** → запуск → успех
3. **Рефакторинг** → запуск → успех
4. **Только потом коммит**

## Шаг 1: Подготовка окружения

### 1.1 Запустите Docker контейнеры
```bash
make up
# или
docker-compose up -d
```

### 1.2 Установите зависимости и создайте тестовую БД
```bash
make test-setup
```

Эта команда выполнит:
- `composer install` - установка всех PHP зависимостей
- Создание базы данных `lms_test`

### 1.3 Проверьте, что PHPUnit установлен
```bash
docker-compose exec app ./vendor/bin/phpunit --version
```

Ожидаемый вывод:
```
PHPUnit 10.x.x by Sebastian Bergmann and contributors.
```

## Шаг 2: Проверка простейшего теста

### 2.1 Запустите тест проверки
```bash
make test-simple
```

Если этот тест проходит, значит базовая настройка работает.

## Шаг 3: Проблемы, которые нужно исправить

### 3.1 Проверка структуры namespaces

Наши тесты используют namespace `Tests\`, но файлы могут не соответствовать PSR-4:

```bash
# Проверьте автозагрузку
docker-compose exec app composer dump-autoload
```

### 3.2 Создайте минимальный рабочий тест

Создайте файл `tests/WorkingTest.php`:

```php
<?php

namespace Tests;

use PHPUnit\Framework\TestCase;

class WorkingTest extends TestCase
{
    public function testBasicAssertion(): void
    {
        $this->assertTrue(true);
    }
    
    public function testBasicMath(): void
    {
        $this->assertEquals(4, 2 + 2);
    }
}
```

Запустите его:
```bash
docker-compose exec app ./vendor/bin/phpunit tests/WorkingTest.php
```

## Шаг 4: Исправление существующих тестов

### 4.1 Проблемы в TestCase.php

Файл `tests/TestCase.php` может иметь проблемы с Faker. Исправьте:

```php
<?php

namespace Tests;

use PHPUnit\Framework\TestCase as BaseTestCase;
use Faker\Factory as Faker;

abstract class TestCase extends BaseTestCase
{
    protected $faker;
    
    protected function setUp(): void
    {
        parent::setUp();
        $this->faker = Faker::create();
    }
}
```

### 4.2 Проблемы с путями и классами

Многие тесты ссылаются на классы, которые могут не существовать:
- `App\User\Domain\User`
- `App\User\Domain\ValueObjects\Email`
- и т.д.

Проверьте, что эти файлы существуют и namespace правильный.

## Шаг 5: Запуск конкретных тестов

### 5.1 Попробуйте запустить unit тесты по одному

```bash
# EmailTest
docker-compose exec app ./vendor/bin/phpunit tests/Unit/User/Domain/ValueObjects/EmailTest.php

# Если не работает, проверьте ошибки и исправьте
```

### 5.2 Типичные ошибки и решения

#### Ошибка: Class not found
```
Fatal error: Class 'App\User\Domain\ValueObjects\Email' not found
```
**Решение**: Проверьте, что файл существует и namespace правильный

#### Ошибка: Call to undefined method
```
Error: Call to undefined method Tests\TestCase::faker()
```
**Решение**: Исправьте TestCase.php как показано выше

#### Ошибка: Cannot instantiate abstract class
```
Error: Cannot instantiate abstract class
```
**Решение**: Проверьте, что тестовый класс не abstract

## Шаг 6: Отладка тестов

### 6.1 Включите подробный вывод
```bash
docker-compose exec app ./vendor/bin/phpunit --debug tests/Unit/User/Domain/ValueObjects/EmailTest.php
```

### 6.2 Запустите с остановкой на первой ошибке
```bash
docker-compose exec app ./vendor/bin/phpunit --stop-on-failure tests/Unit/
```

## Шаг 7: Постепенное исправление

### План действий:
1. **Начните с самого простого теста** (EmailTest или PasswordTest)
2. **Исправьте ошибки** в этом тесте
3. **Убедитесь, что он проходит**
4. **Переходите к следующему**

### Пример исправления EmailTest:

```bash
# 1. Запустите тест
docker-compose exec app ./vendor/bin/phpunit tests/Unit/User/Domain/ValueObjects/EmailTest.php

# 2. Если ошибка "Class Email not found", создайте заглушку:
mkdir -p src/User/Domain/ValueObjects
echo "<?php namespace App\User\Domain\ValueObjects; class Email { private \$value; public function __construct(string \$value) { \$this->value = \$value; } public function getValue(): string { return \$this->value; } }" > src/User/Domain/ValueObjects/Email.php

# 3. Запустите тест снова
docker-compose exec app ./vendor/bin/phpunit tests/Unit/User/Domain/ValueObjects/EmailTest.php
```

## Шаг 8: Когда все тесты заработают

### 8.1 Запустите все тесты
```bash
make test
```

### 8.2 Проверьте покрытие
```bash
make test-coverage
```

### 8.3 Запустите по категориям
```bash
make test-unit        # Только unit тесты
make test-integration # Только integration тесты
make test-feature     # Только feature тесты
```

## Важные замечания

1. **НЕ пытайтесь исправить все тесты сразу** - это приведет к хаосу
2. **Фокусируйтесь на одном тесте** за раз
3. **Коммитьте после каждого исправленного теста**
4. **Если тест слишком сложный** - упростите или перепишите
5. **Помните**: неработающий тест хуже, чем отсутствие теста

## Ожидаемые проблемы

1. **Многие классы Domain не существуют** - нужно их создать
2. **Mockery может не работать** - замените на PHPUnit mocks
3. **Integration тесты требуют реальную БД** - убедитесь, что она создана
4. **Feature тесты требуют Slim** - проверьте, что он установлен

## Следующие шаги

После того, как хотя бы несколько тестов заработают:
1. Удалите нерабочие тесты
2. Перепишите их с нуля, используя TDD
3. Запускайте тесты после каждого изменения
4. Настройте CI/CD для автоматического запуска

## Вывод

Да, текущие тесты - это "фантазия", а не реальные тесты. Но это исправимо. Главное - начать с малого и постепенно двигаться вперед. 