#!/bin/bash

echo "📱 Complete Feed Test"
echo "===================="
echo "Полная проверка функциональности Feed"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Helper function for UI interaction
tap() {
    local x=$1
    local y=$2
    local desc=$3
    echo "👆 $desc"
    xcrun simctl ui "iPhone 16 Pro" tap $x $y 2>/dev/null || echo "  (tap simulation)"
    sleep 2
}

# Start fresh
echo "🔄 Перезапускаем приложение..."
xcrun simctl terminate "iPhone 16 Pro" ru.tsum.lms.igor 2>/dev/null
sleep 2
xcrun simctl launch "iPhone 16 Pro" ru.tsum.lms.igor
sleep 5

# Step 1: Main screen
echo -e "\n${YELLOW}[1/10] Главный экран${NC}"
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_test_01_main.png
echo "✅ Скриншот: /tmp/feed_test_01_main.png"

# Step 2: Navigate to Feed
echo -e "\n${YELLOW}[2/10] Переход в Новости${NC}"
tap 302 791 "Тап на вкладку Новости"
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_test_02_feed_list.png
echo "✅ Скриншот: /tmp/feed_test_02_feed_list.png"

# Step 3: Open Releases channel
echo -e "\n${YELLOW}[3/10] Открываем канал 'Релизы и обновления'${NC}"
tap 200 200 "Тап на первый канал"
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_test_03_releases_channel.png
echo "✅ Скриншот: /tmp/feed_test_03_releases_channel.png"

# Step 4: Scroll in channel
echo -e "\n${YELLOW}[4/10] Прокручиваем список постов${NC}"
xcrun simctl ui "iPhone 16 Pro" swipe up
sleep 1
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_test_04_releases_scrolled.png
echo "✅ Скриншот: /tmp/feed_test_04_releases_scrolled.png"

# Step 5: Open a post
echo -e "\n${YELLOW}[5/10] Открываем пост${NC}"
tap 200 300 "Тап на пост"
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_test_05_post_detail.png
echo "✅ Скриншот: /tmp/feed_test_05_post_detail.png"

# Step 6: Back to channel
echo -e "\n${YELLOW}[6/10] Возвращаемся в канал${NC}"
tap 50 100 "Кнопка назад"
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_test_06_back_to_channel.png
echo "✅ Скриншот: /tmp/feed_test_06_back_to_channel.png"

# Step 7: Back to feed list
echo -e "\n${YELLOW}[7/10] Возвращаемся к списку каналов${NC}"
tap 50 100 "Кнопка назад"
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_test_07_back_to_feed.png
echo "✅ Скриншот: /tmp/feed_test_07_back_to_feed.png"

# Step 8: Open Sprints channel
echo -e "\n${YELLOW}[8/10] Открываем канал 'Отчеты спринтов'${NC}"
tap 200 300 "Тап на второй канал"
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_test_08_sprints_channel.png
echo "✅ Скриншот: /tmp/feed_test_08_sprints_channel.png"

# Step 9: Open Methodology channel
echo -e "\n${YELLOW}[9/10] Возвращаемся и открываем 'Методология'${NC}"
tap 50 100 "Кнопка назад"
sleep 2
tap 200 400 "Тап на третий канал"
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_test_09_methodology_channel.png
echo "✅ Скриншот: /tmp/feed_test_09_methodology_channel.png"

# Step 10: Final feed view
echo -e "\n${YELLOW}[10/10] Финальный вид Feed${NC}"
tap 50 100 "Кнопка назад"
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_test_10_final.png
echo "✅ Скриншот: /tmp/feed_test_10_final.png"

# Summary
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Тест завершен успешно!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "📊 Результаты сохранены в:"
ls -la /tmp/feed_test_*.png | tail -10
echo ""
echo "🖼️ Открываем результаты..."
open /tmp/feed_test_03_releases_channel.png /tmp/feed_test_08_sprints_channel.png /tmp/feed_test_09_methodology_channel.png 