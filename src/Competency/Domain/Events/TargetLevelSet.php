<?php

declare(strict_types=1);

namespace App\Competency\Domain\Events;

use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;
use App\User\Domain\ValueObjects\UserId;

final class TargetLevelSet
{
    public function __construct(
        public readonly UserId $userId,
        public readonly CompetencyId $competencyId,
        public readonly CompetencyLevel $targetLevel,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
} 