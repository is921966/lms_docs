<?php

namespace Tests\Unit\Auth\Infrastructure\Repositories;

use PHPUnit\Framework\TestCase;
use Auth\Infrastructure\Repositories\InMemoryRoleRepository;
use Auth\Domain\Entities\Role;
use Auth\Domain\ValueObjects\RoleId;
use Auth\Domain\ValueObjects\Permission;

class InMemoryRoleRepositoryTest extends TestCase
{
    private InMemoryRoleRepository $repository;

    protected function setUp(): void
    {
        $this->repository = new InMemoryRoleRepository();
    }

    public function testSaveAndFindById()
    {
        // Arrange
        $role = Role::create('admin', 'Administrator');
        
        // Act
        $this->repository->save($role);
        $foundRole = $this->repository->findById($role->getId());

        // Assert
        $this->assertNotNull($foundRole);
        $this->assertTrue($role->equals($foundRole));
        $this->assertEquals('admin', $foundRole->getName());
    }

    public function testFindByName()
    {
        // Arrange
        $role = Role::create('editor', 'Editor role');
        $this->repository->save($role);

        // Act
        $foundRole = $this->repository->findByName('editor');

        // Assert
        $this->assertNotNull($foundRole);
        $this->assertEquals('editor', $foundRole->getName());
    }

    public function testFindByNameNotFound()
    {
        // Act
        $foundRole = $this->repository->findByName('non-existent');

        // Assert
        $this->assertNull($foundRole);
    }

    public function testFindAll()
    {
        // Arrange
        $role1 = Role::create('admin', 'Admin');
        $role2 = Role::create('editor', 'Editor');
        $role3 = Role::create('viewer', 'Viewer');

        $this->repository->save($role1);
        $this->repository->save($role2);
        $this->repository->save($role3);

        // Act
        $roles = $this->repository->findAll();

        // Assert
        $this->assertCount(3, $roles);
    }

    public function testDelete()
    {
        // Arrange
        $role = Role::create('temp', 'Temporary role');
        $this->repository->save($role);

        // Act
        $this->repository->delete($role->getId());
        $foundRole = $this->repository->findById($role->getId());

        // Assert
        $this->assertNull($foundRole);
    }

    public function testExistsByName()
    {
        // Arrange
        $role = Role::create('moderator', 'Moderator');
        $this->repository->save($role);

        // Act & Assert
        $this->assertTrue($this->repository->existsByName('moderator'));
        $this->assertFalse($this->repository->existsByName('non-existent'));
    }

    public function testAssignRoleToUser()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $role = Role::create('editor', 'Editor');
        $this->repository->save($role);

        // Act
        $this->repository->assignToUser($userId, $role->getId());
        $userRoles = $this->repository->findByUserId($userId);

        // Assert
        $this->assertCount(1, $userRoles);
        $this->assertEquals('editor', $userRoles[0]->getName());
    }

    public function testAssignMultipleRolesToUser()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $role1 = Role::create('editor', 'Editor');
        $role2 = Role::create('moderator', 'Moderator');
        $this->repository->save($role1);
        $this->repository->save($role2);

        // Act
        $this->repository->assignToUser($userId, $role1->getId());
        $this->repository->assignToUser($userId, $role2->getId());
        $userRoles = $this->repository->findByUserId($userId);

        // Assert
        $this->assertCount(2, $userRoles);
    }

    public function testRemoveRoleFromUser()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $role1 = Role::create('admin', 'Admin');
        $role2 = Role::create('editor', 'Editor');
        $this->repository->save($role1);
        $this->repository->save($role2);
        $this->repository->assignToUser($userId, $role1->getId());
        $this->repository->assignToUser($userId, $role2->getId());

        // Act
        $this->repository->removeFromUser($userId, $role1->getId());
        $userRoles = $this->repository->findByUserId($userId);

        // Assert
        $this->assertCount(1, $userRoles);
        $this->assertEquals('editor', $userRoles[0]->getName());
    }

    public function testGetUserPermissions()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        
        $role1 = Role::create('editor', 'Editor');
        $role1->addPermission(new Permission('posts.create'));
        $role1->addPermission(new Permission('posts.edit'));
        
        $role2 = Role::create('moderator', 'Moderator');
        $role2->addPermission(new Permission('posts.edit')); // Duplicate
        $role2->addPermission(new Permission('comments.moderate'));
        
        $this->repository->save($role1);
        $this->repository->save($role2);
        $this->repository->assignToUser($userId, $role1->getId());
        $this->repository->assignToUser($userId, $role2->getId());

        // Act
        $permissions = $this->repository->getUserPermissions($userId);

        // Assert
        $this->assertCount(3, $permissions); // No duplicates
        $this->assertContains('posts.create', $permissions);
        $this->assertContains('posts.edit', $permissions);
        $this->assertContains('comments.moderate', $permissions);
    }
} 