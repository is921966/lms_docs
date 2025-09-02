#!/bin/bash

echo "🔍 Проверка загрузки постов из файловой системы..."

# Проверяем количество файлов релизов
echo -e "\n📢 Релизы:"
echo "Путь: /Users/ishirokov/lms_docs/docs/releases/"
ls -la /Users/ishirokov/lms_docs/docs/releases/ | grep "RELEASE.*\.md" | wc -l
echo "Файлы:"
ls /Users/ishirokov/lms_docs/docs/releases/ | grep "RELEASE.*\.md"

# Проверяем количество файлов спринтов
echo -e "\n📊 Спринты:"
echo "Путь: /Users/ishirokov/lms_docs/reports/sprints/"
ls -la /Users/ishirokov/lms_docs/reports/sprints/ | grep -E "(COMPLETION_REPORT|PROGRESS).*\.md" | wc -l
echo "Файлы (первые 10):"
ls /Users/ishirokov/lms_docs/reports/sprints/ | grep -E "(COMPLETION_REPORT|PROGRESS).*\.md" | head -10

# Проверяем количество файлов методологии
echo -e "\n📚 Методология:"
echo "Путь: /Users/ishirokov/lms_docs/reports/methodology/"
ls -la /Users/ishirokov/lms_docs/reports/methodology/ | grep "\.md" | wc -l
echo "Файлы (первые 10):"
ls /Users/ishirokov/lms_docs/reports/methodology/ | grep "\.md" | head -10

# Запускаем приложение и делаем скриншот
echo -e "\n📱 Запускаем приложение..."
xcrun simctl boot "iPhone 16 Pro" 2>/dev/null || true
xcrun simctl launch "iPhone 16 Pro" ru.tsum.lms.igor

# Ждем загрузки
sleep 3

# Открываем вкладку новостей
echo "Открываем новости..."
xcrun simctl io "iPhone 16 Pro" screenshot /tmp/feed_main.png

echo -e "\n✅ Проверка завершена!"
echo "Скриншот сохранен в /tmp/feed_main.png" 