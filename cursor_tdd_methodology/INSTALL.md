# 📦 Установка TDD + Product Manager Methodology

## Быстрая установка (2 минуты)

### Вариант 1: Минимальный набор
```bash
# Скопируйте основные файлы
cp cursor_tdd_methodology/.cursorrules /your/project/
cp cursor_tdd_methodology/Makefile /your/project/
cp cursor_tdd_methodology/productmanager.md /your/project/

# Готово! Откройте в Cursor
```

### Вариант 2: Полная установка
```bash
# Скопируйте всю методологию
cp -r cursor_tdd_methodology /your/project/methodology

# Создайте символические ссылки в корне
ln -s methodology/.cursorrules /your/project/.cursorrules
ln -s methodology/Makefile /your/project/Makefile
```

### Вариант 3: Git submodule
```bash
cd /your/project
git submodule add https://github.com/yourteam/tdd-methodology.git methodology
cp methodology/.cursorrules .
cp methodology/Makefile .
```

## Проверка установки

```bash
# 1. Проверьте, что Cursor видит правила
ls -la .cursorrules

# 2. Проверьте Makefile
make help

# 3. Проверьте TDD процесс
make tdd
```

## Первые шаги

### 1. Создайте техническое задание
```bash
# Прочитайте руководство
cat methodology/PRODUCT_MANAGER_GUIDE.md

# Используйте шаблон из productmanager.md
```

### 2. Начните с теста
```bash
# Создайте первый тест
make test-new

# Следуйте TDD циклу
make tdd
```

### 3. Настройте git hooks
```bash
cp methodology/git-hooks/pre-commit .git/hooks/
chmod +x .git/hooks/pre-commit
```

## Структура файлов после установки

```
your-project/
├── .cursorrules          # Правила для Cursor (ссылка или копия)
├── Makefile             # Команды TDD (ссылка или копия)
├── productmanager.md    # Методология PM (опционально в корне)
├── methodology/         # Полная методология (опционально)
│   ├── TDD_GUIDE.md
│   ├── PRODUCT_MANAGER_GUIDE.md
│   ├── antipatterns.md
│   ├── templates/
│   ├── examples/
│   └── ...
├── src/                 # Ваш код
├── tests/              # Ваши тесты
└── ...
```

## Настройка команды

### Для разработчиков:
1. Прочитать `QUICK_START.md`
2. Изучить `antipatterns.md`
3. Использовать `make` команды

### Для продакт-менеджеров:
1. Изучить `productmanager.md`
2. Использовать `PRODUCT_MANAGER_GUIDE.md`
3. Создавать ТЗ по шаблону

### Для тимлидов:
1. Настроить CI/CD из `ci-cd/`
2. Следить за метриками покрытия
3. Обновлять методологию при необходимости

## Troubleshooting

### "Cursor не видит правила"
- Убедитесь, что `.cursorrules` в корне проекта
- Перезапустите Cursor

### "make: command not found"
- Установите make: `brew install make` (macOS)
- Или используйте команды напрямую из Makefile

### "Тесты не запускаются"
- Проверьте, установлен ли тестовый фреймворк
- См. `make install-tools`

## Обновление методологии

```bash
# Если используете git submodule
cd methodology
git pull origin main

# Если копировали файлы
# Скачайте новую версию и замените файлы
```

## Поддержка

- Проблемы? См. `TDD_GUIDE.md`
- Вопросы по ТЗ? См. `PRODUCT_MANAGER_GUIDE.md`
- Нашли баг? Обновите `antipatterns.md`

---

**Важно:** После установки ОБЯЗАТЕЛЬНО прочитайте `QUICK_START.md` для быстрого старта с TDD! 