<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Infrastructure\Repositories;

use Competency\Domain\Competency;
use Competency\Domain\ValueObjects\CompetencyCategory;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\SkillLevel;
use Competency\Infrastructure\Repositories\InMemoryCompetencyRepository;
use PHPUnit\Framework\TestCase;

class InMemoryCompetencyRepositoryTest extends TestCase
{
    private InMemoryCompetencyRepository $repository;

    protected function setUp(): void
    {
        $this->repository = new InMemoryCompetencyRepository();
    }

    public function testSaveAndFindById(): void
    {
        // Arrange
        $competency = $this->createCompetency();
        
        // Act
        $this->repository->save($competency);
        $found = $this->repository->findById($competency->getId()->getValue());
        
        // Assert
        $this->assertNotNull($found);
        $this->assertTrue($competency->getId()->equals($found->getId()));
        $this->assertEquals($competency->getName(), $found->getName());
    }

    public function testFindByIdReturnsNullWhenNotFound(): void
    {
        // Arrange
        $id = CompetencyId::generate()->getValue();
        
        // Act
        $result = $this->repository->findById($id);
        
        // Assert
        $this->assertNull($result);
    }

    public function testFindByName(): void
    {
        // Arrange
        $competency = $this->createCompetency();
        $this->repository->save($competency);
        
        // Act
        $found = $this->repository->findByName($competency->getName());
        
        // Assert
        $this->assertNotNull($found);
        $this->assertEquals($competency->getName(), $found->getName());
    }

    public function testFindByCategory(): void
    {
        // Arrange
        $category = $this->createCategory();
        $competency1 = $this->createCompetencyWithCategory($category);
        $competency2 = $this->createCompetencyWithCategory($category);
        $competency3 = $this->createCompetency(); // Different category
        
        $this->repository->save($competency1);
        $this->repository->save($competency2);
        $this->repository->save($competency3);
        
        // Act
        $result = $this->repository->findByCategory($category->getId()->getValue());
        
        // Assert
        $this->assertCount(2, $result);
        $this->assertEquals($category->getId()->getValue(), $result[0]->getCategory()->getId()->getValue());
        $this->assertEquals($category->getId()->getValue(), $result[1]->getCategory()->getId()->getValue());
    }

    public function testFindAll(): void
    {
        // Arrange
        $competency1 = $this->createCompetency();
        $competency2 = $this->createCompetency();
        
        $this->repository->save($competency1);
        $this->repository->save($competency2);
        
        // Act
        $result = $this->repository->findAll();
        
        // Assert
        $this->assertCount(2, $result);
    }

    public function testDelete(): void
    {
        // Arrange
        $competency = $this->createCompetency();
        $this->repository->save($competency);
        
        // Act
        $this->repository->delete($competency->getId()->getValue());
        
        // Assert
        $this->assertNull($this->repository->findById($competency->getId()->getValue()));
        $this->assertFalse($this->repository->exists($competency->getId()->getValue()));
    }

    public function testExists(): void
    {
        // Arrange
        $competency = $this->createCompetency();
        
        // Act & Assert
        $this->assertFalse($this->repository->exists($competency->getId()->getValue()));
        
        $this->repository->save($competency);
        $this->assertTrue($this->repository->exists($competency->getId()->getValue()));
    }

    public function testClear(): void
    {
        // Arrange
        $this->repository->save($this->createCompetency());
        $this->repository->save($this->createCompetency());
        
        // Act
        $this->repository->clear();
        
        // Assert
        $this->assertCount(0, $this->repository->findAll());
        $this->assertEquals(0, $this->repository->count());
    }

    public function testCount(): void
    {
        // Arrange & Act & Assert
        $this->assertEquals(0, $this->repository->count());
        
        $this->repository->save($this->createCompetency());
        $this->assertEquals(1, $this->repository->count());
        
        $this->repository->save($this->createCompetency());
        $this->assertEquals(2, $this->repository->count());
    }

    private function createCategory(): CompetencyCategory
    {
        return CompetencyCategory::create(
            'Test Category ' . uniqid(),
            'Test Category Description',
            'TEST_CAT_' . uniqid()
        );
    }

    private function createCompetency(): Competency
    {
        return Competency::create(
            'Test Competency ' . uniqid(),
            'Test Description',
            $this->createCategory()
        );
    }

    private function createCompetencyWithCategory(CompetencyCategory $category): Competency
    {
        return Competency::create(
            'Test Competency ' . uniqid(),
            'Test Description',
            $category
        );
    }
}
