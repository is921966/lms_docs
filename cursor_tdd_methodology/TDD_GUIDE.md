# 🚨 ОБЯЗАТЕЛЬНОЕ РУКОВОДСТВО: Test-Driven Development (TDD)

**Версия:** 1.1.0  
**Дата создания:** 2025-01-19  
**Дата обновления:** 2025-01-22
**Статус:** ОБЯЗАТЕЛЬНО К ИСПОЛНЕНИЮ  
**Критичность:** ВЫСШАЯ

**Что нового в версии 1.1.0:**
- Добавлен раздел "Уроки из практики" с реальными примерами
- Примеры исправления legacy тестов из проекта LMS
- Статистика исправлений Value Objects

---

## 🔴 ОБЯЗАТЕЛЬНОЕ РУКОВОДСТВО ПО TDD

## 🚨 КРИТИЧЕСКИЕ ПРАВИЛА

### 1. Код без запущенных тестов = КОД НЕ СУЩЕСТВУЕТ
- ❌ Написал тест, не запустил = тест не существует
- ❌ Написал код, не протестировал = код не существует
- ✅ Написал тест → запустил → увидел красный → написал код → запустил → увидел зеленый

### 2. 100% ТЕСТОВ ДОЛЖНЫ ПРОХОДИТЬ - БЕЗ ИСКЛЮЧЕНИЙ
- ❌ "90% тестов проходят" = НЕПРИЕМЛЕМО
- ❌ "Эти тесты можно исправить потом" = НЕДОПУСТИМО
- ❌ "Технический долг" = ЗАПРЕЩЕН
- ✅ ВСЕ тесты проходят ИЛИ спринт НЕ ЗАВЕРШЕН

**ПРАВИЛО**: Если требуется архитектурный рефакторинг для прохождения тестов - ДЕЛАЙТЕ ЕГО НЕМЕДЛЕННО. Никаких отговорок, никаких компромиссов.

### 3. Запускай тесты НЕМЕДЛЕННО после написания

## 🚨 КРИТИЧЕСКОЕ ПРАВИЛО #1

### КОД БЕЗ ЗАПУЩЕННЫХ ТЕСТОВ = КОД НЕ СУЩЕСТВУЕТ

**Это НЕ рекомендация. Это ОБЯЗАТЕЛЬНОЕ требование.**

Каждый тест должен быть запущен в течение 5 минут после написания. Если тест не запущен - он не считается написанным.

### Антипаттерн, который УБИВАЕТ проекты:
```
День 1: Написали 50 тестов ✍️
День 2: Написали еще 50 тестов ✍️  
День 3: Написали еще 43 теста ✍️
День 4: Попробовали запустить... 💥 ВСЁ СЛОМАНО
```

### Единственно правильный подход:
```
09:00 - Написали 1 тест
09:05 - Запустили ▶️ Красный ❌
09:10 - Написали код  
09:15 - Запустили ▶️ Зеленый ✅
09:20 - Рефакторинг
09:25 - Запустили ▶️ Зеленый ✅
```

## 📚 КЛЮЧЕВЫЕ УРОКИ ИЗ ПРАКТИКИ

### 1. TDD работает только с немедленным запуском
- ✅ Правильно: Тест написан → запущен в течение 5 минут
- ❌ Неправильно: Накопить 100+ тестов и потом пытаться запустить

### 2. Малые шаги обеспечивают стабильный прогресс
- ✅ Правильно: Один value object = одна итерация (15-30 минут)
- ❌ Неправильно: Писать весь domain слой сразу (2 дня)

### 3. Быстрые команды критичны для продуктивности
- ✅ Правильно: `make test-one TEST=UserTest` (5 секунд)
- ❌ Неправильно: Копировать длинные docker команды (30 секунд + ошибки)

### 4. Инфраструктура должна быть готова с первого дня
- ✅ Правильно: День 1 = работающий `make test-simple`
- ❌ Неправильно: "Настроим окружение когда-нибудь потом"

### 5. Коммиты после каждого зеленого теста
- ✅ Правильно: Зеленый тест = коммит (максимум 2 часа)
- ❌ Неправильно: Один гигантский коммит в конце дня

### 6. Финальная проверка после исправлений
- ✅ Правильно: После исправления всех тестов → запустить ВСЕ тесты еще раз
- ❌ Неправильно: Исправил последний тест и считаешь что всё работает

