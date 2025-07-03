#!/bin/bash

# Fix Assessment events to implement DomainEventInterface methods

echo "🔧 Fixing Assessment events..."
echo "============================="

# 1. Fix AssessmentCreated
echo "📝 Fixing AssessmentCreated..."
cat > src/Competency/Domain/Events/AssessmentCreated.php << 'EOF'
<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\AssessmentId;
use Competency\Domain\ValueObjects\UserCompetencyId;

final class AssessmentCreated implements DomainEventInterface
{
    public function __construct(
        public readonly AssessmentId $assessmentId,
        public readonly UserCompetencyId $userCompetencyId,
        public readonly string $assessmentType,
        public readonly array $questions,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'assessment.created';
    }
    
    public function getAggregateId(): string
    {
        return $this->assessmentId->getValue();
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function toArray(): array
    {
        return [
            'assessmentId' => $this->assessmentId->getValue(),
            'userCompetencyId' => $this->userCompetencyId->getValue(),
            'assessmentType' => $this->assessmentType,
            'questions' => $this->questions,
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
EOF

# 2. Fix AssessmentUpdated
echo "📝 Fixing AssessmentUpdated..."
cat > src/Competency/Domain/Events/AssessmentUpdated.php << 'EOF'
<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\AssessmentId;

final class AssessmentUpdated implements DomainEventInterface
{
    public function __construct(
        public readonly AssessmentId $assessmentId,
        public readonly array $answers,
        public readonly int $currentProgress,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'assessment.updated';
    }
    
    public function getAggregateId(): string
    {
        return $this->assessmentId->getValue();
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function toArray(): array
    {
        return [
            'assessmentId' => $this->assessmentId->getValue(),
            'answers' => $this->answers,
            'currentProgress' => $this->currentProgress,
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
EOF

# 3. Fix AssessmentConfirmed
echo "📝 Fixing AssessmentConfirmed..."
cat > src/Competency/Domain/Events/AssessmentConfirmed.php << 'EOF'
<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\AssessmentId;
use User\Domain\ValueObjects\UserId;

final class AssessmentConfirmed implements DomainEventInterface
{
    public function __construct(
        public readonly AssessmentId $assessmentId,
        public readonly UserId $confirmedBy,
        public readonly string $confirmerRole,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'assessment.confirmed';
    }
    
    public function getAggregateId(): string
    {
        return $this->assessmentId->getValue();
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function toArray(): array
    {
        return [
            'assessmentId' => $this->assessmentId->getValue(),
            'confirmedBy' => $this->confirmedBy->getValue(),
            'confirmerRole' => $this->confirmerRole,
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
EOF

# 4. Make sure AssessmentId value object exists
echo "📝 Checking AssessmentId value object..."

if [ ! -f "src/Competency/Domain/ValueObjects/AssessmentId.php" ]; then
    cat > src/Competency/Domain/ValueObjects/AssessmentId.php << 'EOF'
<?php

declare(strict_types=1);

namespace Competency\Domain\ValueObjects;

final class AssessmentId
{
    private string $value;
    
    public function __construct(string $value)
    {
        if (empty($value)) {
            throw new \InvalidArgumentException('AssessmentId cannot be empty');
        }
        
        $this->value = $value;
    }
    
    public static function generate(): self
    {
        return new self(bin2hex(random_bytes(16)));
    }
    
    public static function fromString(string $value): self
    {
        return new self($value);
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
}
EOF
fi

echo "✅ Assessment events updated"

# 5. Run tests again
echo "📊 Running Competency tests..."
./test-quick.sh tests/Unit/Competency/ 2>&1 | grep -E "(Tests:|OK|FAILURES|Errors:)" | tail -5

echo "�� Script completed!" 