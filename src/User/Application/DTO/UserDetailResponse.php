<?php

namespace User\Application\DTO;

class UserDetailResponse
{
    private string $id;
    private string $firstName;
    private string $lastName;
    private ?string $middleName;
    private string $email;
    private ?string $phone;
    private ?string $department;
    private string $role;
    private string $status;
    private bool $isAdmin;
    private bool $isDeleted;
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    private ?\DateTimeImmutable $deletedAt;

    public function __construct(
        string $id,
        string $firstName,
        string $lastName,
        ?string $middleName,
        string $email,
        ?string $phone,
        ?string $department,
        string $role,
        string $status,
        bool $isAdmin,
        bool $isDeleted,
        \DateTimeImmutable $createdAt,
        \DateTimeImmutable $updatedAt,
        ?\DateTimeImmutable $deletedAt
    ) {
        $this->id = $id;
        $this->firstName = $firstName;
        $this->lastName = $lastName;
        $this->middleName = $middleName;
        $this->email = $email;
        $this->phone = $phone;
        $this->department = $department;
        $this->role = $role;
        $this->status = $status;
        $this->isAdmin = $isAdmin;
        $this->isDeleted = $isDeleted;
        $this->createdAt = $createdAt;
        $this->updatedAt = $updatedAt;
        $this->deletedAt = $deletedAt;
    }

    public function getId(): string
    {
        return $this->id;
    }

    public function getFirstName(): string
    {
        return $this->firstName;
    }

    public function getLastName(): string
    {
        return $this->lastName;
    }

    public function getMiddleName(): ?string
    {
        return $this->middleName;
    }

    public function getFullName(): string
    {
        $parts = array_filter([
            $this->firstName,
            $this->lastName
        ]);
        return implode(' ', $parts);
    }

    public function getEmail(): string
    {
        return $this->email;
    }

    public function getPhone(): ?string
    {
        return $this->phone;
    }

    public function getDepartment(): ?string
    {
        return $this->department;
    }

    public function getRole(): string
    {
        return $this->role;
    }

    public function getStatus(): string
    {
        return $this->status;
    }

    public function isAdmin(): bool
    {
        return $this->isAdmin;
    }

    public function isDeleted(): bool
    {
        return $this->isDeleted;
    }

    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }

    public function getUpdatedAt(): \DateTimeImmutable
    {
        return $this->updatedAt;
    }

    public function getDeletedAt(): ?\DateTimeImmutable
    {
        return $this->deletedAt;
    }

    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'firstName' => $this->firstName,
            'lastName' => $this->lastName,
            'middleName' => $this->middleName,
            'fullName' => $this->getFullName(),
            'email' => $this->email,
            'phone' => $this->phone,
            'department' => $this->department,
            'role' => $this->role,
            'status' => $this->status,
            'isAdmin' => $this->isAdmin,
            'isDeleted' => $this->isDeleted,
            'createdAt' => $this->createdAt->format('Y-m-d H:i:s'),
            'updatedAt' => $this->updatedAt->format('Y-m-d H:i:s'),
            'deletedAt' => $this->deletedAt?->format('Y-m-d H:i:s')
        ];
    }
} 