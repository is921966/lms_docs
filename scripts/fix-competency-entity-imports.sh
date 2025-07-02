#!/bin/bash

echo "🔧 Исправление импортов Competency Entities..."

# Заменяем в тестах
find tests -name "*.php" -type f | while read file; do
    if grep -q "Competency\\\\Domain\\\\Entities\\\\Competency" "$file"; then
        sed -i '' 's/use Competency\\Domain\\Entities\\Competency;/use Competency\\Domain\\Competency;/g' "$file"
        echo "✅ Исправлен: $file"
    fi
done

# Также проверим CompetencyCategory
find tests -name "*.php" -type f | while read file; do
    if grep -q "Competency\\\\Domain\\\\Entities\\\\CompetencyCategory" "$file"; then
        sed -i '' 's/use Competency\\Domain\\Entities\\CompetencyCategory;/use Competency\\Domain\\ValueObjects\\CompetencyCategory;/g' "$file"
        echo "✅ Исправлен Category: $file"
    fi
done

echo ""
echo "✨ Готово! Импорты исправлены." 