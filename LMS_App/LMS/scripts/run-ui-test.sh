#!/bin/bash

# Usage: ./run-ui-test.sh <TestClass> [TestMethod]
# Example: ./run-ui-test.sh CourseManagementUITests testCourseListDisplay

if [ $# -eq 0 ]; then
    echo "Usage: $0 <TestClass> [TestMethod]"
    echo "Example: $0 CourseManagementUITests testCourseListDisplay"
    exit 1
fi

TEST_CLASS=$1
TEST_METHOD=$2
DEVICE_ID="C0F60722-8F57-46A8-A737-2A1CD8819E8E"

echo "🧪 Запуск UI теста: $TEST_CLASS${TEST_METHOD:+/$TEST_METHOD}"
echo "================================================"

# 1. Ensure simulator is running
echo "📱 Проверка симулятора..."
if ! xcrun simctl list devices | grep "$DEVICE_ID" | grep -q "Booted"; then
    echo "🚀 Запуск симулятора..."
    xcrun simctl boot $DEVICE_ID
    sleep 10
else
    echo "✅ Симулятор уже запущен"
fi

# 2. Install apps if needed
echo "📲 Проверка установленных приложений..."
if ! xcrun simctl listapps $DEVICE_ID 2>/dev/null | grep -q "ru.tsum.lms.igor"; then
    echo "📲 Установка приложения..."
    if [ -d "build/Build/Products/Debug-iphonesimulator/LMS.app" ]; then
        xcrun simctl install $DEVICE_ID build/Build/Products/Debug-iphonesimulator/LMS.app
    else
        echo "⚠️  Приложение не найдено, пересборка..."
        xcodebuild build-for-testing \
            -scheme LMS \
            -destination "id=$DEVICE_ID" \
            -derivedDataPath build \
            CODE_SIGNING_REQUIRED=NO \
            -quiet
        xcrun simctl install $DEVICE_ID build/Build/Products/Debug-iphonesimulator/LMS.app
    fi
fi

if ! xcrun simctl listapps $DEVICE_ID 2>/dev/null | grep -q "ru.tsum.LMSUITests.xctrunner"; then
    echo "📲 Установка test runner..."
    if [ -d "build/Build/Products/Debug-iphonesimulator/LMSUITests-Runner.app" ]; then
        xcrun simctl install $DEVICE_ID build/Build/Products/Debug-iphonesimulator/LMSUITests-Runner.app
    fi
fi

# 3. Run the test
echo ""
echo "🧪 Запуск теста..."
echo "----------------"

if [ -z "$TEST_METHOD" ]; then
    # Run all tests in class
    TEST_SPEC="LMSUITests/$TEST_CLASS"
else
    # Run specific test method
    TEST_SPEC="LMSUITests/$TEST_CLASS/$TEST_METHOD"
fi

xcodebuild test \
    -scheme LMS \
    -destination "id=$DEVICE_ID" \
    -only-testing:"$TEST_SPEC" \
    -test-timeouts-enabled NO \
    2>&1 | tee test_output.log | \
    grep -E "(Test case|passed|failed|error|Assertion|Expected|Actual)" | \
    sed 's/^/  /'

# 4. Show summary
echo ""
echo "📊 Результаты:"
echo "-------------"
PASSED=$(grep -c "Test case.*passed" test_output.log || echo 0)
FAILED=$(grep -c "Test case.*failed" test_output.log || echo 0)
TOTAL=$((PASSED + FAILED))

echo "Всего тестов: $TOTAL"
echo "Прошло: $PASSED"
echo "Упало: $FAILED"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo "❌ Детали ошибок:"
    grep -A5 -B5 "failed\|error\|Assertion" test_output.log | tail -50
fi

# 5. Keep simulator running
echo ""
echo "✅ Симулятор остается запущенным для следующих тестов"

# Cleanup
rm -f test_output.log 