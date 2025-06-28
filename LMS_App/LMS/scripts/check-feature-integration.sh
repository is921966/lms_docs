#!/bin/bash
# Скрипт для проверки интеграции всех модулей

set -e

echo "🔍 Проверка интеграции модулей..."
echo ""

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Счетчики
TOTAL_FEATURES=0
INTEGRATED_FEATURES=0
MISSING_FEATURES=0

# Проверяем наличие FeatureRegistry
if [ ! -f "LMS/Features/FeatureRegistry.swift" ]; then
    echo -e "${RED}❌ FeatureRegistry.swift не найден!${NC}"
    echo "Запустите: ./scripts/create-feature-registry.sh"
    exit 1
fi

echo "📂 Сканирование Features/..."
echo ""

# Получаем список всех папок в Features
for dir in LMS/Features/*/; do
    if [ -d "$dir" ]; then
        FEATURE=$(basename "$dir")
        
        # Пропускаем системные папки
        if [[ "$FEATURE" == "Common" || "$FEATURE" == "Shared" || "$FEATURE" == "Base" ]]; then
            continue
        fi
        
        TOTAL_FEATURES=$((TOTAL_FEATURES + 1))
        
        echo -n "🔍 $FEATURE: "
        
        # Проверяем наличие в FeatureRegistry
        if grep -q "case.*$FEATURE" "LMS/Features/FeatureRegistry.swift" 2>/dev/null || \
           grep -q "case.*${FEATURE,,}" "LMS/Features/FeatureRegistry.swift" 2>/dev/null; then
            echo -e "${GREEN}✅ Зарегистрирован${NC}"
            INTEGRATED_FEATURES=$((INTEGRATED_FEATURES + 1))
            
            # Дополнительные проверки
            echo -n "   └─ View: "
            if [ -f "$dir/Views/${FEATURE}View.swift" ]; then
                echo -e "${GREEN}✅${NC}"
            else
                echo -e "${YELLOW}⚠️  Отсутствует${NC}"
            fi
            
            echo -n "   └─ Test: "
            if [ -f "LMSUITests/Features/${FEATURE}IntegrationTests.swift" ] || \
               [ -f "LMSUITests/${FEATURE}/*Tests.swift" ]; then
                echo -e "${GREEN}✅${NC}"
            else
                echo -e "${YELLOW}⚠️  Отсутствует${NC}"
            fi
            
        else
            echo -e "${RED}❌ НЕ зарегистрирован${NC}"
            MISSING_FEATURES=$((MISSING_FEATURES + 1))
            echo -e "   └─ ${YELLOW}Выполните: ./scripts/register-existing-feature.sh $FEATURE${NC}"
        fi
        
        echo ""
    fi
done

# Проверяем ContentView
echo "📱 Проверка ContentView..."
if [ -f "LMS/ContentView.swift" ]; then
    if grep -q "FeatureRegistry\|Feature.allCases" "LMS/ContentView.swift"; then
        echo -e "${GREEN}✅ ContentView использует FeatureRegistry${NC}"
    else
        echo -e "${YELLOW}⚠️  ContentView не использует FeatureRegistry${NC}"
        echo "   └─ Рекомендуется обновить для автоматической навигации"
    fi
else
    echo -e "${RED}❌ ContentView.swift не найден${NC}"
fi

echo ""
echo "═══════════════════════════════════════"
echo "📊 ИТОГОВАЯ СТАТИСТИКА:"
echo "═══════════════════════════════════════"
echo "Всего модулей: $TOTAL_FEATURES"
echo -e "Интегрировано: ${GREEN}$INTEGRATED_FEATURES${NC}"
echo -e "Не интегрировано: ${RED}$MISSING_FEATURES${NC}"
echo ""

# Проверяем статус интеграции
if [ $MISSING_FEATURES -eq 0 ]; then
    echo -e "${GREEN}✅ Все модули успешно интегрированы!${NC}"
    exit 0
else
    echo -e "${RED}❌ Обнаружены неинтегрированные модули${NC}"
    echo ""
    echo "📝 Рекомендуемые действия:"
    echo "1. Запустите ./scripts/migrate-to-feature-registry.sh для автоматической миграции"
    echo "2. Или вручную зарегистрируйте каждый модуль"
    echo "3. Обновите docs/INTEGRATION_STATUS.md"
    exit 1
fi 