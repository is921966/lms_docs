# TDD Workflow для LMS проекта

## 🎯 Основной принцип: Red → Green → Refactor

### ⚡ БЫСТРЫЙ СТАРТ (5-10 секунд на цикл!)

```bash
# 1. RED: Написать тест и увидеть ошибку
./test-quick.sh tests/Unit/User/Domain/UserTest.php

# 2. GREEN: Написать минимальный код
./test-quick.sh tests/Unit/User/Domain/UserTest.php

# 3. REFACTOR: Улучшить код
./test-quick.sh tests/Unit/User/Domain/UserTest.php
```

**Почему test-quick.sh?**
- ✅ 5-10 секунд вместо 2-3 минут
- ✅ Не требует настройки
- ✅ Работает из коробки
- ✅ Идеально для быстрых итераций

### 📋 Пошаговый процесс

#### 1. RED Phase (Красная фаза)
```bash
# Создать тест
vim tests/Unit/User/Domain/UserTest.php

# Запустить и увидеть красный (5 секунд!)
./test-quick.sh tests/Unit/User/Domain/UserTest.php
```

**Что должно произойти:**
- ❌ Тест не проходит
- ❌ Класс не существует
- ❌ Метод не найден

#### 2. GREEN Phase (Зеленая фаза)
```bash
# Создать минимальную реализацию
vim src/User/Domain/User.php

# Запустить и увидеть зеленый (5 секунд!)
./test-quick.sh tests/Unit/User/Domain/UserTest.php
```

**Правила:**
- ✅ Писать МИНИМУМ кода для прохождения теста
- ✅ Не добавлять функциональность "на будущее"
- ✅ Фокус только на текущем тесте

#### 3. REFACTOR Phase (Рефакторинг)
```bash
# Улучшить код (если нужно)
vim src/User/Domain/User.php

# Убедиться что все еще зеленый (5 секунд!)
./test-quick.sh tests/Unit/User/Domain/UserTest.php

# Запустить все тесты модуля
./test-quick.sh tests/Unit/User/Domain/
```

**Что можно делать:**
- ♻️ Удалять дублирование
- ♻️ Улучшать именование
- ♻️ Извлекать методы
- ♻️ НО тесты должны оставаться зелеными!

### 🚀 Практический пример

```bash
# Пример полного цикла для User entity

# 1. RED: Создаем тест для создания пользователя
echo '<?php
namespace Tests\Unit\User\Domain;

use PHPUnit\Framework\TestCase;
use App\User\Domain\User;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\UserId;

class UserTest extends TestCase
{
    public function test_it_creates_user_with_email(): void
    {
        $userId = UserId::generate();
        $email = new Email("test@example.com");
        
        $user = new User($userId, $email);
        
        $this->assertEquals($userId, $user->getId());
        $this->assertEquals($email, $user->getEmail());
    }
}' > tests/Unit/User/Domain/UserTest.php

# Запускаем тест - видим RED (5 секунд!)
./test-quick.sh tests/Unit/User/Domain/UserTest.php
# Error: Class 'App\User\Domain\User' not found

# 2. GREEN: Создаем минимальную реализацию
echo '<?php
namespace App\User\Domain;

use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\UserId;

class User
{
    public function __construct(
        private UserId $id,
        private Email $email
    ) {}
    
    public function getId(): UserId
    {
        return $this->id;
    }
    
    public function getEmail(): Email
    {
        return $this->email;
    }
}' > src/User/Domain/User.php

# Запускаем тест - видим GREEN (5 секунд!)
./test-quick.sh tests/Unit/User/Domain/UserTest.php
# OK (1 test, 2 assertions)

# 3. REFACTOR: Добавляем readonly и final
sed -i 's/class User/final class User/' src/User/Domain/User.php
sed -i 's/private UserId/private readonly UserId/' src/User/Domain/User.php
sed -i 's/private Email/private readonly Email/' src/User/Domain/User.php

# Проверяем что все еще GREEN (5 секунд!)
./test-quick.sh tests/Unit/User/Domain/UserTest.php
# OK (1 test, 2 assertions)
```

