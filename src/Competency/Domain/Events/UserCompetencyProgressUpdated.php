<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\UserCompetencyId;

final class UserCompetencyProgressUpdated implements DomainEventInterface
{
    public function __construct(
        public readonly UserCompetencyId $userCompetencyId,
        public readonly int $oldLevel,
        public readonly int $newLevel,
        public readonly int $progress,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'user_competency.progress_updated';
    }
    
    public function getAggregateId(): string
    {
        return $this->userCompetencyId->getValue();
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function toArray(): array
    {
        return [
            'userCompetencyId' => $this->userCompetencyId->getValue(),
            'oldLevel' => $this->oldLevel,
            'newLevel' => $this->newLevel,
            'progress' => $this->progress,
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
