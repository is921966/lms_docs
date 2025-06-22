#!/bin/bash

# Скрипт для синхронизации методологии между проектом и центральным репозиторием
# Использование: ./sync-methodology.sh [direction]
# direction: "to-central" (проект → репозиторий) или "from-central" (репозиторий → проект)

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Путь к центральному репозиторию методологии
CENTRAL_REPO="/Users/ishirokov/lms_docs/cursor_tdd_methodology"

# Файлы методологии для синхронизации
METHODOLOGY_FILES=(
    ".cursorrules"
    ".cursor/rules/productmanager.mdc"
    "technical_requirements/TDD_MANDATORY_GUIDE.md"
    "technical_requirements/antipatterns.md"
    "TDD_WORKFLOW.md"
    "TESTING_SETUP_GUIDE.md"
    "test-quick.sh"
    "METHODOLOGY_UPDATE_*.md"
)

# Файлы в центральном репозитории
CENTRAL_FILES=(
    ".cursorrules"
    "productmanager.md"
    "TDD_GUIDE.md"
    "antipatterns.md"
    "VERSION.md"
    "CHANGELOG.md"
    "test-quick.sh"
)

echo "🔄 Синхронизация методологии"
echo "============================"

# Определяем направление синхронизации
DIRECTION="${1:-to-central}"

if [ "$DIRECTION" == "to-central" ]; then
    echo -e "${YELLOW}📤 Обновление центрального репозитория из текущего проекта${NC}"
    echo ""
    
    # Синхронизируем основные файлы
    echo "📋 Синхронизация файлов методологии:"
    
    # .cursorrules
    if [ -f ".cursorrules" ]; then
        cp .cursorrules "$CENTRAL_REPO/.cursorrules"
        echo -e "${GREEN}✅ .cursorrules${NC}"
    fi
    
    # productmanager.mdc → productmanager.md
    if [ -f ".cursor/rules/productmanager.mdc" ]; then
        cp .cursor/rules/productmanager.mdc "$CENTRAL_REPO/productmanager.md"
        echo -e "${GREEN}✅ productmanager.md${NC}"
    fi
    
    # TDD_MANDATORY_GUIDE.md → TDD_GUIDE.md
    if [ -f "technical_requirements/TDD_MANDATORY_GUIDE.md" ]; then
        cp technical_requirements/TDD_MANDATORY_GUIDE.md "$CENTRAL_REPO/TDD_GUIDE.md"
        echo -e "${GREEN}✅ TDD_GUIDE.md${NC}"
    fi
    
    # antipatterns.md
    if [ -f "technical_requirements/antipatterns.md" ]; then
        cp technical_requirements/antipatterns.md "$CENTRAL_REPO/antipatterns.md"
        echo -e "${GREEN}✅ antipatterns.md${NC}"
    fi
    
    # test-quick.sh
    if [ -f "test-quick.sh" ]; then
        cp test-quick.sh "$CENTRAL_REPO/test-quick.sh"
        chmod +x "$CENTRAL_REPO/test-quick.sh"
        echo -e "${GREEN}✅ test-quick.sh${NC}"
    fi
    
    # Копируем файлы обновлений методологии
    for file in METHODOLOGY_UPDATE_*.md; do
        if [ -f "$file" ]; then
            cp "$file" "$CENTRAL_REPO/"
            echo -e "${GREEN}✅ $file${NC}"
        fi
    done
    
    echo ""
    echo -e "${GREEN}✅ Центральный репозиторий обновлен!${NC}"
    echo "📍 Путь: $CENTRAL_REPO"
    
elif [ "$DIRECTION" == "from-central" ]; then
    echo -e "${YELLOW}📥 Обновление текущего проекта из центрального репозитория${NC}"
    echo ""
    
    # Создаем необходимые директории
    mkdir -p .cursor/rules
    mkdir -p technical_requirements
    
    echo "📋 Синхронизация файлов из центрального репозитория:"
    
    # .cursorrules
    if [ -f "$CENTRAL_REPO/.cursorrules" ]; then
        cp "$CENTRAL_REPO/.cursorrules" .cursorrules
        echo -e "${GREEN}✅ .cursorrules${NC}"
    fi
    
    # productmanager.md → productmanager.mdc
    if [ -f "$CENTRAL_REPO/productmanager.md" ]; then
        cp "$CENTRAL_REPO/productmanager.md" .cursor/rules/productmanager.mdc
        echo -e "${GREEN}✅ productmanager.mdc${NC}"
    fi
    
    # TDD_GUIDE.md → TDD_MANDATORY_GUIDE.md
    if [ -f "$CENTRAL_REPO/TDD_GUIDE.md" ]; then
        cp "$CENTRAL_REPO/TDD_GUIDE.md" technical_requirements/TDD_MANDATORY_GUIDE.md
        echo -e "${GREEN}✅ TDD_MANDATORY_GUIDE.md${NC}"
    fi
    
    # antipatterns.md
    if [ -f "$CENTRAL_REPO/antipatterns.md" ]; then
        cp "$CENTRAL_REPO/antipatterns.md" technical_requirements/antipatterns.md
        echo -e "${GREEN}✅ antipatterns.md${NC}"
    fi
    
    # test-quick.sh
    if [ -f "$CENTRAL_REPO/test-quick.sh" ]; then
        cp "$CENTRAL_REPO/test-quick.sh" test-quick.sh
        chmod +x test-quick.sh
        echo -e "${GREEN}✅ test-quick.sh${NC}"
    fi
    
    # Копируем файлы обновлений
    for file in "$CENTRAL_REPO"/METHODOLOGY_UPDATE_*.md; do
        if [ -f "$file" ]; then
            cp "$file" ./
            echo -e "${GREEN}✅ $(basename $file)${NC}"
        fi
    done
    
    echo ""
    echo -e "${GREEN}✅ Проект обновлен из центрального репозитория!${NC}"
    
else
    echo -e "${RED}❌ Неверное направление: $DIRECTION${NC}"
    echo "Используйте: ./sync-methodology.sh [to-central|from-central]"
    exit 1
fi

echo ""
echo "📝 Версия методологии:"
if [ -f "$CENTRAL_REPO/VERSION.md" ]; then
    VERSION=$(grep "Current Version:" "$CENTRAL_REPO/VERSION.md" | cut -d' ' -f4)
    DATE=$(grep "Release Date:" "$CENTRAL_REPO/VERSION.md" | cut -d' ' -f3-)
    echo "   Версия: $VERSION"
    echo "   Дата: $DATE"
fi

echo ""
echo "💡 Подсказки:"
echo "   - Для обновления центрального репозитория: ./sync-methodology.sh to-central"
echo "   - Для обновления проекта: ./sync-methodology.sh from-central"
echo "   - Всегда проверяйте изменения перед коммитом!" 