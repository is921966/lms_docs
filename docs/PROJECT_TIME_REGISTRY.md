# Централизованная система учета времени проекта

## 📋 Описание

Централизованная система учета времени проекта решает проблему расхождения календарных дат и условных дней проекта. Все данные хранятся в PostgreSQL базе данных, что обеспечивает:

- ✅ Единую точку правды для всех временных данных
- ✅ Автоматическое заполнение календарной даты из фактического времени начала работы
- ✅ Автоматическую генерацию имени файла отчета при старте дня
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
| `calendar_date` | DATE NULL | Реальная календарная дата (автоматически из start_time) |
| `sprint_number` | INTEGER | Номер спринта |
| `sprint_day` | INTEGER | День внутри спринта (1-5) |
| `start_time` | TIMESTAMP | Время начала работы |
| `end_time` | TIMESTAMP | Время завершения работы |
| `duration_minutes` | INTEGER | Продолжительность в минутах |
| `daily_report_filename` | VARCHAR(100) | Имя файла отчета (автоматически генерируется) |

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
| `daily_report_path` | Путь к ежедневному отчету |
| `completion_report_path` | Путь к отчету завершения |
| `daily_report_filename` | Автоматически генерируемое имя файла (DAY_XXX_SUMMARY_YYYYMMDD.md) |
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
4. **Автоматически устанавливает calendar_date из start_time через триггер**

## ⚠️ Важные замечания

1. **Начало проекта**: 21 июня 2025 года (константа PROJECT_START_DATE)
2. **Автоматическое заполнение даты**: При вызове `start_day` поле `calendar_date` автоматически заполняется текущей датой из `start_time`
3. **Спринты**: По 5 дней, автоматически рассчитываются
4. **Часовой пояс**: Используется локальное время сервера
5. **NULL calendar_date**: Допускается для дней, которые еще не начаты

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
docker exec -it lms_postgres psql -U postgres -d lms

# Проверить данные
SELECT project_day, calendar_date, sprint_number, status, start_time 
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

## 🔄 Автоматическое заполнение calendar_date

С версии 2.0 поле `calendar_date` заполняется автоматически:

1. **При старте дня** (`start_day`) - берется текущая дата
2. **Через триггер БД** - при любом изменении `start_time` автоматически обновляется `calendar_date`
3. **Для существующих записей** - можно обновить через SQL:
   ```sql
   UPDATE project_time_registry 
   SET calendar_date = DATE(start_time) 
   WHERE start_time IS NOT NULL;
   ```

Это решает проблему расхождения дат, так как календарная дата всегда соответствует фактическому времени начала работы.

## 📝 Автоматическая генерация имени файла отчета

С версии 2.1 при старте дня автоматически генерируется имя файла отчета:

1. **Формат имени**: `DAY_XXX_SUMMARY_YYYYMMDD.md`
   - `XXX` - условный день проекта с ведущими нулями (001, 002, ..., 145)
   - `YYYYMMDD` - календарная дата в формате год-месяц-день

2. **Когда генерируется**:
   - Автоматически при вызове `start_day`
   - При обновлении `start_time` через триггер БД

3. **Примеры**:
   - День 143: `DAY_143_SUMMARY_20250709.md`
   - День 144: `DAY_144_SUMMARY_20250704.md`
   - День 145: `DAY_145_SUMMARY_20250704.md`

4. **SQL триггер**:
   ```sql
   -- Триггер автоматически заполняет daily_report_filename
   -- при установке start_time и calendar_date
   ```

---

*Документация обновлена в рамках Sprint 30 для автоматической генерации имен файлов* 