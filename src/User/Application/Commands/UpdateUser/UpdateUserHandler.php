<?php

namespace User\Application\Commands\UpdateUser;

use User\Domain\UserRepository;
use User\Domain\ValueObjects\Email;
use User\Domain\ValueObjects\UserId;
use User\Application\DTO\UserUpdateResponse;

class UpdateUserHandler
{
    private UserRepository $repository;

    public function __construct(UserRepository $repository)
    {
        $this->repository = $repository;
    }

    public function handle(UpdateUserCommand $command): UserUpdateResponse
    {
        // Найти пользователя
        $user = $this->repository->findById(UserId::fromString($command->getUserId()));
        
        if (!$user) {
            throw new \DomainException('User not found');
        }

        // Обновить профиль если переданы данные
        if ($command->getFirstName() !== null || 
            $command->getLastName() !== null || 
            $command->getMiddleName() !== null ||
            $command->getPhone() !== null ||
            $command->getDepartment() !== null) {
            
            $user->updateProfile(
                $command->getFirstName() ?? $user->getFirstName(),
                $command->getLastName() ?? $user->getLastName(),
                $command->getMiddleName() ?? $user->getMiddleName(),
                $command->getPhone() ?? $user->getPhone(),
                $command->getDepartment() ?? $user->getDepartment()
            );
        }

        // Обновить email если передан
        if ($command->getEmail() !== null) {
            $user->changeEmail(new Email($command->getEmail()));
        }

        // TODO: Обновить роль когда будет реализована система ролей

        // Сохранить изменения
        $this->repository->save($user);

        // Вернуть ответ
        return new UserUpdateResponse(
            (string) $user->getId(),
            $user->getFirstName(),
            $user->getLastName(),
            $user->getMiddleName(),
            $user->getEmail(),
            $user->getPhone(),
            $user->getDepartment(),
            $user->getRole(),
            $user->getStatus(),
            $user->getUpdatedAt()
        );
    }
} 