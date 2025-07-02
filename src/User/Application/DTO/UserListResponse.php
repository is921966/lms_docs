<?php

namespace User\Application\DTO;

class UserListResponse
{
    private array $users;
    private int $total;
    private int $page;
    private int $perPage;

    public function __construct(array $users, int $total, int $page, int $perPage)
    {
        $this->users = $users;
        $this->total = $total;
        $this->page = $page;
        $this->perPage = $perPage;
    }

    public function getUsers(): array
    {
        return $this->users;
    }

    public function getTotal(): int
    {
        return $this->total;
    }

    public function getPage(): int
    {
        return $this->page;
    }

    public function getPerPage(): int
    {
        return $this->perPage;
    }

    public function getTotalPages(): int
    {
        return (int) ceil($this->total / $this->perPage);
    }

    public function hasNextPage(): bool
    {
        return $this->page < $this->getTotalPages();
    }

    public function hasPreviousPage(): bool
    {
        return $this->page > 1;
    }

    public function toArray(): array
    {
        return [
            'data' => $this->users,
            'meta' => [
                'total' => $this->total,
                'page' => $this->page,
                'perPage' => $this->perPage,
                'totalPages' => $this->getTotalPages(),
                'hasNextPage' => $this->hasNextPage(),
                'hasPreviousPage' => $this->hasPreviousPage()
            ]
        ];
    }
} 