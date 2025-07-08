#!/bin/bash
# Быстрый запуск тестов Cmi5 модуля

echo "🧪 Запуск тестов Cmi5..."
echo "========================="

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Запуск тестов с таймаутом 60 секунд
timeout 60 xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -only-testing:LMSTests/Cmi5PlayerViewTests \
    -derivedDataPath DerivedData \
    2>&1 | grep -E "(Test Suite|Test Case|passed|failed|error:)" | while read line
do
    if [[ $line == *"passed"* ]]; then
        echo -e "${GREEN}✅ $line${NC}"
    elif [[ $line == *"failed"* ]] || [[ $line == *"error:"* ]]; then
        echo -e "${RED}❌ $line${NC}"
    elif [[ $line == *"Test Suite"* ]] || [[ $line == *"Test Case"* ]]; then
        echo -e "${YELLOW}🔍 $line${NC}"
    else
        echo "$line"
    fi
done

# Проверка кода возврата
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "\n${GREEN}✅ Все тесты Cmi5 прошли успешно!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Тесты Cmi5 провалились!${NC}"
    exit 1
fi 