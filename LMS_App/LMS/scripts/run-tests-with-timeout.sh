#!/bin/bash

# Скрипт для запуска UI тестов с таймаутом
# Предотвращает зависание тестов

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Параметры по умолчанию
DEFAULT_TIMEOUT=300  # 5 минут (должно быть достаточно для большинства тестов)
TIMEOUT=${1:-$DEFAULT_TIMEOUT}
TEST_TARGET=${2:-"LMSUITests"}

echo "🧪 Запуск тестов с таймаутом..."
echo "⏱️  Таймаут: ${TIMEOUT} секунд"
echo "🎯 Цель: ${TEST_TARGET}"
echo ""

# Функция для очистки процессов
cleanup() {
    echo -e "\n${YELLOW}⚠️  Прерывание тестов...${NC}"
    # Убиваем все связанные процессы
    pkill -f "xcodebuild.*${TEST_TARGET}" 2>/dev/null || true
    pkill -f "xctest" 2>/dev/null || true
    pkill -f "SimulatorTrampoline" 2>/dev/null || true
    exit 1
}

# Устанавливаем обработчик сигналов
trap cleanup INT TERM

# Переходим в директорию проекта
cd "$(dirname "$0")/.."

# Проверяем, что мы в правильной директории
if [ ! -f "LMS.xcodeproj/project.pbxproj" ]; then
    echo -e "${RED}❌ Ошибка: LMS.xcodeproj не найден!${NC}"
    echo "Убедитесь, что скрипт запущен из правильной директории"
    exit 1
fi

# Создаем директорию для результатов если её нет
mkdir -p TestResults

# Генерируем имя файла для результатов
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULT_BUNDLE="TestResults/${TEST_TARGET}_${TIMESTAMP}.xcresult"
LOG_FILE="TestResults/${TEST_TARGET}_${TIMESTAMP}.log"

# Функция для запуска тестов с таймаутом
run_tests_with_timeout() {
    local test_command="xcodebuild test \
        -scheme LMS \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
        -resultBundlePath ${RESULT_BUNDLE} \
        -only-testing:${TEST_TARGET}"
    
    echo "📋 Команда: ${test_command}"
    echo ""
    
    # Запускаем тесты в фоне
    ${test_command} 2>&1 | tee "${LOG_FILE}" &
    local test_pid=$!
    
    # Ждем завершения или таймаута
    local elapsed=0
    while kill -0 $test_pid 2>/dev/null; do
        if [ $elapsed -ge $TIMEOUT ]; then
            echo -e "\n${RED}❌ Таймаут! Тесты выполнялись более ${TIMEOUT} секунд${NC}"
            
            # Убиваем процесс тестирования
            kill -TERM $test_pid 2>/dev/null || true
            sleep 2
            kill -KILL $test_pid 2>/dev/null || true
            
            # Убиваем связанные процессы
            pkill -f "xcodebuild.*${TEST_TARGET}" 2>/dev/null || true
            pkill -f "xctest" 2>/dev/null || true
            
            echo -e "${YELLOW}📄 Лог сохранен в: ${LOG_FILE}${NC}"
            echo -e "${YELLOW}📊 Частичные результаты в: ${RESULT_BUNDLE}${NC}"
            
            return 1
        fi
        
        # Показываем прогресс каждые 10 секунд
        if [ $((elapsed % 10)) -eq 0 ] && [ $elapsed -gt 0 ]; then
            echo -e "${YELLOW}⏳ Прошло ${elapsed} секунд...${NC}"
        fi
        
        sleep 1
        ((elapsed++))
    done
    
    # Проверяем код завершения
    wait $test_pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "\n${GREEN}✅ Тесты успешно завершены за ${elapsed} секунд!${NC}"
    else
        echo -e "\n${RED}❌ Тесты завершились с ошибкой (код: ${exit_code})${NC}"
    fi
    
    echo -e "${YELLOW}📄 Лог сохранен в: ${LOG_FILE}${NC}"
    echo -e "${YELLOW}📊 Результаты в: ${RESULT_BUNDLE}${NC}"
    
    return $exit_code
}

# Специфичные функции для разных типов тестов
run_feature_registry_tests() {
    echo "🔧 Запуск Feature Registry Integration Tests..."
    TEST_TARGET="LMSUITests/FeatureRegistryIntegrationTests"
    TIMEOUT=180  # 3 минуты для integration тестов
    run_tests_with_timeout
}

run_onboarding_tests() {
    echo "🚀 Запуск Onboarding Tests..."
    TEST_TARGET="LMSUITests/OnboardingFlowUITests"
    TIMEOUT=240  # 4 минуты для onboarding тестов
    run_tests_with_timeout
}

run_all_ui_tests() {
    echo "🎯 Запуск всех UI тестов..."
    TEST_TARGET="LMSUITests"
    TIMEOUT=600  # 10 минут для всех тестов
    run_tests_with_timeout
}

# Меню выбора тестов
if [ -z "$1" ]; then
    echo "Выберите тесты для запуска:"
    echo "1) Feature Registry Integration Tests (3 мин)"
    echo "2) Onboarding Tests (4 мин)"
    echo "3) Все UI тесты (10 мин)"
    echo "4) Произвольная цель с таймаутом"
    echo ""
    read -p "Ваш выбор (1-4): " choice
    
    case $choice in
        1)
            run_feature_registry_tests
            ;;
        2)
            run_onboarding_tests
            ;;
        3)
            run_all_ui_tests
            ;;
        4)
            read -p "Введите цель тестирования (например, LMSUITests/SomeTest): " custom_target
            read -p "Введите таймаут в секундах (по умолчанию 300): " custom_timeout
            TEST_TARGET=${custom_target}
            TIMEOUT=${custom_timeout:-300}
            run_tests_with_timeout
            ;;
        *)
            echo -e "${RED}Неверный выбор!${NC}"
            exit 1
            ;;
    esac
else
    # Если переданы параметры командной строки
    run_tests_with_timeout
fi

# Анализ результатов
echo ""
echo "📊 Анализ результатов..."

# Проверяем наличие ошибок в логе
if [ -f "${LOG_FILE}" ]; then
    # Подсчитываем количество тестов
    total_tests=$(grep -c "Test Case.*started" "${LOG_FILE}" 2>/dev/null || echo "0")
    passed_tests=$(grep -c "Test Case.*passed" "${LOG_FILE}" 2>/dev/null || echo "0")
    failed_tests=$(grep -c "Test Case.*failed" "${LOG_FILE}" 2>/dev/null || echo "0")
    
    echo "📈 Статистика:"
    echo "   Всего тестов: ${total_tests}"
    echo "   ✅ Прошло: ${passed_tests}"
    echo "   ❌ Провалено: ${failed_tests}"
    
    # Показываем проваленные тесты
    if [ $failed_tests -gt 0 ]; then
        echo ""
        echo "❌ Проваленные тесты:"
        grep "Test Case.*failed" "${LOG_FILE}" | sed 's/^/   /'
    fi
fi

echo ""
echo "✨ Готово!" 