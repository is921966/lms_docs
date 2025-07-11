#!/bin/bash

echo "🧪 Запуск всех тестов LMS..."
echo "================================="

DEVICE_ID="C0F60722-8F57-46A8-A737-2A1CD8819E8E"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULTS_DIR="TestResults/Sprint45_$TIMESTAMP"

# Создаем директорию для результатов
mkdir -p $RESULTS_DIR

# 1. Unit тесты
echo ""
echo "📋 Запуск Unit тестов..."
echo "------------------------"

xcodebuild test \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -only-testing:LMSTests \
    -enableCodeCoverage YES \
    -resultBundlePath "$RESULTS_DIR/unit-tests.xcresult" \
    2>&1 | tee "$RESULTS_DIR/unit-tests.log" | \
    grep -E "(Test Suite|Test Case.*passed|Test Case.*failed|tests? passed|tests? failed)"

# 2. UI тесты - базовые
echo ""
echo "📱 Запуск базовых UI тестов..."
echo "------------------------------"

xcodebuild test \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -only-testing:LMSUITests/BasicLoginTest \
    -only-testing:LMSUITests/SimpleSmokeTest \
    -only-testing:LMSUITests/SmokeTests \
    -enableCodeCoverage YES \
    -resultBundlePath "$RESULTS_DIR/ui-basic-tests.xcresult" \
    2>&1 | tee "$RESULTS_DIR/ui-basic-tests.log" | \
    grep -E "(Test Suite|Test Case.*passed|Test Case.*failed|tests? passed|tests? failed)"

# 3. UI тесты - Course Management (попытка)
echo ""
echo "📚 Попытка запуска Course Management UI тестов..."
echo "-------------------------------------------------"

xcodebuild test \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -only-testing:LMSUITests/CourseManagementUITests/testCourseListDisplay \
    -enableCodeCoverage YES \
    -resultBundlePath "$RESULTS_DIR/ui-course-tests.xcresult" \
    -test-timeouts-enabled NO \
    2>&1 | tee "$RESULTS_DIR/ui-course-tests.log" | \
    grep -E "(Test Suite|Test Case.*passed|Test Case.*failed|tests? passed|tests? failed)"

# 4. Анализ результатов
echo ""
echo "📊 Анализ результатов..."
echo "========================"

# Подсчет unit тестов
UNIT_PASSED=$(grep -c "passed" "$RESULTS_DIR/unit-tests.log" | head -1)
UNIT_FAILED=$(grep -c "failed" "$RESULTS_DIR/unit-tests.log" | head -1)
UNIT_TOTAL=$((UNIT_PASSED + UNIT_FAILED))

echo "Unit тесты:"
echo "  Всего: $UNIT_TOTAL"
echo "  Прошло: $UNIT_PASSED"
echo "  Упало: $UNIT_FAILED"

# Подсчет UI тестов
UI_PASSED=$(grep -c "passed" "$RESULTS_DIR/ui-*.log" | awk -F: '{sum+=$2} END {print sum}')
UI_FAILED=$(grep -c "failed" "$RESULTS_DIR/ui-*.log" | awk -F: '{sum+=$2} END {print sum}')
UI_TOTAL=$((UI_PASSED + UI_FAILED))

echo ""
echo "UI тесты:"
echo "  Всего: $UI_TOTAL"
echo "  Прошло: $UI_PASSED"
echo "  Упало: $UI_FAILED"

# Общая статистика
TOTAL_TESTS=$((UNIT_TOTAL + UI_TOTAL))
TOTAL_PASSED=$((UNIT_PASSED + UI_PASSED))
TOTAL_FAILED=$((UNIT_FAILED + UI_FAILED))
PASS_RATE=$((TOTAL_PASSED * 100 / TOTAL_TESTS))

echo ""
echo "Общая статистика:"
echo "  Всего тестов: $TOTAL_TESTS"
echo "  Прошло: $TOTAL_PASSED"
echo "  Упало: $TOTAL_FAILED"
echo "  Процент успеха: $PASS_RATE%"

echo ""
echo "✅ Результаты сохранены в: $RESULTS_DIR" 