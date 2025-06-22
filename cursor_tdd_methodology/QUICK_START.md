# 🚀 Quick Start: TDD за 5 минут

## Шаг 1: Скопируйте файлы (30 секунд)

```bash
# Скопируйте в корень вашего проекта
cp cursor_tdd_methodology/.cursorrules /path/to/your/project/
cp cursor_tdd_methodology/Makefile /path/to/your/project/

# Установите git hook (опционально)
cp cursor_tdd_methodology/git-hooks/pre-commit /path/to/your/project/.git/hooks/
chmod +x /path/to/your/project/.git/hooks/pre-commit
```

## Шаг 2: Откройте проект в Cursor (10 секунд)

Cursor автоматически прочитает `.cursorrules` и будет следовать TDD методологии.

## Шаг 3: Создайте первый тест (2 минуты)

### Для PHP проекта:
```bash
make test-new
# Введите: Calculator
```

Откройте `tests/Unit/CalculatorTest.php` и напишите:
```php
/** @test */
public function it_adds_two_numbers()
{
    $calc = new Calculator();
    $this->assertEquals(4, $calc->add(2, 2));
}
```

### Для JavaScript проекта:
```bash
make test-new
# Введите: Calculator
```

Откройте `tests/Calculator.test.js` и напишите:
```javascript
test('adds two numbers', () => {
  const calc = new Calculator();
  expect(calc.add(2, 2)).toBe(4);
});
```

### Для Python проекта:
```bash
make test-new
# Введите: Calculator
```

Откройте `tests/test_calculator.py` и напишите:
```python
def test_adds_two_numbers():
    calc = Calculator()
    assert calc.add(2, 2) == 4
```

## Шаг 4: Запустите тест - увидьте КРАСНЫЙ (30 секунд)

```bash
make test-specific TEST=tests/Unit/CalculatorTest.php
# или
make test-specific TEST=tests/Calculator.test.js
# или
make test-specific TEST=tests/test_calculator.py
```

**Тест упадет! Это хорошо!** 🔴

## Шаг 5: Напишите минимальный код (1 минута)

### PHP:
```php
// src/Calculator.php
class Calculator
{
    public function add($a, $b)
    {
        return $a + $b;
    }
}
```

### JavaScript:
```javascript
// src/Calculator.js
class Calculator {
  add(a, b) {
    return a + b;
  }
}
module.exports = Calculator;
```

### Python:
```python
# src/calculator.py
class Calculator:
    def add(self, a, b):
        return a + b
```

## Шаг 6: Запустите тест - увидьте ЗЕЛЕНЫЙ (30 секунд)

```bash
make test-specific TEST=tests/Unit/CalculatorTest.php
```

**Тест прошел!** 🟢

## 🎉 Поздравляем! Вы только что сделали TDD!

## Полезные команды

```bash
make tdd          # Напоминание о процессе
make test         # Запустить все тесты
make test-watch   # Автозапуск при изменениях
make coverage     # Проверить покрытие
```

## Что дальше?

1. **Добавьте еще тестов** для edge cases:
   ```javascript
   test('handles negative numbers', () => {
     expect(calc.add(-1, -1)).toBe(-2);
   });
   ```

2. **Рефакторинг** - улучшите код, тесты защитят от ошибок

3. **Повторите** для следующей функции

## Золотые правила

1. **Никогда** не пишите код без падающего теста
2. **Всегда** запускайте тест сразу после написания
3. **Пишите** минимальный код для прохождения теста
4. **Рефакторите** только при зеленых тестах

## Проблемы?

### "make: command not found"
Используйте команды напрямую:
```bash
# PHP
./vendor/bin/phpunit tests/Unit/CalculatorTest.php

# JavaScript
npm test Calculator.test.js

# Python
pytest tests/test_calculator.py
```

### "No test framework detected"
Установите тестовый фреймворк:
```bash
# PHP
composer require --dev phpunit/phpunit

# JavaScript
npm install --save-dev jest

# Python
pip install pytest
```

## Помните!

> "Код без тестов - это не код, это надежда, что всё работает" 

Начните с малого. Один тест. Один метод. Но начните СЕЙЧАС! 🚀 