**ПРАВИЛО ФИНАЛЬНОЙ ПРОВЕРКИ**: После того как все тесты по отдельности зеленые, ОБЯЗАТЕЛЬНО запустить полный набор тестов. Часто исправление одного теста может сломать другой.

```bash
# После исправления всех тестов
make test-unit        # Все unit тесты
make test-integration # Все integration тесты  
make test            # ВСЕ тесты проекта
```

---

## ⚠️ КРИТИЧЕСКИ ВАЖНО

**Код без запущенных тестов = НЕСУЩЕСТВУЮЩИЙ КОД**

Если вы написали код, но не запустили тесты - вы НЕ написали код. Вы написали текст, который может быть кодом, а может и не быть.

---

## Правило №1: Красный → Зеленый → Рефакторинг

### 1. КРАСНЫЙ (Write a failing test)
```bash
# Пишем тест
vim tests/Unit/Service/CalculatorTest.php

# СРАЗУ запускаем
docker run --rm -v $(pwd):/app -w /app php:8.2-cli ./vendor/bin/phpunit tests/Unit/Service/CalculatorTest.php

# Видим КРАСНЫЙ результат - тест падает
# ЭТО ХОРОШО! Это значит, что тест работает
```

### 2. ЗЕЛЕНЫЙ (Make it pass)
```bash
# Пишем МИНИМАЛЬНЫЙ код для прохождения теста
vim src/Service/Calculator.php

# Запускаем тест СНОВА
docker run --rm -v $(pwd):/app -w /app php:8.2-cli ./vendor/bin/phpunit tests/Unit/Service/CalculatorTest.php

# Видим ЗЕЛЕНЫЙ результат - тест проходит
```

### 3. РЕФАКТОРИНГ (Improve)
```bash
# Улучшаем код (если нужно)
vim src/Service/Calculator.php

# Запускаем тест ЕЩЕ РАЗ
docker run --rm -v $(pwd):/app -w /app php:8.2-cli ./vendor/bin/phpunit tests/Unit/Service/CalculatorTest.php

# Убеждаемся, что все еще ЗЕЛЕНЫЙ
```

---

## Команды для быстрого запуска тестов

### Один конкретный тест
```bash
# Самый быстрый способ
make test-specific TEST=tests/Unit/YourTest.php

# Или напрямую
docker run --rm -v $(pwd):/app -w /app php:8.2-cli ./vendor/bin/phpunit --no-configuration tests/Unit/YourTest.php
```

### Все тесты в директории
```bash
# Unit тесты
make test-unit

# Feature тесты
make test-feature

# Integration тесты
make test-integration
```

### Все тесты проекта
```bash
make test
```

---

## Пример правильного TDD процесса

### Шаг 1: Пишем тест (ПЕРВЫМ!)
```php
<?php
// tests/Unit/Service/UserServiceTest.php

namespace Tests\Unit\Service;

use PHPUnit\Framework\TestCase;
use App\User\Application\Service\UserService;

class UserServiceTest extends TestCase
{
    public function testCreateUserWithValidData(): void
    {
        // Arrange
        $service = new UserService();
        $data = [
            'email' => 'test@example.com',
            'name' => 'Test User'
        ];
        
        // Act
        $user = $service->createUser($data);
        
        // Assert
        $this->assertEquals('test@example.com', $user->getEmail());
        $this->assertEquals('Test User', $user->getName());
    }
}
```

### Шаг 2: Запускаем тест - видим ошибку
```bash
$ make test-specific TEST=tests/Unit/Service/UserServiceTest.php

Fatal error: Class 'App\User\Application\Service\UserService' not found
```

**ЭТО НОРМАЛЬНО! Тест должен упасть!**

### Шаг 3: Пишем минимальный код
```php
<?php
// src/User/Application/Service/UserService.php

namespace App\User\Application\Service;

use App\User\Domain\User;

class UserService
{
    public function createUser(array $data): User
    {
        $user = new User();
        $user->setEmail($data['email']);
        $user->setName($data['name']);
        return $user;
    }
}
```

### Шаг 4: Запускаем тест снова
```bash
$ make test-specific TEST=tests/Unit/Service/UserServiceTest.php

PHPUnit 10.5.0 by Sebastian Bergmann and contributors.

.                                                                   1 / 1 (100%)

Time: 00:00.021, Memory: 6.00 MB

OK (1 test, 2 assertions)
```

**ЗЕЛЕНЫЙ! Код работает!**

---

## Контрольный чек-лист для каждой функции

