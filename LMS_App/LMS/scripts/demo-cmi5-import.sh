#!/bin/bash

# Демо-скрипт для проверки импорта Cmi5

echo "🚀 Запуск демо Cmi5 импорта..."
echo "=============================="

# Убиваем старый симулятор
echo "Закрываем старый симулятор..."
xcrun simctl shutdown all

# Запускаем симулятор
echo "Запускаем симулятор iPhone 16 Pro..."
open -a Simulator --args -CurrentDeviceUDID 899AAE09-580D-4FF5-BF16-3574382CD796

# Ждем запуска симулятора
echo "Ожидаем запуск симулятора..."
sleep 5

# Устанавливаем приложение
echo "Устанавливаем приложение..."
xcrun simctl install booted /Users/ishirokov/Library/Developer/Xcode/DerivedData/LMS-*/Build/Products/Debug-iphonesimulator/LMS.app

# Запускаем приложение
echo "Запускаем приложение..."
xcrun simctl launch booted com.tsum.lms

echo ""
echo "✅ Приложение запущено!"
echo ""
echo "📝 Инструкции для тестирования:"
echo "1. Перейдите во вкладку 'Обучение'"
echo "2. Нажмите 'Управление Cmi5'"
echo "3. Нажмите '+' для импорта"
echo "4. Нажмите 'Использовать демо пакет' (оранжевая кнопка)"
echo "5. После обработки нажмите 'Импортировать'"
echo "6. Проверьте, что пакет появился в списке"
echo ""
echo "🔍 Для отладки используйте Console.app и фильтр: com.tsum.lms" 