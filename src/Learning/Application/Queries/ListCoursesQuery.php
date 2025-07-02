<?php

declare(strict_types=1);

namespace Learning\Application\Queries;

use InvalidArgumentException;
use DateTimeImmutable;

final class ListCoursesQuery
{
    private string $queryId;
    private string $requestedBy;
    private array $filters;
    private int $page;
    private int $perPage;
    private string $sortBy;
    private string $sortOrder;
    private DateTimeImmutable $createdAt;
    
    public function __construct(
        string $requestedBy,
        array $filters = [],
        int $page = 1,
        int $perPage = 10,
        string $sortBy = 'created_at',
        string $sortOrder = 'desc'
    ) {
        if (empty($requestedBy)) {
            throw new InvalidArgumentException('Requested by cannot be empty');
        }
        
        if ($page < 1) {
            throw new InvalidArgumentException('Page must be positive');
        }
        
        if ($perPage < 1 || $perPage > 100) {
            throw new InvalidArgumentException('Per page must be between 1 and 100');
        }
        
        if (!in_array($sortOrder, ['asc', 'desc'], true)) {
            throw new InvalidArgumentException('Sort order must be asc or desc');
        }
        
        $this->queryId = uniqid('query_', true);
        $this->requestedBy = $requestedBy;
        $this->filters = $filters;
        $this->page = $page;
        $this->perPage = $perPage;
        $this->sortBy = $sortBy;
        $this->sortOrder = $sortOrder;
        $this->createdAt = new DateTimeImmutable();
    }
    
    public function getQueryId(): string
    {
        return $this->queryId;
    }
    
    public function getRequestedBy(): string
    {
        return $this->requestedBy;
    }
    
    public function getFilters(): array
    {
        return $this->filters;
    }
    
    public function getPage(): int
    {
        return $this->page;
    }
    
    public function getPerPage(): int
    {
        return $this->perPage;
    }
    
    public function getSortBy(): string
    {
        return $this->sortBy;
    }
    
    public function getSortOrder(): string
    {
        return $this->sortOrder;
    }
    
    public function getCreatedAt(): DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getOffset(): int
    {
        return ($this->page - 1) * $this->perPage;
    }
    
    public function hasFilter(string $key): bool
    {
        return isset($this->filters[$key]);
    }
    
    public function getFilter(string $key): mixed
    {
        return $this->filters[$key] ?? null;
    }
} 