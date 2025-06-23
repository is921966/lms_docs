<?php

declare(strict_types=1);

namespace App\Position\Domain\Events;

use App\Position\Domain\ValueObjects\PositionId;

final class PositionUpdated
{
    public function __construct(
        public readonly PositionId $positionId,
        public readonly array $changes,
        public readonly \DateTimeImmutable $occurredAt
    ) {
    }
    
    public static function occur(PositionId $positionId, array $changes): self
    {
        return new self(
            $positionId,
            $changes,
            new \DateTimeImmutable()
        );
    }
}
