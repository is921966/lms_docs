# Централизованная система учета времени проекта

## 📋 Описание

Централизованная система учета времени проекта решает проблему расхождения календарных дат и условных дней проекта. Все данные хранятся в PostgreSQL базе данных, что обеспечивает:

- ✅ Единую точку правды для всех временных данных
- ✅ Автоматический расчет календарных дат от начала проекта (21.06.2025)
- ✅ Полную историю всех дней разработки
- ✅ Детальные метрики по каждому дню
- ✅ Агрегированную статистику по спринтам и проекту

## 🚀 Быстрый старт

### 1. Запуск локальной базы данных

```bash
# Запустить PostgreSQL в Docker
docker-compose -f docker-compose.local.yml up -d

# Проверить статус
docker-compose -f docker-compose.local.yml ps
```

### 2. Инициализация базы данных

```bash
# Установить зависимости (если нужно)
pip3 install psycopg2-binary

# Инициализировать таблицы
python3 scripts/project_time_db.py init

# Мигрировать существующие данные из JSON
python3 scripts/project_time_db.py migrate
```

### 3. Использование через report.sh

Все существующие команды теперь автоматически синхронизируются с БД:

```bash
# Начать день
./scripts/report.sh start-day 143

# Завершить день  
./scripts/report.sh end-day 143

# Информация о дне
python3 scripts/project_time_db.py info 143
```

## 📊 Структура таблицы

### Основные поля:

| Поле | Тип | Описание |
|------|-----|----------|
| `project_day` | INTEGER | Условный день проекта (1, 2, 3...) |
| `calendar_date` | DATE | Реальная календарная дата |
| `sprint_number` | INTEGER | Номер спринта |
| `sprint_day` | INTEGER | День внутри спринта (1-5) |
| `start_time` | TIMESTAMP | Время начала работы |
| `end_time` | TIMESTAMP | Время завершения работы |
| `duration_minutes` | INTEGER | Продолжительность в минутах |

### Метрики разработки:

| Поле | Описание |
|------|----------|
| `commits_count` | Количество коммитов |
| `files_changed` | Количество измененных файлов |
| `lines_added` | Добавлено строк кода |
| `lines_deleted` | Удалено строк кода |
| `tests_total` | Всего тестов |
| `tests_passed` | Прошло тестов |
| `tests_failed` | Провалилось тестов |
| `tests_fixed` | Исправлено тестов |
| `test_coverage_percent` | Процент покрытия |

### Дополнительные поля:

| Поле | Описание |
|------|----------|
| `tasks_planned` | Запланировано задач |
| `tasks_completed` | Выполнено задач |
| `bugs_fixed` | Исправлено багов |
| `features_added` | Добавлено фич |
| `notes` | Примечания |
| `mood` | Продуктивность (high/normal/low) |
| `blockers` | Блокеры и проблемы |

## 🔧 Команды CLI

### Управление днями:

```bash
# Начать день
python3 scripts/project_time_db.py start 143

# Завершить день
python3 scripts/project_time_db.py end 143

# Информация о дне
python3 scripts/project_time_db.py info 143
```

### Статистика:

```bash
# Общая статистика проекта
python3 scripts/project_time_db.py stats

# Экспорт в JSON (для бэкапа)
python3 scripts/project_time_db.py export --output backup.json
```

## 📈 SQL Views

### sprint_summary
Агрегированная информация по спринтам:
```sql
SELECT * FROM sprint_summary WHERE sprint_number = 30;
```

### daily_productivity
Ежедневная продуктивность:
```sql
SELECT * FROM daily_productivity ORDER BY project_day DESC LIMIT 10;
```

## 🔄 Интеграция с отчетами

Система автоматически:
1. Синхронизирует все операции start/end через report.sh
2. Обновляет метрики из ежедневных отчетов
3. Сохраняет пути к файлам отчетов
4. Рассчитывает календарные даты от 21.06.2025

## ⚠️ Важные замечания

1. **Начало проекта**: 21 июня 2025 года (константа PROJECT_START_DATE)
2. **Формула календарного дня**: `calendar_date = PROJECT_START_DATE + (project_day - 1)`
3. **Спринты**: По 5 дней, автоматически рассчитываются
4. **Часовой пояс**: Используется локальное время сервера

## 🐛 Решение проблем

### PostgreSQL недоступен:
```bash
# Проверить статус
docker-compose -f docker-compose.local.yml ps

# Посмотреть логи
docker-compose -f docker-compose.local.yml logs postgres_local
```

### Ошибка подключения:
```bash
# Проверить переменные окружения
export DB_HOST=localhost
export DB_PORT=5432
export DB_DATABASE=lms
export DB_USERNAME=postgres
export DB_PASSWORD=secret
```

### Проверка данных:
```bash
# Подключиться к БД напрямую
docker exec -it lms_postgres_local psql -U postgres -d lms

# Проверить данные
SELECT project_day, calendar_date, sprint_number, status 
FROM project_time_registry 
ORDER BY project_day DESC 
LIMIT 10;
```

## 📝 Примеры использования

### Обновление метрик дня:
```python
from scripts.project_time_db import ProjectTimeDB

db = ProjectTimeDB()
db.update_day_info(143,
    tests_fixed=15,
    files_changed=4,
    test_coverage_percent=85.5,
    notes="Успешно завершили unit тесты",
    mood="high"
)
```

### Получение статистики спринта:
```python
sprint_stats = db.get_sprint_summary(30)
print(f"Sprint 30: {sprint_stats['total_minutes']/60:.1f} hours")
```

---

*Документация создана в рамках Sprint 30 для решения проблемы учета времени* 