### 📊 Временные метрики

| Этап | Время с test-quick.sh | Время с Docker | Экономия |
|------|---------------------|----------------|----------|
| RED | 5-10 сек | 2-3 мин | 95% |
| GREEN | 5-10 сек | 2-3 мин | 95% |
| REFACTOR | 5-10 сек | 2-3 мин | 95% |
| **Полный цикл** | **15-30 сек** | **6-9 мин** | **95%** |

### 🎯 Best Practices

1. **Один тест за раз**
   - Пишите ОДИН тест
   - Делайте его зеленым
   - Только потом следующий

2. **Быстрая обратная связь**
   - Используйте `./test-quick.sh` всегда
   - Не накапливайте изменения
   - Коммитьте после каждого зеленого

3. **Маленькие шаги**
   - Тест на 1 поведение
   - Минимум кода для прохождения
   - Рефакторинг по необходимости

4. **Continuous Testing**
   ```bash
   # Запускать после КАЖДОГО изменения
   ./test-quick.sh tests/Unit/Current/Test.php
   
   # Периодически запускать все тесты модуля
   ./test-quick.sh tests/Unit/Current/
   ```

### ❌ Антипаттерны

1. **Написать все тесты сразу** - НЕТ! По одному
2. **Реализовать больше чем нужно** - НЕТ! Минимум для теста
3. **Отложить запуск тестов** - НЕТ! Запускать сразу
4. **Игнорировать красные тесты** - НЕТ! Исправить немедленно

### 🔄 Непрерывный цикл

```
┌─────────────┐
│   Написать  │
│    тест     │
└──────┬──────┘
       │ ./test-quick.sh (5 сек)
       ▼
┌─────────────┐
│   Увидеть   │
│   КРАСНЫЙ   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Написать   │
│ минимум кода│
└──────┬──────┘
       │ ./test-quick.sh (5 сек)
       ▼
┌─────────────┐
│   Увидеть   │
│   ЗЕЛЕНЫЙ   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Рефакторинг │
│ (если нужно)│
└──────┬──────┘
       │ ./test-quick.sh (5 сек)
       ▼
┌─────────────┐
│  Все еще    │
│   ЗЕЛЕНЫЙ   │
└──────┬──────┘
       │
       └────────────┐
                    │
                    ▼
            ┌───────────────┐
            │ Следующий тест│
            └───────────────┘
```

### 🎉 Результат

Следуя этому workflow с `test-quick.sh`:
- ⚡ Быстрая обратная связь (5-10 секунд)
- ✅ 100% покрытие тестами
- 🏗️ Чистая архитектура
- 📈 Высокая продуктивность
- 😊 Удовольствие от разработки!

## 🎯 Цель документа
Практическое руководство по TDD на основе реального опыта разработки LMS.

## 📋 Чеклист перед началом работы

- [ ] Docker запущен (`docker ps`)
- [ ] Контейнеры работают (`make status`)
- [ ] Зависимости установлены (`make deps`)
- [ ] Простой тест проходит (`make test-simple`)

## 🔄 Типовые сценарии

### Сценарий 1: Новый Value Object
```bash
# 1. Тест для конструктора
make test-one TEST=PhoneTest  # RED

# 2. Минимальный конструктор
# 3. Тест проходит
make test-one TEST=PhoneTest  # GREEN

# 4. Тест для валидации
# 5. Добавить валидацию
# 6. Все тесты проходят
make test-class CLASS=Phone    # ALL GREEN
```

### Сценарий 2: Новый метод в Entity
```bash
# 1. Очистить события от создания
$user = User::create(...);
$user->pullDomainEvents();  # ВАЖНО!

# 2. Тест для нового метода
# 3. Запустить конкретный тест
make test-one TEST=UserTest::testNewMethod

# 4. Реализовать метод
# 5. Проверить что не сломали другое
make test-class CLASS=User
```

