#!/bin/bash

# Скрипт для быстрого запуска LMS в симуляторе

echo "🚀 Запуск LMS в симуляторе..."

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Bundle ID приложения
BUNDLE_ID="ru.tsum.lms.igor"

# Проверяем, запущен ли симулятор
if ! xcrun simctl list devices | grep -q "Booted"; then
    echo -e "${YELLOW}⚠️  Симулятор не запущен. Запускаю iPhone 16 Pro...${NC}"
    xcrun simctl boot "iPhone 16 Pro" || {
        echo -e "${RED}❌ Не удалось запустить симулятор${NC}"
        exit 1
    }
    open -a Simulator
    sleep 3
fi

# Компилируем приложение
echo -e "${YELLOW}🔨 Компиляция приложения...${NC}"
xcodebuild -scheme LMS -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build -quiet || {
    echo -e "${RED}❌ Ошибка компиляции${NC}"
    exit 1
}

# Находим путь к скомпилированному приложению
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "LMS.app" -path "*/Debug-iphonesimulator/*" | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}❌ Не удалось найти скомпилированное приложение${NC}"
    exit 1
fi

# Удаляем старую версию (если есть)
echo -e "${YELLOW}🗑️  Удаление старой версии...${NC}"
xcrun simctl uninstall booted $BUNDLE_ID 2>/dev/null

# Устанавливаем приложение
echo -e "${YELLOW}📦 Установка приложения...${NC}"
xcrun simctl install booted "$APP_PATH" || {
    echo -e "${RED}❌ Ошибка установки${NC}"
    exit 1
}

# Запускаем приложение
echo -e "${YELLOW}▶️  Запуск приложения...${NC}"
xcrun simctl launch booted $BUNDLE_ID || {
    echo -e "${RED}❌ Ошибка запуска${NC}"
    exit 1
}

echo -e "${GREEN}✅ Приложение успешно запущено!${NC}"
echo -e "${GREEN}📱 Используйте симулятор для тестирования${NC}" 