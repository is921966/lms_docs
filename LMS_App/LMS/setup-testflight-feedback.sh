#!/bin/bash

# TestFlight Feedback Automation - Automatic Setup Script
# Автоматически настраивает всю систему за 1 минуту!

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}🚀 TestFlight Feedback Automation Setup${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Определяем путь к скрипту
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# Шаг 1: Проверяем структуру директорий
echo -e "${YELLOW}📁 Проверяем структуру директорий...${NC}"
mkdir -p scripts
mkdir -p fastlane/actions
mkdir -p private_keys
echo -e "${GREEN}✅ Директории созданы${NC}"

# Шаг 2: Проверяем Python
echo -e "\n${YELLOW}🐍 Проверяем Python...${NC}"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+')
    echo -e "${GREEN}✅ Python найден: $(python3 --version)${NC}"
else
    echo -e "${RED}❌ Python 3 не установлен!${NC}"
    echo "Установите Python 3: brew install python3"
    exit 1
fi

# Шаг 3: Проверяем pip
echo -e "\n${YELLOW}📦 Проверяем pip...${NC}"
if ! command -v pip3 &> /dev/null; then
    echo -e "${YELLOW}Устанавливаем pip...${NC}"
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3 get-pip.py
    rm get-pip.py
fi
echo -e "${GREEN}✅ pip готов${NC}"

# Шаг 4: Устанавливаем Python зависимости
echo -e "\n${YELLOW}📥 Устанавливаем Python зависимости...${NC}"
cd scripts
if [ ! -f "requirements.txt" ]; then
    echo "PyJWT==2.8.0" > requirements.txt
    echo "cryptography==41.0.7" >> requirements.txt
    echo "requests==2.31.0" >> requirements.txt
fi

pip3 install -r requirements.txt --quiet
echo -e "${GREEN}✅ Зависимости установлены${NC}"

# Шаг 5: Создаем .env.local если его нет
echo -e "\n${YELLOW}⚙️ Настраиваем конфигурацию...${NC}"
if [ ! -f ".env.local" ]; then
    if [ -f "env.example" ]; then
        cp env.example .env.local
        echo -e "${GREEN}✅ Создан файл .env.local${NC}"
        echo -e "${YELLOW}📝 Необходимо заполнить .env.local вашими ключами API${NC}"
    fi
else
    echo -e "${GREEN}✅ Файл .env.local уже существует${NC}"
fi

# Шаг 6: Проверяем Fastlane
cd ..
echo -e "\n${YELLOW}🏃 Проверяем Fastlane...${NC}"
if ! command -v fastlane &> /dev/null; then
    echo -e "${YELLOW}Устанавливаем Fastlane...${NC}"
    if command -v gem &> /dev/null; then
        sudo gem install fastlane -NV
    else
        echo -e "${RED}❌ Ruby не установлен. Установите Fastlane вручную${NC}"
    fi
else
    echo -e "${GREEN}✅ Fastlane установлен: $(fastlane --version | head -1)${NC}"
fi

# Шаг 7: Проверяем наличие необходимых файлов
echo -e "\n${YELLOW}📋 Проверяем файлы автоматизации...${NC}"
FILES_OK=true

if [ ! -f "scripts/fetch_testflight_feedback.py" ]; then
    echo -e "${RED}❌ Отсутствует: scripts/fetch_testflight_feedback.py${NC}"
    FILES_OK=false
fi

if [ ! -f "scripts/fetch-feedback.sh" ]; then
    echo -e "${RED}❌ Отсутствует: scripts/fetch-feedback.sh${NC}"
    FILES_OK=false
fi

if [ ! -f "fastlane/actions/fetch_testflight_feedback.rb" ]; then
    echo -e "${RED}❌ Отсутствует: fastlane/actions/fetch_testflight_feedback.rb${NC}"
    FILES_OK=false
fi

if [ "$FILES_OK" = true ]; then
    echo -e "${GREEN}✅ Все файлы на месте${NC}"
else
    echo -e "${RED}Некоторые файлы отсутствуют. Проверьте установку.${NC}"
fi

# Шаг 8: Делаем скрипты исполняемыми
echo -e "\n${YELLOW}🔧 Настраиваем права доступа...${NC}"
chmod +x scripts/fetch-feedback.sh 2>/dev/null || true
chmod +x scripts/fetch_testflight_feedback.py 2>/dev/null || true
echo -e "${GREEN}✅ Права доступа настроены${NC}"

# Шаг 9: Проверяем конфигурацию
echo -e "\n${YELLOW}🔍 Проверяем конфигурацию...${NC}"
cd scripts
if [ -f ".env.local" ]; then
    # Проверяем, заполнены ли ключи
    if grep -q "XXXXXXXXXX" .env.local; then
        echo -e "${YELLOW}⚠️ Необходимо заполнить API ключи в .env.local${NC}"
        READY=false
    else
        echo -e "${GREEN}✅ Конфигурация выглядит настроенной${NC}"
        READY=true
    fi
else
    echo -e "${RED}❌ Файл .env.local не найден${NC}"
    READY=false
fi

# Шаг 10: Создаем helper скрипт
echo -e "\n${YELLOW}📝 Создаем helper команды...${NC}"
cd "$SCRIPT_DIR"
cat > testflight-feedback << 'EOF'
#!/bin/bash
# TestFlight Feedback Helper

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

case "$1" in
    setup)
        "$SCRIPT_DIR/setup-testflight-feedback.sh"
        ;;
    fetch)
        cd "$SCRIPT_DIR/scripts" && ./fetch-feedback.sh ${@:2}
        ;;
    test)
        cd "$SCRIPT_DIR/scripts"
        echo "🧪 Тестируем конфигурацию..."
        python3 -c "import jwt, requests; print('✅ Python модули работают')"
        if [ -f ".env.local" ]; then
            echo "✅ Конфигурация найдена"
        else
            echo "❌ Конфигурация не найдена"
        fi
        ;;
    help|*)
        echo "TestFlight Feedback Automation"
        echo ""
        echo "Usage: ./testflight-feedback [command]"
        echo ""
        echo "Commands:"
        echo "  setup   - Запустить автоматическую настройку"
        echo "  fetch   - Получить feedback из TestFlight"
        echo "  test    - Проверить настройку"
        echo "  help    - Показать эту справку"
        ;;
