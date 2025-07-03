<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyCode;
use Competency\Domain\ValueObjects\CompetencyCategory;

final class CompetencyCreated implements DomainEventInterface
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
    
    public function getEventName(): string
    {
        return 'competency.created';
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
            'code' => $this->code->getValue(),
            'name' => $this->name,
            'description' => $this->description,
            'category' => $this->category->getValue(),
            'parentId' => $this->parentId?->getValue(),
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
