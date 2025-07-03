#!/bin/bash

# Fix remaining Competency Module Events
# Part 2: UserCompetency and CompetencyAssessment events

echo "🔧 Fixing remaining Competency events..."
echo "========================================"

# 1. Fix UserCompetencyCreated event
echo "📝 Fixing UserCompetencyCreated..."
cat > src/Competency/Domain/Events/UserCompetencyCreated.php << 'EOF'
<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\UserCompetencyId;
use Competency\Domain\ValueObjects\CompetencyId;
use User\Domain\ValueObjects\UserId;

final class UserCompetencyCreated implements DomainEventInterface
{
    public function __construct(
        public readonly UserCompetencyId $userCompetencyId,
        public readonly UserId $userId,
        public readonly CompetencyId $competencyId,
        public readonly int $currentLevel,
        public readonly ?int $targetLevel = null,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'user_competency.created';
    }
    
    public function getAggregateId(): string
    {
        return $this->userCompetencyId->getValue();
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function toArray(): array
    {
        return [
            'userCompetencyId' => $this->userCompetencyId->getValue(),
            'userId' => $this->userId->getValue(),
            'competencyId' => $this->competencyId->getValue(),
            'currentLevel' => $this->currentLevel,
            'targetLevel' => $this->targetLevel,
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
EOF

# 2. Fix UserCompetencyProgressUpdated event
echo "📝 Fixing UserCompetencyProgressUpdated..."
cat > src/Competency/Domain/Events/UserCompetencyProgressUpdated.php << 'EOF'
<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\UserCompetencyId;

final class UserCompetencyProgressUpdated implements DomainEventInterface
{
    public function __construct(
        public readonly UserCompetencyId $userCompetencyId,
        public readonly int $oldLevel,
        public readonly int $newLevel,
        public readonly int $progress,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'user_competency.progress_updated';
    }
    
    public function getAggregateId(): string
    {
        return $this->userCompetencyId->getValue();
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function toArray(): array
    {
        return [
            'userCompetencyId' => $this->userCompetencyId->getValue(),
            'oldLevel' => $this->oldLevel,
            'newLevel' => $this->newLevel,
            'progress' => $this->progress,
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
EOF

# 3. Fix CompetencyAssessmentCompleted event
echo "📝 Fixing CompetencyAssessmentCompleted..."
cat > src/Competency/Domain/Events/CompetencyAssessmentCompleted.php << 'EOF'
<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\AssessmentId;
use Competency\Domain\ValueObjects\UserCompetencyId;

final class CompetencyAssessmentCompleted implements DomainEventInterface
{
    public function __construct(
        public readonly AssessmentId $assessmentId,
        public readonly UserCompetencyId $userCompetencyId,
        public readonly int $score,
        public readonly int $achievedLevel,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'competency_assessment.completed';
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
            'score' => $this->score,
            'achievedLevel' => $this->achievedLevel,
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
EOF

# 4. Check if there are more events to fix
echo "📝 Checking for other event files..."
for event_file in src/Competency/Domain/Events/*.php; do
    if ! grep -q "implements DomainEventInterface" "$event_file"; then
        echo "⚠️  Found event without interface: $event_file"
        # Get the class name
        class_name=$(basename "$event_file" .php)
        
        # Add the interface implementation
        sed -i '' "s/final class $class_name$/final class $class_name implements DomainEventInterface/" "$event_file"
        
        # Add the import if not present
        if ! grep -q "use Common\\\\Interfaces\\\\DomainEventInterface;" "$event_file"; then
            sed -i '' '/^namespace/a\
\
use Common\\Interfaces\\DomainEventInterface;' "$event_file"
        fi
    fi
done

echo "✅ All events updated"

# 5. Run tests again
echo "📊 Running tests to check progress..."
echo "Testing UserCompetency..."
./test-quick.sh tests/Unit/Competency/Domain/UserCompetencyTest.php 2>&1 | grep -E "(OK|FAILURES|Tests:)" | tail -3

echo ""
echo "Testing CompetencyAssessment..."
./test-quick.sh tests/Unit/Competency/Domain/CompetencyAssessmentTest.php 2>&1 | grep -E "(OK|FAILURES|Tests:)" | tail -3

echo ""
echo "Testing all Competency unit tests..."
./test-quick.sh tests/Unit/Competency/ 2>&1 | grep -E "(OK|FAILURES|Tests:)" | tail -3

echo "�� Script completed!" 