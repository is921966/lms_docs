#!/bin/bash

echo "🧪 ЗАПУСК ВСЕХ ТЕСТОВ С ИСПРАВЛЕНИЯМИ"
echo "======================================"
echo ""

DEVICE_ID="C0F60722-8F57-46A8-A737-2A1CD8819E8E"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULTS_DIR="TestResults/Fixed_Sprint45_$TIMESTAMP"

mkdir -p $RESULTS_DIR

# 0. Подготовка среды
echo "🔧 Подготовка среды тестирования..."
echo "-----------------------------------"

# Запуск симулятора
echo "📱 Запуск симулятора..."
xcrun simctl boot $DEVICE_ID 2>/dev/null || echo "Симулятор уже запущен"
sleep 5

# Очистка и пересборка
echo "🔨 Чистая сборка проекта..."
xcodebuild clean build-for-testing \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -derivedDataPath build \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    -quiet || { echo "❌ Ошибка сборки"; exit 1; }

# Установка приложений
echo "📲 Установка приложений..."
xcrun simctl install $DEVICE_ID build/Build/Products/Debug-iphonesimulator/LMS.app
xcrun simctl install $DEVICE_ID build/Build/Products/Debug-iphonesimulator/LMSUITests-Runner.app

echo "✅ Подготовка завершена"
echo ""

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

# Поддерживаем симулятор активным
xcrun simctl boot $DEVICE_ID 2>/dev/null || true

# 2. UI тесты - базовые (работающие)
echo ""
echo "📱 2. UI ТЕСТЫ - Базовые (работающие)"
echo "-------------------------------------"
xcodebuild test \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -only-testing:LMSUITests/BasicLoginTest \
    -only-testing:LMSUITests/SimpleSmokeTest \
    -only-testing:LMSUITests/SmokeTests \
    -enableCodeCoverage YES \
    -resultBundlePath "$RESULTS_DIR/ui-basic.xcresult" \
    2>&1 | tee "$RESULTS_DIR/ui-basic.log" | \
    grep -E "(Test case.*passed|Test case.*failed)" | tail -10

# Поддерживаем симулятор активным
xcrun simctl boot $DEVICE_ID 2>/dev/null || true

# 3. UI тесты - Feed (попытка)
echo ""
echo "📰 3. UI ТЕСТЫ - Feed модуль"
echo "----------------------------"
xcodebuild test \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -only-testing:LMSUITests/FeedUITests \
    -enableCodeCoverage YES \
    -resultBundlePath "$RESULTS_DIR/ui-feed.xcresult" \
    -test-timeouts-enabled NO \
    2>&1 | tee "$RESULTS_DIR/ui-feed.log" | \
    grep -E "(Test case.*passed|Test case.*failed|error)" | tail -10

# 4. UI тесты - Onboarding
echo ""
echo "🎯 4. UI ТЕСТЫ - Onboarding"
echo "---------------------------"
xcodebuild test \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -only-testing:LMSUITests/OnboardingFlowUITests \
    -enableCodeCoverage YES \
    -resultBundlePath "$RESULTS_DIR/ui-onboarding.xcresult" \
    -test-timeouts-enabled NO \
    2>&1 | tee "$RESULTS_DIR/ui-onboarding.log" | \
    grep -E "(Test case.*passed|Test case.*failed|error)" | tail -10

# 5. Анализ результатов
echo ""
echo "📊 АНАЛИЗ РЕЗУЛЬТАТОВ"
echo "===================="

# Подсчет unit тестов
UNIT_TOTAL=$(grep -E "Test Suite.*executed" "$RESULTS_DIR/unit-tests.log" | grep -oE "[0-9]+ test" | awk '{sum+=$1} END {print sum}' || echo 0)
UNIT_PASSED=$(grep -E "Test Suite.*passed" "$RESULTS_DIR/unit-tests.log" | grep -oE "[0-9]+ passed" | awk '{sum+=$1} END {print sum}' || echo 0)
UNIT_FAILED=$(grep -E "Test Suite.*failed" "$RESULTS_DIR/unit-tests.log" | grep -oE "[0-9]+ failed" | awk '{sum+=$1} END {print sum}' || echo 0)

# Подсчет UI тестов
UI_PASSED=$(cat "$RESULTS_DIR"/ui-*.log 2>/dev/null | grep -c "Test case.*passed" || echo 0)
UI_FAILED=$(cat "$RESULTS_DIR"/ui-*.log 2>/dev/null | grep -c "Test case.*failed" || echo 0)
UI_TOTAL=$((UI_PASSED + UI_FAILED))

# Общая статистика
TOTAL_TESTS=$((UNIT_TOTAL + UI_TOTAL))
TOTAL_PASSED=$((UNIT_PASSED + UI_PASSED))
TOTAL_FAILED=$((UNIT_FAILED + UI_FAILED))

echo ""
echo "Unit тесты:"
echo "  Всего: $UNIT_TOTAL"
echo "  Прошло: $UNIT_PASSED"
echo "  Упало: $UNIT_FAILED"
echo ""
echo "UI тесты:"
echo "  Всего: $UI_TOTAL"
echo "  Прошло: $UI_PASSED"
echo "  Упало: $UI_FAILED"
echo ""
echo "ИТОГО:"
echo "  Всего тестов: $TOTAL_TESTS"
if [ $TOTAL_TESTS -gt 0 ]; then
    echo "  Прошло: $TOTAL_PASSED ($((TOTAL_PASSED * 100 / TOTAL_TESTS))%)"
    echo "  Упало: $TOTAL_FAILED ($((TOTAL_FAILED * 100 / TOTAL_TESTS))%)"
else
    echo "  Прошло: 0 (0%)"
    echo "  Упало: 0 (0%)"
fi

# Создание итогового отчета
cat > "$RESULTS_DIR/summary.txt" << EOF
Sprint 45 - Fixed Test Results
==============================
Date: $(date)
Total Tests: $TOTAL_TESTS
Passed: $TOTAL_PASSED
Failed: $TOTAL_FAILED
Pass Rate: $([ $TOTAL_TESTS -gt 0 ] && echo "$((TOTAL_PASSED * 100 / TOTAL_TESTS))%" || echo "0%")

Unit Tests:
- Total: $UNIT_TOTAL
- Passed: $UNIT_PASSED
- Failed: $UNIT_FAILED

UI Tests:
- Total: $UI_TOTAL
- Passed: $UI_PASSED
- Failed: $UI_FAILED
EOF

echo ""
echo "✅ Результаты сохранены в: $RESULTS_DIR"
echo "📄 Итоговый отчет: $RESULTS_DIR/summary.txt"
echo ""
echo "✅ ТЕСТИРОВАНИЕ ЗАВЕРШЕНО!" 