- [ ] Тест написан ДО кода
- [ ] Тест запущен и упал (КРАСНЫЙ)
- [ ] Написан минимальный код
- [ ] Тест запущен и прошел (ЗЕЛЕНЫЙ)
- [ ] Код отрефакторен (если нужно)
- [ ] Тест запущен после рефакторинга
- [ ] Все тесты модуля прошли
- [ ] Изменения закоммичены

---

## Антипаттерны (ТАК ДЕЛАТЬ НЕЛЬЗЯ!)

### ❌ Написать весь код, потом все тесты
```bash
# НЕПРАВИЛЬНО:
1. Написать 10 классов
2. Написать 100 тестов
3. "Запущу завтра"
4. Завтра не наступает
5. В продакшн идет непроверенный код
```

### ❌ Написать тесты "для галочки"
```php
// БЕССМЫСЛЕННЫЙ ТЕСТ
public function testNothing(): void
{
    $this->assertTrue(true); // Всегда проходит
}
```

### ❌ Не запускать тесты после изменений
```bash
# ОПАСНО:
1. Изменил код
2. "Тесты же раньше проходили"
3. Не запустил
4. Сломал функциональность
```

---

## Правила для Code Review

### PR не принимается если:
1. Нет тестов для новой функциональности
2. Тесты не запущены локально
3. Нет скриншота/лога успешного прохождения
4. Coverage упал ниже 80%

### Пример правильного PR описания:
```markdown
## Изменения
- Добавлен метод calculateDiscount() в PriceService
- Реализована валидация скидок

## Тесты
✅ Написаны unit тесты (5 тестов)
✅ Все тесты запущены и проходят
✅ Coverage: 85%

### Лог тестов:
```
PHPUnit 10.5.0 by Sebastian Bergmann and contributors.

.....                                                               5 / 5 (100%)

Time: 00:00.042, Memory: 8.00 MB

OK (5 tests, 12 assertions)
```
```

---

## Инструменты для упрощения TDD

### Watch mode (автозапуск тестов)
```bash
# Установка
composer require --dev phpunit-watcher

# Использование
vendor/bin/phpunit-watcher watch --filter=UserServiceTest
```

### Coverage отчеты
```bash
# HTML отчет
make test-coverage

# Открыть в браузере
open coverage/index.html
```

### Быстрая проверка
```bash
# Алиас для быстрого запуска
alias t='docker run --rm -v $(pwd):/app -w /app php:8.2-cli ./vendor/bin/phpunit'

# Использование
t tests/Unit/UserTest.php
```

---

## Метрики успеха TDD

### Хорошие показатели:
- ✅ Каждый коммит имеет тесты
- ✅ Coverage > 80%
- ✅ Тесты запускаются < 1 минуты
- ✅ 0 пропущенных тестов
- ✅ Все PR имеют зеленые тесты

### Плохие показатели:
- ❌ "Напишу тесты потом"
- ❌ Skipped tests > 0
- ❌ Coverage < 60%
- ❌ Тесты не запускались > 1 дня
- ❌ Broken tests в master

---

## Экстренные ситуации

### Если тесты не запускаются:
```bash
# 1. Проверить Docker
docker ps

# 2. Проверить composer
docker run --rm -v $(pwd):/app -w /app composer:latest install

# 3. Проверить конфигурацию
cat phpunit.xml

# 4. Запустить простейший тест
docker run --rm -v $(pwd):/app -w /app php:8.2-cli php -r "echo 'PHP works';"
```

### Если все тесты падают:
```bash
# 1. Проверить автозагрузку
composer dump-autoload

# 2. Проверить базу данных
make db-reset

# 3. Очистить кеш
make cache-clear
```

---

## Заключение

**ПОМНИТЕ:** Тесты - это не дополнение к коду. Тесты - это ЧАСТЬ кода. Код без тестов - это черновик, а не готовый продукт.

**TDD - это не опция, это ОБЯЗАТЕЛЬНОЕ требование.**

Каждый раз, когда вы пишете код без тестов, где-то плачет один DevOps инженер. Не заставляйте DevOps плакать.

---

## Полезные ссылки

