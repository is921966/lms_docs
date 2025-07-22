#!/bin/bash

# Скрипт для тестирования переключения между классической и Telegram лентой

echo "🧪 Тестирование переключения ленты..."

# Проверяем текущее значение
echo "1️⃣ Текущее состояние useNewFeedDesign:"
xcrun simctl spawn booted defaults read ru.tsum.lms.igor useNewFeedDesign || echo "false (default)"

# Устанавливаем классическую ленту
echo -e "\n2️⃣ Устанавливаем классическую ленту (false)..."
xcrun simctl spawn booted defaults write ru.tsum.lms.igor useNewFeedDesign -bool NO

# Проверяем
echo "Проверка:"
xcrun simctl spawn booted defaults read ru.tsum.lms.igor useNewFeedDesign

# Ждем немного
sleep 2

# Устанавливаем новую ленту
echo -e "\n3️⃣ Переключаемся на новую ленту (true)..."
xcrun simctl spawn booted defaults write ru.tsum.lms.igor useNewFeedDesign -bool YES

# Проверяем
echo "Проверка:"
xcrun simctl spawn booted defaults read ru.tsum.lms.igor useNewFeedDesign

echo -e "\n✅ Тест завершен. Перезапустите приложение или нажмите кнопку в UI чтобы увидеть изменения." 