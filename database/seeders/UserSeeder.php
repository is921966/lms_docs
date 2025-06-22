<?php

namespace Database\Seeders;

use App\User\Domain\User;
use App\User\Domain\Role;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\Password;
use App\User\Domain\ValueObjects\UserId;
use Doctrine\ORM\EntityManagerInterface;

class UserSeeder
{
    private EntityManagerInterface $entityManager;
    
    public function __construct(EntityManagerInterface $entityManager)
    {
        $this->entityManager = $entityManager;
    }
    
    public function run(): void
    {
        $users = [
            [
                'email' => 'admin@lms.com',
                'firstName' => 'Admin',
                'lastName' => 'User',
                'password' => 'Admin123!',
                'role' => 'admin',
                'department' => 'IT',
                'phone' => '+7 (999) 111-11-11',
            ],
            [
                'email' => 'manager@lms.com',
                'firstName' => 'Иван',
                'lastName' => 'Петров',
                'middleName' => 'Сергеевич',
                'password' => 'Manager123!',
                'role' => 'manager',
                'department' => 'Управление',
                'phone' => '+7 (999) 222-22-22',
            ],
            [
                'email' => 'hr@lms.com',
                'firstName' => 'Елена',
                'lastName' => 'Сидорова',
                'middleName' => 'Александровна',
                'password' => 'Hr123456!',
                'role' => 'hr',
                'department' => 'HR',
                'phone' => '+7 (999) 333-33-33',
            ],
            [
                'email' => 'instructor@lms.com',
                'firstName' => 'Алексей',
                'lastName' => 'Иванов',
                'middleName' => 'Владимирович',
                'password' => 'Instructor123!',
                'role' => 'instructor',
                'department' => 'Обучение',
                'phone' => '+7 (999) 444-44-44',
            ],
            [
                'email' => 'employee1@lms.com',
                'firstName' => 'Мария',
                'lastName' => 'Козлова',
                'middleName' => 'Ивановна',
                'password' => 'Employee123!',
                'role' => 'employee',
                'department' => 'Продажи',
                'phone' => '+7 (999) 555-55-55',
            ],
            [
                'email' => 'employee2@lms.com',
                'firstName' => 'Дмитрий',
                'lastName' => 'Новиков',
                'middleName' => 'Андреевич',
                'password' => 'Employee123!',
                'role' => 'employee',
                'department' => 'Маркетинг',
                'phone' => '+7 (999) 666-66-66',
            ],
        ];
        
        $roleRepo = $this->entityManager->getRepository(Role::class);
        
        foreach ($users as $userData) {
            $existing = $this->entityManager->getRepository(User::class)
                ->findOneBy(['email' => $userData['email']]);
            
            if (!$existing) {
                $user = new User(
                    UserId::generate(),
                    new Email($userData['email']),
                    $userData['firstName'],
                    $userData['lastName'],
                    Password::fromPlainText($userData['password'])
                );
                
                if (isset($userData['middleName'])) {
                    $user->setMiddleName($userData['middleName']);
                }
                
                $user->setDepartment($userData['department']);
                $user->setPhone($userData['phone']);
                $user->verifyEmail(); // Mark as verified for demo
                
                // Assign role
                $role = $roleRepo->findOneBy(['name' => $userData['role']]);
                if ($role) {
                    $user->addRole($role);
                }
                
                $this->entityManager->persist($user);
            }
        }
        
        $this->entityManager->flush();
        
        echo "Created/verified 6 demo users\n";
        echo "\nDemo credentials:\n";
        foreach ($users as $userData) {
            echo "- {$userData['role']}: {$userData['email']} / {$userData['password']}\n";
        }
    }
} 