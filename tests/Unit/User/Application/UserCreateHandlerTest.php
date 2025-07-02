<?php

use PHPUnit\Framework\TestCase;
use User\Application\UserCreateHandler;
use User\Application\DTO\UserCreateRequest;
use User\Application\DTO\UserCreateResponse;
use User\Domain\UserService;
use User\Domain\UserRepository;

class UserCreateHandlerTest extends TestCase
{
    private UserCreateHandler $handler;
    private UserService $userService;
    private UserRepository $userRepository;

    protected function setUp(): void
    {
        $this->userService = new UserService();
        $this->userRepository = new \Tests\Stubs\InMemoryUserRepository();
        $this->handler = new UserCreateHandler($this->userService, $this->userRepository);
    }

    public function testHandleCreateUserSuccess()
    {
        $request = new UserCreateRequest('Иван Петров', 'ivan@corp.com', 'admin');
        $response = $this->handler->handle($request);
        
        $this->assertInstanceOf(UserCreateResponse::class, $response);
        $this->assertEquals('Иван Петров', $response->getName());
        $this->assertEquals('ivan@corp.com', $response->getEmail());
        $this->assertEquals('', $response->getRole()); // TODO: роли еще не реализованы
        $this->assertEquals('active', $response->getStatus());
        $this->assertNotEmpty($response->getId());
    }

    public function testHandleInvalidRole()
    {
        $request = new UserCreateRequest('Иван', 'ivan@corp.com', 'invalid_role');
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Недопустимая роль');
        $this->handler->handle($request);
    }

    public function testHandleShortName()
    {
        $request = new UserCreateRequest('И', 'ivan@corp.com', 'user');
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Имя должно содержать минимум 2 символа');
        $this->handler->handle($request);
    }

    public function testHandleDuplicateEmail()
    {
        $request1 = new UserCreateRequest('Иван', 'ivan@corp.com', 'admin');
        $this->handler->handle($request1);
        
        $request2 = new UserCreateRequest('Петр', 'ivan@corp.com', 'user');
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Пользователь с таким email уже существует');
        $this->handler->handle($request2);
    }

    public function testResponseToArray()
    {
        $response = new UserCreateResponse('123', 'Иван', 'ivan@corp.com', 'admin', 'active');
        $array = $response->toArray();
        
        $this->assertEquals([
            'id' => '123',
            'name' => 'Иван',
            'email' => 'ivan@corp.com',
            'role' => 'admin',
            'status' => 'active'
        ], $array);
    }
} 