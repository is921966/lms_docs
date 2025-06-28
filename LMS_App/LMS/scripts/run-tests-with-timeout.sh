#!/bin/bash

# Управление таймаутами для UI тестов
# Использование: ./scripts/run-tests-with-timeout.sh [timeout_seconds] [test_pattern]

TIMEOUT_SECONDS="${1:-300}"  # По умолчанию 5 минут
TEST_PATTERN="${2:-}"

# Функция для выбора теста
select_test() {
    echo "🎯 Выберите тест для запуска:"
    echo ""
    echo "1) Все UI тесты (LMSUITests)"
    echo "2) Onboarding тесты"
    echo "3) Feature Registry тесты"
    echo "4) Course тесты"
    echo "5) Analytics тесты"
    echo "6) Конкретный тест (введите путь)"
    echo ""
    read -p "Выбор (1-6): " choice
    
    case $choice in
        1) TEST_PATTERN="LMSUITests" ;;
        2) TEST_PATTERN="LMSUITests/OnboardingFlowUITests" ;;
        3) TEST_PATTERN="LMSUITests/FeatureRegistryIntegrationTests" ;;
        4) TEST_PATTERN="LMSUITests/CourseMaterialsUITests" ;;
        5) TEST_PATTERN="LMSUITests/AnalyticsUITests" ;;
        6) 
            read -p "Введите путь к тесту: " custom_test
            TEST_PATTERN="$custom_test"
            ;;
        *) 
            echo "❌ Неверный выбор"
            exit 1
            ;;
    esac
}

# Если тест не указан, предлагаем выбрать
if [ -z "$TEST_PATTERN" ]; then
    select_test
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏃 ЗАПУСК UI ТЕСТОВ С ТАЙМАУТОМ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 Тесты: $TEST_PATTERN"
echo "⏱️  Таймаут: $TIMEOUT_SECONDS секунд"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Очистка возможных зависших процессов
echo "🧹 Очистка старых процессов..."
pkill -f "xctest" 2>/dev/null || true
pkill -f "XCTestAgent" 2>/dev/null || true

# Запуск симулятора если не запущен
echo "📱 Запуск симулятора..."
open -a Simulator
sleep 2

# Функция для запуска тестов с таймаутом
run_with_timeout() {
    local pattern="$1"
    local timeout="$2"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local log_file="test_report_${timestamp}.log"
    
    echo "🚀 Запуск тестов: $pattern"
    echo "⏱️  Таймаут: $timeout секунд"
    echo "📝 Лог: $log_file"
    echo ""
    
    # Создаем фоновый процесс для xcodebuild
    xcodebuild test -scheme LMS \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
        -only-testing:"$pattern" \
        -resultBundlePath "TestResults/${pattern//\//_}_${timestamp}.xcresult" \
        2>&1 | tee "$log_file" &
    
    local xcodebuild_pid=$!
    
    # Ждем завершения с таймаутом
    local elapsed=0
    local check_interval=1
    local last_progress_marker=0
    
    while true; do
        if ! ps -p $xcodebuild_pid > /dev/null 2>&1; then
            # Процесс завершился
            wait $xcodebuild_pid
            local exit_code=$?
            break
        fi
        
        if [ $elapsed -ge $timeout ]; then
            echo ""
            echo "⏰ ТАЙМАУТ! Прерываем тесты после $timeout секунд"
            kill -9 $xcodebuild_pid 2>/dev/null
            pkill -f "xctest" 2>/dev/null
            pkill -f "XCTestAgent" 2>/dev/null
            echo "❌ Тесты прерваны по таймауту"
            exit 1
        fi
        
        # Показываем прогресс каждые 10 секунд
        if [ $((elapsed - last_progress_marker)) -ge 10 ]; then
            echo "⏳ Прошло $elapsed секунд..."
            last_progress_marker=$elapsed
        fi
        
        sleep $check_interval
        elapsed=$((elapsed + check_interval))
    done
    
    # Анализируем результаты
    local passed=$(grep -o "passed ([0-9.]* seconds)" "$log_file" | wc -l | tr -d ' ')
    local failed=$(grep -o "failed ([0-9.]* seconds)" "$log_file" | wc -l | tr -d ' ')
    local total=$((passed + failed))
    
    # Более надежная проверка провалов
    local test_failed=false
    if grep -q "** TEST FAILED **" "$log_file"; then
        test_failed=true
    fi
    if grep -q "Failing tests:" "$log_file"; then
        test_failed=true
    fi
    if [ "$failed" -gt 0 ]; then
        test_failed=true
    fi
    if [ "$exit_code" -ne 0 ]; then
        test_failed=true
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 РЕЗУЛЬТАТЫ ТЕСТИРОВАНИЯ"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⏱️  Время выполнения: $elapsed сек"
    echo "📋 Всего тестов: $total"
    echo "✅ Прошло: $passed"
    echo "❌ Провалилось: $failed"
    echo ""
    
    if [ "$test_failed" = true ]; then
        echo "❌ ТЕСТЫ ПРОВАЛИЛИСЬ!"
        echo ""
        echo "📋 Список провалившихся тестов:"
        grep "Failing tests:" "$log_file" -A20 | grep -E "^\s+[A-Za-z]" | head -20 || echo "   Не удалось определить"
        exit 1
    else
        echo "🎉 ВСЕ ТЕСТЫ ПРОШЛИ УСПЕШНО!"
    fi
    
    echo ""
    echo "📄 Полный отчет сохранен в: $log_file"
}

# Запуск тестов
run_with_timeout "$TEST_PATTERN" "$TIMEOUT_SECONDS" 