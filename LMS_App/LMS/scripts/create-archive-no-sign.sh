#!/bin/bash
# create-archive-no-sign.sh
# Создание архива для TestFlight без подписи кода (для демонстрации)

set -e

echo "🏗️ Создание архива для TestFlight (без подписи)..."

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Переходим в директорию проекта
cd "$(dirname "$0")/.."
PROJECT_DIR=$(pwd)

# Получаем текущую версию и билд
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" LMS/App/Info.plist)
BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" LMS/App/Info.plist)

echo -e "${YELLOW}📦 Версия: v${VERSION} (Build ${BUILD})${NC}"

# Определяем путь для архива
ARCHIVE_PATH="$HOME/Desktop/LMS_v${VERSION}_build${BUILD}.xcarchive"

# Чистим билд
echo -e "\n${YELLOW}🧹 Очистка билда...${NC}"
xcodebuild clean \
    -scheme LMS \
    -configuration Release \
    -quiet

echo -e "${GREEN}✅ Очистка завершена${NC}"

# Создаем билд для симулятора
echo -e "\n${YELLOW}📦 Создание билда для демонстрации...${NC}"
echo "Это может занять несколько минут..."

xcodebuild build \
    -scheme LMS \
    -configuration Release \
    -destination "platform=iOS Simulator,name=iPhone 16" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    -derivedDataPath build

echo -e "${GREEN}✅ Билд создан успешно!${NC}"

# Копируем приложение на рабочий стол
APP_PATH="build/Build/Products/Release-iphonesimulator/LMS.app"
DESKTOP_APP_PATH="$HOME/Desktop/LMS_v${VERSION}_build${BUILD}.app"

if [ -d "$APP_PATH" ]; then
    cp -R "$APP_PATH" "$DESKTOP_APP_PATH"
    echo -e "${GREEN}✅ Приложение скопировано на рабочий стол${NC}"
    echo -e "${YELLOW}📍 Путь: $DESKTOP_APP_PATH${NC}"
else
    echo -e "${RED}❌ Не удалось найти собранное приложение${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ Готово!${NC}"
echo -e "${YELLOW}📋 Информация о билде:${NC}"
echo -e "   Версия: v${VERSION}"
echo -e "   Билд: ${BUILD}"
echo -e "   Путь: $DESKTOP_APP_PATH"
echo -e "\n${YELLOW}⚠️  Примечание: Это демонстрационный билд для симулятора.${NC}"
echo -e "${YELLOW}    Для загрузки в TestFlight требуется учетная запись разработчика.${NC}" 