#!/bin/bash

# Скрипт для тестирования импорта Cmi5 пакетов

echo "🧪 Тестирование импорта Cmi5 пакетов..."
echo "======================================="

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для запуска тестов
run_test() {
    local test_name=$1
    local test_class=$2
    local test_method=$3
    
    echo -e "\n${YELLOW}▶ Запуск: $test_name${NC}"
    
    if [ -z "$test_method" ]; then
        # Запуск всего класса тестов
        xcodebuild test \
            -scheme LMS \
            -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
            -only-testing:LMSTests/$test_class \
            -quiet | xcpretty
    else
        # Запуск конкретного метода
        xcodebuild test \
            -scheme LMS \
            -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
            -only-testing:LMSTests/$test_class/$test_method \
            -quiet | xcpretty
    fi
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo -e "${GREEN}✅ $test_name - PASSED${NC}"
        return 0
    else
        echo -e "${RED}❌ $test_name - FAILED${NC}"
        return 1
    fi
}

# Функция для запуска UI тестов
run_ui_test() {
    local test_name=$1
    local test_class=$2
    local test_method=$3
    
    echo -e "\n${YELLOW}▶ Запуск UI теста: $test_name${NC}"
    
    if [ -z "$test_method" ]; then
        # Запуск всего класса тестов
        xcodebuild test \
            -scheme LMS \
            -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
            -only-testing:LMSUITests/$test_class \
            -quiet | xcpretty
    else
        # Запуск конкретного метода
        xcodebuild test \
            -scheme LMS \
            -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
            -only-testing:LMSUITests/$test_class/$test_method \
            -quiet | xcpretty
    fi
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo -e "${GREEN}✅ $test_name - PASSED${NC}"
        return 0
    else
        echo -e "${RED}❌ $test_name - FAILED${NC}"
        return 1
    fi
}

# Счетчики результатов
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Unit тесты

echo -e "\n${YELLOW}🔧 Unit тесты${NC}"
echo "----------------"

# Тест парсера
run_test "Cmi5 Parser" "Cmi5ParserTests"
if [ $? -eq 0 ]; then ((PASSED_TESTS++)); else ((FAILED_TESTS++)); fi
((TOTAL_TESTS++))

# Тест моделей
run_test "Cmi5 Models" "Cmi5ModelsTests"
if [ $? -eq 0 ]; then ((PASSED_TESTS++)); else ((FAILED_TESTS++)); fi
((TOTAL_TESTS++))

# Тест сервиса
run_test "Cmi5 Service" "Cmi5ServiceTests"
if [ $? -eq 0 ]; then ((PASSED_TESTS++)); else ((FAILED_TESTS++)); fi
((TOTAL_TESTS++))

# Интеграционные тесты

echo -e "\n${YELLOW}🔗 Интеграционные тесты${NC}"
echo "-------------------------"

# Тест полного цикла импорта
run_test "Import Integration" "Cmi5ImportIntegrationTests" "testImportPackageFullCycle"
if [ $? -eq 0 ]; then ((PASSED_TESTS++)); else ((FAILED_TESTS++)); fi
((TOTAL_TESTS++))

# Тест валидации
run_test "Import Validation" "Cmi5ImportIntegrationTests" "testImportInvalidPackage"
if [ $? -eq 0 ]; then ((PASSED_TESTS++)); else ((FAILED_TESTS++)); fi
((TOTAL_TESTS++))

# UI тесты

echo -e "\n${YELLOW}📱 UI тесты${NC}"
echo "------------"

# Тест UI импорта
run_ui_test "Import UI Flow" "Cmi5ImportUITests" "testCmi5ImportFlow"
if [ $? -eq 0 ]; then ((PASSED_TESTS++)); else ((FAILED_TESTS++)); fi
((TOTAL_TESTS++))

# Тест отображения списка
run_ui_test "Package List UI" "Cmi5ImportUITests" "testCmi5PackageListDisplay"
if [ $? -eq 0 ]; then ((PASSED_TESTS++)); else ((FAILED_TESTS++)); fi
((TOTAL_TESTS++))

# Итоговый отчет

echo -e "\n${YELLOW}📊 Итоговый отчет${NC}"
echo "=================="
echo -e "Всего тестов: $TOTAL_TESTS"
echo -e "${GREEN}Пройдено: $PASSED_TESTS${NC}"
echo -e "${RED}Провалено: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}🎉 Все тесты пройдены успешно!${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️  Некоторые тесты провалились${NC}"
    exit 1
fi 