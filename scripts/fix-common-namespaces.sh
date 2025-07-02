#!/bin/bash

echo "🔧 Исправление namespace в модуле Common..."

# Исправляем namespace во всех файлах Common
find src/Common -name "*.php" -type f | while read file; do
    # Заменяем namespace App\Common на namespace Common
    sed -i '' 's/namespace App\\Common/namespace Common/g' "$file"
    # Заменяем use App\Common на use Common
    sed -i '' 's/use App\\Common/use Common/g' "$file"
    echo "✅ Исправлен: $file"
done

echo ""
echo "✨ Готово! Namespace в Common исправлены."
echo ""
echo "🧪 Проверяем trait HasDomainEvents..."
head -10 src/Common/Traits/HasDomainEvents.php 