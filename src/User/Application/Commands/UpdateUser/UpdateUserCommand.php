<?php

namespace User\Application\Commands\UpdateUser;

class UpdateUserCommand
{
    private string $userId;
    private ?string $firstName;
    private ?string $lastName;
    private ?string $middleName;
    private ?string $phone;
    private ?string $department;
    private ?string $email;
    private ?string $role;

    public function __construct(
        string $userId,
        ?string $firstName = null,
        ?string $lastName = null,
        ?string $middleName = null,
        ?string $phone = null,
        ?string $department = null,
        ?string $email = null,
        ?string $role = null
    ) {
        $this->userId = $userId;
        $this->firstName = $firstName;
        $this->lastName = $lastName;
        $this->middleName = $middleName;
        $this->phone = $phone;
        $this->department = $department;
        $this->email = $email;
        $this->role = $role;
    }

    public function getUserId(): string
    {
        return $this->userId;
    }

    public function getFirstName(): ?string
    {
        return $this->firstName;
    }

    public function getLastName(): ?string
    {
        return $this->lastName;
    }

    public function getMiddleName(): ?string
    {
        return $this->middleName;
    }

    public function getPhone(): ?string
    {
        return $this->phone;
    }

    public function getDepartment(): ?string
    {
        return $this->department;
    }

    public function getEmail(): ?string
    {
        return $this->email;
    }

    public function getRole(): ?string
    {
        return $this->role;
    }
} 