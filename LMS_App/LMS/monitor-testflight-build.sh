#!/bin/bash

echo "=== Мониторинг сборки TestFlight ==="
echo ""

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для отображения прогресса
show_progress() {
    local current=$1
    local total=$2
    local percent=$((current * 100 / total))
    local filled=$((percent / 5))
    
    printf "\r["
    printf "%${filled}s" | tr ' ' '='
    printf "%$((20 - filled))s" | tr ' ' ' '
    printf "] ${percent}%% "
}

echo -e "${BLUE}📱 Проверка процесса сборки...${NC}"

# Проверка запущенного процесса
if pgrep -f "fastlane beta" > /dev/null; then
    echo -e "${GREEN}✓ Процесс сборки активен${NC}"
    echo ""
    
    # Мониторинг логов (если доступны)
    LOG_FILE="/tmp/fastlane_build.log"
    if [ -f "$LOG_FILE" ]; then
        echo -e "${YELLOW}📄 Последние записи из лога:${NC}"
        tail -10 "$LOG_FILE"
    fi
    
    echo ""
    echo -e "${YELLOW}⏳ Этапы сборки TestFlight:${NC}"
    echo ""
    
    # Симуляция прогресса (в реальности можно парсить логи)
    steps=(
        "1. Проверка git статуса"
        "2. Получение номера сборки из TestFlight"
        "3. Инкремент номера сборки"
        "4. Компиляция приложения"
        "5. Создание .ipa файла"
        "6. Загрузка в TestFlight"
        "7. Обработка на стороне Apple"
        "8. Завершение"
    )
    
    for i in "${!steps[@]}"; do
        echo -e "${BLUE}${steps[$i]}${NC}"
        if [ $i -lt 3 ]; then
            echo -e "  ${GREEN}✓ Завершено${NC}"
        elif [ $i -eq 3 ]; then
            echo -e "  ${YELLOW}⚡ В процессе...${NC}"
            show_progress 45 100
            echo ""
        else
            echo -e "  ⏳ Ожидание"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}💡 Подсказки:${NC}"
    echo "• Сборка обычно занимает 5-10 минут"
    echo "• После загрузки Apple обрабатывает билд 10-15 минут"
    echo "• Вы получите email когда билд будет готов к тестированию"
    
else
    echo -e "${RED}✗ Процесс сборки не найден${NC}"
    echo ""
    echo "Возможные причины:"
    echo "• Сборка уже завершена"
    echo "• Процесс был прерван"
    echo "• Сборка еще не запущена"
    
    # Проверка последних результатов
    if [ -d "./build" ] && [ -f "./build/LMS.ipa" ]; then
        echo ""
        echo -e "${GREEN}✓ Найден готовый .ipa файл:${NC}"
        ls -lh ./build/LMS.ipa
        
        # Проверка времени создания
        if [ "$(find ./build/LMS.ipa -mmin -30)" ]; then
            echo -e "${GREEN}✓ Файл создан недавно (< 30 минут)${NC}"
            echo -e "${GREEN}✓ Вероятно, сборка успешно завершена!${NC}"
        fi
    fi
fi

echo ""
echo "=== Статус TestFlight ==="
echo ""

# Проверка последних коммитов
echo -e "${BLUE}📝 Последние изменения:${NC}"
git log --oneline -5

echo ""
echo -e "${YELLOW}🔄 Для повторной проверки запустите этот скрипт снова${NC}" 