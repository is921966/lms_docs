#!/bin/bash

# TestFlight Feedback Fetcher Script
# Удобная обертка для запуска Python скрипта

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Проверяем, есть ли .env файл
if [ -f ".env.local" ]; then
    echo -e "${GREEN}Loading environment from .env.local${NC}"
    export $(cat .env.local | grep -v '^#' | xargs)
elif [ -f ".env" ]; then
    echo -e "${GREEN}Loading environment from .env${NC}"
    export $(cat .env | grep -v '^#' | xargs)
else
    echo -e "${YELLOW}Warning: No .env file found${NC}"
fi

# Проверяем обязательные переменные
if [ -z "$APP_STORE_CONNECT_API_KEY_ID" ] || [ -z "$APP_STORE_CONNECT_API_ISSUER_ID" ] || [ -z "$APP_STORE_CONNECT_API_KEY_PATH" ] || [ -z "$APP_ID" ]; then
    echo -e "${RED}Error: Missing required environment variables${NC}"
    echo ""
    echo "Please create .env.local file with:"
    echo "APP_STORE_CONNECT_API_KEY_ID=your_key_id"
    echo "APP_STORE_CONNECT_API_ISSUER_ID=your_issuer_id"
    echo "APP_STORE_CONNECT_API_KEY_PATH=path/to/key.p8"
    echo "APP_ID=your_app_id"
    exit 1
fi

# Проверяем, существует ли файл ключа
if [ ! -f "$APP_STORE_CONNECT_API_KEY_PATH" ]; then
    echo -e "${RED}Error: Private key file not found: $APP_STORE_CONNECT_API_KEY_PATH${NC}"
    exit 1
fi

# Устанавливаем зависимости если нужно
if ! python3 -c "import jwt" 2>/dev/null; then
    echo -e "${YELLOW}Installing required Python packages...${NC}"
    pip3 install -r requirements.txt
fi

# Параметры из аргументов командной строки
DAYS=${1:-7}
export FEEDBACK_DAYS=$DAYS

echo -e "${GREEN}Fetching TestFlight feedback for the last $DAYS days...${NC}"
echo ""

# Запускаем Python скрипт
python3 fetch_testflight_feedback.py

# Проверяем результат
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Success! Check the generated reports in testflight_reports_* directory${NC}"
    
    # Открываем последний отчет если на macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        LATEST_REPORT=$(ls -t testflight_reports_*/feedback_report.json 2>/dev/null | head -1)
        if [ -n "$LATEST_REPORT" ]; then
            echo -e "${GREEN}Opening report: $LATEST_REPORT${NC}"
            open "$LATEST_REPORT"
        fi
    fi
else
    echo -e "${RED}❌ Failed to fetch feedback${NC}"
    exit 1
fi 