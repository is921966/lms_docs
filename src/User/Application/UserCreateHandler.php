<?php

namespace User\Application;

use User\Domain\UserService;
use User\Domain\UserRepository;
use User\Application\DTO\UserCreateRequest;
use User\Application\DTO\UserCreateResponse;

class UserCreateHandler
{
    private UserService $userService;
    private UserRepository $userRepository;

    public function __construct(UserService $userService, UserRepository $userRepository)
    {
        $this->userService = $userService;
        $this->userRepository = $userRepository;
    }

    public function handle(UserCreateRequest $request): UserCreateResponse
    {
        // Валидация на уровне приложения
        $this->validate($request);
        
        // Создание пользователя через Domain Service
        $user = $this->userService->createUser(
            $this->userRepository,
            $request->getName(),
            $request->getEmail(),
            $request->getRole()
        );
        
        // Возврат DTO ответа
        return new UserCreateResponse(
            (string) $user->getId(),
            $user->getFirstName() . ' ' . $user->getLastName(),
            $user->getEmail(),
            $user->getRole(),
            $user->getStatus()
        );
    }
    
    private function validate(UserCreateRequest $request): void
    {
        // Дополнительная валидация на уровне приложения
        if (mb_strlen($request->getName()) < 2) {
            throw new \InvalidArgumentException('Имя должно содержать минимум 2 символа');
        }
        
        if (!in_array($request->getRole(), ['admin', 'user', 'moderator'])) {
            throw new \InvalidArgumentException('Недопустимая роль');
        }
    }
}
