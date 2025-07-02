<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyCode;
use Competency\Domain\ValueObjects\CompetencyCategory;

final class CompetencyCreated
{
    public function __construct(
        public readonly CompetencyId $competencyId,
        public readonly CompetencyCode $code,
        public readonly string $name,
        public readonly string $description,
        public readonly CompetencyCategory $category,
        public readonly ?CompetencyId $parentId = null,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
} 