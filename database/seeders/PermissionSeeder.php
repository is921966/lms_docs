<?php

namespace Database\Seeders;

use App\User\Domain\Permission;
use Doctrine\ORM\EntityManagerInterface;

class PermissionSeeder
{
    private EntityManagerInterface $entityManager;
    
    public function __construct(EntityManagerInterface $entityManager)
    {
        $this->entityManager = $entityManager;
    }
    
    public function run(): void
    {
        $permissions = [
            // User management
            ['users.view', 'View users', 'users'],
            ['users.create', 'Create users', 'users'],
            ['users.update', 'Update users', 'users'],
            ['users.delete', 'Delete users', 'users'],
            ['users.restore', 'Restore deleted users', 'users'],
            ['users.export', 'Export users', 'users'],
            ['users.import', 'Import users', 'users'],
            ['users.manage_roles', 'Manage user roles', 'users'],
            ['users.reset_password', 'Reset user passwords', 'users'],
            
            // Course management
            ['courses.view', 'View courses', 'courses'],
            ['courses.create', 'Create courses', 'courses'],
            ['courses.update', 'Update courses', 'courses'],
            ['courses.delete', 'Delete courses', 'courses'],
            ['courses.publish', 'Publish courses', 'courses'],
            ['courses.assign', 'Assign courses to users', 'courses'],
            
            // Competency management
            ['competencies.view', 'View competencies', 'competencies'],
            ['competencies.create', 'Create competencies', 'competencies'],
            ['competencies.update', 'Update competencies', 'competencies'],
            ['competencies.delete', 'Delete competencies', 'competencies'],
            ['competencies.assess', 'Assess competencies', 'competencies'],
            
            // Analytics
            ['analytics.view', 'View analytics', 'analytics'],
            ['analytics.export', 'Export analytics', 'analytics'],
            ['analytics.advanced', 'View advanced analytics', 'analytics'],
            
            // Settings
            ['settings.view', 'View settings', 'settings'],
            ['settings.update', 'Update settings', 'settings'],
            ['settings.ldap', 'Manage LDAP settings', 'settings'],
            
            // Content management
            ['content.view', 'View content', 'content'],
            ['content.create', 'Create content', 'content'],
            ['content.update', 'Update content', 'content'],
            ['content.delete', 'Delete content', 'content'],
            
            // System
            ['system.manage', 'System administration', 'system'],
            ['system.logs', 'View system logs', 'system'],
            ['system.backup', 'Manage backups', 'system'],
        ];
        
        foreach ($permissions as [$name, $description, $category]) {
            $existing = $this->entityManager->getRepository(Permission::class)
                ->findOneBy(['name' => $name]);
            
            if (!$existing) {
                $permission = new Permission($name, $description, $category);
                $this->entityManager->persist($permission);
            }
        }
        
        $this->entityManager->flush();
        
        $count = count($permissions);
        echo "Created/verified {$count} permissions\n";
    }
} 