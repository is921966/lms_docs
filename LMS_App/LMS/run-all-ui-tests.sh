#!/bin/bash

# Скрипт для запуска всех UI тестов LMS приложения
# Использование: ./run-all-ui-tests.sh

echo "🚀 Запуск всех UI тестов LMS..."
echo "================================"

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Переменные
PROJECT_PATH="LMS.xcodeproj"
SCHEME="LMS"
DESTINATION="platform=iOS Simulator,name=iPhone 16 Pro"
RESULT_BUNDLE_PATH="TestResults/AllUITests.xcresult"

# Проверка наличия проекта
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}❌ Ошибка: Проект не найден. Запустите скрипт из директории LMS_App/LMS${NC}"
    exit 1
fi

# Создание директории для результатов
mkdir -p TestResults

# Функция для запуска тестов
run_test_suite() {
    local test_class=$1
    local description=$2
    
    echo -e "\n${YELLOW}▶️  Запуск $description...${NC}"
    
    # Запуск тестов
    xcodebuild test \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:LMSUITests/$test_class \
        -resultBundlePath "$RESULT_BUNDLE_PATH" \
        -quiet | grep -E "Test Case|passed|failed|error"
    
    # Проверка результата
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo -e "${GREEN}✅ $description - ПРОЙДЕНО${NC}"
        return 0
    else
        echo -e "${RED}❌ $description - ПРОВАЛЕНО${NC}"
        return 1
    fi
}

# Запуск базовой компиляции
echo -e "\n${YELLOW}🔨 Компиляция проекта...${NC}"
xcodebuild build-for-testing \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -quiet

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка компиляции${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Компиляция успешна${NC}"

# Счетчики
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

# Запуск всех тестовых наборов
echo -e "\n${YELLOW}🧪 Запуск тестовых наборов...${NC}"
echo "================================"

# Phase 1-3: Основные тесты
run_test_suite "ComprehensiveUITests" "Основные UI тесты (Phase 1-3)"
[ $? -eq 0 ] && ((PASSED_SUITES++)) || ((FAILED_SUITES++))
((TOTAL_SUITES++))

# Phase 4: Дополнительные тесты
run_test_suite "Phase4ComprehensiveTests" "Дополнительные тесты (Phase 4)"
[ $? -eq 0 ] && ((PASSED_SUITES++)) || ((FAILED_SUITES++))
((TOTAL_SUITES++))

# Специфические тесты модулей
run_test_suite "CompetencyManagementUITests" "Тесты управления компетенциями"
[ $? -eq 0 ] && ((PASSED_SUITES++)) || ((FAILED_SUITES++))
((TOTAL_SUITES++))

run_test_suite "PositionManagementUITests" "Тесты управления должностями"
[ $? -eq 0 ] && ((PASSED_SUITES++)) || ((FAILED_SUITES++))
((TOTAL_SUITES++))

run_test_suite "UserManagementUITests" "Тесты управления пользователями"
[ $? -eq 0 ] && ((PASSED_SUITES++)) || ((FAILED_SUITES++))
((TOTAL_SUITES++))

run_test_suite "CourseMaterialsUITests" "Тесты материалов курсов"
[ $? -eq 0 ] && ((PASSED_SUITES++)) || ((FAILED_SUITES++))
((TOTAL_SUITES++))

run_test_suite "OnboardingProgramTests" "Тесты программ адаптации"
[ $? -eq 0 ] && ((PASSED_SUITES++)) || ((FAILED_SUITES++))
((TOTAL_SUITES++))

run_test_suite "AnalyticsUITests" "Тесты аналитики"
[ $? -eq 0 ] && ((PASSED_SUITES++)) || ((FAILED_SUITES++))
((TOTAL_SUITES++))

# Edge cases
run_test_suite "EdgeCaseTests" "Тесты граничных случаев"
[ $? -eq 0 ] && ((PASSED_SUITES++)) || ((FAILED_SUITES++))
((TOTAL_SUITES++))

# Итоговый отчет
echo -e "\n================================"
echo -e "${YELLOW}📊 ИТОГОВЫЙ ОТЧЕТ${NC}"
echo "================================"
echo -e "Всего тестовых наборов: $TOTAL_SUITES"
echo -e "${GREEN}✅ Пройдено: $PASSED_SUITES${NC}"
echo -e "${RED}❌ Провалено: $FAILED_SUITES${NC}"

# Расчет процента успешности
if [ $TOTAL_SUITES -gt 0 ]; then
    SUCCESS_RATE=$((PASSED_SUITES * 100 / TOTAL_SUITES))
    echo -e "\nПроцент успешности: ${SUCCESS_RATE}%"
    
    if [ $SUCCESS_RATE -eq 100 ]; then
        echo -e "\n${GREEN}🎉 Все тесты пройдены успешно!${NC}"
        echo -e "${GREEN}✨ MVP готов к релизу!${NC}"
    elif [ $SUCCESS_RATE -ge 80 ]; then
        echo -e "\n${YELLOW}⚠️  Большинство тестов пройдено, но есть проблемы${NC}"
    else
        echo -e "\n${RED}🚨 Критические проблемы с тестами${NC}"
    fi
fi

# Генерация HTML отчета
echo -e "\n${YELLOW}📄 Генерация отчета...${NC}"
xcrun xcresulttool graph --path "$RESULT_BUNDLE_PATH" > /dev/null 2>&1

# Открытие результатов в Xcode (опционально)
echo -e "\nДля просмотра детальных результатов выполните:"
echo -e "${YELLOW}open $RESULT_BUNDLE_PATH${NC}"

# Сохранение времени выполнения
END_TIME=$(date +%s)
if [ -f ".test_start_time" ]; then
    START_TIME=$(cat .test_start_time)
    DURATION=$((END_TIME - START_TIME))
    echo -e "\nВремя выполнения: $((DURATION / 60)) минут $((DURATION % 60)) секунд"
    rm .test_start_time
fi

# Возврат кода ошибки для CI/CD
if [ $FAILED_SUITES -gt 0 ]; then
    exit 1
else
    exit 0
fi 