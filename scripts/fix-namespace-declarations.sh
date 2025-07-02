#!/bin/bash

echo "🔧 Исправление объявлений namespace..."

# Исправляем namespace declarations в src/Competency
echo ""
echo "📁 Исправление namespace declarations в src/Competency..."
find src/Competency -name "*.php" -type f | while read file; do
    # Заменяем namespace App\Competency на namespace Competency
    sed -i '' 's/namespace App\\Competency/namespace Competency/g' "$file"
    echo "✅ Исправлен: $file"
done

# Исправляем namespace declarations в src/Common
echo ""
echo "📁 Исправление namespace declarations в src/Common..."
find src/Common -name "*.php" -type f | while read file; do
    # Заменяем namespace App\Common на namespace Common
    sed -i '' 's/namespace App\\Common/namespace Common/g' "$file"
    echo "✅ Исправлен: $file"
done

# Исправляем namespace declarations в src/User
echo ""
echo "📁 Исправление namespace declarations в src/User..."
find src/User -name "*.php" -type f | while read file; do
    # Заменяем namespace App\User на namespace User
    sed -i '' 's/namespace App\\User/namespace User/g' "$file"
    echo "✅ Исправлен: $file"
done

echo ""
echo "✨ Готово! Все namespace declarations исправлены."
echo ""
echo "🧪 Запускаем тесты для проверки..."
./test-quick.sh tests/Unit/Competency/Domain/CompetencyTest.php 