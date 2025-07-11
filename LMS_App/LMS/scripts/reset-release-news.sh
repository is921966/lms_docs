#!/bin/bash

echo "📰 Информация о новостях релизов"
echo "================================"
echo ""
echo "✅ Новости о релизах теперь постоянные!"
echo ""
echo "Начиная с текущей версии:"
echo "- Новость о релизе всегда отображается в ленте"
echo "- Не удаляется после просмотра"
echo "- Остается доступной для всех пользователей"
echo ""
echo "💡 Новость автоматически добавляется при:"
echo "- Первом запуске после обновления"
echo "- Обновлении ленты (pull-to-refresh)"
echo "- Перезапуске приложения"
echo ""
echo "🚀 Текущая версия:"
VERSION=$(grep MARKETING_VERSION ../LMS.xcodeproj/project.pbxproj | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
BUILD=$(grep CURRENT_PROJECT_VERSION ../LMS.xcodeproj/project.pbxproj | grep -o '[0-9]\+' | head -1)
echo "  Версия: $VERSION"
echo "  Build: $BUILD" 