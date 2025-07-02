#!/bin/bash

echo "🔧 Исправление использования CompetencyCategory во всех тестах..."

# Находим все тесты с проблемным паттерном
echo ""
echo "📁 Поиск файлов с CompetencyCategory::create..."
files=$(grep -r "CompetencyCategory::create" tests/ --include="*.php" -l)

if [ -z "$files" ]; then
    echo "✅ Файлов с CompetencyCategory::create не найдено"
else
    echo "Найдено файлов: $(echo "$files" | wc -l)"
    
    for file in $files; do
        echo "🔄 Обрабатываем: $file"
        
        # Заменяем CompetencyCategory::create на правильные фабричные методы
        sed -i '' 's/CompetencyCategory::create([^)]*))/CompetencyCategory::technical()/g' "$file"
        sed -i '' 's/CompetencyCategory::createWithId([^)]*))/CompetencyCategory::technical()/g' "$file"
        
        # Удаляем импорты CategoryId если они больше не нужны
        if ! grep -q "CategoryId" "$file" | grep -v "use.*CategoryId"; then
            sed -i '' '/use.*CategoryId;/d' "$file"
        fi
        
        echo "✅ Исправлен: $file"
    done
fi

echo ""
echo "📁 Поиск других проблемных паттернов..."

# Исправляем getSkillLevel -> getLevels
find tests/ -name "*.php" -type f | while read file; do
    if grep -q "getSkillLevel" "$file"; then
        echo "🔄 Исправляем getSkillLevel в: $file"
        sed -i '' 's/->getSkillLevel(/->getLevels()[/g' "$file"
        sed -i '' 's/->getSkillLevels(/->getLevels(/g' "$file"
        echo "✅ Исправлен: $file"
    fi
done

echo ""
echo "✨ Готово! Исправления применены."
echo ""
echo "🧪 Запускаем тесты для проверки..."
./test-quick.sh tests/Unit/Competency/ 2>&1 | grep -E "(Tests:|OK|ERRORS)" 