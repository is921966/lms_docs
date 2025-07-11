# Система автоматизированного учета времени и отчетности (LMS)

## 📋 Обзор

Система автоматического отслеживания времени начала/завершения дней и спринтов с автоматическим вычислением продолжительности и созданием отчетов.

## 🛠️ Компоненты системы

### 1. TimeTracker (`scripts/time_tracker.py`)
Основной класс для отслеживания времени:
- Хранение данных в JSON формате
- Автоматический расчет номеров дней и спринтов
- Вычисление продолжительности
- Поддержка истории проекта

### 2. Report Generator (`scripts/report.sh`)
Интегрированная система создания отчетов:
- Автоматическое создание отчетов о завершении дня
- Создание отчетов о завершении спринта
- Интеграция с существующими скриптами

### 3. Simple Demo (`scripts/simple_time_demo.py`)
Упрощенная демонстрация возможностей:
- Создание шаблонов отчетов
- Демонстрация расчета времени
- Тестирование функциональности

## 🚀 Быстрый старт

### Начало дня разработки:
```bash
./scripts/report.sh start-day
```

### Завершение дня разработки:
```bash
./scripts/report.sh end-day
```

### Получение информации о текущем дне:
```bash
./scripts/report.sh time-info
```

### Статистика проекта:
```bash
./scripts/report.sh project-stats
```

## 📊 Основные команды

### TimeTracker команды:
```bash
# Начать день
python3 scripts/time_tracker.py start-day [номер_дня]

# Завершить день
python3 scripts/time_tracker.py end-day [номер_дня]

# Информация о дне
python3 scripts/time_tracker.py day-info [номер_дня]

# Информация о спринте
python3 scripts/time_tracker.py sprint-info [номер_спринта]

# Общая статистика
python3 scripts/time_tracker.py project-stats
```

### Report.sh команды:
```bash
# Управление временем
./scripts/report.sh start-day [день]          # Начать день
./scripts/report.sh end-day [день]            # Завершить день
./scripts/report.sh daily-completion [день]   # Отчет о завершении дня
./scripts/report.sh sprint-completion <спринт> # Отчет о завершении спринта

# Информация
./scripts/report.sh time-info [день]          # Информация о дне
./scripts/report.sh sprint-info [спринт]      # Информация о спринте
./scripts/report.sh project-stats             # Статистика проекта

# Существующая функциональность
./scripts/report.sh daily-create              # Создать ежедневный отчет
./scripts/report.sh sprint <номер> <тип>      # Создать sprint отчет
./scripts/report.sh info                      # Текущая информация
```

## 📁 Структура данных

### JSON файл (`scripts/time_tracking.json`):
```json
{
  "days": {
    "day_31": {
      "day_number": 31,
      "sprint_number": 7,
      "day_in_sprint": 1,
      "start_time": "2025-07-01T08:07:53",
      "end_time": "2025-07-01T08:08:01",
      "duration_hours": 0.0,
      "duration_formatted": "0м",
      "date": "2025-07-01"
    }
  },
  "sprints": {
    "sprint_7": {
      "sprint_number": 7,
      "start_time": "2025-07-01T08:07:53",
      "start_date": "2025-07-01"
    }
  },
  "project_start": "2025-06-01T09:00:00"
}
```

## 📈 Автоматические отчеты

### Отчет о завершении дня
Создается автоматически при выполнении `end-day`:
- Временные метрики (начало, завершение, продолжительность)
- Шаблон для заполнения достижений
- Метрики разработки и эффективности
- Анализ дня и планы на следующий день
- Техническая информация и статус завершения

### Отчет о завершении спринта
Создается при завершении 5-го дня спринта:
- Полные временные метрики спринта
- Статистика выполнения целей
- Ретроспектива и планы
- Сравнение с предыдущими спринтами
- Техническая информация

## 🔧 Конфигурация

### Настройки проекта:
- **Дата начала проекта:** 1 июня 2025, 09:00
- **Продолжительность спринта:** 5 дней
- **Формат времени:** ISO 8601
- **Кодировка:** UTF-8

### Расположение файлов:
- **Данные времени:** `scripts/time_tracking.json`
- **Отчеты дней:** `reports/daily/`
- **Отчеты спринтов:** `reports/sprints/`

## 📋 Примеры использования

### Полный цикл дня:
```bash
# Утром
./scripts/report.sh start-day
# 🚀 Начат день 31 (Спринт 7, День 1/5)
# 📅 Дата: 2025-07-01
# ⏰ Время начала: 2025-07-01 09:00:00

# В течение дня - разработка...

# Вечером
./scripts/report.sh end-day
# ✅ Завершен день 31 (Спринт 7, День 1/5)
# 📅 Дата: 2025-07-01
# ⏰ Время завершения: 2025-07-01 18:30:00
# ⏱️ Продолжительность: 9ч 30м (9.5ч)
# 📝 Создаем отчет о завершении дня...
# ✅ Отчет создан: reports/daily/DAY_31_COMPLETION_REPORT_20250701.md
```