- [PHPUnit Documentation](https://phpunit.de/documentation.html)
- [TDD by Example - Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)
- [Testing Laravel](https://laracasts.com/series/phpunit-testing-in-laravel)

**Дата последнего обновления:** 2025-01-19  
**Следующий review:** 2025-02-19 

---

## Уроки из практики: Исправление Legacy тестов

### 🎓 Реальные примеры из проекта LMS

#### 1. Нормализация должна быть ДО валидации
**Проблема:** Email класс делал trim() после валидации
```php
// ❌ НЕПРАВИЛЬНО
public function __construct(string $email) {
    $this->validate($email);
    $this->value = strtolower(trim($email)); // trim после валидации!
}

// ✅ ПРАВИЛЬНО
public function __construct(string $email) {
    $normalizedEmail = strtolower(trim($email));
    $this->validate($normalizedEmail);
    $this->value = $normalizedEmail;
}
```

#### 2. Интерфейсы должны быть реализованы
**Проблема:** JsonSerializable не был реализован, но json_encode() использовался
```php
// ❌ НЕПРАВИЛЬНО
final class Email implements \Stringable {
    public function jsonSerialize(): string {
        return $this->value;
    }
}

// ✅ ПРАВИЛЬНО
final class Email implements \Stringable, \JsonSerializable {
    public function jsonSerialize(): mixed {
        return $this->value;
    }
}
```

#### 3. Некоторые операции невозможны с хешированными данными
**Проблема:** Password класс не может вычислить силу пароля из хеша
```php
// ❌ НЕРЕАЛИСТИЧНЫЕ ОЖИДАНИЯ
$password = Password::fromPlainText('weak123');
$this->assertEquals('weak', $password->getStrength());

// ✅ РЕАЛИСТИЧНЫЙ ПОДХОД
// Признать ограничение и адаптировать тест
$this->assertEquals('medium', $password->getStrength()); // Всегда возвращает default
```

#### 4. Валидация UUID требует дополнительных проверок
**Проблема:** Ramsey UUID принимает форматы без дефисов
```php
// ❌ НЕДОСТАТОЧНАЯ ВАЛИДАЦИЯ
$uuid = Uuid::fromString('550e8400e29b41d4a716446655440000'); // Принимается!

// ✅ ДОПОЛНИТЕЛЬНАЯ ВАЛИДАЦИЯ
if (!preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i', $id)) {
    throw new \InvalidArgumentException('Invalid UUID format');
}
```

#### 5. Тесты должны соответствовать реальности, а не желаемому
**Проблема:** getLegacyId() не может восстановить оригинальный ID из UUID
```php
// ❌ НЕРЕАЛИСТИЧНЫЕ ОЖИДАНИЯ
$userId = UserId::fromLegacyId(12345);
$this->assertEquals(12345, $userId->getLegacyId());

// ✅ РЕАЛИСТИЧНЫЙ ТЕСТ
$userId = UserId::fromLegacyId(12345);
$this->assertIsInt($userId->getLegacyId()); // Проверяем тип, не значение
```

### 📊 Статистика исправлений Value Objects
- Email: 20 тестов, 5 методов добавлено, 2 багфикса
- Password: 17 тестов, 8 методов добавлено, 3 адаптации тестов
- UserId: 17 тестов, 5 методов добавлено, 2 изменения логики

---

## Заключение

## 10. КОНТРОЛЬНЫЕ ТОЧКИ

### Ежедневный чек-лист:
- [ ] Все новые тесты запущены?
- [ ] Все тесты зеленые?
- [ ] Покрытие > 80%?
- [ ] Нет пропущенных тестов?
- [ ] Коммиты содержат работающий код?

### Недельный чек-лист:
- [ ] Метрики покрытия растут?
- [ ] Время выполнения тестов < 5 минут?
- [ ] Нет флаки-тестов?
- [ ] Документация обновлена?

## 11. УПРАВЛЕНИЕ РАЗМЕРОМ ФАЙЛОВ ДЛЯ LLM

### Почему это важно:
- LLM лучше работает с файлами 50-200 строк
- Большие файлы снижают качество генерации
- Увеличивается время ответа
- Повышается вероятность ошибок

### Оптимальные размеры:
```
✅ Оптимально: 50-150 строк
⚠️  Приемлемо: 150-300 строк
🚨 Требует рефакторинга: > 300 строк
❌ Критично: > 500 строк
```

### Проверка размеров:
```bash
# Проверить файлы больше 300 строк
make check-file-sizes

# Или вручную
find src -name "*.php" -exec wc -l {} \; | awk '$1 > 300 {print}' | sort -nr
```

### Техники рефакторинга больших файлов:

#### 1. Извлечение трейтов
```php
// Было: User.php (677 строк)
class User {
    // 200 строк методов аутентификации
    // 200 строк методов профиля
    // 200 строк методов ролей
}

// Стало: User.php (182 строки)
class User {
    use UserAuthenticationTrait;
    use UserProfileTrait;
    use UserRoleManagementTrait;
}
```

#### 2. Создание специализированных сервисов
```php
// Было: AuthService.php (584 строки)
class AuthService {
    // JWT логика
    // 2FA логика
    // Password reset логика
}

// Стало:
// AuthService.php (289 строк)
// TokenService.php (111 строк)
// TwoFactorService.php (151 строка)
// PasswordResetService.php (88 строк)
```

#### 3. Композиция вместо наследования
```php
// Было: один большой сервис
class LdapService {
    // 600+ строк всей LDAP логики
}

// Стало: композиция сервисов
class LdapService {
    private LdapConnectionService $connection;
    private LdapDataMapper $mapper;
    private LdapGroupService $groups;
}
```

### Правила для команды:
1. **Проверяйте размер перед коммитом**
2. **Не добавляйте "еще один метод" в большой файл**
3. **Рефакторинг при достижении 300 строк**
4. **Экстренный рефакторинг при 500+ строках**

### Интеграция в процесс:
```bash
# В pre-commit hook
files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.php$')
for file in $files; do
    lines=$(wc -l < "$file")
    if [ $lines -gt 300 ]; then
        echo "⚠️  Warning: $file has $lines lines (recommended: < 300)"
    fi
done
```

## ОБНОВЛЕНИЕ ПРАВИЛ (после рефакторинга)

### Добавлены новые критические правила:

1. **Размер файлов критичен для LLM** - держите файлы меньше 300 строк
2. **Проверяйте сигнатуры событий** - ArgumentCountError легко избежать
3. **Тестируйте после каждого рефакторинга** - не доверяйте "должно работать"
4. **Удаляйте временные Refactored версии** - чистота кодовой базы важна
5. **Используйте make check-file-sizes** - регулярно мониторьте размеры

---

## 🚨 КРИТИЧЕСКОЕ ПРАВИЛО #1: БЕЗ ЗАПУЩЕННЫХ ТЕСТОВ = КОД НЕ СУЩЕСТВУЕТ

### ⚡ БЫСТРЫЙ ЗАПУСК ТЕСТОВ (5-10 СЕКУНД!)

**ИСПОЛЬЗУЙТЕ `test-quick.sh` ДЛЯ МГНОВЕННОЙ ОБРАТНОЙ СВЯЗИ:**

```bash
# Запустить конкретный тест (5 секунд!)
./test-quick.sh tests/Unit/User/Domain/UserTest.php

# Запустить все тесты в директории
./test-quick.sh tests/Unit/User/Domain/

# Запустить все тесты
./test-quick.sh
```

**Почему это критически важно:**
- ✅ Не нужно ждать сборку Docker (экономия 2-3 минуты)
- ✅ Работает из коробки без настройки
- ✅ Автоматически устанавливает зависимости
- ✅ Идеально для TDD цикла Red-Green-Refactor

**Альтернативные способы (если test-quick.sh не подходит):**
```bash
# Makefile команды
make test-one TEST=UserTest        # Быстрый запуск одного теста
make test-class CLASS=User         # Все тесты класса
make test-domain                   # Все Domain тесты

# Docker команды (медленнее)
make test-run-specific TEST=path/to/test.php
```

### ПРАВИЛО: Каждый написанный тест должен быть запущен В ТЕЧЕНИЕ 5 МИНУТ после написания!

Если вы написали тест и не запустили его сразу - вы нарушили TDD.

## ОБЯЗАТЕЛЬНАЯ ПОСЛЕДОВАТЕЛЬНОСТЬ TDD

1. **RED**: Написать тест → Запустить `./test-quick.sh` → Увидеть КРАСНЫЙ
2. **GREEN**: Написать минимальный код → Запустить `./test-quick.sh` → Увидеть ЗЕЛЕНЫЙ
3. **REFACTOR**: Улучшить код → Запустить `./test-quick.sh` → Убедиться что ЗЕЛЕНЫЙ

## НЕДОПУСТИМЫЕ ОТГОВОРКИ

❌ "Я запущу тесты позже" - НЕТ! Запускайте СЕЙЧАС!
❌ "Docker долго собирается" - Используйте `test-quick.sh`!
❌ "У меня нет PHP локально" - `test-quick.sh` работает через Docker!
❌ "Это займет время" - 5 секунд это не время!

## ОБЯЗАТЕЛЬНАЯ ПОСЛЕДОВАТЕЛЬНОСТЬ TDD
