<?php

namespace User\Application\Queries\ListUsers;

class ListUsersQuery
{
    private int $page;
    private int $perPage;
    private ?string $search;
    private array $filters;
    private ?string $sortBy;
    private string $sortOrder;

    public function __construct(
        int $page = 1,
        int $perPage = 10,
        ?string $search = null,
        array $filters = [],
        ?string $sortBy = null,
        string $sortOrder = 'asc'
    ) {
        $this->page = max(1, $page);
        $this->perPage = min(100, max(1, $perPage));
        $this->search = $search;
        $this->filters = $filters;
        $this->sortBy = $sortBy;
        $this->sortOrder = in_array(strtolower($sortOrder), ['asc', 'desc']) ? strtolower($sortOrder) : 'asc';
    }

    public function getPage(): int
    {
        return $this->page;
    }

    public function getPerPage(): int
    {
        return $this->perPage;
    }

    public function getSearch(): ?string
    {
        return $this->search;
    }

    public function getFilters(): array
    {
        return $this->filters;
    }

    public function getSortBy(): ?string
    {
        return $this->sortBy;
    }

    public function getSortOrder(): string
    {
        return $this->sortOrder;
    }

    public function getOffset(): int
    {
        return ($this->page - 1) * $this->perPage;
    }
} 