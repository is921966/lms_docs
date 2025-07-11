#!/bin/bash

# prepare-testflight-build.sh
# Скрипт для подготовки сборки для TestFlight

set -e

echo "🚀 Preparing TestFlight Build"
echo "============================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get current directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."
LMS_DIR="$PROJECT_ROOT/LMS_App/LMS"

echo -e "${YELLOW}📍 Working directory: $LMS_DIR${NC}"
cd "$LMS_DIR"

# Function to check last command status
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1 failed${NC}"
        exit 1
    fi
}

# Step 1: Clean build folder
echo -e "\n${YELLOW}🧹 Step 1: Cleaning build folder...${NC}"
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*
xcodebuild clean -scheme LMS -quiet
check_status "Clean build"

# Step 2: Run tests
echo -e "\n${YELLOW}🧪 Step 2: Running tests...${NC}"
echo "Running unit tests..."
xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -only-testing:LMSTests \
    -quiet \
    -resultBundlePath "TestResults/PreTestFlight_$(date +%Y%m%d_%H%M%S).xcresult" || true

echo "Tests completed (failures won't block build)"

# Step 3: Update version and build number
echo -e "\n${YELLOW}📝 Step 3: Checking version and build number...${NC}"

# Read current version from Info.plist
CURRENT_VERSION=$(defaults read "$LMS_DIR/LMS/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "2.1.1")
CURRENT_BUILD=$(defaults read "$LMS_DIR/LMS/Info.plist" CFBundleVersion 2>/dev/null || echo "206")

echo "Current version: $CURRENT_VERSION"
echo "Current build: $CURRENT_BUILD"

# Ask if user wants to update version
echo -e "\n${YELLOW}Do you want to update the version? (y/n)${NC}"
read -r UPDATE_VERSION

if [[ $UPDATE_VERSION == "y" ]]; then
    echo "Enter new version (current: $CURRENT_VERSION):"
    read -r NEW_VERSION
    echo "Enter new build number (current: $CURRENT_BUILD):"
    read -r NEW_BUILD
    
    # Update Info.plist
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEW_VERSION" "$LMS_DIR/LMS/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" "$LMS_DIR/LMS/Info.plist"
    
    echo -e "${GREEN}✅ Updated to version $NEW_VERSION build $NEW_BUILD${NC}"
    
    CURRENT_VERSION=$NEW_VERSION
    CURRENT_BUILD=$NEW_BUILD
fi

# Step 4: Generate release notes
echo -e "\n${YELLOW}📋 Step 4: Generating release notes...${NC}"

# Check if release notes exist
RELEASE_NOTES_PATH="$PROJECT_ROOT/docs/releases/TESTFLIGHT_RELEASE_v${CURRENT_VERSION}_build${CURRENT_BUILD}.md"

if [ ! -f "$RELEASE_NOTES_PATH" ]; then
    echo "Creating release notes template..."
    mkdir -p "$PROJECT_ROOT/docs/releases"
    
    cat > "$RELEASE_NOTES_PATH" << EOF
# TestFlight Release v${CURRENT_VERSION}

**Build**: ${CURRENT_BUILD}
**Date**: $(date +"%Y-%m-%d")

## 🎯 Основные изменения

### ✨ Новые функции
- [Добавьте новые функции здесь]

### 🔧 Улучшения
- [Добавьте улучшения здесь]

### 🐛 Исправления
- [Добавьте исправления здесь]

## 📋 Что нового для тестировщиков

### Проверьте следующие функции:
- [Функция 1]
- [Функция 2]

## 🐛 Известные проблемы
- [Известная проблема 1]

## 📊 Статистика
- Покрытие тестами: XX%
- UI тесты: XX из XX проходят
- Размер приложения: ~XX MB

---

**Инструкция для тестировщиков**: После установки проверьте основные сценарии использования и сообщите о любых проблемах через Feedback в приложении.
EOF

    echo -e "${YELLOW}⚠️  Please edit release notes at: $RELEASE_NOTES_PATH${NC}"
    echo "Press Enter when done..."
    read -r
fi

# Generate release news for the app
if [ -f "$LMS_DIR/scripts/generate-release-news.sh" ]; then
    echo "Generating release news for the app..."
    "$LMS_DIR/scripts/generate-release-news.sh" "$RELEASE_NOTES_PATH"
    check_status "Generate release news"
fi

# Step 5: Build archive
echo -e "\n${YELLOW}🏗️ Step 5: Building archive...${NC}"
echo "This will take a few minutes..."

ARCHIVE_PATH="$LMS_DIR/build/LMS_v${CURRENT_VERSION}_build${CURRENT_BUILD}.xcarchive"

xcodebuild archive \
    -scheme LMS \
    -archivePath "$ARCHIVE_PATH" \
    -destination 'generic/platform=iOS' \
    -configuration Release \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    -quiet

check_status "Archive build"

# Step 6: Export IPA (optional, requires signing)
echo -e "\n${YELLOW}📦 Step 6: Export IPA (requires signing)...${NC}"
echo -e "${YELLOW}Note: This step requires valid provisioning profiles${NC}"
echo "Do you want to export IPA? (y/n)"
read -r EXPORT_IPA

if [[ $EXPORT_IPA == "y" ]]; then
    EXPORT_OPTIONS_PLIST="$LMS_DIR/ExportOptions.plist"
    
    if [ ! -f "$EXPORT_OPTIONS_PLIST" ]; then
        echo "Creating ExportOptions.plist..."
        cat > "$EXPORT_OPTIONS_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <true/>
    <key>compileBitcode</key>
    <true/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
EOF
        echo -e "${RED}⚠️  Please update ExportOptions.plist with your Team ID${NC}"
        exit 1
    fi
    
    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$LMS_DIR/build" \
        -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"
    
    check_status "Export IPA"
fi

# Step 7: Summary
echo -e "\n${GREEN}✅ Build preparation complete!${NC}"
echo -e "\n📊 Summary:"
echo "- Version: $CURRENT_VERSION"
echo "- Build: $CURRENT_BUILD"
echo "- Archive: $ARCHIVE_PATH"

if [[ $EXPORT_IPA == "y" ]]; then
    echo "- IPA: $LMS_DIR/build/LMS.ipa"
fi

echo -e "\n${YELLOW}📱 Next steps:${NC}"
echo "1. Open Xcode"
echo "2. Window → Organizer"
echo "3. Select the archive"
echo "4. Click 'Distribute App'"
echo "5. Choose 'TestFlight & App Store'"
echo "6. Follow the upload wizard"

echo -e "\n${GREEN}🎉 Good luck with your TestFlight release!${NC}" 