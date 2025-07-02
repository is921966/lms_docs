<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;
use Competency\Domain\ValueObjects\AssessmentScore;
use User\Domain\ValueObjects\UserId;

final class AssessmentCreated
{
    public function __construct(
        public readonly string $assessmentId,
        public readonly CompetencyId $competencyId,
        public readonly UserId $userId,
        public readonly UserId $assessorId,
        public readonly CompetencyLevel $level,
        public readonly AssessmentScore $score,
        public readonly ?string $comment,
        public readonly \DateTimeImmutable $assessedAt,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
} 