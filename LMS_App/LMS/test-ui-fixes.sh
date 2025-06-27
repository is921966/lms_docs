#!/bin/bash

# Скрипт для тестирования UI исправлений
# Проверяет: обрезанные тексты и дублирование навигации

echo "🧪 Запуск тестов UI исправлений..."
echo "================================="
echo ""

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для проверки результата
check_result() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
        exit 1
    fi
}

# 1. Запуск специфических UI тестов
echo -e "${YELLOW}1. Тестирование обрезанных текстов...${NC}"
xcodebuild test \
    -project LMS.xcodeproj \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -only-testing:LMSUITests/AdminContentViewTests/testContentTypeCardTexts \
    -only-testing:LMSUITests/OnboardingTests/testCreateFromTemplateButton \
    -only-testing:LMSUITests/OnboardingTests/testProgramCardTitles \
    -quiet
check_result "Тесты обрезанных текстов"

echo ""
echo -e "${YELLOW}2. Тестирование дублирования навигации...${NC}"
xcodebuild test \
    -project LMS.xcodeproj \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -only-testing:LMSUITests/FeedTests/testCreatePostNavigationNoDuplication \
    -quiet
check_result "Тест дублирования навигации"

echo ""
echo -e "${YELLOW}3. Запуск скриншот-тестов...${NC}"
# Создаем директорию для скриншотов
mkdir -p TestScreenshots

# Запускаем тесты со скриншотами
xcodebuild test \
    -project LMS.xcodeproj \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -only-testing:LMSUITests/ScreenshotTests \
    -resultBundlePath TestResults/UIFixesScreenshots.xcresult \
    -quiet
check_result "Скриншот-тесты"

echo ""
echo -e "${GREEN}✅ Все тесты UI исправлений прошли успешно!${NC}"
echo ""
echo "📸 Скриншоты сохранены в: TestScreenshots/"
echo "📊 Результаты тестов: TestResults/UIFixesScreenshots.xcresult"
echo ""
echo "Для просмотра результатов выполните:"
echo "open TestResults/UIFixesScreenshots.xcresult" 