#!/bin/bash

echo "🚀 Открываем Xcode для создания архива..."
echo "========================================"
echo ""
echo "✅ Подготовка завершена:"
echo "   • Версия: 2.1.1"
echo "   • Build: 208"
echo "   • Provisioning: Xcode Managed Profile"
echo "   • Certificate: Apple Development (N97MV6M5PR)"
echo ""
echo "📋 Шаги в Xcode:"
echo "1. Убедитесь, что выбрана схема 'LMS'"
echo "2. Выберите устройство 'Any iOS Device (arm64)'"
echo "3. Нажмите Product → Archive"
echo "4. После создания архива загрузите в TestFlight"
echo ""
echo "⏱️  Ожидаемое время: 5-10 минут"
echo ""

# Открываем проект
open LMS.xcodeproj

echo "✅ Xcode открыт. Следуйте инструкциям выше." 