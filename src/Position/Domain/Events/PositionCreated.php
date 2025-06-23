<?php

declare(strict_types=1);

namespace App\Position\Domain\Events;

use App\Position\Domain\ValueObjects\PositionId;

final class PositionCreated
{
    public function __construct(
        public readonly PositionId $positionId,
        public readonly string $code,
        public readonly string $title,
        public readonly string $department,
        public readonly \DateTimeImmutable $occurredAt
    ) {
    }
    
    public static function occur(
        PositionId $positionId,
        string $code,
        string $title,
        string $department
    ): self {
        return new self(
            $positionId,
            $code,
            $title,
            $department,
            new \DateTimeImmutable()
        );
    }
} 