#!/bin/bash

echo "🔧 Исправление оставшихся проблем в тестах..."

# 1. Исправляем CompetencyCategory::create в тестах репозиториев
echo ""
echo "📁 Исправление InMemoryCompetencyRepositoryTest..."
if [ -f "tests/Unit/Competency/Infrastructure/Repositories/InMemoryCompetencyRepositoryTest.php" ]; then
    # Заменяем CompetencyCategory::create() на фабричные методы
    sed -i '' 's/CompetencyCategory::technical()/CompetencyCategory::technical()/g' tests/Unit/Competency/Infrastructure/Repositories/InMemoryCompetencyRepositoryTest.php
    
    # Удаляем строки с CompetencyCategory::create
    sed -i '' '/CompetencyCategory::create(/,/);/d' tests/Unit/Competency/Infrastructure/Repositories/InMemoryCompetencyRepositoryTest.php
    
    echo "✅ Исправлен InMemoryCompetencyRepositoryTest"
fi

# 2. Исправляем getSkillLevel -> getLevels во всех тестах
echo ""
echo "📁 Исправление методов getSkillLevel..."
find tests/ -name "*.php" -type f | while read file; do
    if grep -q "getSkillLevel(" "$file"; then
        echo "🔄 Исправляем getSkillLevel в: $file"
        # getSkillLevel(1) -> getLevels()[0]
        sed -i '' 's/->getSkillLevel(\([0-9]\))/->getLevels()[\1-1]/g' "$file"
        echo "✅ Исправлен: $file"
    fi
done

# 3. Исправляем методы компетенций
echo ""
echo "📁 Исправление методов компетенций..."
find tests/ -name "*.php" -type f | while read file; do
    # updateDetails -> update
    if grep -q "updateDetails" "$file"; then
        echo "🔄 Исправляем updateDetails в: $file"
        sed -i '' 's/->updateDetails(/->update(/g' "$file"
        echo "✅ Исправлен: $file"
    fi
done

# 4. Создаем helper для создания тестовых компетенций
echo ""
echo "📁 Создаем TestHelper для компетенций..."
cat > tests/Helpers/CompetencyTestHelper.php << 'EOF'
<?php

namespace Tests\Helpers;

use Competency\Domain\Competency;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyCode;
use Competency\Domain\ValueObjects\CompetencyCategory;

class CompetencyTestHelper
{
    public static function createTestCompetency(
        string $name = 'Test Competency',
        string $category = 'technical'
    ): Competency {
        $categoryObject = match($category) {
            'technical' => CompetencyCategory::technical(),
            'soft' => CompetencyCategory::soft(),
            'leadership' => CompetencyCategory::leadership(),
            'business' => CompetencyCategory::business(),
            default => CompetencyCategory::technical()
        };
        
        return Competency::create(
            CompetencyId::generate(),
            CompetencyCode::fromString('TEST-' . rand(100, 999)),
            $name,
            'Test description',
            $categoryObject
        );
    }
}
EOF

echo "✅ TestHelper создан"

echo ""
echo "✨ Готово! Запускаем тесты..."
./test-quick.sh tests/Unit/Competency/ 2>&1 | grep -E "(Tests:|OK|ERRORS)" 