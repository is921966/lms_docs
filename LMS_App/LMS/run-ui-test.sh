#!/bin/bash

echo "🚀 Запуск UI теста..."

# Убеждаемся что приложение установлено
echo "📱 Проверка установки приложения..."
xcrun simctl install booted /Users/ishirokov/Library/Developer/Xcode/DerivedData/LMS-fmibjtqzpojocqddhkjahwikhxzd/Build/Products/Debug-iphonesimulator/LMS.app 2>/dev/null || echo "⚠️  Приложение уже установлено"

# Запускаем приложение
echo "▶️  Запуск приложения..."
xcrun simctl launch booted ru.tsum.lms.igor

# Ждем загрузки
sleep 3

# Делаем скриншот экрана входа
echo "📸 Скриншот экрана входа..."
xcrun simctl io booted screenshot ~/Desktop/01_login.png

# Симулируем нажатие на "Войти как студент"
echo "👤 Вход как студент..."
# Координаты кнопки примерно в центре экрана
xcrun simctl io booted tap 207 500

# Ждем загрузки главного экрана
sleep 2

# Делаем скриншот главного экрана
echo "📸 Скриншот главного экрана..."
xcrun simctl io booted screenshot ~/Desktop/02_main.png

# Проверяем вкладки
echo "📱 Проверка вкладок..."

# Переключаемся на вкладку Курсы (примерные координаты)
xcrun simctl io booted tap 124 896
sleep 1
xcrun simctl io booted screenshot ~/Desktop/03_courses.png

# Переключаемся на вкладку Профиль
xcrun simctl io booted tap 207 896
sleep 1
xcrun simctl io booted screenshot ~/Desktop/04_profile.png

# Переключаемся на вкладку Настройки
xcrun simctl io booted tap 290 896
sleep 1
xcrun simctl io booted screenshot ~/Desktop/05_settings.png

# Прокручиваем вниз чтобы увидеть версию
echo "🔍 Поиск версии приложения..."
xcrun simctl io booted swipe 207 600 207 200
sleep 1
xcrun simctl io booted screenshot ~/Desktop/06_version.png

echo "✅ Тест завершен!"
echo "📁 Скриншоты сохранены на рабочий стол" 