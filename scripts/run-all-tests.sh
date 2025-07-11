#!/bin/bash
# Test Runner с TDD метриками
# Версия: 1.0.0
# Дата: 2025-07-07

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          🧪 TDD Test Runner v1.0.0                     ║${NC}"
echo -e "${BLUE}║          Качество > Количество. Всегда.                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Засекаем время
START_TIME=$(date +%s)

# Переменные для статистики
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
TEST_FILES=0
TDD_COMPLIANCE="UNKNOWN"

# Проверяем, в какой директории мы находимся
if [ -d "LMS_App/LMS" ]; then
    echo -e "${YELLOW}📁 Найден iOS проект${NC}"
    PROJECT_TYPE="ios"
    cd LMS_App/LMS
elif [ -f "phpunit.xml" ] || [ -f "phpunit.xml.dist" ]; then
    echo -e "${YELLOW}📁 Найден PHP проект${NC}"
    PROJECT_TYPE="php"
else
    echo -e "${RED}❌ Не найден проект для тестирования${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🔍 Запуск тестов...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Запуск тестов в зависимости от типа проекта
if [ "$PROJECT_TYPE" == "ios" ]; then
    # Создаем временный файл для логов
    TEST_LOG=$(mktemp)
    
    # Запускаем тесты
    xcodebuild test \
        -scheme LMS \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
        -enableCodeCoverage YES \
        -resultBundlePath testResults.xcresult \
        2>&1 | tee "$TEST_LOG" | grep -E "Test Suite|Test Case.*started|passed|failed|Executed"
    
    TEST_RESULT=${PIPESTATUS[0]}
    
    # Парсим результаты
    if [ -f "$TEST_LOG" ]; then
        TOTAL_TESTS=$(grep -E "Executed [0-9]+ test" "$TEST_LOG" | grep -oE "[0-9]+" | tail -1)
        PASSED_TESTS=$(grep -c "Test Case.*passed" "$TEST_LOG")
        FAILED_TESTS=$(grep -c "Test Case.*failed" "$TEST_LOG")
        TEST_FILES=$(find . -name "*Test.swift" -o -name "*Tests.swift" | wc -l | tr -d ' ')
        
        # Получаем покрытие кода если доступно
        if [ -d "testResults.xcresult" ]; then
            COVERAGE=$(xcrun xccov view --report --json testResults.xcresult 2>/dev/null | jq '.lineCoverage * 100' 2>/dev/null | cut -d. -f1)
        fi
    fi
    
    rm -f "$TEST_LOG"
    
elif [ "$PROJECT_TYPE" == "php" ]; then
    # PHP тесты
    if [ -f "test-quick.sh" ]; then
        ./test-quick.sh | tee test_output.log
        TEST_RESULT=${PIPESTATUS[0]}
    else
        ./vendor/bin/phpunit --coverage-text | tee test_output.log
        TEST_RESULT=${PIPESTATUS[0]}
    fi
    
    # Парсим результаты PHPUnit
    if [ -f "test_output.log" ]; then
        TOTAL_TESTS=$(grep -E "Tests: [0-9]+" test_output.log | grep -oE "[0-9]+" | head -1)
        PASSED_TESTS=$((TOTAL_TESTS - $(grep -E "Failures: [0-9]+" test_output.log | grep -oE "[0-9]+" | head -1 || echo 0)))
        FAILED_TESTS=$(grep -E "Failures: [0-9]+" test_output.log | grep -oE "[0-9]+" | head -1 || echo 0)
        TEST_FILES=$(find tests -name "*Test.php" | wc -l | tr -d ' ')
        COVERAGE=$(grep -E "Lines:.*[0-9]+\.[0-9]+%" test_output.log | grep -oE "[0-9]+\.[0-9]+" | head -1)
    fi
    
    rm -f test_output.log
fi

# Вычисляем время выполнения
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Определяем TDD compliance
if [ "$FAILED_TESTS" -eq 0 ] && [ "$TOTAL_TESTS" -gt 0 ]; then
    TDD_COMPLIANCE="✅ COMPLIANT"
    COMPLIANCE_COLOR=$GREEN
else
    TDD_COMPLIANCE="❌ NON-COMPLIANT"
    COMPLIANCE_COLOR=$RED
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Выводим результаты
echo -e "${PURPLE}📊 РЕЗУЛЬТАТЫ ТЕСТИРОВАНИЯ${NC}"
echo -e "${PURPLE}══════════════════════════${NC}"
echo ""

if [ "$TEST_RESULT" -eq 0 ]; then
    echo -e "${GREEN}✅ ВСЕ ТЕСТЫ ПРОШЛИ УСПЕШНО!${NC}"
else
    echo -e "${RED}❌ ЕСТЬ ПАДАЮЩИЕ ТЕСТЫ!${NC}"
fi

echo ""
echo -e "📈 ${BLUE}Статистика:${NC}"
echo -e "   • Всего тестов: ${YELLOW}$TOTAL_TESTS${NC}"
echo -e "   • Успешных: ${GREEN}$PASSED_TESTS${NC}"
echo -e "   • Провалено: ${RED}$FAILED_TESTS${NC}"
echo -e "   • Тестовых файлов: ${BLUE}$TEST_FILES${NC}"
if [ ! -z "$COVERAGE" ]; then
    echo -e "   • Покрытие кода: ${PURPLE}${COVERAGE}%${NC}"
fi
echo -e "   • Время выполнения: ${YELLOW}${DURATION}с${NC}"

echo ""
echo -e "🎯 ${BLUE}TDD Метрики:${NC}"
echo -e "   • TDD Compliance: ${COMPLIANCE_COLOR}${TDD_COMPLIANCE}${NC}"
echo -e "   • Test Stability: ${GREEN}$((PASSED_TESTS * 100 / (TOTAL_TESTS > 0 ? TOTAL_TESTS : 1)))%${NC}"
echo -e "   • Среднее время/тест: ${YELLOW}$(echo "scale=2; $DURATION / ($TOTAL_TESTS > 0 ? $TOTAL_TESTS : 1)" | bc)с${NC}"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Рекомендации
if [ "$FAILED_TESTS" -gt 0 ]; then
    echo ""
    echo -e "${RED}⚠️  ДЕЙСТВИЯ ТРЕБУЮТСЯ:${NC}"
    echo -e "${RED}   1. Исправьте все красные тесты${NC}"
    echo -e "${RED}   2. Запустите тесты повторно${NC}"
    echo -e "${RED}   3. Коммит возможен только с зелеными тестами${NC}"
elif [ "$TOTAL_TESTS" -eq 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Тесты не найдены!${NC}"
    echo -e "${YELLOW}   Начните с написания первого теста${NC}"
else
    echo ""
    echo -e "${GREEN}✨ Отличная работа! Можно коммитить.${NC}"
fi

echo ""
echo -e "${BLUE}💡 Помните о TDD цикле:${NC}"
echo -e "   1. ${RED}RED${NC} → 2. ${GREEN}GREEN${NC} → 3. ${YELLOW}REFACTOR${NC}"
echo ""

# Возвращаем код ошибки для pre-commit hook
exit $TEST_RESULT 