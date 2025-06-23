<?php

declare(strict_types=1);

namespace App\Position\Domain\Events;

use App\Position\Domain\ValueObjects\PositionId;

final class PositionArchived
{
    public function __construct(
        public readonly PositionId $positionId,
        public readonly \DateTimeImmutable $occurredAt
    ) {
    }
    
    public static function occur(PositionId $positionId): self
    {
        return new self(
            $positionId,
            new \DateTimeImmutable()
        );
    }
}
