<?php

namespace CompetencyService\Tests\Unit\Domain;

use PHPUnit\Framework\TestCase;
use CompetencyService\Domain\Entities\Competency;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\CompetencyCode;
use CompetencyService\Domain\ValueObjects\CompetencyLevel;
use CompetencyService\Domain\Events\CompetencyCreated;
use CompetencyService\Domain\Events\CompetencyUpdated;

class CompetencyTest extends TestCase
{
    public function testCreateCompetency(): void
    {
        // Arrange
        $id = CompetencyId::generate();
        $code = new CompetencyCode('TECH-001');
        $name = 'Software Development';
        $description = 'Ability to develop software applications';
        $category = 'Technical';
        
        // Act
        $competency = new Competency($id, $code, $name, $description, $category);
        
        // Assert
        $this->assertEquals($id, $competency->getId());
        $this->assertEquals($code, $competency->getCode());
        $this->assertEquals($name, $competency->getName());
        $this->assertEquals($description, $competency->getDescription());
        $this->assertEquals($category, $competency->getCategory());
        $this->assertTrue($competency->isActive());
        
        // Check domain event
        $events = $competency->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(CompetencyCreated::class, $events[0]);
    }
    
    public function testAddCompetencyLevel(): void
    {
        // Arrange
        $competency = $this->createCompetency();
        $level = new CompetencyLevel(
            1,
            'Beginner',
            'Basic understanding of concepts',
            ['Complete basic tutorials', 'Understand fundamental concepts']
        );
        
        // Act
        $competency->addLevel($level);
        
        // Assert
        $levels = $competency->getLevels();
        $this->assertCount(1, $levels);
        $this->assertEquals($level, $levels[0]);
    }
    
    public function testUpdateCompetency(): void
    {
        // Arrange
        $competency = $this->createCompetency();
        $newName = 'Advanced Software Development';
        $newDescription = 'Expert ability to develop complex software';
        
        // Act
        $competency->update($newName, $newDescription);
        
        // Assert
        $this->assertEquals($newName, $competency->getName());
        $this->assertEquals($newDescription, $competency->getDescription());
        
        // Check domain event
        $events = $competency->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(CompetencyUpdated::class, $events[0]);
    }
    
    public function testDeactivateCompetency(): void
    {
        // Arrange
        $competency = $this->createCompetency();
        
        // Act
        $competency->deactivate();
        
        // Assert
        $this->assertFalse($competency->isActive());
    }
    
    public function testCompetencyWithMultipleLevels(): void
    {
        // Arrange
        $competency = $this->createCompetency();
        
        $levels = [
            new CompetencyLevel(1, 'Beginner', 'Basic understanding', ['Task 1']),
            new CompetencyLevel(2, 'Intermediate', 'Good understanding', ['Task 2']),
            new CompetencyLevel(3, 'Advanced', 'Expert understanding', ['Task 3']),
            new CompetencyLevel(4, 'Expert', 'Master level', ['Task 4'])
        ];
        
        // Act
        foreach ($levels as $level) {
            $competency->addLevel($level);
        }
        
        // Assert
        $this->assertCount(4, $competency->getLevels());
        $this->assertEquals(1, $competency->getMinLevel());
        $this->assertEquals(4, $competency->getMaxLevel());
    }
    
    private function createCompetency(): Competency
    {
        return new Competency(
            CompetencyId::generate(),
            new CompetencyCode('TEST-001'),
            'Test Competency',
            'Test Description',
            'Test Category'
        );
    }
} 