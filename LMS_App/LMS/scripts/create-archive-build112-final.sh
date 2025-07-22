#!/bin/bash
# create-archive-build112-final.sh
# Создание архива build 112 для TestFlight с правильным Team ID

set -e

echo "🏗️ Создание архива для TestFlight Build 112..."

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

echo -e "${YELLOW}📦 Архивация: v${VERSION} (Build ${BUILD})${NC}"

# Определяем путь для архива
ARCHIVE_PATH="$HOME/Desktop/LMS_v${VERSION}_build${BUILD}.xcarchive"

# Чистим билд
echo -e "\n${YELLOW}🧹 Очистка билда...${NC}"
xcodebuild clean \
    -scheme LMS \
    -configuration Release \
    -quiet

echo -e "${GREEN}✅ Очистка завершена${NC}"

# Создаем архив с правильным Team ID
echo -e "\n${YELLOW}📦 Создание архива...${NC}"
echo "Используем Team ID: N85286S93X"
echo "Это может занять несколько минут..."

xcodebuild archive \
    -scheme LMS \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM=N85286S93X

ARCHIVE_RESULT=$?

if [ $ARCHIVE_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ Архив успешно создан!${NC}"
    echo -e "📍 Расположение: ${GREEN}$ARCHIVE_PATH${NC}"
    
    # Проверяем размер архива
    ARCHIVE_SIZE=$(du -sh "$ARCHIVE_PATH" | cut -f1)
    echo -e "📏 Размер архива: ${GREEN}$ARCHIVE_SIZE${NC}"
    
    # Создаем ExportOptions.plist для TestFlight
    cat > ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>N85286S93X</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF
    
    echo -e "\n${YELLOW}📤 Следующий шаг - экспорт для App Store Connect:${NC}"
    echo "Выполните команду:"
    echo -e "${GREEN}xcodebuild -exportArchive -archivePath \"$ARCHIVE_PATH\" -exportPath ~/Desktop/LMS_Export -exportOptionsPlist ExportOptions.plist -allowProvisioningUpdates${NC}"
    
    echo -e "\n${YELLOW}Или используйте Xcode:${NC}"
    echo "1. Window → Organizer"
    echo "2. Выберите архив LMS v${VERSION} (${BUILD})"
    echo "3. Нажмите 'Distribute App'"
    echo "4. Выберите 'App Store Connect' → 'Upload'"
    
    # Создаем release notes
    RELEASE_NOTES_FILE="docs/releases/TESTFLIGHT_BUILD_${BUILD}.md"
    mkdir -p docs/releases
    cat > "$RELEASE_NOTES_FILE" << NOTES
# TestFlight Build ${BUILD} - v${VERSION}

## Дата: $(date +"%Y-%m-%d %H:%M")

## Sprint 48 - День 3-4
### Новый функционал: Оргструктура компании
- ✅ Просмотр организационной структуры
- ✅ Древовидное отображение департаментов
- ✅ Поиск сотрудников
- ✅ Детальная информация о сотрудниках
- ✅ Навигация по иерархии
- ✅ Подготовка к импорту из Excel

### Технические улучшения
- Добавлено 39 unit тестов для оргструктуры
- Добавлено 11 UI тестов
- Интеграция с Feature Registry
- Подготовка API клиента

## Инструкции для тестирования
1. Откройте меню "Ещё"
2. Выберите "Оргструктура" 
3. Проверьте древовидное отображение
4. Попробуйте поиск сотрудников
5. Откройте детали департамента/сотрудника

## Известные ограничения
- Импорт Excel пока не подключен к реальному API
- Используются mock данные
NOTES
    
    echo -e "${GREEN}✅ Release notes созданы: $RELEASE_NOTES_FILE${NC}"
    
else
    echo -e "${RED}❌ Ошибка при создании архива!${NC}"
    echo "Код ошибки: $ARCHIVE_RESULT"
    exit 1
fi 