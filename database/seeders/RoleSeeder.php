<?php

namespace Database\Seeders;

use App\User\Domain\Role;
use App\User\Domain\Permission;
use Doctrine\ORM\EntityManagerInterface;

class RoleSeeder
{
    private EntityManagerInterface $entityManager;
    
    public function __construct(EntityManagerInterface $entityManager)
    {
        $this->entityManager = $entityManager;
    }
    
    public function run(): void
    {
        $roles = [
            [
                'name' => 'admin',
                'description' => 'System Administrator',
                'permissions' => '*', // All permissions
            ],
            [
                'name' => 'manager',
                'description' => 'Manager',
                'permissions' => [
                    'users.view',
                    'users.update',
                    'users.export',
                    'courses.*',
                    'competencies.*',
                    'analytics.*',
                    'content.*',
                ],
            ],
            [
                'name' => 'employee',
                'description' => 'Employee',
                'permissions' => [
                    'courses.view',
                    'competencies.view',
                    'content.view',
                ],
            ],
            [
                'name' => 'instructor',
                'description' => 'Instructor',
                'permissions' => [
                    'courses.view',
                    'courses.create',
                    'courses.update',
                    'courses.publish',
                    'courses.assign',
                    'content.*',
                    'analytics.view',
                ],
            ],
            [
                'name' => 'hr',
                'description' => 'Human Resources',
                'permissions' => [
                    'users.*',
                    'competencies.*',
                    'analytics.*',
                ],
            ],
        ];
        
        $permissionRepo = $this->entityManager->getRepository(Permission::class);
        
        foreach ($roles as $roleData) {
            $existing = $this->entityManager->getRepository(Role::class)
                ->findOneBy(['name' => $roleData['name']]);
            
            if (!$existing) {
                $role = new Role($roleData['name'], $roleData['description']);
                
                // Add permissions
                if ($roleData['permissions'] === '*') {
                    // Add all permissions
                    $allPermissions = $permissionRepo->findAll();
                    foreach ($allPermissions as $permission) {
                        $role->addPermission($permission);
                    }
                } else {
                    foreach ($roleData['permissions'] as $permissionName) {
                        if (str_ends_with($permissionName, '.*')) {
                            // Wildcard - add all permissions in category
                            $category = str_replace('.*', '', $permissionName);
                            $categoryPermissions = $permissionRepo->findBy(['category' => $category]);
                            foreach ($categoryPermissions as $permission) {
                                $role->addPermission($permission);
                            }
                        } else {
                            // Specific permission
                            $permission = $permissionRepo->findOneBy(['name' => $permissionName]);
                            if ($permission) {
                                $role->addPermission($permission);
                            }
                        }
                    }
                }
                
                $this->entityManager->persist($role);
            }
        }
        
        $this->entityManager->flush();
        
        echo "Created/verified 5 system roles\n";
    }
} 