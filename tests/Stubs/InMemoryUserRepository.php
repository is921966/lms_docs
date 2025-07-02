<?php

namespace Tests\Stubs;

use User\Domain\User;
use User\Domain\UserRepository;
use User\Domain\ValueObjects\UserId;

class InMemoryUserRepository implements UserRepository
{
    private array $users = [];
    private int $nextId = 1;

    public function findByEmail(string $email): ?User
    {
        foreach ($this->users as $user) {
            if ($user->getEmail() === $email) {
                return $user;
            }
        }
        return null;
    }

    public function findById(UserId $id): ?User
    {
        $key = (string) $id;
        return $this->users[$key] ?? null;
    }

    public function findAll(): array
    {
        return array_values($this->users);
    }

    public function save(User $user): void
    {
        $this->users[(string)$user->getId()] = $user;
    }

    public function nextId(): int
    {
        return $this->nextId++;
    }
} 