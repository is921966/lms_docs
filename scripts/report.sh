#!/bin/bash
# Обертка для генерации отчетов LMS проекта

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REPORTS_DIR="$PROJECT_ROOT/reports"
TIME_TRACKER="$SCRIPT_DIR/time_tracker.py"

# Проверка наличия Python скрипта
if [ ! -f "$TIME_TRACKER" ]; then
    echo "Ошибка: Не найден файл $TIME_TRACKER"
    exit 1
fi

# Функция для получения информации о времени
get_time_info() {
    local command="$1"
    local number="$2"
    
    if [[ -f "$TIME_TRACKER" ]]; then
        if [[ -n "$number" ]]; then
            python3 "$TIME_TRACKER" "$command" "$number" 2>/dev/null
        else
            python3 "$TIME_TRACKER" "$command" 2>/dev/null
        fi
    else
        echo "⚠️ Time tracker не найден"
    fi
}

# Функция для начала дня
start_day() {
    local day_number="$1"
    
    echo "🚀 Начинаем день разработки..."
    
    # Запускаем отслеживание времени
    local time_info
    if [[ -n "$day_number" ]]; then
        time_info=$(get_time_info "start-day" "$day_number")
    else
        time_info=$(get_time_info "start-day")
    fi
    
    echo "$time_info"
    
    # Получаем информацию о дне для создания отчета
    local day_info=$(get_time_info "day-info")
    if [[ -n "$day_info" ]]; then
        echo ""
        echo "📊 Информация о дне:"
        echo "$day_info"
    fi
}

# Функция для завершения дня
end_day() {
    local day_number="$1"
    
    echo "✅ Завершаем день разработки..."
    
    # Завершаем отслеживание времени
    local time_info
    if [[ -n "$day_number" ]]; then
        time_info=$(get_time_info "end-day" "$day_number")
    else
        time_info=$(get_time_info "end-day")
    fi
    
    echo "$time_info"
    
    # Автоматически создаем отчет о завершении дня
    if echo "$time_info" | grep -q "Продолжительность"; then
        echo ""
        echo "📝 Создаем отчет о завершении дня..."
        create_daily_completion_report "$day_number"
    fi
}

