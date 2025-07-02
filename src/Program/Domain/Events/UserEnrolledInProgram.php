<?php

declare(strict_types=1);

namespace Program\Domain\Events;

use Common\Domain\DomainEvent;
use Program\Domain\ValueObjects\ProgramId;
use User\Domain\ValueObjects\UserId;

final class UserEnrolledInProgram implements DomainEvent
{
    private UserId $userId;
    private ProgramId $programId;
    private \DateTimeImmutable $enrolledAt;
    private \DateTimeImmutable $occurredOn;
    
    public function __construct(
        UserId $userId,
        ProgramId $programId,
        \DateTimeImmutable $enrolledAt
    ) {
        $this->userId = $userId;
        $this->programId = $programId;
        $this->enrolledAt = $enrolledAt;
        $this->occurredOn = new \DateTimeImmutable();
    }
    
    public function getAggregateId(): string
    {
        return $this->programId->getValue();
    }
    
    public function occurredOn(): \DateTimeImmutable
    {
        return $this->occurredOn;
    }
    
    public function getUserId(): UserId
    {
        return $this->userId;
    }
    
    public function getProgramId(): ProgramId
    {
        return $this->programId;
    }
    
    public function getEnrolledAt(): \DateTimeImmutable
    {
        return $this->enrolledAt;
    }
} 