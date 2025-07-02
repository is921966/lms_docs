<?php

namespace User\Application\Queries\GetUser;

use User\Domain\UserRepository;
use User\Domain\ValueObjects\UserId;
use User\Application\DTO\UserDetailResponse;

class GetUserHandler
{
    private UserRepository $repository;

    public function __construct(UserRepository $repository)
    {
        $this->repository = $repository;
    }

    public function handle(GetUserQuery $query): UserDetailResponse
    {
        // Найти пользователя
        $user = $this->repository->findById(UserId::fromString($query->getUserId()));
        
        if (!$user) {
            throw new \DomainException('User not found');
        }

        // Вернуть детальную информацию
        return new UserDetailResponse(
            (string) $user->getId(),
            $user->getFirstName(),
            $user->getLastName(),
            $user->getMiddleName(),
            $user->getEmail(),
            $user->getPhone(),
            $user->getDepartment(),
            $user->getRole(),
            $user->getStatus(),
            $user->isAdmin(),
            $user->isDeleted(),
            $user->getCreatedAt(),
            $user->getUpdatedAt(),
            $user->getDeletedAt()
        );
    }
} 