<?php

declare(strict_types=1);

namespace App\Competency\Domain\Events;

use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyCode;
use App\Competency\Domain\ValueObjects\CompetencyCategory;

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