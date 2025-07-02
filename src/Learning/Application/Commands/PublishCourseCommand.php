<?php

declare(strict_types=1);

namespace Learning\Application\Commands;

use InvalidArgumentException;
use DateTimeImmutable;

final class PublishCourseCommand
{
    private string $commandId;
    private string $courseId;
    private string $publishedBy;
    private DateTimeImmutable $publishDate;
    private bool $notifyStudents;
    private DateTimeImmutable $createdAt;
    
    public function __construct(
        string $courseId,
        string $publishedBy,
        ?DateTimeImmutable $publishDate = null,
        bool $notifyStudents = false
    ) {
        if (empty($courseId)) {
            throw new InvalidArgumentException('Course ID cannot be empty');
        }
        
        if (empty($publishedBy)) {
            throw new InvalidArgumentException('Published by cannot be empty');
        }
        
        $publishDate = $publishDate ?? new DateTimeImmutable();
        
        // Don't allow publishing in the past
        $now = new DateTimeImmutable();
        if ($publishDate < $now->modify('-1 minute')) { // Allow 1 minute tolerance
            throw new InvalidArgumentException('Publish date cannot be in the past');
        }
        
        $this->commandId = uniqid('cmd_', true);
        $this->courseId = $courseId;
        $this->publishedBy = $publishedBy;
        $this->publishDate = $publishDate;
        $this->notifyStudents = $notifyStudents;
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
    
    public function getPublishedBy(): string
    {
        return $this->publishedBy;
    }
    
    public function getPublishDate(): DateTimeImmutable
    {
        return $this->publishDate;
    }
    
    public function shouldNotifyStudents(): bool
    {
        return $this->notifyStudents;
    }
    
    public function getCreatedAt(): DateTimeImmutable
    {
        return $this->createdAt;
    }
} 