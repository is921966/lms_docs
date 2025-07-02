<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;
use User\Domain\ValueObjects\UserId;

final class UserCompetencyCreated
{
    public function __construct(
        public readonly UserId $userId,
        public readonly CompetencyId $competencyId,
        public readonly CompetencyLevel $currentLevel,
        public readonly ?CompetencyLevel $targetLevel,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
} 