#!/bin/bash

echo "🔍 Анализ покрытия кода проекта LMS..."
echo "========================================"

# Count total lines in main app code
echo "�� Основное приложение (LMS/):"
APP_LINES=$(find LMS -name "*.swift" -type f \
    -not -path "*/Tests/*" \
    -not -path "*/LMSTests/*" \
    -not -path "*/LMSUITests/*" \
    -exec wc -l {} + | tail -1 | awk '{print $1}')
echo "  Всего строк кода: $APP_LINES"

# Count lines by category
echo ""
echo "📂 По категориям:"
echo "  - Services: $(find LMS/Services -name "*.swift" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}') строк"
echo "  - Views: $(find LMS/Views -name "*.swift" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}') строк"
echo "  - ViewModels: $(find LMS/ViewModels -name "*.swift" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}') строк"
echo "  - Models: $(find LMS/Models -name "*.swift" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}') строк"
echo "  - Features: $(find LMS/Features -name "*.swift" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}') строк"

# Count test lines
echo ""
echo "🧪 Тесты (LMSTests/):"
TEST_LINES=$(find LMSTests -name "*.swift" -type f -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
echo "  Всего строк тестов: $TEST_LINES"

# Count test files
echo ""
echo "📊 Статистика тестов:"
echo "  - Тестовых файлов: $(find LMSTests -name "*Tests.swift" -type f | wc -l)"
echo "  - ViewModels тесты: $(find LMSTests/ViewModels -name "*Tests.swift" 2>/dev/null | wc -l)"
echo "  - Services тесты: $(find LMSTests/Services -name "*Tests.swift" 2>/dev/null | wc -l)"
echo "  - Views тесты: $(find LMSTests/Views -name "*Tests.swift" 2>/dev/null | wc -l)"
echo "  - Models тесты: $(find LMSTests/Models -name "*Tests.swift" 2>/dev/null | wc -l)"

# Estimate coverage
echo ""
echo "📈 Оценка покрытия:"
if [ $APP_LINES -gt 0 ]; then
    COVERAGE_RATIO=$(echo "scale=2; $TEST_LINES * 100 / $APP_LINES" | bc)
    echo "  Соотношение тест/код: ${COVERAGE_RATIO}%"
    
    # Rough estimate: 1 line of test covers ~3 lines of code
    ESTIMATED_COVERAGE=$(echo "scale=2; $TEST_LINES * 3 * 100 / $APP_LINES" | bc)
    if (( $(echo "$ESTIMATED_COVERAGE > 100" | bc -l) )); then
        ESTIMATED_COVERAGE="100"
    fi
    echo "  Примерное покрытие: ~${ESTIMATED_COVERAGE}%"
fi

# Count TODO/FIXME
echo ""
echo "⚠️  Технический долг:"
echo "  - TODO: $(grep -r "TODO:" LMS --include="*.swift" 2>/dev/null | wc -l)"
echo "  - FIXME: $(grep -r "FIXME:" LMS --include="*.swift" 2>/dev/null | wc -l)"

echo ""
echo "========================================"
echo "📝 Примечание: Это грубая оценка на основе количества строк."
echo "Для точного покрытия нужно исправить ошибки компиляции тестов."
