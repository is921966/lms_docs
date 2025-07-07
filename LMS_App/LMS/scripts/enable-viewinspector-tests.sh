#!/bin/bash

# 🚀 Скрипт для включения ViewInspector тестов
# Автоматизирует часть процесса интеграции ViewInspector

set -e

echo "🔧 ViewInspector Tests Enabler"
echo "=============================="
echo ""

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Проверка, что мы в правильной директории
if [ ! -f "LMS.xcodeproj/project.pbxproj" ]; then
    echo -e "${RED}❌ Ошибка: Запустите скрипт из директории /Users/ishirokov/lms_docs/LMS_App/LMS${NC}"
    exit 1
fi

echo "📍 Текущая директория: $(pwd)"
echo ""

# Шаг 1: Поиск отключенных тестов
echo "🔍 Шаг 1: Поиск отключенных ViewInspector тестов..."
disabled_files=$(find LMSTests -name "*.swift.disabled" -type f 2>/dev/null)

if [ -z "$disabled_files" ]; then
    echo -e "${YELLOW}⚠️  Отключенных тестов не найдено${NC}"
else
    count=$(echo "$disabled_files" | wc -l | tr -d ' ')
    echo -e "${GREEN}✅ Найдено отключенных файлов: $count${NC}"
    echo "$disabled_files" | while read -r file; do
        echo "   - $file"
    done
fi
echo ""

# Шаг 2: Включение тестов
if [ ! -z "$disabled_files" ]; then
    echo "🔄 Шаг 2: Включение тестов..."
    
    echo "$disabled_files" | while read -r file; do
        if [ ! -z "$file" ]; then
            new_name="${file%.disabled}"
            mv "$file" "$new_name"
            echo -e "   ${GREEN}✅${NC} $(basename "$file") → $(basename "$new_name")"
        fi
    done
    
    echo -e "${GREEN}✅ Все тесты включены!${NC}"
else
    echo "⏭️  Шаг 2: Пропущен (нет отключенных тестов)"
fi
echo ""

# Шаг 3: Проверка Package.swift
echo "📦 Шаг 3: Проверка Package.swift..."
if [ -f "Package.swift" ]; then
    if grep -q "ViewInspector" Package.swift; then
        echo -e "${GREEN}✅ ViewInspector найден в Package.swift${NC}"
        
        # Показать версию
        version=$(grep -A2 'ViewInspector' Package.swift | grep -E 'from:|exact:' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if [ ! -z "$version" ]; then
            echo "   Версия: $version"
        fi
    else
        echo -e "${RED}❌ ViewInspector НЕ найден в Package.swift${NC}"
        echo "   Необходимо добавить через Xcode UI"
    fi
else
    echo -e "${YELLOW}⚠️  Package.swift не найден${NC}"
fi
echo ""

# Шаг 4: Очистка кэша
echo "🧹 Шаг 4: Очистка кэша сборки..."
echo "   Удаление DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-* 2>/dev/null || true
echo -e "${GREEN}✅ Кэш очищен${NC}"
echo ""

# Шаг 5: Инструкции для пользователя
echo "📋 Следующие шаги (требуют Xcode):"
echo "=================================="
echo ""
echo "1️⃣  Откройте Xcode:"
echo "    ${YELLOW}open LMS.xcodeproj${NC}"
echo ""
echo "2️⃣  Добавьте ViewInspector через UI:"
echo "    • Кликните на корневой проект LMS"
echo "    • Перейдите в Package Dependencies"
echo "    • Нажмите '+' и добавьте: ${YELLOW}https://github.com/nalexn/ViewInspector${NC}"
echo "    • Версия: ${YELLOW}0.9.8${NC}"
echo "    • Target: ${YELLOW}только LMSTests${NC}"
echo ""
echo "3️⃣  Обновите пакеты:"
echo "    • File → Packages → Reset Package Caches"
echo ""
echo "4️⃣  Запустите тесты:"
echo "    • Cmd+U или используйте скрипт ниже"
echo ""

# Шаг 6: Создание команды для запуска тестов
echo "🚀 Команда для запуска тестов с покрытием:"
echo "=========================================="
cat << 'EOF' > run-tests-with-coverage.sh
#!/bin/bash
xcodebuild test \
  -scheme LMS \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -enableCodeCoverage YES \
  -resultBundlePath testResultsCoverage.xcresult \
  2>&1 | tee test_output_viewinspector_$(date +%Y%m%d_%H%M%S).log

# Показать краткую статистику
echo ""
echo "📊 Результаты тестов:"
tail -20 test_output_viewinspector_*.log | grep -E "Test Suite.*passed|failed|Executed"
EOF

chmod +x run-tests-with-coverage.sh
echo -e "${GREEN}✅ Создан скрипт: run-tests-with-coverage.sh${NC}"
echo ""

# Итоговая статистика
echo "📊 Итоговая статистика:"
echo "======================"
total_swift_files=$(find LMSTests -name "*.swift" -type f | wc -l | tr -d ' ')
viewinspector_files=$(find LMSTests -name "*ViewInspectorTests.swift" -type f 2>/dev/null | wc -l | tr -d ' ')

echo "• Всего тестовых файлов: $total_swift_files"
echo "• ViewInspector тестов: $viewinspector_files"
echo ""

echo -e "${GREEN}✅ Автоматическая часть завершена!${NC}"
echo ""
echo "⚠️  ${YELLOW}ВАЖНО: Теперь необходимо выполнить шаги в Xcode (см. выше)${NC}"
echo ""
echo "📚 Полная инструкция: ${YELLOW}VIEWINSPECTOR_XCODE_INTEGRATION_GUIDE.md${NC}" 