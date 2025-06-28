#!/bin/bash

# Быстрый запуск UI тестов с коротким таймаутом
# Использование: ./test-quick-ui.sh [TestClass/testMethod]

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Параметры
TEST_TO_RUN=${1:-"LMSUITests/FeatureRegistryIntegrationTests/testAllMainModulesAreAccessible"}
QUICK_TIMEOUT=60  # 1 минута для быстрых тестов

echo -e "${BLUE}⚡ Быстрый запуск UI теста${NC}"
echo -e "🎯 Тест: ${TEST_TO_RUN}"
echo -e "⏱️  Таймаут: ${QUICK_TIMEOUT} секунд"
echo ""

# Переходим в директорию проекта
cd "$(dirname "$0")/.."

# Убиваем старые процессы симулятора если есть
echo "🧹 Очистка старых процессов..."
pkill -f "Simulator" 2>/dev/null || true
pkill -f "xctest" 2>/dev/null || true

# Запускаем симулятор
echo "📱 Запуск симулятора..."
open -a Simulator --args -CurrentDeviceUDID 899AAE09-580D-4FF5-BF16-3574382CD796

# Ждем пока симулятор запустится
sleep 3

# Запускаем тест с timeout
echo -e "\n${YELLOW}▶️  Запуск теста...${NC}"

# Используем gtimeout если установлен (brew install coreutils)
if command -v gtimeout &> /dev/null; then
    TIMEOUT_CMD="gtimeout"
else
    # Fallback на встроенный timeout
    TIMEOUT_CMD="timeout"
fi

# Запускаем тест
${TIMEOUT_CMD} ${QUICK_TIMEOUT} xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -only-testing:"${TEST_TO_RUN}" \
    2>&1 | tee test_quick_output.log | grep -E "(Test Case|started|passed|failed|\[.*\])" &

TEST_PID=$!

# Ждем завершения
if wait $TEST_PID; then
    echo -e "\n${GREEN}✅ Тест успешно завершен!${NC}"
    exit 0
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 124 ] || [ $EXIT_CODE -eq 143 ]; then
        echo -e "\n${RED}❌ Таймаут! Тест не завершился за ${QUICK_TIMEOUT} секунд${NC}"
        echo -e "${YELLOW}💡 Совет: Попробуйте запустить конкретный тестовый метод${NC}"
        echo -e "${YELLOW}   Пример: ./test-quick-ui.sh LMSUITests/SomeTest/testSpecificMethod${NC}"
    else
        echo -e "\n${RED}❌ Тест провалился (код: ${EXIT_CODE})${NC}"
        
        # Показываем последние строки лога
        echo -e "\n${YELLOW}📋 Последние строки лога:${NC}"
        tail -20 test_quick_output.log | grep -v "^$"
    fi
    exit $EXIT_CODE
fi 