#!/bin/bash

# Быстрый запуск одного UI теста с таймаутом
# Использование: ./scripts/test-quick-ui.sh TestClass/testMethod

TEST_NAME="$1"
TIMEOUT_SECONDS="${2:-60}"

if [ -z "$TEST_NAME" ]; then
    echo "❌ Укажите имя теста"
    echo "Использование: $0 TestClass/testMethod [timeout_seconds]"
    echo "Пример: $0 LMSUITests/OnboardingFlowUITests/testViewOnboardingDashboard 120"
    exit 1
fi

echo "⚡ Быстрый запуск UI теста"
echo "🎯 Тест: $TEST_NAME"
echo "⏱️  Таймаут: $TIMEOUT_SECONDS секунд"
echo ""

# Очистка возможных зависших процессов
echo "🧹 Очистка старых процессов..."
pkill -f "xctest" 2>/dev/null || true
pkill -f "XCTestAgent" 2>/dev/null || true

# Запуск симулятора если не запущен
echo "📱 Запуск симулятора..."
open -a Simulator
sleep 3

# Подготовка временного файла для вывода
TEMP_LOG=$(mktemp)
echo "📝 Лог: $TEMP_LOG"
echo ""

# Запуск теста в фоне
echo "▶️  Запуск теста..."
xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -only-testing:"$TEST_NAME" \
    -parallel-testing-enabled NO \
    -maximum-concurrent-test-simulator-destinations 1 \
    2>&1 | tee "$TEMP_LOG" &

# Сохраняем PID процесса
TEST_PID=$!

# Ждем завершения теста или таймаута
SECONDS_WAITED=0
while [ $SECONDS_WAITED -lt $TIMEOUT_SECONDS ]; do
    if ! kill -0 $TEST_PID 2>/dev/null; then
        # Процесс завершился
        wait $TEST_PID
        EXIT_CODE=$?
        break
    fi
    sleep 1
    ((SECONDS_WAITED++))
    
    # Показываем прогресс каждые 10 секунд
    if [ $((SECONDS_WAITED % 10)) -eq 0 ]; then
        echo "⏳ Прошло $SECONDS_WAITED секунд..."
    fi
done

# Если процесс все еще работает - убиваем его
if kill -0 $TEST_PID 2>/dev/null; then
    echo ""
    echo "⏰ Таймаут! Останавливаем тест..."
    kill -TERM $TEST_PID 2>/dev/null
    sleep 2
    kill -KILL $TEST_PID 2>/dev/null
    
    # Очистка зависших процессов
    pkill -f "xctest" 2>/dev/null || true
    pkill -f "XCTestAgent" 2>/dev/null || true
    
    EXIT_CODE=124  # Стандартный код для таймаута
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Проверка результата
if [ ${EXIT_CODE:-1} -eq 0 ]; then
    echo "✅ Тест прошел успешно!"
elif [ ${EXIT_CODE:-1} -eq 124 ]; then
    echo "⏰ Тест превысил таймаут ($TIMEOUT_SECONDS сек)"
else
    echo "❌ Тест провалился (код: ${EXIT_CODE:-1})"
fi

# Показать последние строки лога
echo ""
echo "📋 Последние строки лога:"
tail -20 "$TEMP_LOG" | grep -E "(Test Case|passed|failed|error)" || tail -10 "$TEMP_LOG"

# Очистка
rm -f "$TEMP_LOG"

exit ${EXIT_CODE:-1} 