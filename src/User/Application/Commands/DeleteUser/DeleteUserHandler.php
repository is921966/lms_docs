<?php

namespace User\Application\Commands\DeleteUser;

use User\Domain\UserRepository;
use User\Domain\ValueObjects\UserId;

class DeleteUserHandler
{
    private UserRepository $repository;

    public function __construct(UserRepository $repository)
    {
        $this->repository = $repository;
    }

    public function handle(DeleteUserCommand $command): void
    {
        // Найти пользователя
        $user = $this->repository->findById(UserId::fromString($command->getUserId()));
        
        if (!$user) {
            throw new \DomainException('User not found');
        }

        // Проверить, не удален ли уже
        if ($user->isDeleted()) {
            throw new \DomainException('User is already deleted');
        }

        // Выполнить soft delete
        $user->delete();

        // Сохранить изменения
        $this->repository->save($user);
    }
} 