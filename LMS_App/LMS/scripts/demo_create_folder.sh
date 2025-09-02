#!/bin/bash

echo "📱 Демонстрация создания папки в Feed..."

# Переходим в Feed
echo "1️⃣ Переходим в Feed..."
xcrun simctl io booted tap 200 800  # Feed tab
sleep 2

# Делаем скриншот начального экрана
echo "2️⃣ Скриншот начального экрана..."
xcrun simctl io booted screenshot /tmp/feed_initial.png

# Нажимаем кнопку создания папки
echo "3️⃣ Нажимаем кнопку создания папки..."
xcrun simctl io booted tap 350 220  # Plus button (approximate)
sleep 2

# Делаем скриншот формы создания
echo "4️⃣ Скриншот формы создания папки..."
xcrun simctl io booted screenshot /tmp/create_folder_form.png

# Вводим название папки
echo "5️⃣ Вводим название папки..."
xcrun simctl io booted tap 200 250  # Text field
sleep 1
xcrun simctl io booted sendText "Важные новости"
sleep 1

# Выбираем иконку
echo "6️⃣ Выбираем иконку звезды..."
xcrun simctl io booted tap 150 350  # Star icon
sleep 1

# Выбираем каналы
echo "7️⃣ Выбираем каналы..."
xcrun simctl io booted swipe 200 400 200 200  # Scroll to channels
sleep 1
xcrun simctl io booted tap 350 450  # First channel
sleep 0.5
xcrun simctl io booted tap 350 500  # Second channel
sleep 1

# Делаем скриншот с выбранными каналами
echo "8️⃣ Скриншот с выбранными каналами..."
xcrun simctl io booted screenshot /tmp/channels_selected.png

# Создаем папку
echo "9️⃣ Создаем папку..."
xcrun simctl io booted tap 350 50  # Create button
sleep 2

# Финальный скриншот
echo "🎉 Финальный скриншот с новой папкой..."
xcrun simctl io booted screenshot /tmp/feed_with_folder.png

# Сохраняем скриншоты
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p /Users/ishirokov/lms_docs/feedback_screenshots/create_folder_demo_${TIMESTAMP}
cp /tmp/feed_initial.png /Users/ishirokov/lms_docs/feedback_screenshots/create_folder_demo_${TIMESTAMP}/01_initial.png
cp /tmp/create_folder_form.png /Users/ishirokov/lms_docs/feedback_screenshots/create_folder_demo_${TIMESTAMP}/02_form.png
cp /tmp/channels_selected.png /Users/ishirokov/lms_docs/feedback_screenshots/create_folder_demo_${TIMESTAMP}/03_channels.png
cp /tmp/feed_with_folder.png /Users/ishirokov/lms_docs/feedback_screenshots/create_folder_demo_${TIMESTAMP}/04_result.png

echo "✅ Демонстрация завершена!"
echo "📁 Скриншоты сохранены в: /Users/ishirokov/lms_docs/feedback_screenshots/create_folder_demo_${TIMESTAMP}/"
open /Users/ishirokov/lms_docs/feedback_screenshots/create_folder_demo_${TIMESTAMP}/ 