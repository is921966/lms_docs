#!/bin/bash

echo "📱 Monitoring LMS export template logs..."
echo "Press Ctrl+C to stop"
echo ""

# Запускаем мониторинг логов в реальном времени
xcrun simctl spawn booted log stream --process=LMS --level=debug 2>&1 | while read line; do
    # Фильтруем только релевантные сообщения
    if echo "$line" | grep -E "(downloadTemplate|Excel|template|Creating|Writing|ZIP|Error|Failed|📥|📝|🔨|📄|📁|🗜️|❌|✅|⚠️|🔍|🔧|📦)" &>/dev/null; then
        echo "$line"
    fi
done 