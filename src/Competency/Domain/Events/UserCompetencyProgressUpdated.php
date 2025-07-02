<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;
use User\Domain\ValueObjects\UserId;

final class UserCompetencyProgressUpdated
{
    public function __construct(
        public readonly UserId $userId,
        public readonly CompetencyId $competencyId,
        public readonly CompetencyLevel $oldLevel,
        public readonly CompetencyLevel $newLevel,
        public readonly int $progressPercentage,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
} 