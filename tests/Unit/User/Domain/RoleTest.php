<?php

namespace Tests\Unit\User\Domain;

use Tests\TestCase;
use App\User\Domain\Role;
use App\User\Domain\Permission;

class RoleTest extends TestCase
{
    /**
     * @test
     */
    public function it_creates_role_with_valid_data(): void
    {
        $role = Role::create('manager', 'Manager Role', 'Can manage users');
        
        $this->assertInstanceOf(Role::class, $role);
        $this->assertEquals('manager', $role->getName());
        $this->assertEquals('Manager Role', $role->getDisplayName());
        $this->assertFalse($role->isSystem());
        $this->assertEquals(100, $role->getPriority());
    }
    
    /**
     * @test
     */
    public function it_validates_role_name(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Role name must be between 3 and 50 characters');
        
        Role::create('a', 'Too short name');
    }
    
    /**
     * @test
     */
    public function it_validates_role_name_format(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Role name must contain only lowercase letters, numbers and underscores');
        
        Role::create('Invalid-Role-Name', 'Invalid format');
    }
    
    /**
     * @test
     */
    public function it_recognizes_system_roles(): void
    {
        $systemRoles = [Role::ROLE_ADMIN, Role::ROLE_MANAGER, Role::ROLE_EMPLOYEE, Role::ROLE_INSTRUCTOR, Role::ROLE_HR];
        
        foreach ($systemRoles as $roleName) {
            $role = Role::createSystem($roleName, 'System role');
            $this->assertTrue($role->isSystem(), "Role {$roleName} should be system role");
        }
        
        $customRole = Role::create('custom_role', 'Custom role');
        $this->assertFalse($customRole->isSystem());
    }
    
    /**
     * @test
     */
    public function it_prevents_system_role_update(): void
    {
        $systemRole = Role::createSystem('admin', 'Administrator');
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot update system role');
        
        $systemRole->update('New Admin', 'New description');
    }
    
    /**
     * @test
     */
    public function it_manages_permissions(): void
    {
        $role = Role::create('editor', 'Editor');
        $permission1 = Permission::create('posts.create', 'Create posts', Permission::CATEGORY_COURSE);
        $permission2 = Permission::create('posts.edit', 'Edit posts', Permission::CATEGORY_COURSE);
        $permission3 = Permission::create('posts.delete', 'Delete posts', Permission::CATEGORY_COURSE);
        
        // Add permissions
        $role->assignPermission($permission1);
        $role->assignPermission($permission2);
        
        $this->assertTrue($role->hasPermission('posts.create'));
        $this->assertTrue($role->hasPermission('posts.edit'));
        $this->assertFalse($role->hasPermission('posts.delete'));
        $this->assertCount(2, $role->getPermissions());
        
        // Remove permission
        $role->removePermission($permission1);
        
        $this->assertFalse($role->hasPermission('posts.create'));
        $this->assertTrue($role->hasPermission('posts.edit'));
        $this->assertCount(1, $role->getPermissions());
        
        // Sync permissions
        $role->syncPermissions([$permission3]);
        
        $this->assertFalse($role->hasPermission('posts.edit'));
        $this->assertTrue($role->hasPermission('posts.delete'));
        $this->assertCount(1, $role->getPermissions());
    }
    
    /**
     * @test
     */
    public function it_prevents_duplicate_permissions(): void
    {
        $role = Role::create('editor', 'Editor');
        $permission = Permission::create('posts.create', 'Create posts', Permission::CATEGORY_COURSE);
        
        $role->assignPermission($permission);
        $role->assignPermission($permission); // Should not add duplicate
        
        $this->assertCount(1, $role->getPermissions());
    }
    
    /**
     * @test
     */
    public function it_updates_role_details(): void
    {
        $role = Role::create('manager', 'Manager', 'Basic description');
        
        $role->update('Updated Manager', 'Detailed description');
        
        $this->assertEquals('Updated Manager', $role->getDisplayName());
        $this->assertEquals('Detailed description', $role->getDescription());
    }
    
    /**
     * @test
     */
    public function it_checks_if_role_can_be_deleted(): void
    {
        $systemRole = Role::createSystem('admin', 'Admin');
        $customRole = Role::create('custom', 'Custom');
        
        $this->assertFalse($systemRole->canBeDeleted());
        $this->assertTrue($customRole->canBeDeleted());
    }
} 