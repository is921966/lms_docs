<?php

declare(strict_types=1);

namespace Learning\Application\Commands;

use InvalidArgumentException;
use DateTimeImmutable;

final class UpdateCourseCommand
{
    private string $commandId;
    private string $courseId;
    private array $updates;
    private string $updatedBy;
    private DateTimeImmutable $createdAt;
    
    public function __construct(
        string $courseId,
        array $updates,
        string $updatedBy
    ) {
        if (empty($courseId)) {
            throw new InvalidArgumentException('Course ID cannot be empty');
        }
        
        if (empty($updates)) {
            throw new InvalidArgumentException('No updates provided');
        }
        
        if (empty($updatedBy)) {
            throw new InvalidArgumentException('Updated by cannot be empty');
        }
        
        // Validate specific updates
        if (isset($updates['duration_hours']) && $updates['duration_hours'] <= 0) {
            throw new InvalidArgumentException('Duration must be positive');
        }
        
        $this->commandId = uniqid('cmd_', true);
        $this->courseId = $courseId;
        $this->updates = $updates;
        $this->updatedBy = $updatedBy;
        $this->createdAt = new DateTimeImmutable();
    }
    
    public function getCommandId(): string
    {
        return $this->commandId;
    }
    
    public function getCourseId(): string
    {
        return $this->courseId;
    }
    
    public function getUpdates(): array
    {
        return $this->updates;
    }
    
    public function getUpdatedBy(): string
    {
        return $this->updatedBy;
    }
    
    public function getCreatedAt(): DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getUpdate(string $key): mixed
    {
        return $this->updates[$key] ?? null;
    }
    
    public function hasUpdate(string $key): bool
    {
        return isset($this->updates[$key]);
    }
} 