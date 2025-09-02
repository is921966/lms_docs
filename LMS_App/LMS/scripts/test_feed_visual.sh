#!/bin/bash

echo "📱 Visual Feed Test"
echo "=================="
echo "Визуальное тестирование каналов новостей"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Timestamp for unique filenames
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Step 1: Kill and restart app
echo "🔄 Перезапускаем приложение..."
xcrun simctl terminate "iPhone 16 Pro" ru.tsum.lms.igor 2>/dev/null
sleep 2

# Step 2: Launch app
echo "🚀 Запускаем приложение..."
xcrun simctl launch "iPhone 16 Pro" ru.tsum.lms.igor
sleep 5

# Step 3: Take screenshot of main screen
echo "📸 [1/5] Главный экран..."
xcrun simctl io "iPhone 16 Pro" screenshot "/tmp/feed_test_${TIMESTAMP}_1_main.png"

# Step 4: Navigate to Feed using coordinates
echo "👆 Переходим на вкладку Новости..."
# Coordinates for Feed tab (second tab)
osascript -e 'tell application "Simulator" to activate'
sleep 1
# Click on Feed tab (approximate coordinates)
osascript <<EOF
tell application "System Events"
    tell process "Simulator"
        click at {172, 812}
    end tell
end tell
EOF

sleep 3

# Step 5: Take screenshot of Feed screen
echo "📸 [2/5] Экран новостей..."
xcrun simctl io "iPhone 16 Pro" screenshot "/tmp/feed_test_${TIMESTAMP}_2_feed.png"

# Step 6: Try to tap on first channel
echo "👆 Открываем первый канал..."
osascript <<EOF
tell application "System Events"
    tell process "Simulator"
        click at {200, 200}
    end tell
end tell
EOF

sleep 2

# Step 7: Take screenshot of channel detail
echo "📸 [3/5] Детали канала..."
xcrun simctl io "iPhone 16 Pro" screenshot "/tmp/feed_test_${TIMESTAMP}_3_detail.png"

# Step 8: Go back
echo "👆 Возвращаемся назад..."
osascript <<EOF
tell application "System Events"
    tell process "Simulator"
        click at {50, 100}
    end tell
end tell
EOF

sleep 2

# Step 9: Scroll down
echo "👆 Прокручиваем список..."
osascript <<EOF
tell application "System Events"
    tell process "Simulator"
        -- Swipe up to scroll down
        click at {200, 600}
        delay 0.1
        drag from {200, 600} to {200, 200}
    end tell
end tell
EOF

sleep 2

# Step 10: Final screenshot
echo "📸 [4/5] После прокрутки..."
xcrun simctl io "iPhone 16 Pro" screenshot "/tmp/feed_test_${TIMESTAMP}_4_scrolled.png"

# Step 11: Search
echo "👆 Тестируем поиск..."
osascript <<EOF
tell application "System Events"
    tell process "Simulator"
        click at {200, 150}
    end tell
end tell
EOF

sleep 2

echo "📸 [5/5] Поиск активен..."
xcrun simctl io "iPhone 16 Pro" screenshot "/tmp/feed_test_${TIMESTAMP}_5_search.png"

# Step 12: Create montage of all screenshots
echo ""
echo "🎨 Создаем коллаж из скриншотов..."
if command -v montage &> /dev/null; then
    montage -geometry 300x650+10+10 -tile 5x1 -label '%f' \
        "/tmp/feed_test_${TIMESTAMP}_"*.png \
        "/tmp/feed_test_${TIMESTAMP}_montage.png"
    echo -e "${GREEN}✅ Коллаж создан: /tmp/feed_test_${TIMESTAMP}_montage.png${NC}"
else
    echo -e "${YELLOW}⚠️ ImageMagick не установлен, коллаж не создан${NC}"
fi

# Step 13: Open screenshots
echo ""
echo "📂 Открываем скриншоты..."
open "/tmp/feed_test_${TIMESTAMP}_2_feed.png"

# Step 14: Analysis
echo ""
echo "📊 Анализ скриншотов:"
echo "===================="
echo ""
echo "Проверьте следующее на скриншотах:"
echo ""
echo "1. На экране Feed (скриншот 2):"
echo "   - [ ] Видны каналы 'Релизы и обновления'"
echo "   - [ ] Видны каналы 'Отчеты спринтов'"
echo "   - [ ] Видны каналы 'Методология'"
echo "   - [ ] Есть счетчики непрочитанных"
echo "   - [ ] Видны аватары каналов"
echo ""
echo "2. Количество постов:"
echo "   - [ ] Релизы: должно быть 11+ постов"
echo "   - [ ] Спринты: должно быть 52+ постов"
echo "   - [ ] Методология: должно быть 31+ постов"
echo ""
echo "3. Функциональность:"
echo "   - [ ] Поиск работает (скриншот 5)"
echo "   - [ ] Навигация работает (скриншот 3)"
echo "   - [ ] Прокрутка работает (скриншот 4)"
echo ""

# Final summary
echo "========== РЕЗУЛЬТАТЫ =========="
echo "📸 Скриншоты сохранены:"
ls -la "/tmp/feed_test_${TIMESTAMP}_"*.png | awk '{print "   - " $9}'
echo ""
echo "🔍 Для детального анализа откройте:"
echo "   open /tmp/feed_test_${TIMESTAMP}_*.png"
echo "===============================" 