### Сценарий 3: Исправление бага
```bash
# 1. Написать тест, воспроизводящий баг
make test-one TEST=BugTest  # RED - баг воспроизведен

# 2. Исправить код
# 3. Тест проходит
make test-one TEST=BugTest  # GREEN - баг исправлен

# 4. Проверить регрессию
make test-domain  # Все Domain тесты должны пройти
```

## 🚀 Команды для продуктивности

### Базовые команды
```bash
make test-one TEST=EmailTest        # Один конкретный тест
make test-class CLASS=User          # Все тесты класса
make test-domain                    # Все Domain тесты
make test-last                      # Перезапустить последний упавший
```

### Продвинутые команды
```bash
make test-watch                     # Автоматический перезапуск
make test-coverage                  # С покрытием
make test TEST=tests/Unit/User/     # Конкретная папка
```

## ⚠️ Частые ошибки и решения

### Ошибка: Call to private constructor
```php
// ❌ Неправильно
$user = new User(...);

// ✅ Правильно
$user = User::create(...);
```

### Ошибка: События домена
```php
// ❌ Неправильно - UserCreated уже в массиве
$user = User::create(...);
$events = $user->pullDomainEvents();
$this->assertCount(0, $events);

// ✅ Правильно
$user = User::create(...);
$user->pullDomainEvents();  // Очистить
$user->suspend();
$events = $user->pullDomainEvents();
$this->assertCount(1, $events);
```

### Ошибка: Неинициализированные свойства
```php
// ❌ Неправильно
private ?string $phone;

// ✅ Правильно в конструкторе
$this->phone = null;
```

## 📊 Метрики успеха

### Хорошие метрики
- ✅ Время от написания теста до зеленого статуса: < 30 минут
- ✅ Размер коммита: < 200 строк
- ✅ Частота запуска тестов: > 10 раз в час
- ✅ Покрытие новой функции: > 80%

### Плохие метрики
- ❌ Тесты не запускались > 1 часа
- ❌ Коммит > 500 строк
- ❌ Несколько красных тестов одновременно
- ❌ Покрытие < 50%

## 🎓 Правила для команды

1. **Правило 5 минут**: Запусти тест в течение 5 минут после написания
2. **Правило одного красного**: Только один тест может быть красным
3. **Правило малых шагов**: Коммит каждые 2 часа максимум
4. **Правило чистоты**: Исправь warnings сразу
5. **Правило простоты**: Начни с простейшего теста

## 💡 Советы

### Для новичков в TDD
1. Начни с теста для "счастливого пути"
2. Потом добавь тесты для валидации
3. В конце - граничные случаи

### Для ускорения работы
1. Используй `make test-one` вместо полного прогона
2. Держи тесты изолированными
3. Не мокай то, что можно использовать напрямую

### Для поддержки кода
1. Удаляй неиспользуемые тесты
2. Обновляй тесты при изменении требований
3. Документируй нестандартные подходы

## 📝 Шаблон для новой функции

```php
<?php

namespace Tests\Unit\Domain;

use Tests\TestCase;
use App\Domain\NewFeature;

class NewFeatureTest extends TestCase
{
    /**
     * @test
     */
    public function it_works_with_valid_data(): void
    {
        // Arrange
        $data = 'valid';
        
        // Act
        $feature = NewFeature::create($data);
        
        // Assert
        $this->assertEquals('valid', $feature->getData());
    }
    
    /**
     * @test
     */
    public function it_validates_input(): void
    {
        // Arrange & Act & Assert
        $this->expectException(\InvalidArgumentException::class);
        NewFeature::create('');
    }
}
```

## 🏁 Контрольный список перед коммитом

- [ ] Все новые тесты зеленые
- [ ] Старые тесты не сломаны
- [ ] Нет warnings/deprecations
- [ ] Покрытие >= 80% для нового кода
- [ ] Размер коммита < 200 строк
- [ ] Есть описание что и зачем сделано

---

**Помни**: TDD - это не про тесты, это про дизайн и обратную связь! 