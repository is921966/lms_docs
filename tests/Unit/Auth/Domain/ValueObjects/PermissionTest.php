<?php

namespace Tests\Unit\Auth\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use Auth\Domain\ValueObjects\Permission;

class PermissionTest extends TestCase
{
    public function testCreateValidPermission()
    {
        // Arrange & Act
        $permission = new Permission('users.create', 'Create new users');

        // Assert
        $this->assertEquals('users.create', $permission->getName());
        $this->assertEquals('Create new users', $permission->getDescription());
        $this->assertEquals('users', $permission->getResource());
        $this->assertEquals('create', $permission->getAction());
    }

    public function testCreatePermissionWithoutDescription()
    {
        // Arrange & Act
        $permission = new Permission('posts.edit');

        // Assert
        $this->assertEquals('posts.edit', $permission->getName());
        $this->assertEquals('', $permission->getDescription());
    }

    public function testCreateNestedPermission()
    {
        // Arrange & Act
        $permission = new Permission('admin.users.delete', 'Delete users in admin panel');

        // Assert
        $this->assertEquals('admin.users.delete', $permission->getName());
        $this->assertEquals('admin', $permission->getResource());
        $this->assertEquals('delete', $permission->getAction());
    }

    public function testInvalidPermissionNameEmpty()
    {
        // Act & Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Permission name cannot be empty');
        new Permission('');
    }

    public function testInvalidPermissionNameFormat()
    {
        // Act & Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Permission name must be in format: resource.action');
        new Permission('Users.Create'); // Capital letters not allowed
    }

    public function testInvalidPermissionNameWithSpaces()
    {
        // Act & Assert
        $this->expectException(\InvalidArgumentException::class);
        new Permission('users create');
    }

    public function testInvalidPermissionNameWithSpecialChars()
    {
        // Act & Assert
        $this->expectException(\InvalidArgumentException::class);
        new Permission('users@create');
    }

    public function testPermissionEquality()
    {
        // Arrange
        $permission1 = new Permission('posts.publish', 'Publish posts');
        $permission2 = new Permission('posts.publish', 'Different description');
        $permission3 = new Permission('posts.edit', 'Edit posts');

        // Act & Assert
        $this->assertTrue($permission1->equals($permission2));
        $this->assertFalse($permission1->equals($permission3));
    }

    public function testPermissionToString()
    {
        // Arrange
        $permission = new Permission('comments.moderate', 'Moderate comments');

        // Act & Assert
        $this->assertEquals('comments.moderate', (string)$permission);
    }

    public function testSingleWordPermission()
    {
        // Arrange & Act
        $permission = new Permission('dashboard', 'Access dashboard');

        // Assert
        $this->assertEquals('dashboard', $permission->getName());
        $this->assertEquals('dashboard', $permission->getResource());
        $this->assertEquals('dashboard', $permission->getAction());
    }
} 