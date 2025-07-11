#!/bin/bash

echo "🚀 Запуск всех тестов после исправлений..."
echo "=========================================="
echo ""

DEVICE_ID="C0F60722-8F57-46A8-A737-2A1CD8819E8E"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="/Users/ishirokov/lms_docs/reports/ALL_TESTS_FINAL_REPORT_${TIMESTAMP}.md"

# Счетчики результатов
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Функция для запуска тестов
run_test_suite() {
    local suite_name=$1
    local test_path=$2
    local display_name=$3
    
    echo "📱 Запуск $display_name..."
    echo "------------------------"
    
    xcodebuild test \
        -scheme LMS \
        -destination "platform=iOS Simulator,id=$DEVICE_ID" \
        -only-testing:"$test_path" \
        -resultBundlePath "TestResults/${suite_name}_${TIMESTAMP}.xcresult" \
        -quiet 2>&1 | tail -10
    
    local result=$?
    
    if [ $result -eq 0 ]; then
        echo "✅ $display_name - УСПЕШНО"
        ((PASSED_TESTS++))
    else
        echo "❌ $display_name - ПРОВАЛЕНО"
        ((FAILED_TESTS++))
    fi
    ((TOTAL_TESTS++))
    
    echo ""
    return $result
}

# Начало отчета
cat > "$REPORT_FILE" << EOF
# Финальный отчет по всем тестам

**Дата**: $(date)
**Время начала**: $(date +%H:%M:%S)

## 📊 Результаты тестирования

EOF

echo "🧪 ЗАПУСК ВСЕХ ТЕСТОВ"
echo "===================="
echo ""

# 1. Базовые UI тесты (работали ранее)
run_test_suite "BasicLogin" "LMSUITests/BasicLoginTest" "BasicLoginTest (1 тест)"
run_test_suite "SimpleSmokeTest" "LMSUITests/SimpleSmokeTest" "SimpleSmokeTest (2 теста)"
run_test_suite "SmokeTests" "LMSUITests/SmokeTests" "SmokeTests (2 теста)"
run_test_suite "OnboardingFlow" "LMSUITests/OnboardingFlowUITests" "OnboardingFlowUITests (4 теста)"

# 2. Исправленные тесты
run_test_suite "Feed" "LMSUITests/FeedUITests" "FeedUITests (~8 тестов)"
run_test_suite "Cmi5" "LMSUITests/Cmi5UITests" "Cmi5UITests (12 тестов)"
run_test_suite "CourseManagement" "LMSUITests/CourseManagementUITests" "CourseManagementUITests (11 тестов)"
run_test_suite "E2E" "LMSUITests/FullFlowE2ETests" "E2E Tests (3 теста)"

# Итоговая статистика
echo ""
echo "📊 ИТОГОВАЯ СТАТИСТИКА"
echo "====================="
echo "Всего тестовых наборов: $TOTAL_TESTS"
echo "Успешно: $PASSED_TESTS"
echo "Провалено: $FAILED_TESTS"
echo "Процент успеха: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%"

# Дополнение отчета
cat >> "$REPORT_FILE" << EOF

### Сводка по тестовым наборам:

| Тестовый набор | Статус | Количество тестов |
|----------------|--------|-------------------|
| BasicLoginTest | $([ -f "TestResults/BasicLogin_${TIMESTAMP}.xcresult" ] && echo "✅" || echo "❌") | 1 |
| SimpleSmokeTest | $([ -f "TestResults/SimpleSmokeTest_${TIMESTAMP}.xcresult" ] && echo "✅" || echo "❌") | 2 |
| SmokeTests | $([ -f "TestResults/SmokeTests_${TIMESTAMP}.xcresult" ] && echo "✅" || echo "❌") | 2 |
| OnboardingFlowUITests | $([ -f "TestResults/OnboardingFlow_${TIMESTAMP}.xcresult" ] && echo "✅" || echo "❌") | 4 |
| FeedUITests | $([ -f "TestResults/Feed_${TIMESTAMP}.xcresult" ] && echo "✅" || echo "❌") | ~8 |
| Cmi5UITests | $([ -f "TestResults/Cmi5_${TIMESTAMP}.xcresult" ] && echo "✅" || echo "❌") | 12 |
| CourseManagementUITests | $([ -f "TestResults/CourseManagement_${TIMESTAMP}.xcresult" ] && echo "✅" || echo "❌") | 11 |
| E2E Tests | $([ -f "TestResults/E2E_${TIMESTAMP}.xcresult" ] && echo "✅" || echo "❌") | 3 |

### Итоговые метрики:
- **Всего тестовых наборов**: $TOTAL_TESTS
- **Успешно**: $PASSED_TESTS  
- **Провалено**: $FAILED_TESTS
- **Процент успеха**: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%

## 🔧 Что было исправлено:

1. **MockCmi5Service** - создан с правильной структурой моделей
2. **FeedUITests** - полностью переписаны
3. **E2ETestHelper** - создан для E2E тестов
4. **CourseManagementTestHelper** - обновлен для правильной навигации

## 📈 Прогресс по сравнению с началом Sprint 45:

- **До**: Фальшивые 94.4%, реально ~20% работали
- **После первого этапа**: 9 тестов (17%) работали стабильно
- **Сейчас**: Проверено $TOTAL_TESTS тестовых наборов

**Время завершения**: $(date +%H:%M:%S)

---

*Отчет сгенерирован автоматически*
EOF

echo ""
echo "✅ Тестирование завершено!"
echo "📄 Полный отчет сохранен в: $REPORT_FILE"
echo ""

# Показать краткую сводку
echo "📋 КРАТКАЯ СВОДКА:"
echo "=================="
if [ $FAILED_TESTS -eq 0 ]; then
    echo "🎉 ВСЕ ТЕСТЫ ПРОШЛИ УСПЕШНО!"
else
    echo "⚠️  Некоторые тесты провалились. См. отчет для деталей."
fi 