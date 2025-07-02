#!/bin/bash

echo "🔧 Исправление namespace в тестах модуля Competency..."

# Находим все PHP файлы в tests/Unit/Competency и заменяем App\Competency на Competency
find tests/Unit/Competency -name "*.php" -type f | while read file; do
    # Заменяем use App\Competency на use Competency
    sed -i '' 's/use App\\Competency/use Competency/g' "$file"
    echo "✅ Исправлен: $file"
done

# Также проверяем Integration тесты
if [ -d "tests/Integration/Competency" ]; then
    find tests/Integration/Competency -name "*.php" -type f | while read file; do
        sed -i '' 's/use App\\Competency/use Competency/g' "$file"
        echo "✅ Исправлен: $file"
    done
fi

# И Feature тесты
if [ -d "tests/Feature/Competency" ]; then
    find tests/Feature/Competency -name "*.php" -type f | while read file; do
        sed -i '' 's/use App\\Competency/use Competency/g' "$file"
        echo "✅ Исправлен: $file"
    done
fi

echo "✨ Готово! Все namespace исправлены."
echo ""
echo "🧪 Запускаем тесты для проверки..."
./test-quick.sh tests/Unit/Competency/Domain/CompetencyTest.php 