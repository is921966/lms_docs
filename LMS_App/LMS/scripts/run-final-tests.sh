#!/bin/bash

echo "🧪 ФИНАЛЬНЫЙ ЗАПУСК ВСЕХ ТЕСТОВ SPRINT 45"
echo "=========================================="
echo ""

DEVICE_ID="C0F60722-8F57-46A8-A737-2A1CD8819E8E"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULTS_DIR="TestResults/Final_Sprint45_$TIMESTAMP"

mkdir -p $RESULTS_DIR

# 1. Unit тесты
echo "📋 1. UNIT ТЕСТЫ"
echo "----------------"
xcodebuild test \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -only-testing:LMSTests \
    -enableCodeCoverage YES \
    -resultBundlePath "$RESULTS_DIR/unit-tests.xcresult" \
    2>&1 | tee "$RESULTS_DIR/unit-tests.log" | \
    grep -E "(Test Suite.*passed|Test Suite.*failed|tests passed|tests failed)" | tail -5

# 2. UI тесты - базовые
echo ""
echo "📱 2. UI ТЕСТЫ - Базовые"
echo "------------------------"
xcodebuild test \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -only-testing:LMSUITests/BasicLoginTest \
    -only-testing:LMSUITests/SimpleSmokeTest \
    -only-testing:LMSUITests/SmokeTests \
    -enableCodeCoverage YES \
    -resultBundlePath "$RESULTS_DIR/ui-basic.xcresult" \
    2>&1 | tee "$RESULTS_DIR/ui-basic.log" | \
    grep -E "(Test Suite.*passed|Test Suite.*failed|tests passed|tests failed)" | tail -5

# 3. UI тесты - Course Management
echo ""
echo "📚 3. UI ТЕСТЫ - Course Management"
echo "----------------------------------"
xcodebuild test \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -only-testing:LMSUITests/CourseManagementUITests \
    -enableCodeCoverage YES \
    -resultBundlePath "$RESULTS_DIR/ui-course.xcresult" \
    -test-timeouts-enabled NO \
    2>&1 | tee "$RESULTS_DIR/ui-course.log" | \
    grep -E "(Test Suite.*passed|Test Suite.*failed|tests passed|tests failed)" | tail -5

# 4. UI тесты - Cmi5
echo ""
echo "🎯 4. UI ТЕСТЫ - Cmi5"
echo "---------------------"
xcodebuild test \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -only-testing:LMSUITests/Cmi5UITests \
    -enableCodeCoverage YES \
    -resultBundlePath "$RESULTS_DIR/ui-cmi5.xcresult" \
    -test-timeouts-enabled NO \
    2>&1 | tee "$RESULTS_DIR/ui-cmi5.log" | \
    grep -E "(Test Suite.*passed|Test Suite.*failed|tests passed|tests failed)" | tail -5

# 5. E2E тесты
echo ""
echo "🔗 5. E2E ТЕСТЫ"
echo "---------------"
xcodebuild test \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -only-testing:LMSUITests/CourseManagementE2ETests \
    -only-testing:LMSUITests/Cmi5E2ETests \
    -only-testing:LMSUITests/ModulesIntegrationE2ETests \
    -enableCodeCoverage YES \
    -resultBundlePath "$RESULTS_DIR/e2e-tests.xcresult" \
    -test-timeouts-enabled NO \
    2>&1 | tee "$RESULTS_DIR/e2e-tests.log" | \
    grep -E "(Test Suite.*passed|Test Suite.*failed|tests passed|tests failed)" | tail -5

# 6. Финальный подсчет
echo ""
echo "📊 ФИНАЛЬНЫЕ РЕЗУЛЬТАТЫ"
echo "======================="

# Unit тесты
UNIT_PASSED=$(grep -c "passed" "$RESULTS_DIR/unit-tests.log" || echo 0)
UNIT_FAILED=$(grep -c "failed" "$RESULTS_DIR/unit-tests.log" || echo 0)
UNIT_TOTAL=$((UNIT_PASSED + UNIT_FAILED))

# UI тесты
UI_PASSED=$(cat "$RESULTS_DIR"/ui-*.log "$RESULTS_DIR"/e2e-*.log 2>/dev/null | grep -c "passed" || echo 0)
UI_FAILED=$(cat "$RESULTS_DIR"/ui-*.log "$RESULTS_DIR"/e2e-*.log 2>/dev/null | grep -c "failed" || echo 0)
UI_TOTAL=$((UI_PASSED + UI_FAILED))

# Общая статистика
TOTAL_TESTS=$((UNIT_TOTAL + UI_TOTAL))
TOTAL_PASSED=$((UNIT_PASSED + UI_PASSED))
TOTAL_FAILED=$((UNIT_FAILED + UI_FAILED))

if [ $TOTAL_TESTS -gt 0 ]; then
    PASS_RATE=$((TOTAL_PASSED * 100 / TOTAL_TESTS))
else
    PASS_RATE=0
fi

echo ""
echo "Unit тесты:"
echo "  Всего: $UNIT_TOTAL"
echo "  Прошло: $UNIT_PASSED"
echo "  Упало: $UNIT_FAILED"
echo ""
echo "UI/E2E тесты:"
echo "  Всего: $UI_TOTAL"
echo "  Прошло: $UI_PASSED"
echo "  Упало: $UI_FAILED"
echo ""
echo "ИТОГО:"
echo "  Всего тестов: $TOTAL_TESTS"
echo "  Прошло: $TOTAL_PASSED ($([ $TOTAL_PASSED -gt 0 ] && echo "$((TOTAL_PASSED * 100 / TOTAL_TESTS))" || echo 0)%)"
echo "  Упало: $TOTAL_FAILED ($([ $TOTAL_FAILED -gt 0 ] && echo "$((TOTAL_FAILED * 100 / TOTAL_TESTS))" || echo 0)%)"
echo ""
echo "✅ Результаты сохранены в: $RESULTS_DIR"
echo ""

# Генерация отчета покрытия
echo "📈 Генерация отчета покрытия..."
if [ -f "$RESULTS_DIR/unit-tests.xcresult" ]; then
    xcrun xccov view --report "$RESULTS_DIR/unit-tests.xcresult" > "$RESULTS_DIR/coverage-report.txt" 2>/dev/null || echo "Не удалось сгенерировать отчет покрытия"
fi

echo "✅ ТЕСТИРОВАНИЕ ЗАВЕРШЕНО!" 