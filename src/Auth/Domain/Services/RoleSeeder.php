<?php

namespace Auth\Domain\Services;

use Auth\Domain\Entities\Role;
use Auth\Domain\ValueObjects\Permission;
use Auth\Domain\Repositories\RoleRepositoryInterface;

class RoleSeeder
{
    private RoleRepositoryInterface $roleRepository;

    public function __construct(RoleRepositoryInterface $roleRepository)
    {
        $this->roleRepository = $roleRepository;
    }

    public function seed(): void
    {
        $this->createAdminRole();
        $this->createModeratorRole();
        $this->createEditorRole();
        $this->createLearnerRole();
    }

    private function createAdminRole(): void
    {
        if ($this->roleRepository->existsByName('admin')) {
            return;
        }

        $role = Role::create('admin', 'System Administrator');
        
        // User management
        $role->addPermission(new Permission('users.create', 'Create users'));
        $role->addPermission(new Permission('users.read', 'View users'));
        $role->addPermission(new Permission('users.update', 'Update users'));
        $role->addPermission(new Permission('users.delete', 'Delete users'));
        
        // Role management
        $role->addPermission(new Permission('roles.manage', 'Manage roles and permissions'));
        
        // Content management
        $role->addPermission(new Permission('competencies.manage', 'Manage competencies'));
        $role->addPermission(new Permission('courses.manage', 'Manage courses'));
        $role->addPermission(new Permission('programs.manage', 'Manage learning programs'));
        
        // System
        $role->addPermission(new Permission('system.settings', 'Manage system settings'));
        $role->addPermission(new Permission('analytics.view', 'View analytics'));
        
        $this->roleRepository->save($role);
    }

    private function createModeratorRole(): void
    {
        if ($this->roleRepository->existsByName('moderator')) {
            return;
        }

        $role = Role::create('moderator', 'Content Moderator');
        
        // User management (limited)
        $role->addPermission(new Permission('users.read', 'View users'));
        $role->addPermission(new Permission('users.update', 'Update users'));
        
        // Content management
        $role->addPermission(new Permission('competencies.manage', 'Manage competencies'));
        $role->addPermission(new Permission('courses.manage', 'Manage courses'));
        $role->addPermission(new Permission('programs.manage', 'Manage learning programs'));
        
        // Analytics
        $role->addPermission(new Permission('analytics.view', 'View analytics'));
        
        $this->roleRepository->save($role);
    }

    private function createEditorRole(): void
    {
        if ($this->roleRepository->existsByName('editor')) {
            return;
        }

        $role = Role::create('editor', 'Content Editor');
        
        // Content creation
        $role->addPermission(new Permission('courses.create', 'Create courses'));
        $role->addPermission(new Permission('courses.update', 'Update courses'));
        $role->addPermission(new Permission('courses.read', 'View courses'));
        
        // Limited analytics
        $role->addPermission(new Permission('analytics.own', 'View own content analytics'));
        
        $this->roleRepository->save($role);
    }

    private function createLearnerRole(): void
    {
        if ($this->roleRepository->existsByName('learner')) {
            return;
        }

        $role = Role::create('learner', 'Regular Learner');
        
        // Learning permissions
        $role->addPermission(new Permission('courses.read', 'View courses'));
        $role->addPermission(new Permission('courses.enroll', 'Enroll in courses'));
        $role->addPermission(new Permission('courses.progress', 'Track course progress'));
        
        // Profile
        $role->addPermission(new Permission('profile.read', 'View own profile'));
        $role->addPermission(new Permission('profile.update', 'Update own profile'));
        
        $this->roleRepository->save($role);
    }

    public function assignDefaultRoleToUser(string $userId): void
    {
        $learnerRole = $this->roleRepository->findByName('learner');
        if ($learnerRole) {
            $this->roleRepository->assignToUser($userId, $learnerRole->getId());
        }
    }
} 