<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Competency\Domain\ValueObjects\CompetencyId;

final class CompetencyDeactivated
{
    public function __construct(
        public readonly CompetencyId $competencyId,
        public readonly string $reason = '',
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
} 