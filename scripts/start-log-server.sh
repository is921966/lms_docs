#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🚀 Запуск LMS Log Server...${NC}"

# Проверяем наличие Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 не установлен${NC}"
    exit 1
fi

# Проверяем наличие Flask
if ! python3 -c "import flask" 2>/dev/null; then
    echo -e "${YELLOW}📦 Устанавливаем Flask...${NC}"
    pip3 install flask flask-cors
fi

# Получаем IP адрес для локальной сети
IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1 || echo "localhost")

echo -e "${GREEN}✅ Log Server запускается на:${NC}"
echo -e "   - Локально: ${YELLOW}http://localhost:5002${NC}"
echo -e "   - В сети: ${YELLOW}http://$IP:5002${NC}"
echo ""
echo -e "${GREEN}📱 Для iOS устройства используйте:${NC}"
echo -e "   ${YELLOW}http://$IP:5002/api/logs${NC}"
echo ""
echo -e "${GREEN}🔍 Откройте браузер для просмотра логов${NC}"

# Запускаем сервер
cd "$(dirname "$0")"
python3 log_server.py 