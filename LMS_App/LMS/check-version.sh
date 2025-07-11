#!/bin/bash

# Скрипт для проверки версии LMS в симуляторе

echo "🔍 Проверка версии LMS в симуляторе..."

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Bundle ID приложения
BUNDLE_ID="ru.tsum.lms.igor"

# Получаем ID активного симулятора
DEVICE_ID=$(xcrun simctl list devices | grep "Booted" | grep -E -o "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}" | head -1)

if [ -z "$DEVICE_ID" ]; then
    echo -e "${YELLOW}⚠️  Симулятор не запущен${NC}"
    exit 1
fi

# Путь к приложению в симуляторе
APP_PATH=$(xcrun simctl get_app_container "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null)

if [ -z "$APP_PATH" ]; then
    echo -e "${YELLOW}⚠️  Приложение LMS не установлено в симуляторе${NC}"
    exit 1
fi

# Читаем Info.plist
INFO_PLIST="$APP_PATH/LMS.app/Info.plist"

if [ -f "$INFO_PLIST" ]; then
    echo -e "${BLUE}📱 Информация о приложении:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Версия
    VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO_PLIST" 2>/dev/null)
    echo -e "${GREEN}Версия:${NC} $VERSION"
    
    # Сборка
    BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO_PLIST" 2>/dev/null)
    echo -e "${GREEN}Сборка:${NC} $BUILD"
    
    # Bundle ID
    echo -e "${GREEN}Bundle ID:${NC} $BUNDLE_ID"
    
    # Путь установки
    echo -e "${GREEN}Путь:${NC} $APP_PATH"
    
    # Дата установки
    INSTALL_DATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$APP_PATH/LMS.app")
    echo -e "${GREEN}Установлено:${NC} $INSTALL_DATE"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo -e "${YELLOW}⚠️  Не удалось найти Info.plist${NC}"
fi 