esac
EOF

chmod +x testflight-feedback
echo -e "${GREEN}✅ Helper команда создана${NC}"

# Итоговый отчет
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}📊 Результаты установки${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

if [ "$READY" = true ] && [ "$FILES_OK" = true ]; then
    echo -e "${GREEN}✅ Система готова к использованию!${NC}"
    echo ""
    echo -e "${YELLOW}Запустите получение feedback:${NC}"
    echo -e "  ${BLUE}cd scripts && ./fetch-feedback.sh${NC}"
    echo ""
    echo -e "${YELLOW}Или используйте helper:${NC}"
    echo -e "  ${BLUE}./testflight-feedback fetch${NC}"
else
    echo -e "${YELLOW}⚠️ Система почти готова!${NC}"
    echo ""
    echo -e "${YELLOW}Необходимо выполнить:${NC}"
    
    if [ ! -f "scripts/.env.local" ] || grep -q "XXXXXXXXXX" "scripts/.env.local" 2>/dev/null; then
        echo -e "1. ${RED}Заполнить API ключи в scripts/.env.local${NC}"
        echo ""
        echo "   Получите ключи в App Store Connect:"
        echo "   https://appstoreconnect.apple.com"
        echo "   Users and Access → Keys → App Store Connect API"
        echo ""
        echo "   Откройте файл:"
        echo -e "   ${BLUE}open scripts/.env.local${NC}"
    fi
    
    if [ "$FILES_OK" = false ]; then
        echo -e "2. ${RED}Убедиться, что все файлы автоматизации на месте${NC}"
    fi
fi

echo ""
echo -e "${BLUE}📚 Документация:${NC}"
echo "  - Быстрый старт: TESTFLIGHT_FEEDBACK_QUICKSTART.md"
echo "  - Полное руководство: TESTFLIGHT_FEEDBACK_AUTOMATION.md"
echo ""

# Предложение открыть конфигурацию
if [ "$READY" = false ] && [ -f "scripts/.env.local" ]; then
    echo -e "${YELLOW}Открыть файл конфигурации? (y/n)${NC}"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open scripts/.env.local
    fi
fi

echo -e "${GREEN}✨ Установка завершена!${NC}" 