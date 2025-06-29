#!/bin/bash

# 🚀 Build and Upload to TestFlight Script
# Этот скрипт собирает приложение локально и загружает в TestFlight

set -e

echo "🚀 LMS TestFlight Deploy Script"
echo "==============================="
echo ""

# Переходим в директорию проекта
cd "$(dirname "$0")/.."
echo "📁 Working directory: $(pwd)"

# Проверяем наличие проекта
if [ ! -f "LMS.xcodeproj/project.pbxproj" ]; then
    echo "❌ Проект LMS.xcodeproj не найден!"
    exit 1
fi

# Настройки
SCHEME="LMS"
CONFIGURATION="Release"
ARCHIVE_PATH="build/LMS.xcarchive"
EXPORT_PATH="build"

echo ""
echo "🧹 Очистка предыдущих сборок..."
rm -rf build
rm -rf ~/Library/Developer/Xcode/DerivedData

echo ""
echo "🔨 Сборка архива..."
echo "Это может занять 5-10 минут..."

xcodebuild archive \
    -project LMS.xcodeproj \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    -allowProvisioningUpdates \
    DEVELOPMENT_TEAM=N85286S93X \
    PRODUCT_BUNDLE_IDENTIFIER=ru.tsum.lms.igor \
    IPHONEOS_DEPLOYMENT_TARGET=18.0 \
    CODE_SIGN_STYLE=Automatic

if [ ! -d "$ARCHIVE_PATH" ]; then
    echo "❌ Архив не создан! Проверьте ошибки выше."
    exit 1
fi

echo ""
echo "✅ Архив создан успешно!"
echo ""
echo "📦 Экспорт IPA..."

# Создаем ExportOptions.plist для автоматической подписи
cat > ExportOptions.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>destination</key>
    <string>export</string>
    <key>teamID</key>
    <string>N85286S93X</string>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>uploadBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist ExportOptions.plist \
    -allowProvisioningUpdates

if [ ! -f "$EXPORT_PATH/LMS.ipa" ]; then
    echo "❌ IPA файл не создан! Проверьте ошибки выше."
    exit 1
fi

echo ""
echo "✅ IPA создан успешно!"
echo ""
echo "🚀 Загрузка в TestFlight..."
echo ""
echo "⚠️  ВАЖНО: Для загрузки вам нужно:"
echo "1. Открыть Xcode"
echo "2. Window → Organizer"
echo "3. Выбрать архив LMS"
echo "4. Нажать 'Distribute App'"
echo "5. Следовать инструкциям"
echo ""
echo "Или используйте Transporter:"
echo "1. Скачайте Transporter из Mac App Store"
echo "2. Откройте и войдите с Apple ID"
echo "3. Перетащите файл: $EXPORT_PATH/LMS.ipa"
echo ""
echo "📍 Расположение файлов:"
echo "- Архив: $ARCHIVE_PATH"
echo "- IPA: $EXPORT_PATH/LMS.ipa"
echo ""
echo "✅ Готово для загрузки!" 