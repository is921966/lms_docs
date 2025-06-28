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
        4) TEST_PATTERN="LMSUITests/CourseManagementUITests" ;;
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

# Если тест не указан, показываем меню
if [ -z "$TEST_PATTERN" ]; then
    select_test
fi

echo "⏰ Запуск тестов с управляемым таймаутом"
echo "🎯 Тесты: $TEST_PATTERN"
echo "⏱️  Таймаут: $TIMEOUT_SECONDS секунд"
echo ""

# Очистка старых процессов
echo "🧹 Очистка старых процессов..."
pkill -f "xctest" 2>/dev/null || true
pkill -f "XCTestAgent" 2>/dev/null || true

# Запуск симулятора
echo "📱 Подготовка симулятора..."
open -a Simulator
sleep 3

# Временные файлы
TEMP_LOG=$(mktemp)
RESULT_FILE=$(mktemp)
echo "0" > "$RESULT_FILE"  # Начальный статус

echo "📝 Лог: $TEMP_LOG"
echo ""

# Запуск тестов в фоне
echo "▶️  Запуск тестов..."
START_TIME=$(date +%s)

xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -only-testing:"$TEST_PATTERN" \
    -parallel-testing-enabled NO \
    -maximum-concurrent-test-simulator-destinations 1 \
    -resultBundlePath "TestResults/${TEST_PATTERN//\//_}_$(date +%Y%m%d_%H%M%S).xcresult" \
    2>&1 | tee "$TEMP_LOG" &

TEST_PID=$!

# Мониторинг прогресса
SECONDS_WAITED=0
LAST_LINE=""
while [ $SECONDS_WAITED -lt $TIMEOUT_SECONDS ]; do
    if ! kill -0 $TEST_PID 2>/dev/null; then
        # Процесс завершился
        wait $TEST_PID
        EXIT_CODE=$?
        echo "$EXIT_CODE" > "$RESULT_FILE"
        break
    fi
    
    # Показываем текущий тест каждые 5 секунд
    if [ $((SECONDS_WAITED % 5)) -eq 0 ]; then
        CURRENT_TEST=$(tail -100 "$TEMP_LOG" | grep -E "Test Case.*started" | tail -1 || echo "")
        if [ -n "$CURRENT_TEST" ] && [ "$CURRENT_TEST" != "$LAST_LINE" ]; then
            echo "🔄 $CURRENT_TEST"
            LAST_LINE="$CURRENT_TEST"
        elif [ $((SECONDS_WAITED % 20)) -eq 0 ]; then
            echo "⏳ Прошло $SECONDS_WAITED секунд..."
        fi
    fi
    
    sleep 1
    ((SECONDS_WAITED++))
done

# Обработка таймаута
if kill -0 $TEST_PID 2>/dev/null; then
    echo ""
    echo "⏰ Таймаут! Останавливаем тесты..."
    
    # Пытаемся корректно завершить
    kill -TERM $TEST_PID 2>/dev/null
    sleep 5
    
    # Если не завершился - принудительно
    if kill -0 $TEST_PID 2>/dev/null; then
        kill -KILL $TEST_PID 2>/dev/null
    fi
    
    # Очистка всех связанных процессов
    pkill -f "xctest" 2>/dev/null || true
    pkill -f "XCTestAgent" 2>/dev/null || true
    
    echo "124" > "$RESULT_FILE"  # Код таймаута
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
EXIT_CODE=$(cat "$RESULT_FILE")

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 РЕЗУЛЬТАТЫ ТЕСТИРОВАНИЯ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Анализ результатов
TOTAL_TESTS=$(grep -c "Test Case.*started" "$TEMP_LOG" || echo "0")
PASSED_TESTS=$(grep -c "Test Case.*passed" "$TEMP_LOG" || echo "0")
FAILED_TESTS=$(grep -c "Test Case.*failed" "$TEMP_LOG" || echo "0")

echo "⏱️  Время выполнения: ${DURATION} сек"
echo "📋 Всего тестов: $TOTAL_TESTS"
echo "✅ Прошло: $PASSED_TESTS"
echo "❌ Провалилось: $FAILED_TESTS"
echo ""

# Итоговый статус
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "🎉 ВСЕ ТЕСТЫ ПРОШЛИ УСПЕШНО!"
elif [ "$EXIT_CODE" -eq 124 ]; then
    echo "⏰ ТЕСТЫ ПРЕВЫСИЛИ ТАЙМАУТ!"
    echo ""
    echo "💡 Рекомендации:"
    echo "   • Увеличьте таймаут: $0 600 $TEST_PATTERN"
    echo "   • Запустите меньше тестов"
    echo "   • Используйте test-quick-ui.sh для одного теста"
else
    echo "❌ ТЕСТЫ ПРОВАЛИЛИСЬ!"
    echo ""
    echo "📋 Провалившиеся тесты:"
    grep "Test Case.*failed" "$TEMP_LOG" | sed 's/^/   /' || echo "   Не удалось определить"
fi

# Сохранение результатов
if [ -f "$TEMP_LOG" ]; then
    REPORT_FILE="test_report_$(date +%Y%m%d_%H%M%S).log"
    cp "$TEMP_LOG" "$REPORT_FILE"
    echo ""
    echo "📄 Полный отчет сохранен в: $REPORT_FILE"
fi

# Очистка
rm -f "$TEMP_LOG" "$RESULT_FILE"

exit $EXIT_CODE 