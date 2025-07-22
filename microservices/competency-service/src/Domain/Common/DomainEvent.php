<?php

namespace CompetencyService\Domain\Common;

interface DomainEvent
{
    public function getAggregateId(): string;
    public function getOccurredAt(): \DateTimeImmutable;
    public function getEventName(): string;
    public function toArray(): array;
} 