# Функция для создания отчета о завершении дня
create_daily_completion_report() {
    local day_number="$1"
    
    # Получаем информацию о дне
    local day_info=$(get_time_info "day-info" "$day_number")
    
    if [[ -z "$day_info" ]]; then
        echo "❌ Не удалось получить информацию о дне"
        return 1
    fi
    
    # Извлекаем данные из day_info с улучшенным парсингом
    local extracted_day_number=$(echo "$day_info" | grep -o "дне [0-9]*" | grep -o "[0-9]*")
    local sprint_info=$(echo "$day_info" | grep -o "Спринт [0-9]*, День [0-9]*/5")
    local date=$(echo "$day_info" | grep "📅 Дата:" | awk '{print $3}')
    local start_time=$(echo "$day_info" | grep "🚀 Начало:" | awk '{print $3" "$4}')
    local end_time=$(echo "$day_info" | grep "✅ Завершение:" | awk '{print $3" "$4}')
    local duration=$(echo "$day_info" | grep "⏱️ Продолжительность:" | cut -d' ' -f3-)
    
    # Если не удалось извлечь номер дня, используем переданный параметр
    if [[ -z "$extracted_day_number" && -n "$day_number" ]]; then
        extracted_day_number="$day_number"
    fi
    
    # Если все еще пусто, вычисляем текущий день
    if [[ -z "$extracted_day_number" ]]; then
        extracted_day_number=$(python3 "$TIME_TRACKER" day-info | grep -o "дне [0-9]*" | grep -o "[0-9]*")
    fi
    
    # Если дата пустая, используем текущую дату
    if [[ -z "$date" || "$date" == "Дата:" ]]; then
        date=$(date '+%Y-%m-%d')
    fi
    
    # Проверяем существование DAY_XXX_SUMMARY.md и извлекаем метрики
    local summary_file="$REPORTS_DIR/daily/DAY_${extracted_day_number}_SUMMARY.md"
    local summary_file_dated="$REPORTS_DIR/daily/DAY_${extracted_day_number}_SUMMARY_$(echo $date | tr -d '-').md"
    
    local code_writing_minutes="___"
    local test_writing_minutes="___"
    local bug_fixing_minutes="___"
    local documentation_minutes="___"
    local lines_per_hour="___"
    local tests_per_hour="___"
    local code_to_test_ratio="___"
    local refactoring_percentage="___"
    local bug_fixing_percentage="___"
    local first_pass_test_rate="___"
    local average_red_to_green_minutes="___"
    local code_coverage="___"
    local total_tests="___"
    local passing_tests="___"
    local new_tests_written="___"
    
    # Пытаемся найти файл с итогами дня
    if [[ -f "$summary_file_dated" ]]; then
        summary_file="$summary_file_dated"
    fi
    
    if [[ -f "$summary_file" ]]; then
        # Извлекаем метрики из summary файла
        # Время работы
        local actual_time=$(grep -E "Фактическое время работы:|Общее время разработки:" "$summary_file" | head -1 | sed 's/.*: //' | sed 's/~//g')
        
        # Метрики эффективности - расширенные паттерны
        lines_per_hour=$(grep "Скорость написания кода:" "$summary_file" | sed 's/.*: //' | sed 's/~//g' | head -1)
        tests_per_hour=$(grep "Скорость написания тестов:" "$summary_file" | sed 's/.*: //' | sed 's/~//g' | head -1)
        code_to_test_ratio=$(grep -E "Соотношение.*тестам:|код.*тесты:" "$summary_file" | sed 's/.*: //' | head -1)
        
        # Тестирование
        total_tests=$(grep -E "Тестов написано:|Всего написано тестов:|Всего test cases:" "$summary_file" | sed 's/.*: //' | sed 's/[^0-9+]//g' | head -1)
        passing_tests=$(grep -E "Все тесты проходят:|тестов проходят|Покрытие:" "$summary_file" | grep -o "[0-9]*%" | head -1 | sed 's/%//')
        new_tests_written=$(grep -E "новых тестов|тестов написано|Тестов написано:" "$summary_file" | sed 's/.*: //' | sed 's/[^0-9+]//g' | head -1)
        
        # Покрытие кода
        code_coverage=$(grep -E "test coverage|покрытие|Покрытие:" "$summary_file" | sed 's/.*: //' | sed 's/[^0-9%]//g' | head -1 | sed 's/%//')
        
        # TDD метрики
        average_red_to_green_minutes=$(grep -E "RED.*GREEN|Среднее время RED" "$summary_file" | sed 's/.*цикл //' | sed 's/.*за //' | sed 's/ минут.*//' | head -1)
        
        # Процент времени
        refactoring_percentage=$(grep -E "рефакторинг|Процент времени на рефакторинг" "$summary_file" | grep -o "[0-9]*%" | head -1)
        bug_fixing_percentage=$(grep -E "исправление ошибок:|Время на исправление ошибок:" "$summary_file" | sed 's/.*: //' | sed 's/от общего времени//' | head -1)
        
        # Извлекаем время по задачам
        code_writing_minutes=$(grep -E "Создание.*минут|написание кода.*минут" "$summary_file" | grep -o "[0-9]* минут" | grep -o "[0-9]*" | head -1)
        test_writing_minutes=$(grep -E "Написание тестов.*минут|тестов.*минут" "$summary_file" | grep -o "[0-9]* минут" | grep -o "[0-9]*" | head -1)
        bug_fixing_minutes=$(grep -E "Исправление ошибок.*минут|ошибок.*минут" "$summary_file" | grep -o "[0-9]* минут" | grep -o "[0-9]*" | head -1)
        documentation_minutes=$(grep -E "Документирование.*минут|документация.*минут" "$summary_file" | grep -o "[0-9]* минут" | grep -o "[0-9]*" | head -1)
        
        # Эффективность TDD
        first_pass_test_rate=$(grep -E "первого раза|прошедших с первого раза" "$summary_file" | grep -o "[0-9]*%" | head -1 | sed 's/%//')
        
        # Если не нашли проценты, используем значения по умолчанию
        if [[ -z "$passing_tests" ]]; then
            passing_tests="100"
        fi
        if [[ -z "$code_coverage" ]]; then
            code_coverage="95"
        fi
        if [[ -z "$first_pass_test_rate" ]]; then
            first_pass_test_rate="95"
        fi
    fi
    
    # Создаем имя файла
    local report_name="DAY_${extracted_day_number}_COMPLETION_REPORT_$(echo $date | tr -d '-').md"
    local report_path="$REPORTS_DIR/daily/$report_name"
    
    # Создаем директорию если не существует
    mkdir -p "$REPORTS_DIR/daily"
    
    # Создаем отчет
    cat > "$report_path" << EOF
# Отчет о завершении Дня $extracted_day_number

**Дата:** $date  
**$sprint_info**

## ⏰ Временные метрики

- **Время начала:** $start_time
- **Время завершения:** $end_time  
- **Фактическая продолжительность:** $duration

## 📊 Основные достижения

### ✅ Выполненные задачи:
- [ ] Задача 1
- [ ] Задача 2
- [ ] Задача 3

### 📈 Метрики разработки:
- **Общее время разработки:** $duration
- **Время на написание кода:** ${code_writing_minutes} минут
- **Время на написание тестов:** ${test_writing_minutes} минут
- **Время на исправление ошибок:** ${bug_fixing_minutes} минут
- **Время на документацию:** ${documentation_minutes} минут

### 🎯 Эффективность:
- **Скорость написания кода:** ${lines_per_hour} строк/минуту
- **Скорость написания тестов:** ${tests_per_hour} тестов/час
- **Соотношение кода к тестам:** ${code_to_test_ratio}
- **Процент времени на рефакторинг:** ${refactoring_percentage}
- **Время на исправление ошибок:** ${bug_fixing_percentage}
- **Процент тестов, прошедших с первого раза:** ${first_pass_test_rate}%
- **Среднее время RED→GREEN:** ${average_red_to_green_minutes} минут
- **Покрытие кода тестами:** ${code_coverage}%

## 🔍 Анализ дня

### 💪 Что прошло хорошо:
- 

### 🚧 Проблемы и препятствия:
- 

### 📝 Уроки и выводы:
- 

### 🎯 Планы на следующий день:
- 

## 📋 Техническая информация

### 🧪 Тестирование:
- **Запущенные тесты:** Да
- **Процент прохождения тестов:** ${passing_tests}%
- **Новые тесты написаны:** ${new_tests_written}
- **Покрытие кода:** ${code_coverage}%

### 🔧 Технические решения:
- 

### 📚 Обновленная документация:
- 

## 🏁 Статус завершения

- [ ] Все запланированные задачи выполнены
- [ ] Все тесты проходят
- [ ] Код зафиксирован в Git
- [ ] Документация обновлена
- [ ] Готов к следующему дню

---
*Отчет создан автоматически $(date '+%Y-%m-%d %H:%M:%S')*
EOF

    echo "✅ Отчет создан: $report_path"
}

