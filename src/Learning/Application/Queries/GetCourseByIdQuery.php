<?php

declare(strict_types=1);

namespace Learning\Application\Queries;

use InvalidArgumentException;
use DateTimeImmutable;

final class GetCourseByIdQuery
{
    private string $queryId;
    private string $courseId;
    private string $requestedBy;
    private DateTimeImmutable $createdAt;
    
    public function __construct(string $courseId, string $requestedBy)
    {
        if (empty($courseId)) {
            throw new InvalidArgumentException('Course ID cannot be empty');
        }
        
        if (empty($requestedBy)) {
            throw new InvalidArgumentException('Requested by cannot be empty');
        }
        
        $this->queryId = uniqid('query_', true);
        $this->courseId = $courseId;
        $this->requestedBy = $requestedBy;
        $this->createdAt = new DateTimeImmutable();
    }
    
    public function getQueryId(): string
    {
        return $this->queryId;
    }
    
    public function getCourseId(): string
    {
        return $this->courseId;
    }
    
    public function getRequestedBy(): string
    {
        return $this->requestedBy;
    }
    
    public function getCreatedAt(): DateTimeImmutable
    {
        return $this->createdAt;
    }
} 