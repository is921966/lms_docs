<?php

namespace Tests;

use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\Tools\SchemaTool;

abstract class IntegrationTestCase extends TestCase
{
    protected EntityManagerInterface $entityManager;
    protected array $fixtures = [];
    
    protected function setUp(): void
    {
        parent::setUp();
        
        // Get entity manager from container
        $this->entityManager = $this->getEntityManager();
        
        // Create schema
        $this->createSchema();
        
        // Load fixtures
        $this->loadFixtures();
    }
    
    protected function tearDown(): void
    {
        parent::tearDown();
        
        // Drop schema
        $this->dropSchema();
        
        // Close entity manager
        $this->entityManager->close();
    }
    
    protected function getEntityManager(): EntityManagerInterface
    {
        // This would be replaced with actual container setup
        $config = \Doctrine\ORM\Tools\Setup::createAnnotationMetadataConfiguration(
            [__DIR__ . '/../src'],
            true,
            null,
            null,
            false
        );
        
        $connection = [
            'driver' => 'pdo_pgsql',
            'host' => $_ENV['DB_HOST'] ?? 'localhost',
            'port' => $_ENV['DB_PORT'] ?? 5432,
            'dbname' => $_ENV['DB_DATABASE'] ?? 'lms_test',
            'user' => $_ENV['DB_USERNAME'] ?? 'postgres',
            'password' => $_ENV['DB_PASSWORD'] ?? 'postgres',
        ];
        
        return \Doctrine\ORM\EntityManager::create($connection, $config);
    }
    
    protected function createSchema(): void
    {
        $metadata = $this->entityManager->getMetadataFactory()->getAllMetadata();
        $schemaTool = new SchemaTool($this->entityManager);
        $schemaTool->dropSchema($metadata);
        $schemaTool->createSchema($metadata);
    }
    
    protected function dropSchema(): void
    {
        $metadata = $this->entityManager->getMetadataFactory()->getAllMetadata();
        $schemaTool = new SchemaTool($this->entityManager);
        $schemaTool->dropSchema($metadata);
    }
    
    protected function loadFixtures(): void
    {
        foreach ($this->fixtures as $fixture) {
            if (is_callable($fixture)) {
                $fixture($this->entityManager);
            }
        }
        
        $this->entityManager->flush();
    }
    
    /**
     * Refresh entity from database
     */
    protected function refresh($entity): void
    {
        $this->entityManager->refresh($entity);
    }
    
    /**
     * Clear entity manager
     */
    protected function clearEntityManager(): void
    {
        $this->entityManager->clear();
    }
    
    /**
     * Begin transaction
     */
    protected function beginTransaction(): void
    {
        $this->entityManager->beginTransaction();
    }
    
    /**
     * Rollback transaction
     */
    protected function rollback(): void
    {
        $this->entityManager->rollback();
    }
    
    /**
     * Commit transaction
     */
    protected function commit(): void
    {
        $this->entityManager->commit();
    }
    
    /**
     * Assert entity exists in database
     */
    protected function assertEntityExists(string $class, array $criteria): void
    {
        $entity = $this->entityManager->getRepository($class)->findOneBy($criteria);
        $this->assertNotNull($entity, "Entity {$class} with given criteria not found");
    }
    
    /**
     * Assert entity does not exist in database
     */
    protected function assertEntityNotExists(string $class, array $criteria): void
    {
        $entity = $this->entityManager->getRepository($class)->findOneBy($criteria);
        $this->assertNull($entity, "Entity {$class} with given criteria should not exist");
    }
    
    /**
     * Count entities in database
     */
    protected function countEntities(string $class, array $criteria = []): int
    {
        return count($this->entityManager->getRepository($class)->findBy($criteria));
    }
} 