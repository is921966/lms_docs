# Скрипты автоматизации LMS проекта

## �� Быстрый старт

### Управление временем проекта (НОВОЕ!)
```bash
# Проверить текущую информацию о времени
python3 scripts/project-time.py

# Установить условный день
python3 scripts/project-time.py set-day 138

# Получить имя файла для отчета
python3 scripts/project-time.py filename daily
```

### Ежедневные отчеты
```bash
# Узнать информацию о текущем дне
./scripts/report.sh info

# Создать ежедневный отчет
./scripts/report.sh daily-create

# Начать день (с отслеживанием времени)
./scripts/report.sh start-day

# Завершить день (создает отчет автоматически)
./scripts/report.sh end-day
```

### Sprint отчеты
```bash
# План спринта
./scripts/report.sh sprint 29 PLAN

# Прогресс спринта
./scripts/report.sh sprint 29 PROGRESS

# Завершение спринта
./scripts/report.sh sprint-completion 29
```

## 📊 Текущая информация

На 3 июля 2025:
- **Условный день проекта**: 138
- **Календарный день**: 13 (от начала 21 июня)
- **Спринт**: 29 (день 4/5)
- **Название спринта**: Test Quality & Technical Debt

## 📁 Структура файлов

### ✅ Актуальные (рабочие) файлы:
- `project-time.py` - Централизованное управление временем проекта
- `report.sh` - Основной скрипт создания отчетов
- `time_tracker.py` - Отслеживание времени работы
- `.project-time.json` - Конфигурация текущего состояния времени

### ⚠️ Устаревшие файлы (префикс `---`):
- `---generate_report_name.py` - Заменен на `project-time.py`
- `---update_conditional_day.py` - Заменен на `project-time.py`
- `---project_day_tracker.json` - Заменен на `.project-time.json`

## 📖 Документация

- `README_FILE_NAMING.md` - Правила именования файлов
- `docs/AUTOMATED_REPORT_NAMING.md` - Детальная документация по отчетам
- `reports/methodology/TIME_MANAGEMENT_SYSTEM_v2.0.md` - Система управления временем

## 🔄 Миграция на новую систему

Если вы использовали старые скрипты:

```bash
# Было:
python3 generate_report_name.py daily

# Стало:
python3 project-time.py filename daily

# Было:
python3 update_conditional_day.py next

# Стало:
python3 project-time.py set-day 139
```

---

**Последнее обновление**: 3 июля 2025 