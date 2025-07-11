#!/bin/bash

# Report generation script v2.0 - с интеграцией project-time.py
# Использует централизованную систему управления временем

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPORTS_DIR="$PROJECT_ROOT/reports"

# Функция для получения данных из project-time.py
get_time_data() {
    local command=$1
    python3 "$SCRIPT_DIR/project-time.py" $command
}

# Создание ежедневного отчета
create_daily_report() {
    local filename=$(get_time_data "filename daily")
    local header=$(get_time_data "header")
    local filepath="$REPORTS_DIR/daily/$filename"
    
    if [ -f "$filepath" ]; then
        echo "⚠️  Файл уже существует: $filename"
        echo "Хотите перезаписать? (y/n)"
        read -r response
        if [[ "$response" != "y" ]]; then
            return 1
        fi
    fi
    
    cat > "$filepath" << EOF
$header
**Спринт**: $(get_time_data "sprint" | cut -d',' -f1) - [Название спринта]  
**Автор**: AI Development Team

## 🎯 Цели дня
1. [ ] Цель 1
2. [ ] Цель 2
3. [ ] Цель 3

## ✅ Выполненные задачи

### 1. Задача 1 (время)
- Детали выполнения
- Результаты

### 2. Задача 2 (время)
- Детали выполнения
- Результаты

## 📊 Метрики дня
- **Написано кода**: X строк
- **Создано тестов**: Y тестов
- **Покрытие тестами**: Z%
- **Исправлено багов**: N

## ⏱️ Затраченное время
- **Общее время разработки**: X часов
- **Написание кода**: Y часов
- **Написание тестов**: Z часов
- **Отладка и исправления**: W часов

## 💡 Выводы и инсайты
- Что работает хорошо
- Что можно улучшить
- Блокеры и проблемы

## 🎯 План на следующий день
1. Задача 1
2. Задача 2
3. Задача 3

---

**Статус**: День завершен  
**Следующий отчет**: День $(( $(get_time_data "conditional-day") + 1 ))
EOF

    echo "✅ Создан файл: $filename"
    echo "📁 Путь: $filepath"
}

# Создание отчета о завершении спринта
create_sprint_completion() {
    local sprint_num=$1
    if [ -z "$sprint_num" ]; then
        sprint_data=$(get_time_data "sprint")
        sprint_num=$(echo $sprint_data | cut -d',' -f1)
    fi
    
    local filename="SPRINT_${sprint_num}_COMPLETION_REPORT_$(date +%Y%m%d).md"
    local filepath="$REPORTS_DIR/sprints/$filename"
    
    cat > "$filepath" << EOF
# Sprint $sprint_num Completion Report

**Дата завершения**: $(date '+%d %B %Y' | sed 's/July/июля/g')  
**Продолжительность**: 5 дней  
**Команда**: AI Development Team

## 📊 Общая статистика

### Запланировано vs Выполнено
- **Запланировано задач**: X
- **Выполнено задач**: Y
- **Процент выполнения**: Z%

### Метрики кода
- **Написано строк кода**: X
- **Создано тестов**: Y
- **Покрытие тестами**: Z%
- **Технический долг**: уменьшен/увеличен на N%

## ✅ Выполненные задачи

### 1. [Название задачи]
- **Статус**: Завершено
- **Затрачено времени**: X часов
- **Результат**: Описание результата

## 🚧 Незавершенные задачи

### 1. [Название задачи]
- **Статус**: X% выполнено
- **Причина**: Описание причины
- **План**: Перенесено в Sprint Y

## 💡 Ключевые достижения

1. Достижение 1
2. Достижение 2
3. Достижение 3

## 📈 Метрики эффективности

- **Скорость разработки**: X строк/час
- **Скорость тестирования**: Y тестов/час
- **Время на исправление багов**: Z% от общего времени

## 🔍 Проблемы и решения

### Проблема 1
- **Описание**: Что произошло
- **Решение**: Как решили
- **Уроки**: Что узнали

## 🎯 Рекомендации для следующего спринта

1. Рекомендация 1
2. Рекомендация 2
3. Рекомендация 3

---

**Sprint $sprint_num завершен успешно!**
EOF

    echo "✅ Создан отчет о завершении Sprint $sprint_num"
    echo "📁 Путь: $filepath"
}

# Показать информацию
show_info() {
    python3 "$SCRIPT_DIR/project-time.py"
}

# Обновить условный день
update_day() {
    local day=$1
    if [ -z "$day" ]; then
        echo "Использование: $0 set-day <номер_дня>"
        return 1
    fi
    python3 "$SCRIPT_DIR/project-time.py" set-day $day
}

# Синхронизация с существующими данными
sync_time() {
    python3 "$SCRIPT_DIR/project-time.py" sync
}

# Главное меню
case "$1" in
    "daily")
        create_daily_report
        ;;
    "sprint-completion")
        create_sprint_completion $2
        ;;
    "info")
        show_info
        ;;
    "set-day")
        update_day $2
        ;;
    "sync")
        sync_time
        ;;
    *)
        echo "Report Generator v2.0 - с централизованным управлением временем"
        echo
        echo "Использование: $0 <команда> [параметры]"
        echo
        echo "Команды:"
        echo "  daily              - Создать ежедневный отчет"
        echo "  sprint-completion  - Создать отчет о завершении спринта"
        echo "  info              - Показать текущую информацию о времени"
        echo "  set-day <день>    - Установить условный день"
        echo "  sync              - Синхронизировать с report.sh"
        echo
        echo "Примеры:"
        echo "  $0 daily"
        echo "  $0 sprint-completion 29"
        echo "  $0 set-day 135"
        echo "  $0 info"
        ;;
esac 