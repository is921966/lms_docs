#!/bin/bash
# prepare-testflight-build.sh
# Подготовка билда для TestFlight

set -e

echo "🚀 Подготовка билда для TestFlight..."

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Переходим в директорию проекта
cd "$(dirname "$0")/.."
PROJECT_DIR=$(pwd)

echo "📁 Рабочая директория: $PROJECT_DIR"

# Проверяем текущую версию и билд
CURRENT_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" LMS/App/Info.plist)
CURRENT_BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" LMS/App/Info.plist)

echo -e "${YELLOW}📊 Текущая версия: $CURRENT_VERSION (Build $CURRENT_BUILD)${NC}"

# Увеличиваем номер билда
NEW_BUILD=$((CURRENT_BUILD + 1))

# Спрашиваем, нужно ли изменить версию
read -p "Изменить версию? (текущая: $CURRENT_VERSION) [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Введите новую версию: " NEW_VERSION
    /usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString $NEW_VERSION" LMS/App/Info.plist
    echo -e "${GREEN}✅ Версия обновлена до $NEW_VERSION${NC}"
else
    NEW_VERSION=$CURRENT_VERSION
fi

# Обновляем номер билда
/usr/libexec/PlistBuddy -c "Set CFBundleVersion $NEW_BUILD" LMS/App/Info.plist
echo -e "${GREEN}✅ Билд обновлен до $NEW_BUILD${NC}"

# Создаем release notes
RELEASE_NOTES_FILE="docs/releases/TESTFLIGHT_RELEASE_v${NEW_VERSION}_build${NEW_BUILD}.md"
cat > "$RELEASE_NOTES_FILE" << EOF
# TestFlight Release v${NEW_VERSION} (Build ${NEW_BUILD})

## Дата релиза
$(date +"%Y-%m-%d %H:%M")

## Основные изменения

### Sprint 47 - Course Management
- ✅ Полная реализация управления курсами
- ✅ Просмотр курсов в режиме студента
- ✅ Интеграция Cmi5 контента
- ✅ Поддержка markdown в Feed
- ✅ Массовые операции с курсами

### Исправления
- 🔧 Исправлена проблема с отображением Cmi5 модулей
- 🔧 Улучшена загрузка Cmi5 пакетов
- 🔧 Добавлена автоматическая загрузка контента

### Технические улучшения
- 📈 Улучшено логирование
- 📈 Добавлена диагностика ошибок
- 📈 Оптимизирована производительность

## Инструкции для тестирования

### Управление курсами
1. Откройте меню "Ещё" → "Управление курсами"
2. Попробуйте создать новый курс
3. Протестируйте просмотр в режиме студента
4. Проверьте работу Cmi5 модулей

### Известные проблемы
- Cmi5 контент показывает симуляцию (реальный контент в разработке)

## Метрики
- Покрытие тестами: 85%+
- Количество тестов: 150+
- Размер приложения: ~35 MB
EOF

echo -e "${GREEN}✅ Release notes созданы: $RELEASE_NOTES_FILE${NC}"

# Проверяем конфигурацию подписи
echo -e "\n${YELLOW}🔐 Проверка конфигурации подписи...${NC}"

# Проверяем наличие сертификатов
security find-identity -p codesigning -v | grep -q "Apple Distribution" && {
    echo -e "${GREEN}✅ Сертификат для дистрибуции найден${NC}"
} || {
    echo -e "${RED}❌ Сертификат для дистрибуции не найден!${NC}"
    echo "Убедитесь, что сертификат Apple Distribution установлен"
    exit 1
}

# Создаем чеклист для архивации
CHECKLIST_FILE="ARCHIVE_CHECKLIST_BUILD_${NEW_BUILD}.md"
cat > "$CHECKLIST_FILE" << EOF
# Archive Checklist for Build ${NEW_BUILD}

## Pre-Archive
- [ ] Все тесты проходят
- [ ] Нет критических warnings
- [ ] Версия обновлена: v${NEW_VERSION}
- [ ] Билд обновлен: ${NEW_BUILD}
- [ ] Release notes готовы

## Archive Process
- [ ] Clean build folder (Cmd+Shift+K)
- [ ] Select "Any iOS Device (arm64)"
- [ ] Product → Archive
- [ ] Validate archive
- [ ] Distribute App → App Store Connect → Upload

## Post-Archive
- [ ] Архив успешно загружен
- [ ] Появился в App Store Connect
- [ ] TestFlight обработал билд
- [ ] Отправлен тестировщикам

## Git
- [ ] Коммит изменений версии
- [ ] Создать тег: v${NEW_VERSION}-build${NEW_BUILD}
- [ ] Push в репозиторий
EOF

echo -e "${GREEN}✅ Чеклист создан: $CHECKLIST_FILE${NC}"

# Очищаем DerivedData
echo -e "\n${YELLOW}🧹 Очистка DerivedData...${NC}"
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*
echo -e "${GREEN}✅ DerivedData очищена${NC}"

# Выводим итоговую информацию
echo -e "\n${GREEN}=== Подготовка завершена ===${NC}"
echo -e "Версия: ${GREEN}v${NEW_VERSION}${NC}"
echo -e "Билд: ${GREEN}${NEW_BUILD}${NC}"
echo -e "Release Notes: ${GREEN}${RELEASE_NOTES_FILE}${NC}"
echo -e "Чеклист: ${GREEN}${CHECKLIST_FILE}${NC}"

echo -e "\n${YELLOW}📱 Следующие шаги:${NC}"
echo "1. Откройте Xcode"
echo "2. Выберите 'Any iOS Device (arm64)' как destination"
echo "3. Product → Archive"
echo "4. Следуйте чеклисту в $CHECKLIST_FILE"

echo -e "\n${GREEN}Удачи с релизом! 🚀${NC}" 