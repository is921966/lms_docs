#!/bin/bash

echo "🔍 Полное тестирование отступов в Feed"
echo "======================================="
echo ""

# Step 1: Navigate to Feed
echo "📱 Шаг 1: Переход в Feed..."
xcrun simctl ui "iPhone 16 Pro" tap 302 791 2>/dev/null || echo "  (tap Feed)"
sleep 3

# Step 2: Take screenshot of current state
echo "📸 Шаг 2: Скриншот текущего состояния..."
xcrun simctl io "iPhone 16 Pro" screenshot "/tmp/feed_current_state.png"

# Step 3: Measure the visual elements
echo "📏 Шаг 3: Визуальный анализ..."
cat > /tmp/visual_analysis.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Feed Spacing Visual Analysis</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h1 { color: #333; text-align: center; }
        .container { max-width: 1200px; margin: 0 auto; }
        .comparison { display: flex; gap: 20px; margin: 20px 0; }
        .screenshot-box { flex: 1; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .screenshot { width: 100%; max-width: 400px; margin: 0 auto; display: block; }
        .annotation { position: relative; }
        .highlight-box { position: absolute; border: 3px solid red; background-color: rgba(255,0,0,0.1); }
        .measurement { position: absolute; color: red; font-weight: bold; font-size: 14px; background: white; padding: 2px 5px; border-radius: 3px; }
        .problem-area { border: 3px solid #ff6b6b !important; }
        .fixed-area { border: 3px solid #51cf66 !important; }
        .notes { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .status { text-align: center; font-size: 24px; margin: 20px 0; }
        .status.problem { color: #ff6b6b; }
        .status.fixed { color: #51cf66; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        td, th { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #f8f9fa; }
        .code-fix { background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 10px 0; font-family: monospace; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Анализ отступов в Feed</h1>
        <p style="text-align: center; color: #666;">Дата: $(date "+%Y-%m-%d %H:%M:%S")</p>
        
        <div class="notes">
            <h3>🎯 Проблема:</h3>
            <p>Счетчики новостей в правом верхнем углу каналов перекрываются поисковой строкой и панелью папок.</p>
        </div>
        
        <div class="comparison">
            <div class="screenshot-box">
                <h2>Текущее состояние</h2>
                <div class="annotation">
                    <img src="feed_current_state.png" class="screenshot problem-area">
                    <p style="text-align: center; color: #ff6b6b;">⚠️ Проблема видна в верхней части</p>
                </div>
            </div>
        </div>
        
        <h2>📐 Измерения и исправления</h2>
        <table>
            <tr>
                <th>Элемент</th>
                <th>Было</th>
                <th>Стало</th>
                <th>Изменение</th>
            </tr>
            <tr>
                <td>Отступ снизу у поиска</td>
                <td>8 пунктов</td>
                <td>12 пунктов</td>
                <td>+4 пункта</td>
            </tr>
            <tr>
                <td>Отступ снизу у папок</td>
                <td>0 пунктов</td>
                <td>4 пункта</td>
                <td>+4 пункта</td>
            </tr>
            <tr>
                <td>Отступ сверху у списка</td>
                <td>8 пунктов</td>
                <td>12 пунктов</td>
                <td>+4 пункта</td>
            </tr>
            <tr style="background-color: #e8f5e9;">
                <td><strong>Общее увеличение</strong></td>
                <td>-</td>
                <td>-</td>
                <td><strong>+12 пунктов</strong></td>
            </tr>
        </table>
        
        <h2>🔧 Код исправлений</h2>
        <div class="code-fix">
// TelegramFeedView.swift

// 1. Увеличен отступ снизу у поисковой строки:
.padding(.bottom, 12)  // Было: .padding(.bottom, 8)

// 2. Добавлен отступ снизу у панели папок:
.frame(height: 44)
.padding(.bottom, 4)  // Новое

// 3. Увеличен верхний отступ списка:
.padding(.top, 12)  // Было: .padding(.top, 8)
        </div>
        
        <div class="status problem">
            ⚠️ Требуется проверка применения изменений
        </div>
    </div>
</body>
</html>
EOF

echo ""
echo "✅ Анализ завершен. Открываю отчет..."
open /tmp/visual_analysis.html

echo ""
echo "🔨 Пересобираю приложение с изменениями..." 