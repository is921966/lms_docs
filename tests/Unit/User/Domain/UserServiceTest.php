<?php

use PHPUnit\Framework\TestCase;
use User\Domain\UserService;
use User\Domain\UserRepository;
use User\Domain\User;

class UserServiceTest extends TestCase
{
    private UserService $service;
    private UserRepository $repo;

    protected function setUp(): void
    {
        $this->service = new UserService();
        $this->repo = new \Tests\Stubs\InMemoryUserRepository();
    }

    public function testCreateUserSuccess()
    {
        $user = $this->service->createUser($this->repo, 'Иван Петров', 'ivan@corp.com', 'admin');
        $this->assertInstanceOf(User::class, $user);
        $this->assertEquals('Иван', $user->getFirstName());
        $this->assertEquals('Петров', $user->getLastName());
        $this->assertEquals('ivan@corp.com', $user->getEmail());
        $this->assertEquals('active', $user->getStatus());
    }

    public function testCreateUserDuplicateEmail()
    {
        $this->service->createUser($this->repo, 'Иван', 'ivan@corp.com', 'admin');
        $this->expectException(\DomainException::class);
        $this->service->createUser($this->repo, 'Петр', 'ivan@corp.com', 'user');
    }

    public function testCreateUserInvalidEmail()
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->service->createUser($this->repo, 'Иван', 'not-an-email', 'admin');
    }

    public function testCreateUserMissingFields()
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->service->createUser($this->repo, '', 'ivan@corp.com', 'admin');
    }
} 