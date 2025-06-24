#!/bin/bash

echo "🔐 Экспорт сертификата через Xcode"
echo "=================================="
echo ""
echo "Сертификат найден в системе! ✅"
echo "ID: 8832B46C8A5DBE0DD205C50315A17670320D1EC2"
echo ""
echo "📱 Простой способ экспорта через Xcode:"
echo ""
echo "1. Открываем Xcode..."
open -a Xcode
sleep 2
echo ""
echo "2. В Xcode:"
echo "   → Settings (Cmd+,)"
echo "   → Accounts"
echo "   → Выберите 'Igor Shirokov'"
echo "   → Нажмите 'Manage Certificates...'"
echo ""
echo "3. В окне сертификатов:"
echo "   → Найдите 'Apple Distribution'"
echo "   → Правый клик на нем"
echo "   → 'Export Certificate...'"
echo "   → Сохраните как 'cert.p12' на Рабочий стол"
echo "   → Используйте пароль: 123456"
echo ""
read -p "Нажмите Enter когда экспортировали сертификат..."

if [ -f ~/Desktop/cert.p12 ]; then
    echo "✅ Отлично! Сертификат найден на Рабочем столе"
    echo ""
    echo "Теперь можете запустить основной скрипт:"
    echo "./setup-ios-cicd.sh"
else
    echo "❌ Файл cert.p12 не найден на Рабочем столе"
    echo "   Попробуйте еще раз"
fi 