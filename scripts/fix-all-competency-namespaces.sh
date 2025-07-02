#!/bin/bash

echo "🔧 Исправление namespace во всем модуле Competency..."

# 1. Исправляем в основном коде (src/Competency)
echo ""
echo "📁 Исправление в src/Competency..."
find src/Competency -name "*.php" -type f | while read file; do
    # Заменяем use App\Competency на use Competency
    sed -i '' 's/use App\\Competency/use Competency/g' "$file"
    # Заменяем use App\Common на use Common
    sed -i '' 's/use App\\Common/use Common/g' "$file"
    # Заменяем use App\User на use User
    sed -i '' 's/use App\\User/use User/g' "$file"
    echo "✅ Исправлен: $file"
done

# 2. Исправляем в тестах
echo ""
echo "📁 Исправление в tests..."

# Unit tests
if [ -d "tests/Unit/Competency" ]; then
    find tests/Unit/Competency -name "*.php" -type f | while read file; do
        sed -i '' 's/use App\\Competency/use Competency/g' "$file"
        sed -i '' 's/use App\\Common/use Common/g' "$file"
        sed -i '' 's/use App\\User/use User/g' "$file"
        echo "✅ Исправлен: $file"
    done
fi

# Integration tests
if [ -d "tests/Integration/Competency" ]; then
    find tests/Integration/Competency -name "*.php" -type f | while read file; do
        sed -i '' 's/use App\\Competency/use Competency/g' "$file"
        sed -i '' 's/use App\\Common/use Common/g' "$file"
        sed -i '' 's/use App\\User/use User/g' "$file"
        echo "✅ Исправлен: $file"
    done
fi

# Feature tests
if [ -d "tests/Feature/Competency" ]; then
    find tests/Feature/Competency -name "*.php" -type f | while read file; do
        sed -i '' 's/use App\\Competency/use Competency/g' "$file"
        sed -i '' 's/use App\\Common/use Common/g' "$file"
        sed -i '' 's/use App\\User/use User/g' "$file"
        echo "✅ Исправлен: $file"
    done
fi

# 3. Проверяем что trait HasDomainEvents существует
echo ""
echo "🔍 Проверка наличия Common\Traits\HasDomainEvents..."
if [ ! -f "src/Common/Traits/HasDomainEvents.php" ]; then
    echo "⚠️  Trait HasDomainEvents не найден. Создаем..."
    mkdir -p src/Common/Traits
    cat > src/Common/Traits/HasDomainEvents.php << 'EOF'
<?php

declare(strict_types=1);

namespace Common\Traits;

trait HasDomainEvents
{
    private array $domainEvents = [];

    protected function addDomainEvent(object $event): void
    {
        $this->domainEvents[] = $event;
    }

    public function pullDomainEvents(): array
    {
        $events = $this->domainEvents;
        $this->domainEvents = [];
        return $events;
    }

    public function getDomainEvents(): array
    {
        return $this->domainEvents;
    }
}
EOF
    echo "✅ Trait создан"
fi

echo ""
echo "✨ Готово! Все namespace исправлены."
echo ""
echo "🧪 Запускаем тесты для проверки..."
./test-quick.sh tests/Unit/Competency/Domain/CompetencyTest.php 