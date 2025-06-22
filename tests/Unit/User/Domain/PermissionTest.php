<?php

namespace Tests\Unit\User\Domain;

use Tests\TestCase;
use App\User\Domain\Permission;

class PermissionTest extends TestCase
{
    /**
     * @test
     */
    public function it_creates_permission_with_valid_data(): void
    {
        $permission = Permission::create(
            'user.create',
            'Create users',
            Permission::CATEGORY_USER,
            'Allows creating new user accounts'
        );
        
        $this->assertInstanceOf(Permission::class, $permission);
        $this->assertEquals('user.create', $permission->getName());
        $this->assertEquals('Create users', $permission->getDisplayName());
        $this->assertEquals(Permission::CATEGORY_USER, $permission->getCategory());
        $this->assertEquals('Allows creating new user accounts', $permission->getDescription());
    }
    
    /**
     * @test
     */
    public function it_validates_permission_name_format(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Permission name must be in format: resource.action');
        
        Permission::create('invalid_format', 'Invalid permission', Permission::CATEGORY_USER);
    }
    
    /**
     * @test
     */
    public function it_validates_category(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid permission category');
        
        Permission::create('test.action', 'Test', 'invalid_category');
    }
    
    /**
     * @test
     */
    public function it_recognizes_valid_categories(): void
    {
        $categories = [
            Permission::CATEGORY_USER,
            Permission::CATEGORY_COMPETENCY,
            Permission::CATEGORY_POSITION,
            Permission::CATEGORY_COURSE,
            Permission::CATEGORY_PROGRAM,
            Permission::CATEGORY_ANALYTICS,
            Permission::CATEGORY_SYSTEM
        ];
        
        foreach ($categories as $category) {
            $permission = Permission::create("test.view", 'Test', $category);
            $this->assertEquals($category, $permission->getCategory());
        }
    }
    
    /**
     * @test
     */
    public function it_checks_permission_matching(): void
    {
        $permission = Permission::create('user.create', 'Create users', Permission::CATEGORY_USER);
        
        // Exact match
        $this->assertTrue($permission->matches('user.create'));
        $this->assertFalse($permission->matches('user.edit'));
        
        // Wildcard match
        $this->assertTrue($permission->matches('user.*'));
        $this->assertFalse($permission->matches('course.*'));
    }
    
    /**
     * @test
     */
    public function it_extracts_resource_and_action(): void
    {
        $permission = Permission::create('user.create', 'Create users', Permission::CATEGORY_USER);
        
        $this->assertEquals('user', $permission->getResource());
        $this->assertEquals('create', $permission->getAction());
    }
    
    /**
     * @test
     */
    public function it_checks_category_membership(): void
    {
        $permission = Permission::create('user.create', 'Create users', Permission::CATEGORY_USER);
        
        $this->assertTrue($permission->isInCategory(Permission::CATEGORY_USER));
        $this->assertFalse($permission->isInCategory(Permission::CATEGORY_COURSE));
    }
    
    /**
     * @test
     */
    public function it_gets_default_permissions(): void
    {
        $defaults = Permission::getDefaultPermissions();
        
        $this->assertNotEmpty($defaults);
        $this->assertIsArray($defaults);
        
        // Check structure
        $first = $defaults[0];
        $this->assertArrayHasKey('name', $first);
        $this->assertArrayHasKey('displayName', $first);
        $this->assertArrayHasKey('category', $first);
        
        // Check some expected permissions
        $names = array_column($defaults, 'name');
        $this->assertContains(Permission::USER_VIEW, $names);
        $this->assertContains(Permission::COURSE_CREATE, $names);
        $this->assertContains(Permission::ANALYTICS_VIEW, $names);
    }
} 