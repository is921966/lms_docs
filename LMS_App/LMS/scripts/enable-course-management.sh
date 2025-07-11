#!/bin/bash

echo "🔧 Включение модуля Course Management..."
echo "========================================"

DEVICE_ID="C0F60722-8F57-46A8-A737-2A1CD8819E8E"

# 1. Ensure simulator is running
echo "📱 Проверка симулятора..."
if ! xcrun simctl list devices | grep "$DEVICE_ID" | grep -q "Booted"; then
    echo "🚀 Запуск симулятора..."
    xcrun simctl boot $DEVICE_ID
    sleep 10
fi

# 2. Enable Course Management via UserDefaults
echo "⚙️  Включение Course Management через UserDefaults..."
xcrun simctl spawn $DEVICE_ID defaults write ru.tsum.lms.igor "feature_Управление курсами" -bool YES

# 3. Enable all ready modules
echo "⚙️  Включение всех готовых модулей..."
xcrun simctl spawn $DEVICE_ID defaults write ru.tsum.lms.igor "feature_Компетенции" -bool YES
xcrun simctl spawn $DEVICE_ID defaults write ru.tsum.lms.igor "feature_Должности" -bool YES
xcrun simctl spawn $DEVICE_ID defaults write ru.tsum.lms.igor "feature_Новости" -bool YES
xcrun simctl spawn $DEVICE_ID defaults write ru.tsum.lms.igor "feature_Cmi5 Контент" -bool YES

# 4. Restart app to apply changes
echo "🔄 Перезапуск приложения..."
xcrun simctl terminate $DEVICE_ID ru.tsum.lms.igor 2>/dev/null || true
sleep 2
xcrun simctl launch $DEVICE_ID ru.tsum.lms.igor

echo "✅ Course Management модуль включен!"
echo ""
echo "Теперь в приложении должны быть доступны:"
echo "  - Управление курсами"
echo "  - Компетенции"
echo "  - Должности"
echo "  - Новости"
echo "  - Cmi5 Контент" 