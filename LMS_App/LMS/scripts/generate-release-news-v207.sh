#!/bin/bash

echo "📰 Генерация новости о релизе v2.1.1 Build 207..."
echo "=============================================="

# Фиксированные значения для этого релиза
VERSION="2.1.1"
BUILD="207"

# Путь к release notes
RELEASE_NOTES_PATH="/Users/ishirokov/lms_docs/docs/releases/TESTFLIGHT_RELEASE_v${VERSION}_build${BUILD}.md"

# Проверяем существование release notes
if [ ! -f "$RELEASE_NOTES_PATH" ]; then
    echo "❌ Release notes не найдены: $RELEASE_NOTES_PATH"
    echo "Создайте release notes перед генерацией новости"
    exit 1
fi

echo "📋 Версия: $VERSION"
echo "📋 Build: $BUILD"
echo "📋 Release Notes: $RELEASE_NOTES_PATH"
echo ""

# Создаем файл RELEASE_NOTES.md в bundle
BUNDLE_NOTES="LMS/Resources/RELEASE_NOTES.md"
mkdir -p LMS/Resources

echo "📝 Копирование release notes в bundle..."
cp "$RELEASE_NOTES_PATH" "$BUNDLE_NOTES"
echo "✅ Release notes скопированы в: $BUNDLE_NOTES"

# Обновляем Info.plist с флагом новой версии
echo "📝 Обновление Info.plist..."

/usr/libexec/PlistBuddy -c "Set :LMSHasNewRelease true" LMS/App/Info.plist 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Add :LMSHasNewRelease bool true" LMS/App/Info.plist

echo "✅ Info.plist обновлен"
echo ""

echo "🎉 Генерация новости о релизе завершена!"
echo ""
echo "📋 Что было сделано:"
echo "  1. Release notes скопированы в bundle"
echo "  2. Обновлен Info.plist с флагом новой версии"
echo ""
echo "🚀 При следующем запуске приложения:"
echo "  - Новость автоматически появится в ленте"
echo "  - Пользователи увидят уведомление о новой версии" 