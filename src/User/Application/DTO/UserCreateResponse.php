<?php

namespace User\Application\DTO;

class UserCreateResponse
{
    private string $id;
    private string $name;
    private string $email;
    private string $role;
    private string $status;

    public function __construct(string $id, string $name, string $email, string $role, string $status)
    {
        $this->id = $id;
        $this->name = $name;
        $this->email = $email;
        $this->role = $role;
        $this->status = $status;
    }

    public function getId(): string
    {
        return $this->id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getEmail(): string
    {
        return $this->email;
    }

    public function getRole(): string
    {
        return $this->role;
    }

    public function getStatus(): string
    {
        return $this->status;
    }

    public function toArray(): array
    {
        return [
            "id" => $this->id,
            "name" => $this->name,
            "email" => $this->email,
            "role" => $this->role,
            "status" => $this->status
        ];
    }
}
