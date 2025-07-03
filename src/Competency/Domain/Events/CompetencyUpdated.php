<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\CompetencyId;

final class CompetencyUpdated implements DomainEventInterface
{
    public function __construct(
        public readonly CompetencyId $competencyId,
        public readonly array $changes,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'competency.updated';
    }
    
    public function getAggregateId(): string
    {
        return $this->competencyId->getValue();
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function toArray(): array
    {
        return [
            'competencyId' => $this->competencyId->getValue(),
            'changes' => $this->changes,
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
