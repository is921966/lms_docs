#!/bin/bash

# run-all-ios-tests.sh - Запуск всех iOS тестов с отчетом о покрытии
# Sprint 28: Technical Debt & Stabilization

set -e

echo "🧪 Sprint 28: Запуск всех iOS тестов"
echo "=================================="
echo ""

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Переменные
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA_PATH="$PROJECT_DIR/DerivedData"
COVERAGE_PATH="$PROJECT_DIR/TestResults/Coverage"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Функция для вывода прогресса
print_progress() {
    echo -e "${YELLOW}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Очистка предыдущих результатов
print_progress "Очистка предыдущих результатов..."
rm -rf "$DERIVED_DATA_PATH"
rm -rf "$COVERAGE_PATH"
mkdir -p "$COVERAGE_PATH"

# Запуск Unit тестов
echo ""
echo "📋 Unit Tests"
echo "-------------"

print_progress "Запуск Unit тестов..."
START_TIME=$(date +%s)

if xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -enableCodeCoverage YES \
    -quiet \
    2>&1 | tee "$COVERAGE_PATH/unit_tests_$TIMESTAMP.log"; then
    
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    print_success "Unit тесты пройдены за $DURATION секунд"
else
    print_error "Unit тесты провалены!"
    exit 1
fi

# Генерация отчета о покрытии
echo ""
echo "📊 Code Coverage"
echo "----------------"

print_progress "Генерация отчета о покрытии..."

# Поиск файла с результатами покрытия
PROFDATA=$(find "$DERIVED_DATA_PATH" -name '*.profdata' | head -n 1)
BINARY=$(find "$DERIVED_DATA_PATH" -name 'LMS.app' -path '*/Debug-iphonesimulator/*' | head -n 1)/LMS

if [ -f "$PROFDATA" ] && [ -f "$BINARY" ]; then
    # Генерация отчета
    xcrun llvm-cov report \
        "$BINARY" \
        -instr-profile="$PROFDATA" \
        -ignore-filename-regex='.*Tests.*' \
        -ignore-filename-regex='.*Mock.*' \
        > "$COVERAGE_PATH/coverage_report_$TIMESTAMP.txt"
    
    # Показать краткую статистику
    echo ""
    echo "Покрытие по модулям:"
    xcrun llvm-cov report \
        "$BINARY" \
        -instr-profile="$PROFDATA" \
        -ignore-filename-regex='.*Tests.*' \
        -ignore-filename-regex='.*Mock.*' \
        | grep -E "(Services|Models|ViewModels|Features)" | head -20
    
    # Генерация HTML отчета
    print_progress "Генерация HTML отчета..."
    xcrun llvm-cov show \
        "$BINARY" \
        -instr-profile="$PROFDATA" \
        -format=html \
        -output-dir="$COVERAGE_PATH/html_$TIMESTAMP" \
        -ignore-filename-regex='.*Tests.*' \
        -ignore-filename-regex='.*Mock.*'
    
    print_success "HTML отчет создан: $COVERAGE_PATH/html_$TIMESTAMP/index.html"
else
    print_error "Не удалось найти данные покрытия"
fi

# Запуск UI тестов (если есть)
echo ""
echo "🖥️ UI Tests"
echo "-----------"

if [ -d "$PROJECT_DIR/LMSUITests" ]; then
    print_progress "Запуск UI тестов..."
    START_TIME=$(date +%s)
    
    if xcodebuild test \
        -scheme LMS \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
        -derivedDataPath "$DERIVED_DATA_PATH" \
        -testPlan "UITests" \
        -quiet \
        2>&1 | tee "$COVERAGE_PATH/ui_tests_$TIMESTAMP.log"; then
        
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        print_success "UI тесты пройдены за $DURATION секунд"
    else
        print_error "UI тесты провалены!"
        # Не выходим, так как UI тесты могут быть нестабильными
    fi
else
    print_progress "UI тесты не найдены"
fi

# Итоговый отчет
echo ""
echo "📈 Итоговый отчет"
echo "================="

# Подсчет количества тестов
TOTAL_TESTS=$(grep -E "Test Case .* passed|failed" "$COVERAGE_PATH/unit_tests_$TIMESTAMP.log" | wc -l | tr -d ' ')
PASSED_TESTS=$(grep -E "Test Case .* passed" "$COVERAGE_PATH/unit_tests_$TIMESTAMP.log" | wc -l | tr -d ' ')
FAILED_TESTS=$(grep -E "Test Case .* failed" "$COVERAGE_PATH/unit_tests_$TIMESTAMP.log" | wc -l | tr -d ' ')

echo "Всего тестов: $TOTAL_TESTS"
echo "✅ Пройдено: $PASSED_TESTS"
echo "❌ Провалено: $FAILED_TESTS"

# Общее покрытие
if [ -f "$COVERAGE_PATH/coverage_report_$TIMESTAMP.txt" ]; then
    TOTAL_COVERAGE=$(tail -1 "$COVERAGE_PATH/coverage_report_$TIMESTAMP.txt" | awk '{print $(NF-1)}')
    echo ""
    echo "📊 Общее покрытие кода: $TOTAL_COVERAGE"
fi

# Сохранение результатов
echo ""
echo "💾 Результаты сохранены:"
echo "- Логи: $COVERAGE_PATH/*_$TIMESTAMP.log"
echo "- Отчет о покрытии: $COVERAGE_PATH/coverage_report_$TIMESTAMP.txt"
echo "- HTML отчет: $COVERAGE_PATH/html_$TIMESTAMP/index.html"

# Открыть HTML отчет в браузере
if [ -d "$COVERAGE_PATH/html_$TIMESTAMP" ]; then
    echo ""
    read -p "Открыть HTML отчет в браузере? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "$COVERAGE_PATH/html_$TIMESTAMP/index.html"
    fi
fi

echo ""
print_success "Тестирование завершено!" 