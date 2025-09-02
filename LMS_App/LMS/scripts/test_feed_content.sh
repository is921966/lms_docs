#!/bin/bash

echo "📱 Feed Content Test"
echo "==================="
echo "Проверка содержимого каналов"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Kill and restart app
echo "🔄 Перезапускаем приложение..."
xcrun simctl terminate "iPhone 16 Pro" ru.tsum.lms.igor 2>/dev/null
sleep 2

# Launch app
echo "🚀 Запускаем приложение..."
xcrun simctl launch "iPhone 16 Pro" ru.tsum.lms.igor
sleep 5

# Navigate to Feed
echo "👆 Переходим в раздел Новости..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_1_main.png
./scripts/ui_tap.sh 302 791  # Feed tab (adjust if needed)
sleep 3

# Take screenshot of Feed
echo "📸 Скриншот списка каналов..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_2_channels.png

# Tap on "Релизы и обновления" (approximate position)
echo "👆 Открываем канал 'Релизы и обновления'..."
./scripts/ui_tap.sh 200 200  # First channel position
sleep 3

# Take screenshot of channel detail
echo "📸 Скриншот канала с релизами..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_3_releases.png

# Scroll down to see more content
echo "📜 Прокручиваем вниз..."
xcrun simctl ui "iPhone 16 Pro" swipe up
sleep 2
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_4_releases_scrolled.png

# Go back
echo "⬅️ Возвращаемся назад..."
./scripts/ui_tap.sh 50 100  # Back button
sleep 2

# Tap on "Отчеты спринтов"
echo "👆 Открываем канал 'Отчеты спринтов'..."
./scripts/ui_tap.sh 200 300  # Second channel position
sleep 3

# Take screenshot
echo "📸 Скриншот канала со спринтами..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_5_sprints.png

# Scroll to see more
echo "📜 Прокручиваем вниз..."
xcrun simctl ui "iPhone 16 Pro" swipe up
sleep 2
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_6_sprints_scrolled.png

# Go back
echo "⬅️ Возвращаемся назад..."
./scripts/ui_tap.sh 50 100  # Back button
sleep 2

# Tap on "Методология"
echo "👆 Открываем канал 'Методология'..."
./scripts/ui_tap.sh 200 400  # Third channel position
sleep 3

# Take screenshot
echo "📸 Скриншот канала с методологией..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_7_methodology.png

# Create composite image
echo ""
echo "🖼️ Создаем композитное изображение..."
convert /tmp/feed_2_channels.png /tmp/feed_3_releases.png /tmp/feed_5_sprints.png /tmp/feed_7_methodology.png -geometry +10+10 -tile 2x2 /tmp/feed_content_test_result.png 2>/dev/null || {
    echo -e "${YELLOW}⚠️ ImageMagick не установлен, открываем отдельные файлы${NC}"
    open /tmp/feed_2_channels.png
    open /tmp/feed_3_releases.png
    open /tmp/feed_5_sprints.png
    open /tmp/feed_7_methodology.png
}

echo ""
echo -e "${GREEN}✅ Тест завершен!${NC}"
echo ""
echo "📊 Результаты:"
echo "- Скриншот каналов: /tmp/feed_2_channels.png"
echo "- Канал релизов: /tmp/feed_3_releases.png и /tmp/feed_4_releases_scrolled.png"
echo "- Канал спринтов: /tmp/feed_5_sprints.png и /tmp/feed_6_sprints_scrolled.png"
echo "- Канал методологии: /tmp/feed_7_methodology.png"
echo ""
echo "Проверьте скриншоты для подтверждения:"
echo "1. Все каналы отображаются в списке"
echo "2. Контент загружается полностью (не только 10 постов)"
echo "3. Markdown правильно конвертируется в HTML" 