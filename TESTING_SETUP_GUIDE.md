# 🧪 Руководство по настройке тестирования LMS

## 🚨 Проблема
Регулярные проблемы с запуском тестов локально из-за:
1. Отсутствия PHP на локальной машине
2. Проблем с Docker (отсутствие LDAP extension)
3. Сложности настройки окружения

## ✅ Системные решения

### Решение 1: Быстрые тесты без сборки (⭐ РЕКОМЕНДУЕТСЯ)

Самый простой и быстрый способ - использовать готовый PHP образ:

```bash
# Запустить все тесты
./test-quick.sh

# Запустить конкретный тест
./test-quick.sh tests/Unit/Competency/Domain/ValueObjects/CompetencyLevelTest.php

# Запустить все тесты в директории
./test-quick.sh tests/Unit/Competency/Domain/ValueObjects/
```

**Преимущества:**
- ✅ Не требует сборки Docker образов
- ✅ Работает сразу из коробки
- ✅ Быстрый запуск (5-10 секунд)
- ✅ Автоматически устанавливает зависимости
- ✅ Минимальные требования

### Решение 2: Упрощенное тестовое окружение

Мы создали отдельное Docker окружение специально для тестов:

```bash
# 1. Собрать тестовое окружение
make test-build

# 2. Запустить тестовые контейнеры
make test-up

# 3. Запустить все тесты
make test-run

# 4. Запустить конкретный тест
make test-run-specific TEST=tests/Unit/Competency/Domain/ValueObjects/CompetencyLevelTest.php

# 5. Остановить тестовое окружение
make test-down
```

**Преимущества:**
- ✅ Изолированное окружение только для тестов
- ✅ Быстрый запуск (минимум сервисов)
- ✅ Включены все необходимые PHP расширения
- ✅ Не конфликтует с основным окружением

### Решение 3: Локальный запуск (без Docker)

Если у вас установлен PHP локально:

```bash
# 1. Установить PHP (если нет)
# macOS:
brew install php@8.2

# Ubuntu/Debian:
sudo apt update && sudo apt install php8.2-cli php8.2-mbstring php8.2-xml

# 2. Запустить тесты локально
make test-local

# 3. Запустить конкретный тест
make test-local-specific TEST=tests/Unit/Competency/Domain/ValueObjects/CompetencyLevelTest.php
```

### Решение 4: Исправить основной Docker

Если нужно исправить основное окружение:

```bash
# Автоматическое исправление Docker
make fix-docker
```

Это команда:
1. Добавит LDAP extension в Dockerfile
2. Пересоберет контейнеры
3. Перезапустит сервисы

### Решение 5: Быстрые тесты через Docker run

Для быстрого запуска без полного окружения:

```bash
# Запустить все тесты Domain слоя
make test-domain

# Запустить тесты одного класса
make test-class CLASS=CompetencyLevel

# Запустить один тест
make test-one TEST=CompetencyLevelTest
```

## 📋 Рекомендуемый workflow для TDD

### 1. Используйте быстрый скрипт (РЕКОМЕНДУЕТСЯ)
```bash
# 1. Написать тест
vim tests/Unit/Competency/Domain/CompetencyTest.php

# 2. Запустить и увидеть красный тест (5 секунд!)
./test-quick.sh tests/Unit/Competency/Domain/CompetencyTest.php

# 3. Написать код
vim src/Competency/Domain/Competency.php

# 4. Запустить и увидеть зеленый тест (5 секунд!)
./test-quick.sh tests/Unit/Competency/Domain/CompetencyTest.php

# 5. Рефакторинг и повторный запуск
./test-quick.sh tests/Unit/Competency/Domain/
```

### 2. Альтернатива - тестовое окружение
```bash
# Подготовить тестовое окружение (один раз)
make test-build
make test-up

# Цикл разработки
make test-run-specific TEST=путь/к/тесту

# В конце дня
make test-down
```

## 🔧 Troubleshooting

### Проблема: Docker не запускается
```bash
# Проверить статус Docker
docker --version
docker ps

# Перезапустить Docker Desktop (macOS)
# Или systemctl restart docker (Linux)
```

### Проблема: test-quick.sh не работает
```bash
# Проверить права доступа
chmod +x test-quick.sh

# Проверить Docker
docker run hello-world
```

### Проблема: Composer dependencies
```bash
# Очистить кеш и переустановить
rm -rf vendor
docker run --rm -v $(pwd):/app -w /app composer:2.6 install --ignore-platform-reqs
```

## 📊 Сравнение решений

| Решение | Скорость | Надежность | Сложность настройки |
|---------|----------|------------|---------------------|
| test-quick.sh | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐ |
| Тестовое окружение | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Локальный PHP | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Основной Docker | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Docker run | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐ |

## ✅ Итоговая рекомендация

**Для ежедневной работы используйте `test-quick.sh`:**
1. Не требует настройки
2. Работает из коробки
3. Очень быстрый запуск (5-10 секунд)
4. Идеально для TDD цикла

```bash
# Это всё что нужно!
./test-quick.sh tests/Unit/Competency/Domain/CompetencyTest.php
```

## 📝 Памятка команд

```bash
# Быстрый запуск (РЕКОМЕНДУЕТСЯ)
./test-quick.sh                 # Все тесты
./test-quick.sh path/to/test    # Конкретный тест

# Тестовое окружение
make test-build          # Собрать
make test-up            # Запустить
make test-run           # Все тесты
make test-run-specific  # Конкретный тест
make test-down          # Остановить

# Локальные тесты
make test-local         # Все тесты
make test-local-specific # Конкретный тест

# Быстрые тесты
make test-domain        # Domain тесты
make test-class         # Тесты класса
make test-one          # Один тест

# Исправления
make fix-docker        # Исправить Docker
```

## 🎯 Результаты внедрения

После внедрения `test-quick.sh`:
- ✅ Время запуска тестов: 5-10 секунд (было 2-3 минуты)
- ✅ Сложность настройки: 0 (было много шагов)
- ✅ Требования: только Docker (было PHP + extensions)
- ✅ Sprint 3 тесты: 46/46 проходят успешно! 