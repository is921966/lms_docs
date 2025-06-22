<?php

namespace Database\Seeders;

use Doctrine\ORM\EntityManagerInterface;

class DatabaseSeeder
{
    private EntityManagerInterface $entityManager;
    private array $seeders = [
        PermissionSeeder::class,
        RoleSeeder::class,
        UserSeeder::class,
    ];
    
    public function __construct(EntityManagerInterface $entityManager)
    {
        $this->entityManager = $entityManager;
    }
    
    /**
     * Run all seeders
     */
    public function run(): void
    {
        echo "Seeding database...\n";
        
        foreach ($this->seeders as $seederClass) {
            echo "Running {$seederClass}...\n";
            
            $seeder = new $seederClass($this->entityManager);
            $seeder->run();
            
            echo "Completed {$seederClass}\n";
        }
        
        echo "Database seeding completed!\n";
    }
    
    /**
     * Run specific seeder
     */
    public function runSeeder(string $seederClass): void
    {
        echo "Running {$seederClass}...\n";
        
        $seeder = new $seederClass($this->entityManager);
        $seeder->run();
        
        echo "Completed {$seederClass}\n";
    }
} 