<?php

namespace Tests\Unit\Competency\Domain\Entities;

use PHPUnit\Framework\TestCase;
use Competency\Domain\ValueObjects\CompetencyCategory;
use Competency\Domain\ValueObjects\CategoryId;

class CompetencyCategoryTest extends TestCase
{
    public function testCreateCategory()
    {
        // Act
        $category = CompetencyCategory::create(
            'Technical Skills',
            'Technical competencies required for development'
        );

        // Assert
        $this->assertInstanceOf(CompetencyCategory::class, $category);
        $this->assertInstanceOf(CategoryId::class, $category->getId());
        $this->assertEquals('Technical Skills', $category->getName());
        $this->assertEquals('Technical competencies required for development', $category->getDescription());
        $this->assertTrue($category->isActive());
    }

    public function testUpdateCategoryDetails()
    {
        // Arrange
        $category = CompetencyCategory::create('Soft', 'Soft skills');

        // Act
        $category->updateDetails(
            'Soft Skills',
            'Interpersonal and communication skills'
        );

        // Assert
        $this->assertEquals('Soft Skills', $category->getName());
        $this->assertEquals('Interpersonal and communication skills', $category->getDescription());
    }

    public function testDeactivateCategory()
    {
        // Arrange
        $category = CompetencyCategory::create('Legacy', 'Old competencies');

        // Act
        $category->deactivate();

        // Assert
        $this->assertFalse($category->isActive());
    }

    public function testReactivateCategory()
    {
        // Arrange
        $category = CompetencyCategory::create('Management', 'Management skills');
        $category->deactivate();

        // Act
        $category->activate();

        // Assert
        $this->assertTrue($category->isActive());
    }

    public function testCategoryHierarchy()
    {
        // Arrange
        $parentCategory = CompetencyCategory::create('IT', 'Information Technology');
        $childCategory = CompetencyCategory::create('Programming', 'Programming languages');

        // Act
        $childCategory->setParent($parentCategory);

        // Assert
        $this->assertTrue($childCategory->hasParent());
        $this->assertTrue($childCategory->getParent()->equals($parentCategory));
    }

    public function testRemoveParentCategory()
    {
        // Arrange
        $parentCategory = CompetencyCategory::create('Business', 'Business skills');
        $childCategory = CompetencyCategory::create('Finance', 'Financial skills');
        $childCategory->setParent($parentCategory);

        // Act
        $childCategory->removeParent();

        // Assert
        $this->assertFalse($childCategory->hasParent());
        $this->assertNull($childCategory->getParent());
    }

    public function testCategoryEquality()
    {
        // Arrange
        $category1 = CompetencyCategory::create('Leadership', 'Leadership skills');
        $category2 = CompetencyCategory::createWithId(
            $category1->getId(),
            'Leadership',
            'Leadership skills'
        );

        // Act & Assert
        $this->assertTrue($category1->equals($category2));
    }

    public function testCategoryWithDifferentIdsAreNotEqual()
    {
        // Arrange
        $category1 = CompetencyCategory::create('Sales', 'Sales skills');
        $category2 = CompetencyCategory::create('Sales', 'Sales skills');

        // Act & Assert
        $this->assertFalse($category1->equals($category2));
    }

    public function testCategoryColor()
    {
        // Arrange
        $category = CompetencyCategory::create('Technical', 'Tech skills');

        // Act
        $category->setColor('#FF5733');

        // Assert
        $this->assertEquals('#FF5733', $category->getColor());
    }

    public function testCategoryIcon()
    {
        // Arrange
        $category = CompetencyCategory::create('Communication', 'Communication skills');

        // Act
        $category->setIcon('chat-bubble');

        // Assert
        $this->assertEquals('chat-bubble', $category->getIcon());
    }
} 