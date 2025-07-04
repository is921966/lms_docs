# Автоматическая система нумерации отчетов

**Версия:** 1.0.0  
**Дата создания:** 30 июня 2025  
**Автор:** LMS Development Team

## 🎯 Проблема

Ручная нумерация дней в отчетах приводила к ошибкам:
- ❌ Неправильные номера дней (DAY_83 вместо DAY_30)
- ❌ Несоответствие реальным датам
- ❌ Путаница в хронологии проекта
- ❌ Ошибки в планировании спринтов

## ✅ Решение

Автоматическая система генерации названий отчетов на основе:
- **Реальной даты и времени**
- **Даты начала проекта** (1 июня 2025)
- **Автоматического расчета спринтов** (5 дней = 1 спринт)

## 🔧 Компоненты системы

### 1. Python скрипт: `scripts/generate_report_name.py`

**Основные функции:**
- `calculate_day_number()` - Вычисляет номер дня от начала проекта
- `generate_daily_report_name()` - Генерирует название ежедневного отчета
- `generate_sprint_report_name()` - Генерирует название sprint отчета
- `get_current_sprint_info()` - Определяет текущий спринт и день в спринте

### 2. Shell обертка: `scripts/report.sh`

**Удобные команды:**
```bash
./scripts/report.sh info              # Информация о проекте
./scripts/report.sh daily             # Название отчета
./scripts/report.sh daily-create      # Создать отчет с шаблоном
./scripts/report.sh sprint 16 PLAN    # Sprint отчет
```

## 📋 Использование

### Быстрый старт

```bash
# Узнать текущую информацию
./scripts/report.sh info

# Создать ежедневный отчет
./scripts/report.sh daily-create

# Получить название sprint отчета
./scripts/report.sh sprint 16 COMPLETION_REPORT
```

### Детальное использование

```bash
# Прямое использование Python скрипта
python3 scripts/generate_report_name.py info
python3 scripts/generate_report_name.py daily --create
python3 scripts/generate_report_name.py sprint 16 PLAN

# С указанием конкретной даты
python3 scripts/generate_report_name.py daily --date 2025-06-25
```

## 📊 Формат названий

### Ежедневные отчеты
```
DAY_30_SUMMARY_20250630.md
DAY_31_SUMMARY_20250701.md
```

**Формат:** `DAY_{номер_дня:02d}_SUMMARY_{YYYYMMDD}.md`

### Sprint отчеты
```
SPRINT_16_PLAN_20250630.md
SPRINT_16_PROGRESS_20250701.md
SPRINT_16_COMPLETION_REPORT_20250702.md
```

**Формат:** `SPRINT_{номер:02d}_{тип}_{YYYYMMDD}.md`

**Типы отчетов:**
- `PLAN` - План спринта
- `PROGRESS` - Прогресс спринта
- `COMPLETION_REPORT` - Отчет о завершении

## 🗓️ Логика расчета

### Дни проекта
- **Начало проекта:** 1 июня 2025 = День 1
- **30 июня 2025:** = День 30
- **1 июля 2025:** = День 31

### Спринты
- **Длительность спринта:** 5 рабочих дней
- **Sprint 1:** Дни 1-5
- **Sprint 6:** Дни 26-30 (текущий)
- **Sprint 7:** Дни 31-35

### День в спринте
```python
sprint_number = ((day_number - 1) // 5) + 1
day_in_sprint = ((day_number - 1) % 5) + 1
```

## 🔄 Автоматизация

### Интеграция в workflow

```bash
# В начале рабочего дня
REPORT_NAME=$(./scripts/report.sh daily)
echo "Сегодняшний отчет: $REPORT_NAME"

# Создание отчета с шаблоном
./scripts/report.sh daily-create
```

### Git hooks (опционально)

```bash
# pre-commit hook для проверки названий
#!/bin/bash
if git diff --cached --name-only | grep -q "reports/daily/DAY_.*\.md"; then
    echo "Проверка названий отчетов..."
    # Дополнительные проверки
fi
```

## 📈 Преимущества

### Надежность
- ✅ **Исключает человеческие ошибки** в нумерации
- ✅ **Автоматическая синхронизация** с реальным временем
- ✅ **Консистентность** во всех отчетах

### Удобство
- ✅ **Простые команды** для ежедневного использования
- ✅ **Автоматические шаблоны** отчетов
- ✅ **Информация о спринтах** из коробки

### Масштабируемость
- ✅ **Поддержка исторических дат** (--date параметр)
- ✅ **Расширяемость** для новых типов отчетов
- ✅ **Интеграция с CI/CD** возможна

## 🔧 Настройка

### Требования
- Python 3.6+
- Unix-like система (macOS, Linux)
- Права на выполнение для shell скриптов

### Установка
```bash
# Сделать скрипты исполняемыми
chmod +x scripts/report.sh
chmod +x scripts/generate_report_name.py

# Проверить работу
./scripts/report.sh info
```

## 📝 Примеры вывода

### Информация о проекте
```
Текущая дата: 2025-06-30
День проекта: 30
Спринт: 6
День в спринте: 5/5

Название ежедневного отчета: DAY_30_SUMMARY_20250630.md
```

### Создание отчета
```
DAY_30_SUMMARY_20250630.md
Создан файл: /Users/ishirokov/lms_docs/reports/daily/DAY_30_SUMMARY_20250630.md
```

## 🚀 Будущие улучшения

### Планируемые функции
- [ ] **Автоматическое заполнение** метаданных в отчетах
- [ ] **Интеграция с календарем** для учета выходных
- [ ] **Уведомления** о необходимости создания отчета
- [ ] **Валидация** существующих отчетов
- [ ] **Экспорт** в различные форматы

### Интеграции
- [ ] **GitHub Actions** для автоматического создания отчетов
- [ ] **Slack уведомления** о новых отчетах
- [ ] **Dashboard** с визуализацией прогресса

## 📞 Поддержка

При проблемах с системой:
1. Проверьте права на выполнение скриптов
2. Убедитесь в наличии Python 3.6+
3. Проверьте структуру папок reports/
4. Обратитесь к документации или команде разработки

---

**Примечание:** Эта система полностью заменяет ручную нумерацию отчетов и должна использоваться для всех новых отчетов начиная с 30 июня 2025. 