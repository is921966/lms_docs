<?php

declare(strict_types=1);

namespace Learning\Application\Commands;

final class ArchiveCourseCommand
{
    public function __construct(
        private readonly string $courseId
    ) {
    }
    
    public function getCourseId(): string
    {
        return $this->courseId;
    }
} 