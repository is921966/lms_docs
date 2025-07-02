<?php

namespace User\Http\Controllers;

use User\Application\Commands\CreateUser\CreateUserCommand;
use User\Application\Commands\CreateUser\CreateUserHandler;
use User\Application\Commands\UpdateUser\UpdateUserCommand;
use User\Application\Commands\UpdateUser\UpdateUserHandler;
use User\Application\Commands\DeleteUser\DeleteUserCommand;
use User\Application\Commands\DeleteUser\DeleteUserHandler;
use User\Application\Queries\GetUser\GetUserQuery;
use User\Application\Queries\GetUser\GetUserHandler;
use User\Application\Queries\ListUsers\ListUsersQuery;
use User\Application\Queries\ListUsers\ListUsersHandler;
use User\Application\DTO\UserCreateRequest;
use User\Http\Requests\CreateUserRequest;
use User\Http\Requests\UpdateUserRequest;
use User\Http\Resources\UserResource;
use User\Http\Resources\UserCollection;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;

class UserController
{
    private CreateUserHandler $createUserHandler;
    private UpdateUserHandler $updateUserHandler;
    private DeleteUserHandler $deleteUserHandler;
    private GetUserHandler $getUserHandler;
    private ListUsersHandler $listUsersHandler;

    public function __construct(
        CreateUserHandler $createUserHandler,
        UpdateUserHandler $updateUserHandler,
        DeleteUserHandler $deleteUserHandler,
        GetUserHandler $getUserHandler,
        ListUsersHandler $listUsersHandler
    ) {
        $this->createUserHandler = $createUserHandler;
        $this->updateUserHandler = $updateUserHandler;
        $this->deleteUserHandler = $deleteUserHandler;
        $this->getUserHandler = $getUserHandler;
        $this->listUsersHandler = $listUsersHandler;
    }

    /**
     * Create a new user
     */
    public function store(Request $request): JsonResponse
    {
        // Валидация
        $validatedData = $this->validateCreateRequest($request);
        
        try {
            // Создать команду
            $command = new UserCreateRequest(
                $validatedData['name'],
                $validatedData['email'],
                $validatedData['role']
            );
            
            // Выполнить команду
            $response = $this->createUserHandler->handle($command);
            
            // Вернуть ответ
            return new JsonResponse([
                'data' => $response->toArray()
            ], Response::HTTP_CREATED);
            
        } catch (\InvalidArgumentException $e) {
            return new JsonResponse([
                'message' => $e->getMessage()
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        } catch (\DomainException $e) {
            return new JsonResponse([
                'message' => $e->getMessage()
            ], Response::HTTP_CONFLICT);
        }
    }

    /**
     * Get user by ID
     */
    public function show(string $id): JsonResponse
    {
        try {
            $query = new GetUserQuery($id);
            $response = $this->getUserHandler->handle($query);
            
            return new JsonResponse([
                'data' => $response->toArray()
            ]);
            
        } catch (\DomainException $e) {
            return new JsonResponse([
                'message' => 'User not found'
            ], Response::HTTP_NOT_FOUND);
        }
    }

    /**
     * Update user
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        try {
            $command = new UpdateUserCommand(
                $id,
                $data['firstName'] ?? null,
                $data['lastName'] ?? null,
                $data['middleName'] ?? null,
                $data['phone'] ?? null,
                $data['department'] ?? null,
                $data['email'] ?? null,
                $data['role'] ?? null
            );
            
            $response = $this->updateUserHandler->handle($command);
            
            return new JsonResponse([
                'data' => $response->toArray()
            ]);
            
        } catch (\DomainException $e) {
            return new JsonResponse([
                'message' => $e->getMessage()
            ], Response::HTTP_NOT_FOUND);
        } catch (\InvalidArgumentException $e) {
            return new JsonResponse([
                'message' => $e->getMessage()
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }
    }

    /**
     * Delete user
     */
    public function destroy(string $id): JsonResponse
    {
        try {
            $command = new DeleteUserCommand($id);
            $this->deleteUserHandler->handle($command);
            
            return new JsonResponse(null, Response::HTTP_NO_CONTENT);
            
        } catch (\DomainException $e) {
            return new JsonResponse([
                'message' => $e->getMessage()
            ], Response::HTTP_NOT_FOUND);
        }
    }

    /**
     * List users with pagination and filters
     */
    public function index(Request $request): JsonResponse
    {
        $query = new ListUsersQuery(
            (int) $request->query->get('page', 1),
            (int) $request->query->get('perPage', 10),
            $request->query->get('search'),
            $request->query->all('filters') ?: [],
            $request->query->get('sortBy'),
            $request->query->get('sortOrder', 'asc')
        );
        
        $response = $this->listUsersHandler->handle($query);
        
        return new JsonResponse($response->toArray());
    }

    /**
     * Validate create user request
     */
    private function validateCreateRequest(Request $request): array
    {
        $data = json_decode($request->getContent(), true);
        
        $errors = [];
        
        if (empty($data['name']) || strlen($data['name']) < 2) {
            $errors['name'] = ['The name must be at least 2 characters.'];
        }
        
        if (empty($data['email']) || !filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            $errors['email'] = ['The email must be a valid email address.'];
        }
        
        if (empty($data['role']) || !in_array($data['role'], ['admin', 'user', 'moderator'])) {
            $errors['role'] = ['The selected role is invalid.'];
        }
        
        if (!empty($errors)) {
            throw new \InvalidArgumentException(json_encode(['errors' => $errors]));
        }
        
        return $data;
    }
} 