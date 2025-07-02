<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Competency\Domain\ValueObjects\CompetencyLevel;
use Competency\Domain\ValueObjects\AssessmentScore;

final class AssessmentUpdated
{
    public function __construct(
        public readonly string $assessmentId,
        public readonly CompetencyLevel $newLevel,
        public readonly AssessmentScore $newScore,
        public readonly ?string $newComment,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
} 