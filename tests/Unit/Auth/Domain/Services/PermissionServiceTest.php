<?php

namespace Tests\Unit\Auth\Domain\Services;

use PHPUnit\Framework\TestCase;
use Auth\Domain\Services\PermissionService;
use Auth\Domain\Repositories\RoleRepositoryInterface;
use Auth\Domain\Entities\Role;
use Auth\Domain\ValueObjects\Permission;

class PermissionServiceTest extends TestCase
{
    private PermissionService $service;
    private $roleRepository;

    protected function setUp(): void
    {
        $this->roleRepository = $this->createMock(RoleRepositoryInterface::class);
        $this->service = new PermissionService($this->roleRepository);
    }

    public function testUserHasPermissionThroughRole()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $role = Role::create('editor', 'Editor role');
        $role->addPermission(new Permission('posts.create'));
        $role->addPermission(new Permission('posts.edit'));

        $this->roleRepository->expects($this->once())
            ->method('findByUserId')
            ->with($userId)
            ->willReturn([$role]);

        // Act
        $hasPermission = $this->service->userHasPermission($userId, 'posts.edit');

        // Assert
        $this->assertTrue($hasPermission);
    }

    public function testUserDoesNotHavePermission()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $role = Role::create('viewer', 'Viewer role');
        $role->addPermission(new Permission('posts.view'));

        $this->roleRepository->expects($this->once())
            ->method('findByUserId')
            ->with($userId)
            ->willReturn([$role]);

        // Act
        $hasPermission = $this->service->userHasPermission($userId, 'posts.delete');

        // Assert
        $this->assertFalse($hasPermission);
    }

    public function testUserHasPermissionThroughMultipleRoles()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        
        $role1 = Role::create('author', 'Author role');
        $role1->addPermission(new Permission('posts.create'));
        
        $role2 = Role::create('moderator', 'Moderator role');
        $role2->addPermission(new Permission('comments.moderate'));
        $role2->addPermission(new Permission('posts.publish'));

        $this->roleRepository->expects($this->once())
            ->method('findByUserId')
            ->with($userId)
            ->willReturn([$role1, $role2]);

        // Act
        $hasCreate = $this->service->userHasPermission($userId, 'posts.create');
        $hasModerate = $this->service->userHasPermission($userId, 'comments.moderate');
        $hasPublish = $this->service->userHasPermission($userId, 'posts.publish');

        // Assert
        $this->assertTrue($hasCreate);
        $this->assertTrue($hasModerate);
        $this->assertTrue($hasPublish);
    }

    public function testUserHasAnyPermission()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $role = Role::create('editor', 'Editor role');
        $role->addPermission(new Permission('posts.edit'));
        $role->addPermission(new Permission('posts.publish'));

        $this->roleRepository->expects($this->once())
            ->method('findByUserId')
            ->with($userId)
            ->willReturn([$role]);

        // Act
        $hasAny = $this->service->userHasAnyPermission($userId, [
            'posts.delete',
            'posts.edit',
            'users.manage'
        ]);

        // Assert
        $this->assertTrue($hasAny);
    }

    public function testUserHasAllPermissions()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $role = Role::create('admin', 'Admin role');
        $role->addPermission(new Permission('posts.create'));
        $role->addPermission(new Permission('posts.edit'));
        $role->addPermission(new Permission('posts.delete'));

        $this->roleRepository->expects($this->once())
            ->method('findByUserId')
            ->with($userId)
            ->willReturn([$role]);

        // Act
        $hasAll = $this->service->userHasAllPermissions($userId, [
            'posts.create',
            'posts.edit'
        ]);

        // Assert
        $this->assertTrue($hasAll);
    }

    public function testUserDoesNotHaveAllPermissions()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $role = Role::create('editor', 'Editor role');
        $role->addPermission(new Permission('posts.create'));
        $role->addPermission(new Permission('posts.edit'));

        $this->roleRepository->expects($this->once())
            ->method('findByUserId')
            ->with($userId)
            ->willReturn([$role]);

        // Act
        $hasAll = $this->service->userHasAllPermissions($userId, [
            'posts.create',
            'posts.edit',
            'posts.delete' // Missing this permission
        ]);

        // Assert
        $this->assertFalse($hasAll);
    }

    public function testGetUserPermissions()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        
        $role1 = Role::create('editor', 'Editor role');
        $role1->addPermission(new Permission('posts.create'));
        $role1->addPermission(new Permission('posts.edit'));
        
        $role2 = Role::create('moderator', 'Moderator role');
        $role2->addPermission(new Permission('posts.edit')); // Duplicate
        $role2->addPermission(new Permission('comments.moderate'));

        $this->roleRepository->expects($this->once())
            ->method('findByUserId')
            ->with($userId)
            ->willReturn([$role1, $role2]);

        // Act
        $permissions = $this->service->getUserPermissions($userId);

        // Assert
        $this->assertCount(3, $permissions); // No duplicates
        $this->assertContains('posts.create', $permissions);
        $this->assertContains('posts.edit', $permissions);
        $this->assertContains('comments.moderate', $permissions);
    }

    public function testUserWithNoRoles()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';

        $this->roleRepository->expects($this->once())
            ->method('findByUserId')
            ->with($userId)
            ->willReturn([]);

        // Act
        $hasPermission = $this->service->userHasPermission($userId, 'any.permission');
        $permissions = $this->service->getUserPermissions($userId);

        // Assert
        $this->assertFalse($hasPermission);
        $this->assertEmpty($permissions);
    }
} 