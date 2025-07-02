<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use User\Domain\ValueObjects\UserId;

final class AssessmentConfirmed
{
    public function __construct(
        public readonly string $assessmentId,
        public readonly UserId $confirmedBy,
        public readonly \DateTimeImmutable $confirmedAt,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
} 