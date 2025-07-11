#!/bin/bash

echo "🚀 Запуск исправленных тестов (простая версия)..."
echo "================================================"
echo ""

DEVICE_ID="C0F60722-8F57-46A8-A737-2A1CD8819E8E"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 1. Запуск базовых UI тестов
echo "📱 Запуск базовых UI тестов (которые точно работают)..."
echo "======================================================"

xcodebuild test \
    -scheme LMS \
    -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -only-testing:LMSUITests/BasicLoginTest \
    -only-testing:LMSUITests/SimpleSmokeTest \
    -only-testing:LMSUITests/OnboardingFlowUITests \
    -resultBundlePath "TestResults/BasicUITests_${TIMESTAMP}.xcresult" \
    -quiet

BASIC_RESULT=$?

if [ $BASIC_RESULT -eq 0 ]; then
    echo "✅ Базовые UI тесты прошли успешно!"
else
    echo "❌ Базовые UI тесты провалились"
fi

# 2. Запуск Cmi5 тестов
echo ""
echo "📚 Запуск Cmi5 UI тестов (с исправлениями)..."
echo "==========================================="

xcodebuild test \
    -scheme LMS \
    -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -only-testing:LMSUITests/Cmi5UITests/testCmi5ModuleAccessibility \
    -only-testing:LMSUITests/Cmi5UITests/testPackageListDisplay \
    -resultBundlePath "TestResults/Cmi5UITests_${TIMESTAMP}.xcresult" \
    -quiet

CMI5_RESULT=$?

if [ $CMI5_RESULT -eq 0 ]; then
    echo "✅ Cmi5 тесты прошли успешно!"
else
    echo "❌ Cmi5 тесты провалились"
fi

# 3. Запуск Course Management тестов
echo ""
echo "🎓 Запуск Course Management UI тестов (с исправлениями)..."
echo "========================================================"

xcodebuild test \
    -scheme LMS \
    -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -only-testing:LMSUITests/CourseManagementUITests/testCourseManagementAccess \
    -only-testing:LMSUITests/CourseManagementUITests/testEmptyStateDisplay \
    -resultBundlePath "TestResults/CourseManagementUITests_${TIMESTAMP}.xcresult" \
    -quiet

COURSE_RESULT=$?

if [ $COURSE_RESULT -eq 0 ]; then
    echo "✅ Course Management тесты прошли успешно!"
else
    echo "❌ Course Management тесты провалились"
fi

# 4. Итоговая статистика
echo ""
echo "📊 ИТОГОВЫЕ РЕЗУЛЬТАТЫ"
echo "===================="
echo ""

TOTAL_PASSED=0
TOTAL_FAILED=0

if [ $BASIC_RESULT -eq 0 ]; then
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
    echo "✅ Базовые UI тесты: ПРОШЛИ"
else
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
    echo "❌ Базовые UI тесты: ПРОВАЛЕНЫ"
fi

if [ $CMI5_RESULT -eq 0 ]; then
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
    echo "✅ Cmi5 тесты: ПРОШЛИ"
else
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
    echo "❌ Cmi5 тесты: ПРОВАЛЕНЫ"
fi

if [ $COURSE_RESULT -eq 0 ]; then
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
    echo "✅ Course Management тесты: ПРОШЛИ"
else
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
    echo "❌ Course Management тесты: ПРОВАЛЕНЫ"
fi

echo ""
echo "Всего наборов тестов: 3"
echo "Прошло: $TOTAL_PASSED"
echo "Провалено: $TOTAL_FAILED"
echo ""

# 5. Создание отчета
REPORT_FILE="/Users/ishirokov/lms_docs/reports/SPRINT_45_FIXED_TESTS_SIMPLE_${TIMESTAMP}.md"

cat > "$REPORT_FILE" << EOF
# Sprint 45 - Результаты исправленных тестов

**Дата**: $(date)
**Время**: $(date +%H:%M:%S)

## 📊 Результаты

### Базовые UI тесты
- **Статус**: $([ $BASIC_RESULT -eq 0 ] && echo "✅ ПРОШЛИ" || echo "❌ ПРОВАЛЕНЫ")
- Включены: BasicLoginTest, SimpleSmokeTest, OnboardingFlowUITests

### Cmi5 UI тесты
- **Статус**: $([ $CMI5_RESULT -eq 0 ] && echo "✅ ПРОШЛИ" || echo "❌ ПРОВАЛЕНЫ")
- Протестированы: testCmi5ModuleAccessibility, testPackageListDisplay

### Course Management UI тесты
- **Статус**: $([ $COURSE_RESULT -eq 0 ] && echo "✅ ПРОШЛИ" || echo "❌ ПРОВАЛЕНЫ")
- Протестированы: testCourseManagementAccess, testEmptyStateDisplay

## 📈 Итого

- Всего наборов тестов: 3
- Прошло: $TOTAL_PASSED
- Провалено: $TOTAL_FAILED
- Процент успеха: $(echo "scale=1; $TOTAL_PASSED * 100 / 3" | bc)%

## 🔧 Исправления

1. **Cmi5**: Добавлены тестовые пакеты из /Users/ishirokov/lms_docs/cmi5_courses
2. **Course Management**: Исправлена навигация через меню "Ещё"
3. **Инфраструктура**: Созданы helper классы для тестов
EOF

echo "📄 Отчет сохранен в: $REPORT_FILE"
echo ""
echo "✅ Тестирование завершено!" 