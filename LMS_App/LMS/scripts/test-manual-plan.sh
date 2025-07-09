#!/bin/bash

# Скрипт для запуска автоматических тестов на основе Manual Test Plan

echo "🧪 Запуск автоматических тестов по Manual Test Plan..."
echo "=================================================="

# Проверяем что мы в правильной директории
if [ ! -f "LMS.xcodeproj/project.pbxproj" ]; then
    echo "❌ Ошибка: Запустите скрипт из директории LMS_App/LMS/"
    exit 1
fi

# Опции для запуска
DESTINATION="platform=iOS Simulator,name=iPhone 15,OS=17.0"
SCHEME="LMS"
TIMEOUT=300

# Функция для запуска конкретного теста
run_test() {
    local test_class=$1
    local test_method=$2
    local description=$3
    
    echo ""
    echo "▶️  $description"
    echo "   Класс: $test_class"
    if [ ! -z "$test_method" ]; then
        echo "   Метод: $test_method"
    fi
    echo "   ⏳ Запуск..."
    
    if [ -z "$test_method" ]; then
        # Запуск всех тестов в классе
        xcodebuild test \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -only-testing:"LMSUITests/$test_class" \
            -quiet \
            2>&1 | grep -E "(Test Case|failed|passed|error)"
    else
        # Запуск конкретного теста
        xcodebuild test \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -only-testing:"LMSUITests/$test_class/$test_method" \
            -quiet \
            2>&1 | grep -E "(Test Case|failed|passed|error)"
    fi
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Успешно"
    else
        echo "   ❌ Ошибка"
    fi
}

# Меню выбора тестов
echo ""
echo "Выберите категорию тестов:"
echo "1) Все тесты из Manual Test Plan"
echo "2) Только Cmi5 тесты"  
echo "3) Авторизация и роли"
echo "4) Модуль обучения"
echo "5) Тестирование (quizzes)"
echo "6) Административные функции"
echo "7) Технические аспекты"
echo "8) Конкретный тест"
echo ""
read -p "Ваш выбор (1-8): " choice

case $choice in
    1)
        echo "🚀 Запуск всех тестов..."
        run_test "ManualTestPlanAutomation" "" "Все тесты из Manual Test Plan"
        run_test "Cmi5UITests" "" "Все Cmi5 тесты"
        ;;
    2)
        echo "🎯 Запуск Cmi5 тестов..."
        run_test "Cmi5UITests" "testScenario1_BasicCmi5Launch" "Сценарий 1: Базовый запуск"
        run_test "Cmi5UITests" "testScenario2_OfflineMode" "Сценарий 2: Офлайн режим"
        run_test "Cmi5UITests" "testScenario3_InterruptionHandling" "Сценарий 3: Прерывание"
        run_test "Cmi5UITests" "testScenario4_AnalyticsAndReports" "Сценарий 4: Аналитика"
        run_test "Cmi5UITests" "testScenario5_InvalidContent" "Сценарий 5: Некорректный контент"
        run_test "Cmi5UITests" "testScenario6_MultipleAUs" "Сценарий 6: Множественные AU"
        run_test "Cmi5UITests" "testScenario7_Performance" "Сценарий 7: Производительность"
        run_test "Cmi5UITests" "testScenario8_EdgeCases" "Сценарий 8: Граничные случаи"
        ;;
    3)
        echo "🔐 Запуск тестов авторизации..."
        run_test "ManualTestPlanAutomation" "test_1_1_LoginScreen" "Экран входа"
        run_test "ManualTestPlanAutomation" "test_1_2_RoleBasedAccess" "Ролевой доступ"
        ;;
    4)
        echo "📚 Запуск тестов модуля обучения..."
        run_test "ManualTestPlanAutomation" "test_3_1_CoursesList" "Список курсов"
        run_test "ManualTestPlanAutomation" "test_3_2_CourseDetails" "Детали курса"
        run_test "ManualTestPlanAutomation" "test_3_3_Lessons" "Уроки"
        ;;
    5)
        echo "📝 Запуск тестов тестирования..."
        run_test "ManualTestPlanAutomation" "test_4_1_TestsList" "Список тестов"
        run_test "ManualTestPlanAutomation" "test_4_2_TakeTest" "Прохождение теста"
        ;;
    6)
        echo "👨‍💼 Запуск административных тестов..."
        run_test "ManualTestPlanAutomation" "test_5_2_AdminDashboard" "Админ дашборд"
        run_test "ManualTestPlanAutomation" "test_6_1_UserManagement" "Управление пользователями"
        ;;
    7)
        echo "⚙️ Запуск технических тестов..."
        run_test "ManualTestPlanAutomation" "test_7_1_Performance" "Производительность"
        run_test "ManualTestPlanAutomation" "test_7_2_ErrorHandling" "Обработка ошибок"
        run_test "ManualTestPlanAutomation" "test_7_3_Accessibility" "Доступность"
        ;;
    8)
        echo "Доступные тест-классы:"
        echo "- ManualTestPlanAutomation"
        echo "- Cmi5UITests"
        echo ""
        read -p "Введите имя класса: " test_class
        read -p "Введите имя метода (или оставьте пустым для всех): " test_method
        run_test "$test_class" "$test_method" "Выбранный тест"
        ;;
    *)
        echo "❌ Неверный выбор"
        exit 1
        ;;
esac

echo ""
echo "=================================================="
echo "✅ Тестирование завершено!"
echo ""
echo "💡 Совет: Для просмотра детальных результатов используйте:"
echo "   open testResults.xcresult"
echo "" 