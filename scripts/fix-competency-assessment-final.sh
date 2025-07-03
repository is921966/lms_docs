#!/bin/bash

# Final fix for CompetencyAssessment to use AssessmentId value object

echo "🔧 Final fix for CompetencyAssessment..."
echo "========================================"

# 1. Update CompetencyAssessment to use AssessmentId
echo "📝 Updating CompetencyAssessment entity..."

cat > src/Competency/Domain/CompetencyAssessment.php << 'EOF'
<?php

declare(strict_types=1);

namespace Competency\Domain;

use Common\Traits\HasDomainEvents;
use Competency\Domain\Events\AssessmentCreated;
use Competency\Domain\Events\AssessmentUpdated;
use Competency\Domain\Events\AssessmentConfirmed;
use Competency\Domain\ValueObjects\AssessmentId;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;
use Competency\Domain\ValueObjects\AssessmentScore;
use Competency\Domain\ValueObjects\UserCompetencyId;
use User\Domain\ValueObjects\UserId;

class CompetencyAssessment
{
    use HasDomainEvents;
    
    private AssessmentId $id;
    private UserCompetencyId $userCompetencyId;
    private UserId $assessorId;
    private CompetencyLevel $level;
    private AssessmentScore $score;
    private ?string $comment;
    private \DateTimeImmutable $assessedAt;
    private ?UserId $confirmedBy;
    private ?\DateTimeImmutable $confirmedAt;
    
    private function __construct(
        AssessmentId $id,
        UserCompetencyId $userCompetencyId,
        UserId $assessorId,
        CompetencyLevel $level,
        AssessmentScore $score,
        ?string $comment = null,
        \DateTimeImmutable $assessedAt = new \DateTimeImmutable(),
        ?UserId $confirmedBy = null,
        ?\DateTimeImmutable $confirmedAt = null
    ) {
        $this->id = $id;
        $this->userCompetencyId = $userCompetencyId;
        $this->assessorId = $assessorId;
        $this->level = $level;
        $this->score = $score;
        $this->comment = $comment;
        $this->assessedAt = $assessedAt;
        $this->confirmedBy = $confirmedBy;
        $this->confirmedAt = $confirmedAt;
    }
    
    public static function create(
        UserCompetencyId $userCompetencyId,
        UserId $assessorId,
        CompetencyLevel $level,
        AssessmentScore $score,
        ?string $comment = null
    ): self {
        $id = AssessmentId::generate();
        $assessedAt = new \DateTimeImmutable();
        
        $assessment = new self(
            $id,
            $userCompetencyId,
            $assessorId,
            $level,
            $score,
            $comment,
            $assessedAt
        );
        
        $questions = [
            'level' => $level->getValue(),
            'score' => $score->getValue(),
            'comment' => $comment,
        ];
        
        $assessment->recordDomainEvent(new AssessmentCreated(
            $id,
            $userCompetencyId,
            'competency',
            $questions,
            $assessedAt
        ));
        
        return $assessment;
    }
    
    public static function createWithId(
        AssessmentId $id,
        UserCompetencyId $userCompetencyId,
        UserId $assessorId,
        CompetencyLevel $level,
        AssessmentScore $score,
        ?string $comment = null
    ): self {
        $assessedAt = new \DateTimeImmutable();
        
        $assessment = new self(
            $id,
            $userCompetencyId,
            $assessorId,
            $level,
            $score,
            $comment,
            $assessedAt
        );
        
        $questions = [
            'level' => $level->getValue(),
            'score' => $score->getValue(),
            'comment' => $comment,
        ];
        
        $assessment->recordDomainEvent(new AssessmentCreated(
            $id,
            $userCompetencyId,
            'competency',
            $questions,
            $assessedAt
        ));
        
        return $assessment;
    }
    
    public function confirm(UserId $confirmerId): void
    {
        if ($this->isConfirmed()) {
            throw new \DomainException('Assessment is already confirmed');
        }
        
        $this->confirmedBy = $confirmerId;
        $this->confirmedAt = new \DateTimeImmutable();
        
        $assessment->recordDomainEvent(new AssessmentConfirmed(
            $this->id,
            $confirmerId,
            'manager',
            $this->confirmedAt
        ));
    }
    
