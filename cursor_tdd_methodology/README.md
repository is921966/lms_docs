# Test-Driven Development (TDD) Methodology for Cursor

Полный набор файлов и инструкций для внедрения обязательного TDD процесса в проекты разработки с использованием Cursor AI.

## 🚨 Главное правило

**Код без запущенных тестов = КОД НЕ СУЩЕСТВУЕТ**

## Быстрый старт

### 1. Скопируйте файлы в ваш проект

```bash
# Клонируйте или скопируйте эту папку
cp -r cursor_tdd_methodology/* /path/to/your/project/

# Или используйте отдельные файлы:
cp cursor_tdd_methodology/.cursorrules /path/to/your/project/
cp cursor_tdd_methodology/Makefile /path/to/your/project/
```

### 2. Настройте Cursor

1. Откройте проект в Cursor
2. Убедитесь, что `.cursorrules` находится в корне проекта
3. Cursor автоматически применит правила TDD

### 3. Начните с теста!

```bash
# Создайте тест
touch tests/CalculatorTest.php

# Напишите тест (см. примеры в .cursorrules)

# Запустите тест - он должен упасть!
make test-specific TEST=tests/CalculatorTest.php

# Теперь пишите код
```

## Содержимое пакета

### Основные файлы

1. **`.cursorrules`** - Правила для Cursor AI с TDD методологией
2. **`productmanager.md`** - Методология создания ТЗ для LLM-разработки
3. **`TDD_GUIDE.md`** - Подробное руководство по TDD
4. **`Makefile`** - Готовые команды для TDD workflow
5. **`templates/`** - Шаблоны тестов для разных языков
6. **`git-hooks/`** - Git hooks для автоматической проверки тестов
7. **`ci-cd/`** - Примеры настройки CI/CD с обязательными тестами

### Дополнительные материалы

- **`examples/`** - Примеры правильного TDD подхода
- **`PRODUCT_MANAGER_GUIDE.md`** - Как создавать ТЗ для LLM-разработки
- **`antipatterns.md`** - Что НЕ надо делать
- **`metrics.md`** - Как измерять успех TDD
- **`team-guide.md`** - Руководство для команды

## Создание технического задания

Перед началом разработки **ОБЯЗАТЕЛЬНО** создайте правильное техническое задание согласно `productmanager.md`. Это критически важно для LLM-разработки!

### Ключевые принципы ТЗ для LLM:
1. **Jobs-to-Be-Done** - начинайте с пользовательской "работы"
2. **BDD сценарии** - пишите в формате Gherkin (Given-When-Then)
3. **Микросервисы** - декомпозируйте по bounded contexts
4. **TDD-ready** - все acceptance criteria должны превращаться в тесты

### Структура ТЗ:
- Product Context (бизнес-ценность, метрики)
- User Stories с BDD Acceptance Criteria
- Техническая архитектура (API, БД, интеграции)
- Definition of Done с обязательными тестами

## Процесс TDD

### 1. RED (Красный) - Напишите падающий тест

```php
public function testCalculatorAddsNumbers()
{
    $calc = new Calculator();
    $this->assertEquals(4, $calc->add(2, 2));
}
```

Запустите: `make test-specific TEST=tests/CalculatorTest.php`

**Тест должен упасть!** Это хорошо.

### 2. GREEN (Зеленый) - Напишите минимальный код

```php
class Calculator
{
    public function add($a, $b)
    {
        return $a + $b;
    }
}
```

Запустите тест снова. **Теперь он должен пройти!**

### 3. REFACTOR (Рефакторинг) - Улучшите код

Только при зеленых тестах!

## Команды Makefile

```bash
# TDD workflow
make tdd                    # Показать напоминание о TDD процессе
make test-new TEST=MyTest   # Создать новый тест и запустить
make test-watch TEST=MyTest # Автозапуск теста при изменениях

# Запуск тестов
make test                   # Все тесты
make test-unit             # Только unit тесты
make test-specific TEST=... # Конкретный тест
make test-coverage         # С отчетом о покрытии

# Проверки
make test-check            # Проверить, что все тесты проходят
make coverage-check        # Проверить покрытие (должно быть >= 80%)
```

## Интеграция с IDE

### VS Code / Cursor расширения

Установите эти расширения для лучшего TDD опыта:

```json
{
  "recommendations": [
    "hbenl.vscode-test-explorer",
    "ryanluker.vscode-coverage-gutters",
    "donjayamanne.githistory",
    "eamodio.gitlens"
  ]
}
```

### Настройки

```json
{
  "testing.automaticallyOpenPeekView": "failureInVisibleDocument",
  "testing.followRunningTest": true,
  "coverage-gutters.showGutterCoverage": true,
  "coverage-gutters.showLineCoverage": true
}
```

## Git Hooks

### Автоматическая проверка перед коммитом

```bash
# Установка
cp git-hooks/pre-commit .git/hooks/
chmod +x .git/hooks/pre-commit
```

Теперь тесты будут запускаться автоматически перед каждым коммитом.

## CI/CD

### GitHub Actions

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: make test
      - name: Check coverage
        run: make coverage-check
```

### GitLab CI

```yaml
test:
  script:
    - make test
    - make coverage-check
  coverage: '/Lines:\s*\d+\.\d+%/'
```

## Метрики успеха

### Что отслеживать:

1. **Coverage** - должен быть >= 80%
2. **Test/Code Ratio** - минимум 1:1
3. **Build Time** - тесты должны выполняться < 60 сек
4. **Failed Builds** - стремиться к 0

### Команды для метрик:

```bash
make metrics          # Показать все метрики
make coverage-report  # Детальный отчет покрытия
make test-stats      # Статистика по тестам
```

## FAQ

### Q: Что если у меня legacy код без тестов?

A: Начните с новых функций - они должны разрабатываться через TDD. Для старого кода:
1. Пишите тесты при любых изменениях
2. Добавляйте тесты при исправлении багов
3. Постепенно увеличивайте покрытие

### Q: TDD замедляет разработку?

A: Только в начале. Исследования показывают:
- 15-30% больше времени на начальную разработку
- 40-80% меньше багов в продакшене
- 50% меньше времени на поддержку

### Q: Нужно ли тестировать всё?

A: Фокусируйтесь на:
- Бизнес-логике (100% покрытие)
- Публичных API (100% покрытие)
- Критических путях пользователя
- Сложных алгоритмах

Можно пропустить:
- Простые геттеры/сеттеры
- Конфигурационные файлы
- Сторонние библиотеки

## Поддержка

### Ресурсы:
- [TDD by Example - Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)
- [Growing Object-Oriented Software, Guided by Tests](https://www.amazon.com/Growing-Object-Oriented-Software-Guided-Tests/dp/0321503627)
- [Test-Driven Development in PHP](https://leanpub.com/test-driven)

### Сообщество:
- Stack Overflow: тег `[tdd]`
- Reddit: r/TDD
- Dev.to: #tdd

## Лицензия

MIT License - используйте свободно в своих проектах!

---

**Помните:** TDD - это не о тестировании, это о дизайне. Хороший тест - это спецификация вашего кода. 