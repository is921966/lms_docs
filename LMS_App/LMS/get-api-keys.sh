#!/bin/bash

# Гид по получению API ключей для TestFlight Feedback

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}🔑 Получение API ключей App Store Connect${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "${YELLOW}Шаг 1: Откройте App Store Connect${NC}"
echo -e "Нажмите Enter чтобы открыть в браузере..."
read -r
open "https://appstoreconnect.apple.com"

echo ""
echo -e "${YELLOW}Шаг 2: Войдите в аккаунт${NC}"
echo "Используйте Apple ID разработчика с доступом к приложению"
echo -e "${GREEN}Нажмите Enter когда войдете...${NC}"
read -r

echo ""
echo -e "${YELLOW}Шаг 3: Перейдите к API ключам${NC}"
echo "1. Нажмите 'Users and Access' в верхнем меню"
echo "2. Выберите вкладку 'Keys'"
echo "3. В разделе 'App Store Connect API' нажмите '+'"
echo -e "${GREEN}Нажмите Enter когда будете на странице создания ключа...${NC}"
read -r

echo ""
echo -e "${YELLOW}Шаг 4: Создайте новый ключ${NC}"
echo "1. Name: TestFlight Feedback Bot"
echo "2. Access: App Manager (или Admin)"
echo "3. Нажмите 'Generate'"
echo -e "${GREEN}Нажмите Enter после создания ключа...${NC}"
read -r

echo ""
echo -e "${RED}⚠️  ВАЖНО: Скачайте .p8 файл!${NC}"
echo "Это можно сделать только ОДИН РАЗ!"
echo ""
echo "После скачивания вы увидите:"
echo "- Key ID: например, ABC123DEF4"
echo "- Issuer ID: например, 69a6de7c-1234-47e3-a053-5abc1234def5"
echo ""
echo -e "${GREEN}Нажмите Enter когда скачаете файл...${NC}"
read -r

echo ""
echo -e "${YELLOW}Шаг 5: Найдите App ID${NC}"
echo "1. Вернитесь в My Apps"
echo "2. Выберите ваше приложение"
echo "3. В разделе 'App Information' найдите 'Apple ID' (10 цифр)"
echo -e "${GREEN}Нажмите Enter когда найдете App ID...${NC}"
read -r

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}📝 Теперь заполните конфигурацию${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Интерактивное заполнение
echo -e "${YELLOW}Хотите заполнить конфигурацию сейчас? (y/n)${NC}"
read -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}Введите Key ID (например, ABC123DEF4):${NC}"
    read -r KEY_ID
    
    echo -e "${YELLOW}Введите Issuer ID (формат: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx):${NC}"
    read -r ISSUER_ID
    
    echo -e "${YELLOW}Введите App ID (10 цифр):${NC}"
    read -r APP_ID
    
    echo -e "${YELLOW}Путь к .p8 файлу (или нажмите Enter для стандартного):${NC}"
    read -r P8_PATH
    if [ -z "$P8_PATH" ]; then
        P8_PATH="./private_keys/AuthKey_${KEY_ID}.p8"
    fi
    
    # Обновляем конфигурацию
    if [ -f "scripts/.env.local" ]; then
        # Создаем backup
        cp scripts/.env.local scripts/.env.local.backup
        
        # Обновляем значения
        sed -i '' "s/APP_STORE_CONNECT_API_KEY_ID=.*/APP_STORE_CONNECT_API_KEY_ID=$KEY_ID/" scripts/.env.local
        sed -i '' "s/APP_STORE_CONNECT_API_ISSUER_ID=.*/APP_STORE_CONNECT_API_ISSUER_ID=$ISSUER_ID/" scripts/.env.local
        sed -i '' "s|APP_STORE_CONNECT_API_KEY_PATH=.*|APP_STORE_CONNECT_API_KEY_PATH=$P8_PATH|" scripts/.env.local
        sed -i '' "s/APP_ID=.*/APP_ID=$APP_ID/" scripts/.env.local
        
        echo ""
        echo -e "${GREEN}✅ Конфигурация обновлена!${NC}"
        
        # Перемещаем .p8 файл
        echo ""
        echo -e "${YELLOW}Переместить скачанный .p8 файл? (y/n)${NC}"
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mkdir -p private_keys
            echo "Перетащите .p8 файл в терминал и нажмите Enter:"
            read -r P8_SOURCE
            if [ -f "$P8_SOURCE" ]; then
                cp "$P8_SOURCE" "private_keys/AuthKey_${KEY_ID}.p8"
                echo -e "${GREEN}✅ Ключ скопирован в private_keys/${NC}"
            fi
        fi
    fi
fi

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}🚀 Готово к использованию!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "${YELLOW}Проверить настройку:${NC}"
echo -e "  ${BLUE}./testflight-feedback test${NC}"
echo ""

echo -e "${YELLOW}Получить feedback:${NC}"
echo -e "  ${BLUE}./testflight-feedback fetch${NC}"
echo ""

echo -e "${GREEN}✨ Удачи!${NC}" 