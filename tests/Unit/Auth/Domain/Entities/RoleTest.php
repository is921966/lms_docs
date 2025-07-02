<?php

namespace Tests\Unit\Auth\Domain\Entities;

use PHPUnit\Framework\TestCase;
use Auth\Domain\Entities\Role;
use Auth\Domain\ValueObjects\RoleId;
use Auth\Domain\ValueObjects\Permission;

class RoleTest extends TestCase
{
    public function testCreateRole()
    {
        // Arrange & Act
        $role = Role::create('admin', 'Administrator role');

        // Assert
        $this->assertInstanceOf(Role::class, $role);
        $this->assertInstanceOf(RoleId::class, $role->getId());
        $this->assertEquals('admin', $role->getName());
        $this->assertEquals('Administrator role', $role->getDescription());
        $this->assertEmpty($role->getPermissions());
    }

    public function testAddPermission()
    {
        // Arrange
        $role = Role::create('editor', 'Editor role');
        $permission = new Permission('posts.create', 'Create posts');

        // Act
        $role->addPermission($permission);

        // Assert
        $permissions = $role->getPermissions();
        $this->assertCount(1, $permissions);
        $this->assertTrue($role->hasPermission('posts.create'));
    }

    public function testAddMultiplePermissions()
    {
        // Arrange
        $role = Role::create('moderator', 'Moderator role');
        $permission1 = new Permission('posts.edit', 'Edit posts');
        $permission2 = new Permission('posts.delete', 'Delete posts');
        $permission3 = new Permission('comments.moderate', 'Moderate comments');

        // Act
        $role->addPermission($permission1);
        $role->addPermission($permission2);
        $role->addPermission($permission3);

        // Assert
        $this->assertCount(3, $role->getPermissions());
        $this->assertTrue($role->hasPermission('posts.edit'));
        $this->assertTrue($role->hasPermission('posts.delete'));
        $this->assertTrue($role->hasPermission('comments.moderate'));
    }

    public function testRemovePermission()
    {
        // Arrange
        $role = Role::create('admin', 'Admin role');
        $permission1 = new Permission('users.create', 'Create users');
        $permission2 = new Permission('users.delete', 'Delete users');
        $role->addPermission($permission1);
        $role->addPermission($permission2);

        // Act
        $role->removePermission('users.create');

        // Assert
        $this->assertCount(1, $role->getPermissions());
        $this->assertFalse($role->hasPermission('users.create'));
        $this->assertTrue($role->hasPermission('users.delete'));
    }

    public function testHasPermissionReturnsFalseForNonExistent()
    {
        // Arrange
        $role = Role::create('user', 'Regular user');

        // Act & Assert
        $this->assertFalse($role->hasPermission('admin.access'));
    }

    public function testPreventDuplicatePermissions()
    {
        // Arrange
        $role = Role::create('admin', 'Admin role');
        $permission = new Permission('settings.manage', 'Manage settings');

        // Act
        $role->addPermission($permission);
        $role->addPermission($permission); // Try to add same permission again

        // Assert
        $this->assertCount(1, $role->getPermissions());
    }

    public function testRoleEquality()
    {
        // Arrange
        $role1 = Role::create('admin', 'Admin role');
        $role2 = Role::createWithId(
            $role1->getId(),
            'admin',
            'Admin role'
        );

        // Act & Assert
        $this->assertTrue($role1->equals($role2));
    }

    public function testUpdateRoleDescription()
    {
        // Arrange
        $role = Role::create('manager', 'Manager role');

        // Act
        $role->updateDescription('Senior Manager role');

        // Assert
        $this->assertEquals('Senior Manager role', $role->getDescription());
    }

    public function testClearAllPermissions()
    {
        // Arrange
        $role = Role::create('admin', 'Admin role');
        $role->addPermission(new Permission('users.manage', 'Manage users'));
        $role->addPermission(new Permission('posts.manage', 'Manage posts'));
        $role->addPermission(new Permission('settings.manage', 'Manage settings'));

        // Act
        $role->clearPermissions();

        // Assert
        $this->assertEmpty($role->getPermissions());
    }

    public function testGetPermissionNames()
    {
        // Arrange
        $role = Role::create('editor', 'Editor role');
        $role->addPermission(new Permission('posts.create', 'Create posts'));
        $role->addPermission(new Permission('posts.edit', 'Edit posts'));
        $role->addPermission(new Permission('posts.publish', 'Publish posts'));

        // Act
        $permissionNames = $role->getPermissionNames();

        // Assert
        $this->assertEquals(['posts.create', 'posts.edit', 'posts.publish'], $permissionNames);
    }
} 