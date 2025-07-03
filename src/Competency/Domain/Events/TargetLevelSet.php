<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\UserCompetencyId;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;
use User\Domain\ValueObjects\UserId;

final class TargetLevelSet implements DomainEventInterface
{
    public function __construct(
        public readonly UserCompetencyId $userCompetencyId,
        public readonly UserId $userId,
        public readonly CompetencyId $competencyId,
        public readonly CompetencyLevel $targetLevel,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'user_competency.target_level_set';
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
            'userId' => $this->userId->getValue(),
            'competencyId' => $this->competencyId->getValue(),
            'targetLevel' => $this->targetLevel->getValue(),
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