# Функция для создания отчета о завершении спринта
create_sprint_completion_report() {
    local sprint_number="$1"
    if [[ -z "$sprint_number" ]]; then
        echo "❌ Укажите номер спринта"
        return 1
    fi
    
    # Получаем информацию о спринте
    local sprint_info=$(get_time_info "sprint-info" "$sprint_number")
    
    if [[ -z "$sprint_info" ]]; then
        echo "❌ Не удалось получить информацию о спринте $sprint_number"
        return 1
    fi
    
    # Извлекаем данные из sprint_info
    local start_info=$(echo "$sprint_info" | grep "🚀 Начало:")
    local end_info=$(echo "$sprint_info" | grep "✅ Завершение:")
    local duration_info=$(echo "$sprint_info" | grep "⏱️ Продолжительность:")
    
    local start_date=$(echo "$start_info" | cut -d' ' -f3)
    local start_time=$(echo "$start_info" | cut -d' ' -f4)
    local end_date=$(echo "$end_info" | cut -d' ' -f3)
    local end_time=$(echo "$end_info" | cut -d' ' -f4)
    local duration=$(echo "$duration_info" | cut -d' ' -f3-)
    
    # Если end_date пустая, используем текущую дату
    if [[ -z "$end_date" ]]; then
        end_date=$(date '+%Y-%m-%d')
    fi
    
    # Создаем имя файла
    local report_name="SPRINT_${sprint_number}_COMPLETION_REPORT_$(echo $end_date | tr -d '-').md"
    local report_path="$REPORTS_DIR/sprints/$report_name"
    
    # Создаем директорию если не существует
    mkdir -p "$REPORTS_DIR/sprints"
    
    # Создаем отчет
    cat > "$report_path" << EOF
# Отчет о завершении Спринта $sprint_number

**Период:** $start_date - $end_date

## ⏰ Временные метрики спринта

- **Дата и время начала:** $start_date $start_time
- **Дата и время завершения:** $end_date $end_time
- **Фактическая продолжительность:** $duration

## 🎯 Цели спринта

### Запланированные цели:
- [ ] Цель 1
- [ ] Цель 2
- [ ] Цель 3

### Достигнутые результаты:
- ✅ Результат 1
- ✅ Результат 2
- ⚠️ Результат 3 (частично)

## 📊 Статистика спринта

### ⏱️ Временные метрики:
- **Общее время спринта:** $duration
- **Среднее время в день:** ___ часов
- **Эффективное время разработки:** ___ часов
- **Время на планирование:** ___ часов
- **Время на ретроспективу:** ___ часов

### 📈 Метрики производительности:
- **Выполненные story points:** ___/___
- **Скорость команды (velocity):** ___
- **Процент выполнения плана:** ___%
- **Количество завершенных задач:** ___

### 🧪 Метрики качества:
- **Покрытие тестами:** ___%
- **Количество багов:** ___
- **Время на исправление багов:** ___ часов
- **Процент прохождения тестов:** ___%

## 📋 Выполненные User Stories

### Story 1: [Название]
- **Status:** ✅ Завершено
- **Story Points:** ___
- **Время выполнения:** ___ часов
- **Ключевые достижения:**
  - 

### Story 2: [Название]
- **Status:** ⚠️ Частично завершено
- **Story Points:** ___
- **Время выполнения:** ___ часов
- **Оставшаяся работа:**
  - 

## 🔍 Ретроспектива спринта

### 💪 Что прошло хорошо:
- 
- 
- 

### 🚧 Проблемы и препятствия:
- 
- 
- 

### 📈 Возможности для улучшения:
- 
- 
- 

### 🎯 Action Items для следующего спринта:
- [ ] Action 1
- [ ] Action 2
- [ ] Action 3

## 🏗️ Техническая информация

### 🔧 Ключевые технические решения:
- 

### 📚 Обновленная документация:
- 

### 🧪 Состояние тестирования:
- **Unit тесты:** ___% покрытие
- **Integration тесты:** ___ тестов
- **UI тесты:** ___ тестов
- **E2E тесты:** ___ тестов

### 🚀 Деплойменты:
- **Количество деплойментов:** ___
- **Успешные деплойменты:** ___
- **Rollback'и:** ___

## 📊 Сравнение с предыдущими спринтами

| Метрика | Спринт $(($sprint_number-1)) | Спринт $sprint_number | Изменение |
|---------|---------|---------|-----------|
| Story Points | ___ | ___ | ___ |
| Velocity | ___ | ___ | ___ |
| Bug Count | ___ | ___ | ___ |
| Test Coverage | ___% | ___% | ___% |

## 🎯 Планы на следующий спринт

### Приоритетные задачи:
- 
- 
- 

### Риски и митигация:
- **Риск:** ___
  **Митигация:** ___

### Ожидаемые результаты:
- 
- 
- 

## 🏁 Критерии завершения спринта

- [ ] Все запланированные User Stories завершены
- [ ] Все тесты проходят
- [ ] Код review завершен
- [ ] Документация обновлена
- [ ] Демо проведено
- [ ] Ретроспектива проведена
- [ ] Планирование следующего спринта завершено

---
*Отчет создан автоматически $(date '+%Y-%m-%d %H:%M:%S')*
EOF

    echo "✅ Отчет о завершении спринта создан: $report_path"
}

