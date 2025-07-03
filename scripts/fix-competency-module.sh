#!/bin/bash

# Fix Competency Module Issues Script
# Fixes domain events, namespaces, and other issues

echo "🔧 Fixing Competency Module Issues..."
echo "===================================="

# 1. Update all Competency events to implement DomainEventInterface
echo "📝 Step 1: Updating domain events to implement DomainEventInterface..."

# Fix CompetencyCreated event
cat > src/Competency/Domain/Events/CompetencyCreated.php << 'EOF'
<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyCode;
use Competency\Domain\ValueObjects\CompetencyCategory;

final class CompetencyCreated implements DomainEventInterface
{
    public function __construct(
        public readonly CompetencyId $competencyId,
        public readonly CompetencyCode $code,
        public readonly string $name,
        public readonly string $description,
        public readonly CompetencyCategory $category,
        public readonly ?CompetencyId $parentId = null,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'competency.created';
    }
    
    public function getAggregateId(): string
    {
        return $this->competencyId->getValue();
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function toArray(): array
    {
        return [
            'competencyId' => $this->competencyId->getValue(),
            'code' => $this->code->getValue(),
            'name' => $this->name,
            'description' => $this->description,
            'category' => $this->category->getValue(),
            'parentId' => $this->parentId?->getValue(),
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
EOF

# Fix CompetencyUpdated event
cat > src/Competency/Domain/Events/CompetencyUpdated.php << 'EOF'
<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\CompetencyId;

final class CompetencyUpdated implements DomainEventInterface
{
    public function __construct(
        public readonly CompetencyId $competencyId,
        public readonly array $changes,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'competency.updated';
    }
    
    public function getAggregateId(): string
    {
        return $this->competencyId->getValue();
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function toArray(): array
    {
        return [
            'competencyId' => $this->competencyId->getValue(),
            'changes' => $this->changes,
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
EOF

# Fix CompetencyDeactivated event
cat > src/Competency/Domain/Events/CompetencyDeactivated.php << 'EOF'
<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\CompetencyId;

final class CompetencyDeactivated implements DomainEventInterface
{
    public function __construct(
        public readonly CompetencyId $competencyId,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'competency.deactivated';
    }
    
    public function getAggregateId(): string
    {
        return $this->competencyId->getValue();
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function toArray(): array
    {
        return [
            'competencyId' => $this->competencyId->getValue(),
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
EOF

# Fix CompetencyActivated event
cat > src/Competency/Domain/Events/CompetencyActivated.php << 'EOF'
<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\CompetencyId;

final class CompetencyActivated implements DomainEventInterface
{
    public function __construct(
        public readonly CompetencyId $competencyId,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'competency.activated';
    }
    
    public function getAggregateId(): string
    {
        return $this->competencyId->getValue();
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function toArray(): array
    {
        return [
            'competencyId' => $this->competencyId->getValue(),
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
EOF

echo "✅ Domain events updated"

# 2. Fix namespace issues in tests
echo "📝 Step 2: Fixing namespace issues in tests..."

# Find and fix all App\Competency namespace usages
find tests/Unit/Competency tests/Integration/Competency -name "*.php" -type f -exec sed -i '' 's/App\\Competency\\/Competency\\/g' {} \;

echo "✅ Namespaces fixed"

# 3. Update value objects that might have getValue() issues
echo "📝 Step 3: Checking value objects have getValue() method..."

# Make sure all value objects have getValue() method
for file in src/Competency/Domain/ValueObjects/*.php; do
    if ! grep -q "public function getValue()" "$file"; then
        # Add getValue() method if missing
        sed -i '' '/^}$/i\
\
    public function getValue(): string\
    {\
        return $this->value;\
    }' "$file"
    fi
done

echo "✅ Value objects checked"

# 4. Run tests to see remaining issues
echo "📊 Running tests to check progress..."
./test-quick.sh tests/Unit/Competency/Domain/CompetencyTest.php

echo "🎯 Script completed! Check test results above." 