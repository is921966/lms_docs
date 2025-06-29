#!/bin/bash

echo "🔍 Проверка статуса загрузки TestFlight..."
echo "==========================================="
echo ""

# Проверяем последний коммит
echo "📝 Последний коммит:"
git log -1 --oneline
echo ""

# Проверяем время с момента пуша
PUSH_TIME=$(git log -1 --format=%ct)
CURRENT_TIME=$(date +%s)
ELAPSED=$((CURRENT_TIME - PUSH_TIME))
ELAPSED_MIN=$((ELAPSED / 60))

echo "⏱️  Прошло времени с момента push: $ELAPSED_MIN минут"
echo ""

if [ $ELAPSED_MIN -lt 15 ]; then
    echo "⏳ GitHub Actions должен еще выполняться..."
    echo "   Обычно процесс занимает 10-15 минут"
else
    echo "✅ GitHub Actions должен быть завершен"
    echo "   Проверьте TestFlight в App Store Connect"
fi

echo ""
echo "📱 Полезные ссылки:"
echo "   • GitHub Actions: https://github.com/is921966/lms_docs/actions"
echo "   • App Store Connect: https://appstoreconnect.apple.com"
echo ""

# Проверяем наличие локального билда
if [ -f "build/LMS-TestFlight/LMS.ipa" ]; then
    echo "✅ Локальный IPA файл найден:"
    ls -lh build/LMS-TestFlight/LMS.ipa
else
    echo "❌ Локальный IPA файл не найден"
fi

echo ""
echo "==========================================="
echo "💡 Совет: Если прошло больше 20 минут и билд"
echo "   не появился в TestFlight, проверьте логи"
echo "   GitHub Actions на наличие ошибок." 