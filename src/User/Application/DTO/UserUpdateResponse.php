<?php

namespace User\Application\DTO;

class UserUpdateResponse
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
    private \DateTimeImmutable $updatedAt;

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
        \DateTimeImmutable $updatedAt
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
        $this->updatedAt = $updatedAt;
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

    public function getUpdatedAt(): \DateTimeImmutable
    {
        return $this->updatedAt;
    }

    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'firstName' => $this->firstName,
            'lastName' => $this->lastName,
            'middleName' => $this->middleName,
            'email' => $this->email,
            'phone' => $this->phone,
            'department' => $this->department,
            'role' => $this->role,
            'status' => $this->status,
            'updatedAt' => $this->updatedAt->format('Y-m-d H:i:s')
        ];
    }
} 