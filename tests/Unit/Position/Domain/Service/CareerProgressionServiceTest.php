<?php

declare(strict_types=1);

namespace Tests\Unit\Position\Domain\Service;

use App\Position\Domain\Service\CareerProgressionService;
use App\Position\Domain\CareerPath;
use App\Position\Domain\Position;
use App\Position\Domain\ValueObjects\PositionId;
use App\Position\Domain\ValueObjects\PositionCode;
use App\Position\Domain\ValueObjects\PositionLevel;
use App\Position\Domain\ValueObjects\Department;
use PHPUnit\Framework\TestCase;

class CareerProgressionServiceTest extends TestCase
{
    private CareerProgressionService $service;
    
    protected function setUp(): void
    {
        $this->service = new CareerProgressionService();
    }
    
    public function testCalculateProgressPercentage(): void
    {
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 24 // months
        );
        
        // 0 months = 0%
        $this->assertEquals(0, $this->service->calculateProgress($careerPath, 0));
        
        // 6 months = 25%
        $this->assertEquals(25, $this->service->calculateProgress($careerPath, 6));
        
        // 12 months = 50%
        $this->assertEquals(50, $this->service->calculateProgress($careerPath, 12));
        
        // 24 months = 100%
        $this->assertEquals(100, $this->service->calculateProgress($careerPath, 24));
        
        // Over duration = still 100%
        $this->assertEquals(100, $this->service->calculateProgress($careerPath, 30));
    }
    
    public function testGetRemainingMonths(): void
    {
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 24
        );
        
        $this->assertEquals(24, $this->service->getRemainingMonths($careerPath, 0));
        $this->assertEquals(18, $this->service->getRemainingMonths($careerPath, 6));
        $this->assertEquals(12, $this->service->getRemainingMonths($careerPath, 12));
        $this->assertEquals(0, $this->service->getRemainingMonths($careerPath, 24));
        $this->assertEquals(0, $this->service->getRemainingMonths($careerPath, 30));
    }
    
    public function testIsEligibleForPromotion(): void
    {
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 24
        );
        
        // Not eligible at start
        $this->assertFalse($this->service->isEligibleForPromotion($careerPath, 0));
        
        // Not eligible at 50%
        $this->assertFalse($this->service->isEligibleForPromotion($careerPath, 12));
        
        // Not eligible at 80%
        $this->assertFalse($this->service->isEligibleForPromotion($careerPath, 19));
        
        // Eligible at 90%
        $this->assertTrue($this->service->isEligibleForPromotion($careerPath, 22));
        
        // Eligible at 100%
        $this->assertTrue($this->service->isEligibleForPromotion($careerPath, 24));
    }
    
    public function testGetNextMilestone(): void
    {
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 24
        );
        
        $careerPath->addMilestone('First Review', 'Complete first performance review', 6);
        $careerPath->addMilestone('Mid Review', 'Complete mid-term review', 12);
        $careerPath->addMilestone('Final Review', 'Complete final review', 18);
        
        // At month 0, next is First Review
        $milestone = $this->service->getNextMilestone($careerPath, 0);
        $this->assertNotNull($milestone);
        $this->assertEquals('First Review', $milestone['title']);
        
        // At month 7, next is Mid Review
        $milestone = $this->service->getNextMilestone($careerPath, 7);
        $this->assertNotNull($milestone);
        $this->assertEquals('Mid Review', $milestone['title']);
        
        // At month 19, no more milestones
        $milestone = $this->service->getNextMilestone($careerPath, 19);
        $this->assertNull($milestone);
    }
    
    public function testGetCompletedMilestones(): void
    {
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 24
        );
        
        $careerPath->addMilestone('First', 'First milestone', 6);
        $careerPath->addMilestone('Second', 'Second milestone', 12);
        $careerPath->addMilestone('Third', 'Third milestone', 18);
        
        // At month 0, no completed milestones
        $completed = $this->service->getCompletedMilestones($careerPath, 0);
        $this->assertCount(0, $completed);
        
        // At month 7, one completed
        $completed = $this->service->getCompletedMilestones($careerPath, 7);
        $this->assertCount(1, $completed);
        $this->assertEquals('First', $completed[0]['title']);
        
        // At month 13, two completed
        $completed = $this->service->getCompletedMilestones($careerPath, 13);
        $this->assertCount(2, $completed);
        
        // At month 20, all completed
        $completed = $this->service->getCompletedMilestones($careerPath, 20);
        $this->assertCount(3, $completed);
    }
} 