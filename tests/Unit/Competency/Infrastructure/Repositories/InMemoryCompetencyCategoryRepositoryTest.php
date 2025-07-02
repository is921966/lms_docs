<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Infrastructure\Repositories;

use Competency\Domain\ValueObjects\CompetencyCategory;
use Competency\Infrastructure\Repositories\InMemoryCompetencyCategoryRepository;
use PHPUnit\Framework\TestCase;

class InMemoryCompetencyCategoryRepositoryTest extends TestCase
{
    private InMemoryCompetencyCategoryRepository $repository;

    protected function setUp(): void
    {
        $this->repository = new InMemoryCompetencyCategoryRepository();
    }

    public function testSaveAndFindById(): void
    {
        // Arrange
        $category = $this->createCategory();
        
        // Act
        $this->repository->save($category);
        $found = $this->repository->findById($category->getId()->getValue());
        
        // Assert
        $this->assertNotNull($found);
        $this->assertTrue($category->getId()->equals($found->getId()));
        $this->assertEquals($category->getName(), $found->getName());
    }

    public function testFindByIdReturnsNullWhenNotFound(): void
    {
        // Arrange
        $id = CategoryId::generate()->getValue();
        
        // Act
        $result = $this->repository->findById($id);
        
        // Assert
        $this->assertNull($result);
    }

    public function testFindByName(): void
    {
        // Arrange
        $category = $this->createCategory();
        $this->repository->save($category);
        
        // Act
        $found = $this->repository->findByName($category->getName());
        
        // Assert
        $this->assertNotNull($found);
        $this->assertEquals($category->getName(), $found->getName());
    }

    public function testFindByParentId(): void
    {
        // Arrange
        $parent = $this->createCategory();
        $child1 = $this->createCategoryWithParent($parent);
        $child2 = $this->createCategoryWithParent($parent);
        $orphan = $this->createCategory();
        
        $this->repository->save($parent);
        $this->repository->save($child1);
        $this->repository->save($child2);
        $this->repository->save($orphan);
        
        // Act
        $children = $this->repository->findByParentId($parent->getId()->getValue());
        
        // Assert
        $this->assertCount(2, $children);
        $this->assertTrue($children[0]->hasParent());
        $this->assertTrue($children[1]->hasParent());
        $this->assertTrue($children[0]->getParent()->equals($parent));
        $this->assertTrue($children[1]->getParent()->equals($parent));
    }

    public function testFindActive(): void
    {
        // Arrange
        $active1 = $this->createCategory();
        $active2 = $this->createCategory();
        $inactive = $this->createCategory();
        $inactive->deactivate();
        
        $this->repository->save($active1);
        $this->repository->save($active2);
        $this->repository->save($inactive);
        
        // Act
        $activeCategories = $this->repository->findActive();
        
        // Assert
        $this->assertCount(2, $activeCategories);
        $this->assertTrue($activeCategories[0]->isActive());
        $this->assertTrue($activeCategories[1]->isActive());
    }

    public function testDelete(): void
    {
        // Arrange
        $category = $this->createCategory();
        $this->repository->save($category);
        $id = $category->getId()->getValue();
        
        // Act
        $this->repository->delete($id);
        
        // Assert
        $this->assertNull($this->repository->findById($id));
        $this->assertFalse($this->repository->exists($id));
    }

    public function testClear(): void
    {
        // Arrange
        $this->repository->save($this->createCategory());
        $this->repository->save($this->createCategory());
        
        // Act
        $this->repository->clear();
        
        // Assert
        $this->assertCount(0, $this->repository->findAll());
        $this->assertEquals(0, $this->repository->count());
    }

    private function createCategory(): CompetencyCategory
    {
        return CompetencyCategory::create(
            'Test Category ' . uniqid(),
            'Test Description'
        );
    }

    private function createCategoryWithParent(CompetencyCategory $parent): CompetencyCategory
    {
        $category = CompetencyCategory::create(
            'Child Category ' . uniqid(),
            'Child Description'
        );
        $category->setParent($parent);
        return $category;
    }
}
