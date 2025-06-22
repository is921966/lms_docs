<?php

declare(strict_types=1);

namespace App\Competency\Domain\Events;

use App\Competency\Domain\ValueObjects\CompetencyLevel;
use App\Competency\Domain\ValueObjects\AssessmentScore;

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