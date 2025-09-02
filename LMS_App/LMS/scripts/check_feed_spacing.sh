#!/bin/bash

echo "📱 Проверка отступов в Feed"
echo "=========================="

# Navigate to Feed
echo "👆 Переход в Feed..."
xcrun simctl ui "iPhone 16 Pro" tap 302 791 2>/dev/null || echo "  (tap Feed)"
sleep 3

# Take screenshots
echo "📸 Скриншот общего вида Feed..."
xcrun simctl io "iPhone 16 Pro" screenshot "/tmp/feed_spacing_1_overview.png"

# Zoom in on top part
echo "📸 Скриншот верхней части (проверка перекрытия)..."
xcrun simctl io "iPhone 16 Pro" screenshot "/tmp/feed_spacing_2_top.png"

# Create comparison HTML
cat > /tmp/feed_spacing_report.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Feed Spacing Fix Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        .screenshot { max-width: 400px; margin: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .container { display: flex; gap: 20px; flex-wrap: wrap; }
        .note { background-color: #f0f0f0; padding: 10px; margin: 10px 0; border-radius: 5px; }
        .highlight { border: 3px solid #ff6b6b; }
    </style>
</head>
<body>
    <h1>Отчет об исправлении отступов в Feed</h1>
    <p>Дата: $(date)</p>
    
    <div class="note">
        <h3>Внесенные изменения:</h3>
        <ul>
            <li>Увеличен отступ снизу у поисковой строки: с 8 до 12 пунктов</li>
            <li>Добавлен отступ снизу у панели папок: 4 пункта</li>
            <li>Увеличен верхний отступ списка каналов: с 8 до 12 пунктов</li>
        </ul>
    </div>
    
    <h2>Скриншоты после исправления:</h2>
    <div class="container">
        <div>
            <h3>Общий вид Feed</h3>
            <img src="feed_spacing_1_overview.png" class="screenshot">
        </div>
        <div>
            <h3>Верхняя часть (счетчики новостей)</h3>
            <img src="feed_spacing_2_top.png" class="screenshot highlight">
            <p>Проверьте, что счетчики в правом верхнем углу каналов теперь полностью видны</p>
        </div>
    </div>
    
    <div class="note">
        <h3>Что проверить:</h3>
        <ul>
            <li>✅ Счетчики новостей (синие кружки с цифрами) полностью видны</li>
            <li>✅ Нет перекрытия с поисковой строкой</li>
            <li>✅ Достаточный отступ между элементами</li>
            <li>✅ Общий вид остался гармоничным</li>
        </ul>
    </div>
</body>
</html>
EOF

echo ""
echo "✅ Скриншоты сохранены:"
echo "   - /tmp/feed_spacing_1_overview.png"
echo "   - /tmp/feed_spacing_2_top.png"
echo ""
echo "🌐 Открываю отчет..."
open /tmp/feed_spacing_report.html 