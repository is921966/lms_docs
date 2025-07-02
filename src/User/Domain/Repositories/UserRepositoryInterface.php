<?php

namespace User\Domain\Repositories;

use User\Domain\User;
use User\Domain\ValueObjects\UserId;

interface UserRepositoryInterface
{
    public function save(User $user): void;
    public function findById(UserId $id): ?User;
    public function findByEmail(string $email): ?User;
    public function exists(UserId $id): bool;
    public function delete(UserId $id): void;
    public function list(int $page, int $perPage): array;
    public function count(): int;
} 