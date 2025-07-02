<?php

namespace User\Domain;

use User\Domain\ValueObjects\UserId;

interface UserRepository
{
    public function findByEmail(string $email): ?User;
    public function findById(UserId $id): ?User;
    public function findAll(): array;
    public function save(User $user): void;
    public function nextId(): int;
} 