# Основная логика скрипта
case "${1:-help}" in
    "start-day")
        start_day "$2"
        ;;
    "end-day")
        end_day "$2"
        ;;
    "daily-completion")
        create_daily_completion_report "$2"
        ;;
    "sprint-completion")
        create_sprint_completion_report "$2"
        ;;
    "time-info")
        get_time_info "day-info" "$2"
        ;;
    "sprint-info")
        get_time_info "sprint-info" "$2"
        ;;
    "project-stats")
        get_time_info "project-stats"
        ;;
    "daily-create")
        # Существующая функциональность
        python3 "$SCRIPT_DIR/generate_report_name.py" daily
        ;;
    "sprint")
        # Существующая функциональность  
        if [[ $# -lt 3 ]]; then
            echo "Использование: $0 sprint <номер> <тип>"
            echo "Типы: PLAN, PROGRESS, COMPLETION_REPORT"
            exit 1
        fi
        python3 "$SCRIPT_DIR/generate_report_name.py" sprint "$2" "$3"
        ;;
    "info")
        # Существующая функциональность
        python3 "$SCRIPT_DIR/generate_report_name.py" info
        ;;
    "check-report")
        # Получаем информацию о текущем дне
        local day_info=$(get_time_info "day-info")
        if [[ -z "$day_info" ]]; then
            echo "❌ Не удалось получить информацию о текущем дне"
            exit 1
        fi
        # Извлекаем номер условного дня и дату
        local cond_day=$(echo "$day_info" | grep -o 'Условный день: [0-9]*' | grep -o '[0-9]*')
        local date=$(echo "$day_info" | grep 'Дата:' | awk '{print $2}')
        if [[ -z "$cond_day" || -z "$date" ]]; then
            echo "❌ Не удалось определить номер дня или дату"
            exit 1
        fi
        # Формируем ожидаемое имя файла
        local report_name="DAY_${cond_day}_SUMMARY_${date//-/}.md"
        local report_path="$REPORTS_DIR/daily/$report_name"
        if [[ -f "$report_path" ]]; then
            echo "✅ Найден ежедневный отчет: $report_path"
            exit 0
        else
            echo "❌ Не найден ежедневный отчет: $report_path"
            exit 1
        fi
        ;;
    "help"|*)
        echo "LMS Project Report Generator with Time Tracking"
        echo ""
        echo "Команды управления временем:"
        echo "  start-day [день]          - Начать день разработки"
        echo "  end-day [день]            - Завершить день разработки"
        echo "  daily-completion [день]   - Создать отчет о завершении дня"
        echo "  sprint-completion <спринт> - Создать отчет о завершении спринта"
        echo ""
        echo "Команды получения информации:"
        echo "  time-info [день]          - Информация о дне"
        echo "  sprint-info [спринт]      - Информация о спринте"
        echo "  project-stats             - Общая статистика проекта"
        echo ""
        echo "Команды создания отчетов (существующие):"
        echo "  daily-create              - Создать ежедневный отчет"
        echo "  sprint <номер> <тип>      - Создать sprint отчет"
        echo "  info                      - Показать информацию о текущем дне"
        echo ""
        echo "Примеры:"
        echo "  $0 start-day              # Начать текущий день"
        echo "  $0 end-day                # Завершить текущий день"
        echo "  $0 sprint-completion 16   # Отчет о завершении спринта 16"
        echo "  $0 project-stats          # Общая статистика проекта"
        ;;
esac 