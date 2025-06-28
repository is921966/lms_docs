#!/bin/bash

# Автоматический запуск iOS тестов из правильной директории
# Использование: ./run-ios-tests.sh [test-target]

# Определяем корневую директорию проекта
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
XCODE_PROJECT_DIR="$PROJECT_ROOT/LMS_App/LMS"

# Переходим в директорию с Xcode проектом
cd "$XCODE_PROJECT_DIR" || exit 1

# Параметры по умолчанию
SCHEME="LMS"
DESTINATION="platform=iOS Simulator,name=iPhone 16 Pro"
TEST_TARGET="${1:-LMSUITests}"

echo "🚀 Запуск тестов из директории: $XCODE_PROJECT_DIR"
echo "📱 Схема: $SCHEME"
echo "🎯 Тесты: $TEST_TARGET"

# Создаем временный файл для логов
LOG_FILE="test_run_$(date +%Y%m%d_%H%M%S).log"

# Запускаем тесты
if [ "$TEST_TARGET" = "all" ]; then
    echo "🔄 Запуск всех тестов..."
    xcodebuild test -scheme "$SCHEME" -destination "$DESTINATION" \
        -resultBundlePath "TestResults/AllTests.xcresult" \
        2>&1 | tee "$LOG_FILE"
    TEST_RESULT=${PIPESTATUS[0]}
else
    echo "🔄 Запуск тестов: $TEST_TARGET"
    xcodebuild test -scheme "$SCHEME" -destination "$DESTINATION" \
        -only-testing:"$TEST_TARGET" \
        -resultBundlePath "TestResults/${TEST_TARGET//\//_}.xcresult" \
        2>&1 | tee "$LOG_FILE"
    TEST_RESULT=${PIPESTATUS[0]}
fi

# Проверяем результат правильно
if [ $TEST_RESULT -eq 0 ]; then
    # Дополнительная проверка на "TEST FAILED" в логах
    if grep -q "TEST FAILED" "$LOG_FILE"; then
        echo "❌ Тесты завершились с ошибками (найдено TEST FAILED в логах)"
        exit 1
    else
        echo "✅ Тесты прошли успешно!"
        exit 0
    fi
else
    echo "❌ Тесты завершились с ошибками (код выхода: $TEST_RESULT)"
    exit 1
fi 