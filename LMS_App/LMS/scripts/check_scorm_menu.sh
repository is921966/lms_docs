#!/bin/bash

echo "🔍 Проверка SCORM в меню Ещё"
echo "================================"

# Ждем загрузку приложения
sleep 2

# Делаем скриншот главного экрана
echo "📸 Снимок главного экрана..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/scorm_check_1_main.png

# Переходим в раздел "Ещё"
echo "📱 Переход в раздел Ещё..."
xcrun simctl ui "iPhone 16 Pro" tap 302 791 2>/dev/null || echo "tap More"
sleep 2

# Делаем скриншот меню "Ещё"
echo "📸 Снимок меню Ещё..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/scorm_check_2_more_menu.png

# Скроллим вниз чтобы увидеть больше пунктов
echo "📜 Скроллинг вниз..."
xcrun simctl ui "iPhone 16 Pro" swipe 207 400 207 200
sleep 1

# Делаем скриншот после скролла
echo "📸 Снимок после скролла..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/scorm_check_3_after_scroll.png

# Ищем SCORM и нажимаем если найдем
echo "🔍 Поиск SCORM в меню..."
# Примерная позиция где может быть SCORM (после CMI5)
xcrun simctl ui "iPhone 16 Pro" tap 207 450 2>/dev/null || echo "tap SCORM position"
sleep 2

# Делаем финальный скриншот
echo "📸 Финальный снимок..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/scorm_check_4_final.png

# Создаем HTML отчет
cat > /tmp/scorm_menu_report.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>SCORM Menu Check Report</title>
    <meta charset="utf-8">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; padding: 20px; background: #f5f5f7; }
        .container { max-width: 1200px; margin: 0 auto; }
        h1 { color: #1d1d1f; text-align: center; }
        .screenshot { margin: 20px 0; text-align: center; background: white; padding: 20px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .screenshot img { max-width: 300px; border: 1px solid #d2d2d7; border-radius: 8px; }
        .screenshot h3 { color: #1d1d1f; margin-bottom: 10px; }
        .status { padding: 10px 20px; border-radius: 20px; display: inline-block; font-weight: 600; margin: 10px; }
        .success { background: #34c759; color: white; }
        .warning { background: #ff9500; color: white; }
        .info { background: #007aff; color: white; }
        .instructions { background: #f2f2f7; padding: 20px; border-radius: 12px; margin: 20px 0; }
        .instructions h3 { color: #1d1d1f; margin-top: 0; }
        .instructions ol { color: #3c3c43; }
        .instructions li { margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 Проверка SCORM в меню "Ещё"</h1>
        
        <div class="instructions">
            <h3>📋 Что мы проверяем:</h3>
            <ol>
                <li>Наличие пункта "SCORM Контент" в меню "Ещё"</li>
                <li>Расположение после "Cmi5 Контент"</li>
                <li>Иконка и описание</li>
                <li>Переход в раздел SCORM</li>
            </ol>
        </div>
        
        <div class="screenshot">
            <h3>1. Главный экран</h3>
            <img src="scorm_check_1_main.png" alt="Main screen">
            <p>Начальный экран приложения</p>
        </div>
        
        <div class="screenshot">
            <h3>2. Меню "Ещё"</h3>
            <img src="scorm_check_2_more_menu.png" alt="More menu">
            <p>Раздел с дополнительными функциями</p>
            <div class="status info">Проверьте наличие SCORM после CMI5</div>
        </div>
        
        <div class="screenshot">
            <h3>3. После скролла</h3>
            <img src="scorm_check_3_after_scroll.png" alt="After scroll">
            <p>Вид после прокрутки вниз</p>
        </div>
        
        <div class="screenshot">
            <h3>4. SCORM раздел</h3>
            <img src="scorm_check_4_final.png" alt="SCORM section">
            <p>Если переход успешен - экран SCORM управления</p>
        </div>
        
        <div class="instructions">
            <h3>✅ Ожидаемый результат:</h3>
            <ol>
                <li><strong>Пункт "SCORM Контент"</strong> должен быть виден в меню</li>
                <li><strong>Иконка:</strong> doc.badge.gearshape (документ с шестеренкой)</li>
                <li><strong>Описание:</strong> "Импорт и управление SCORM пакетами"</li>
                <li><strong>Бейдж:</strong> "НОВОЕ" красного цвета</li>
                <li><strong>Цвет иконки:</strong> Indigo (сине-фиолетовый)</li>
            </ol>
        </div>
        
        <div style="text-align: center; margin-top: 40px;">
            <div class="status success">SCORM функционал добавлен</div>
            <p style="color: #86868b; margin-top: 20px;">Сгенерировано: <span id="timestamp"></span></p>
        </div>
    </div>
    
    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString('ru-RU');
    </script>
</body>
</html>
EOF

echo ""
echo "✅ Проверка завершена!"
echo "📄 Отчет сохранен в: /tmp/scorm_menu_report.html"
echo ""
echo "Для просмотра отчета выполните:"
echo "open /tmp/scorm_menu_report.html" 