### Получение статистики:
```bash
./scripts/report.sh project-stats
# 📊 Статистика проекта:
# 🚀 Начало проекта: 2025-06-01 09:00:00
# 📅 Текущее время: 2025-07-01 18:30:00
# 📆 Дней с начала проекта: 31
# ⏱️ Общее время работы: 247.5ч
# ✅ Завершенных дней: 30
# 🏁 Завершенных спринтов: 6
# 📈 Среднее время в день: 8.25ч
```

### Создание отчета о завершении спринта:
```bash
./scripts/report.sh sprint-completion 16
# ✅ Отчет о завершении спринта создан: reports/sprints/SPRINT_16_COMPLETION_REPORT_20250701.md
```

## 🎯 Преимущества системы

### 1. Автоматизация
- Автоматический расчет номеров дней и спринтов
- Автоматическое создание отчетов
- Автоматическое вычисление продолжительности

### 2. Точность
- Использование Python datetime для точных расчетов
- Сохранение всей истории в JSON
- Поддержка часовых поясов

### 3. Интеграция
- Полная интеграция с существующими скриптами
- Совместимость с системой отчетов
- Расширяемость для новых функций

### 4. Удобство
- Простые команды для ежедневного использования
- Автоматическое создание шаблонов отчетов
- Детальная статистика и аналитика

## 🚧 Требования к заполнению отчетов

### В ежедневных отчетах ОБЯЗАТЕЛЬНО указывать:
- ✅ Фактическое время начала и завершения (автоматически)
- ✅ Фактическую продолжительность (автоматически)
- ⚠️ Детализацию времени по задачам (вручную)
- ⚠️ Метрики эффективности (вручную)
- ⚠️ Анализ дня и планы (вручную)

### В отчетах о завершении спринта ОБЯЗАТЕЛЬНО указывать:
- ✅ Полные временные метрики спринта (автоматически)
- ⚠️ Статистику выполнения целей (вручную)
- ⚠️ Ретроспективу и action items (вручную)
- ⚠️ Сравнение с предыдущими спринтами (вручную)

## 🔄 Интеграция с методологией

Система полностью интегрирована с методологией продакт-менеджера:
- Соответствует требованиям Definition of Done
- Поддерживает метрики эффективности разработки
- Автоматизирует создание обязательных отчетов
- Обеспечивает трекинг временных затрат

## 📞 Поддержка

При возникновении проблем:
1. Проверьте существование файла `scripts/time_tracking.json`
2. Убедитесь в правильности прав доступа к файлам
3. Проверьте кодировку терминала (должна быть UTF-8)
4. При необходимости используйте `simple_time_demo.py` для тестирования

## Как это работает

- Перед каждым коммитом автоматически проверяется:
  - Начат ли текущий день (`./scripts/report.sh start-day`)
  - Завершены ли все предыдущие дни (`./scripts/report.sh end-day`)
  - Создан ли ежедневный отчет с двойной нумерацией (например, `DAY_96_SUMMARY_20250701.md` в `reports/daily/`)
- Если что-то не так — коммит блокируется с понятным сообщением.

## Основные команды

- **Начать день:**
  ```bash
  ./scripts/report.sh start-day
  ```
- **Завершить день:**
  ```bash
  ./scripts/report.sh end-day
  ```
- **Создать ежедневный отчет:**
  ```bash
  ./scripts/report.sh daily-create
  ```
- **Проверить информацию о дне:**
  ```bash
  ./scripts/report.sh time-info
  ```
- **Проверить наличие отчета (используется в pre-commit):**
  ```bash
  ./scripts/report.sh check-report
  ```

## Типовые ошибки и их решения

- ❌ **Текущий день не начат!**  
  _Решение:_ Выполните `./scripts/report.sh start-day`

- ❌ **Есть незавершенные дни!**  
  _Решение:_ Выполните `./scripts/report.sh end-day`

- ❌ **Не найден ежедневный отчет...**  
  _Решение:_ Выполните `./scripts/report.sh daily-create` и заполните отчет

## FAQ

**Q: Почему не могу сделать коммит?**
A: Проверьте сообщения pre-commit — скорее всего, не создан или не завершен отчет, либо не начат день.

**Q: Как узнать, какой сейчас день и как называется нужный отчет?**
A: Выполните `./scripts/report.sh time-info` — будет показан номер условного дня и дата. Имя отчета: `DAY_<номер>_SUMMARY_<дата>.md`.

**Q: Где должны лежать отчеты?**
A: Все ежедневные отчеты — строго в `reports/daily/`, спринтовые — в `reports/sprints/`.

**Q: Какой формат имени файла?**
A: Пример: `DAY_96_SUMMARY_20250701.md` (условный день 96, дата 2025-07-01).

**Q: Можно ли обойти pre-commit?**
A: Не рекомендуется! Но для экстренных случаев: `git commit --no-verify` (использовать только по согласованию с тимлидом).

---

⚠️ **Важно:**
- Все отчеты должны быть созданы и заполнены в день работы
- Без отчета за день коммитить изменения запрещено
- Соблюдайте структуру и правила именования файлов

---

*Документ обновлен автоматически. Последняя версия методологии — в reports/methodology/.* 