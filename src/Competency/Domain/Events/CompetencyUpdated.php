<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Competency\Domain\ValueObjects\CompetencyId;

final class CompetencyUpdated
{
    public function __construct(
        public readonly CompetencyId $competencyId,
        public readonly array $changes,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
} 