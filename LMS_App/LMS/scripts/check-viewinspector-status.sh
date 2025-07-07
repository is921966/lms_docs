#!/bin/bash

# 🔍 Скрипт проверки статуса интеграции ViewInspector

echo "🔍 ViewInspector Integration Status Check"
echo "========================================"
echo ""

# Цвета
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 1. Проверка отключенных тестов
echo "📋 1. Отключенные тесты:"
echo "------------------------"
disabled_count=$(find LMSTests -name "*.swift.disabled" -type f | wc -l | tr -d ' ')

if [ "$disabled_count" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Найдено отключенных файлов: $disabled_count${NC}"
    find LMSTests -name "*.swift.disabled" -type f | while read -r file; do
        basename_file=$(basename "$file")
        if [[ "$basename_file" == *"ViewInspector"* ]]; then
            echo -e "   ${RED}❌${NC} $basename_file (ViewInspector test)"
        else
            echo -e "   ${YELLOW}⚠️${NC} $basename_file (другой тест)"
        fi
    done
else
    echo -e "${GREEN}✅ Все тесты включены${NC}"
fi
echo ""

# 2. Проверка Package.swift
echo "📦 2. Package.swift:"
echo "-------------------"
if [ -f "Package.swift" ]; then
    if grep -q "ViewInspector" Package.swift; then
        echo -e "${GREEN}✅ ViewInspector добавлен в Package.swift${NC}"
        version=$(grep -A2 'ViewInspector' Package.swift | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        echo "   Версия: $version"
    else
        echo -e "${RED}❌ ViewInspector НЕ найден в Package.swift${NC}"
    fi
else
    echo -e "${RED}❌ Package.swift не найден${NC}"
fi
echo ""

# 3. Проверка Xcode проекта
echo "🛠️  3. Xcode Project:"
echo "-------------------"
if grep -q "ViewInspector" LMS.xcodeproj/project.pbxproj 2>/dev/null; then
    echo -e "${GREEN}✅ ViewInspector интегрирован в Xcode проект${NC}"
    
    # Проверка привязки к таргетам
    if grep -B5 -A5 "ViewInspector" LMS.xcodeproj/project.pbxproj | grep -q "LMSTests"; then
        echo -e "   ${GREEN}✅ Привязан к таргету LMSTests${NC}"
    else
        echo -e "   ${YELLOW}⚠️  Проверьте привязку к таргету LMSTests${NC}"
    fi
else
    echo -e "${RED}❌ ViewInspector НЕ интегрирован в Xcode проект${NC}"
    echo "   Требуется добавить через Xcode UI"
fi
echo ""

# 4. Статистика тестов
echo "📊 4. Статистика тестов:"
echo "-----------------------"
total_tests=$(find LMSTests -name "*.swift" ! -name "*.disabled" -type f | wc -l | tr -d ' ')
viewinspector_tests=$(find LMSTests -name "*ViewInspectorTests.swift" ! -name "*.disabled" -type f | wc -l | tr -d ' ')
disabled_vi_tests=$(find LMSTests -name "*ViewInspectorTests.swift.disabled" -type f | wc -l | tr -d ' ')

echo "• Активных тестовых файлов: $total_tests"
echo "• Активных ViewInspector тестов: $viewinspector_tests"
echo "• Отключенных ViewInspector тестов: $disabled_vi_tests"

if [ "$viewinspector_tests" -gt 0 ]; then
    echo -e "${GREEN}✅ ViewInspector тесты активны${NC}"
else
    echo -e "${YELLOW}⚠️  ViewInspector тесты не активны${NC}"
fi
echo ""

# 5. Готовность к запуску
echo "🚀 5. Готовность к запуску:"
echo "--------------------------"

ready=true
issues=()

if [ "$disabled_count" -gt 0 ]; then
    ready=false
    issues+=("Включите отключенные тесты")
fi

if ! grep -q "ViewInspector" LMS.xcodeproj/project.pbxproj 2>/dev/null; then
    ready=false
    issues+=("Добавьте ViewInspector в Xcode")
fi

if [ "$ready" = true ]; then
    echo -e "${GREEN}✅ Система готова к запуску тестов!${NC}"
    echo ""
    echo "Запустите тесты:"
    echo -e "${BLUE}./run-tests-with-coverage.sh${NC}"
else
    echo -e "${RED}❌ Система НЕ готова${NC}"
    echo ""
    echo "Необходимо выполнить:"
    for issue in "${issues[@]}"; do
        echo "   • $issue"
    done
    echo ""
    echo "Инструкции:"
    echo -e "${YELLOW}./scripts/enable-viewinspector-tests.sh${NC} - для автоматической части"
    echo -e "${YELLOW}VIEWINSPECTOR_XCODE_INTEGRATION_GUIDE.md${NC} - для ручной части"
fi
echo ""

# 6. Последняя сборка
echo "📅 6. Информация о последней сборке:"
echo "-----------------------------------"
latest_log=$(ls -t test_output_*.log 2>/dev/null | head -1)
if [ ! -z "$latest_log" ]; then
    echo "Последний лог: $latest_log"
    echo "Дата: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$latest_log" 2>/dev/null || date -r "$latest_log" 2>/dev/null || echo "неизвестно")"
    
    # Попробуем найти результаты
    if grep -q "Test Suite.*passed" "$latest_log" 2>/dev/null; then
        passed=$(grep -E "Test Suite.*passed" "$latest_log" | tail -1)
        echo -e "${GREEN}Результат: $passed${NC}"
    fi
else
    echo "Логи тестов не найдены"
fi

echo ""
echo "========================================" 