    public function update(CompetencyLevel $level, AssessmentScore $score, ?string $comment = null): void
    {
        if ($this->isConfirmed()) {
            throw new \DomainException('Cannot update confirmed assessment');
        }
        
        $this->level = $level;
        $this->score = $score;
        $this->comment = $comment;
        
        $answers = [
            'level' => $level->getValue(),
            'score' => $score->getValue(),
            'comment' => $comment,
        ];
        
        $this->recordDomainEvent(new AssessmentUpdated(
            $this->id,
            $answers,
            100 // Progress is 100% for competency assessment
        ));
    }
    
    public function isSelfAssessment(): bool
    {
        // For now, we'll need to get user from UserCompetency
        // This is a simplification - in real app we'd have this info
        return false;
    }
    
    public function isConfirmed(): bool
    {
        return $this->confirmedBy !== null;
    }
    
    public function getAssessmentType(): string
    {
        return $this->isSelfAssessment() ? 'self' : 'manager';
    }
    
    public function getGapToTarget(CompetencyLevel $targetLevel): int
    {
        return $targetLevel->getValue() - $this->level->getValue();
    }
    
    public function isAboveLevel(CompetencyLevel $level): bool
    {
        return $this->level->getValue() > $level->getValue();
    }
    
    public function getDaysSinceAssessment(): int
    {
        $now = new \DateTimeImmutable();
        $diff = $now->diff($this->assessedAt);
        return (int) $diff->days;
    }
    
    public function getId(): AssessmentId
    {
        return $this->id;
    }
    
    public function getUserCompetencyId(): UserCompetencyId
    {
        return $this->userCompetencyId;
    }
    
    public function getAssessorId(): UserId
    {
        return $this->assessorId;
    }
    
    public function getLevel(): CompetencyLevel
    {
        return $this->level;
    }
    
    public function getScore(): AssessmentScore
    {
        return $this->score;
    }
    
    public function getComment(): ?string
    {
        return $this->comment;
    }
    
    public function getAssessedAt(): \DateTimeImmutable
    {
        return $this->assessedAt;
    }
    
    public function getConfirmedBy(): ?UserId
    {
        return $this->confirmedBy;
    }
    
    public function getConfirmedAt(): ?\DateTimeImmutable
    {
        return $this->confirmedAt;
    }
}
EOF

# 2. Update the tests to use new API
echo "📝 Updating CompetencyAssessmentTest to use new API..."

# Find and replace old create method calls
sed -i '' 's/CompetencyAssessment::create(/CompetencyAssessment::create(/g' tests/Unit/Competency/Domain/CompetencyAssessmentTest.php

# Update test to not pass ID as first parameter
sed -i '' 's/CompetencyAssessment::create(\$assessmentId,/CompetencyAssessment::create(/g' tests/Unit/Competency/Domain/CompetencyAssessmentTest.php
sed -i '' 's/CompetencyAssessment::create('"'"'assessment-[^'"'"']*'"'"',/CompetencyAssessment::create(/g' tests/Unit/Competency/Domain/CompetencyAssessmentTest.php

# Fix createWithDate calls
sed -i '' 's/CompetencyAssessment::createWithDate(\$assessmentId,/CompetencyAssessment::createWithId(AssessmentId::fromString(\$assessmentId),/g' tests/Unit/Competency/Domain/CompetencyAssessmentTest.php
sed -i '' 's/CompetencyAssessment::createWithDate('"'"'[^'"'"']*'"'"',/CompetencyAssessment::createWithId(AssessmentId::fromString('"'"'test-id'"'"'),/g' tests/Unit/Competency/Domain/CompetencyAssessmentTest.php

# Add AssessmentId import to test file
sed -i '' '/^namespace/a\
\
use Competency\\Domain\\ValueObjects\\AssessmentId;' tests/Unit/Competency/Domain/CompetencyAssessmentTest.php

# 3. Run tests
echo "📊 Running CompetencyAssessment tests..."
./test-quick.sh tests/Unit/Competency/Domain/CompetencyAssessmentTest.php 2>&1 | grep -E "(OK|FAILURES|Tests:|Errors:)" | tail -5

echo ""
echo "📊 Running all Competency tests..."
./test-quick.sh tests/Unit/Competency/ 2>&1 | grep -E "(Tests:|OK|FAILURES|Errors:)" | tail -5

echo "�� Script completed!" 