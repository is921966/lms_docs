<?php

declare(strict_types=1);

namespace Tests\Unit\Position\Domain;

use App\Position\Domain\CareerPath;
use App\Position\Domain\ValueObjects\PositionId;
use PHPUnit\Framework\TestCase;

class CareerPathTest extends TestCase
{
    public function testCreateCareerPath(): void
    {
        $fromPositionId = PositionId::generate();
        $toPositionId = PositionId::generate();
        
        $careerPath = CareerPath::create(
            fromPositionId: $fromPositionId,
            toPositionId: $toPositionId,
            requirements: ['3 years in current position', 'Performance rating > 4.0'],
            estimatedDuration: 24 // months
        );
        
        $this->assertEquals($fromPositionId, $careerPath->getFromPositionId());
        $this->assertEquals($toPositionId, $careerPath->getToPositionId());
        $this->assertCount(2, $careerPath->getRequirements());
        $this->assertEquals(24, $careerPath->getEstimatedDuration());
        $this->assertTrue($careerPath->isActive());
        $this->assertCount(0, $careerPath->getMilestones());
    }
    
    public function testAddMilestone(): void
    {
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 12
        );
        
        $careerPath->addMilestone(
            title: 'Complete Leadership Training',
            description: 'Finish all leadership courses',
            monthsFromStart: 3
        );
        
        $milestones = $careerPath->getMilestones();
        $this->assertCount(1, $milestones);
        
        $milestone = $milestones[0];
        $this->assertEquals('Complete Leadership Training', $milestone['title']);
        $this->assertEquals('Finish all leadership courses', $milestone['description']);
        $this->assertEquals(3, $milestone['monthsFromStart']);
    }
    
    public function testCannotAddMilestoneAfterEstimatedDuration(): void
    {
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 12
        );
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Milestone cannot be after estimated duration');
        
        $careerPath->addMilestone(
            title: 'Too late milestone',
            description: 'This is too late',
            monthsFromStart: 15
        );
    }
    
    public function testUpdateRequirements(): void
    {
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: ['Old requirement'],
            estimatedDuration: 12
        );
        
        $newRequirements = ['New requirement 1', 'New requirement 2'];
        $careerPath->updateRequirements($newRequirements);
        
        $this->assertEquals($newRequirements, $careerPath->getRequirements());
    }
    
    public function testDeactivateCareerPath(): void
    {
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 12
        );
        
        $this->assertTrue($careerPath->isActive());
        
        $careerPath->deactivate();
        
        $this->assertFalse($careerPath->isActive());
    }
    
    public function testActivateCareerPath(): void
    {
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 12
        );
        
        $careerPath->deactivate();
        $this->assertFalse($careerPath->isActive());
        
        $careerPath->activate();
        $this->assertTrue($careerPath->isActive());
    }
    
    public function testUpdateEstimatedDuration(): void
    {
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 12
        );
        
        $careerPath->updateEstimatedDuration(18);
        
        $this->assertEquals(18, $careerPath->getEstimatedDuration());
    }
    
    public function testCannotSetNegativeEstimatedDuration(): void
    {
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 12
        );
        
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Estimated duration must be positive');
        
        $careerPath->updateEstimatedDuration(-5);
    }
    
    public function testRemoveMilestone(): void
    {
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 12
        );
        
        $careerPath->addMilestone('Milestone 1', 'Description 1', 3);
        $careerPath->addMilestone('Milestone 2', 'Description 2', 6);
        
        $this->assertCount(2, $careerPath->getMilestones());
        
        $careerPath->removeMilestone('Milestone 1');
        
        $milestones = $careerPath->getMilestones();
        $this->assertCount(1, $milestones);
        $this->assertEquals('Milestone 2', $milestones[0]['title']);
    }
    
    public function testGetDurationInYears(): void
    {
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 24
        );
        
        $this->assertEquals(2.0, $careerPath->getDurationInYears());
    }
} 