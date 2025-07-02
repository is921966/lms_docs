<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Domain;

use Competency\Domain\UserCompetency;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;
use Competency\Domain\Events\UserCompetencyCreated;
use Competency\Domain\Events\UserCompetencyProgressUpdated;
use Competency\Domain\Events\TargetLevelSet;
use User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;

class UserCompetencyTest extends TestCase
{
    public function testCreateUserCompetency(): void
    {
        $userId = UserId::generate();
        $competencyId = CompetencyId::generate();
        $currentLevel = CompetencyLevel::beginner();
        
        $userCompetency = UserCompetency::create(
            userId: $userId,
            competencyId: $competencyId,
            currentLevel: $currentLevel
        );
        
        $this->assertEquals($userId, $userCompetency->getUserId());
        $this->assertEquals($competencyId, $userCompetency->getCompetencyId());
        $this->assertEquals($currentLevel, $userCompetency->getCurrentLevel());
        $this->assertNull($userCompetency->getTargetLevel());
        $this->assertInstanceOf(\DateTimeImmutable::class, $userCompetency->getLastUpdated());
        $this->assertEquals(0, $userCompetency->getProgressPercentage());
        
        // Check domain event
        $events = $userCompetency->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(UserCompetencyCreated::class, $events[0]);
    }
    
    public function testCreateUserCompetencyWithTargetLevel(): void
    {
        $targetLevel = CompetencyLevel::advanced();
        
        $userCompetency = UserCompetency::create(
            userId: UserId::generate(),
            competencyId: CompetencyId::generate(),
            currentLevel: CompetencyLevel::beginner(),
            targetLevel: $targetLevel
        );
        
        $this->assertEquals($targetLevel, $userCompetency->getTargetLevel());
        $this->assertTrue($userCompetency->hasTargetLevel());
    }
    
    public function testSetTargetLevel(): void
    {
        $userCompetency = $this->createSampleUserCompetency();
        $userCompetency->pullDomainEvents(); // Clear creation event
        
        $targetLevel = CompetencyLevel::expert();
        $userCompetency->setTargetLevel($targetLevel);
        
        $this->assertEquals($targetLevel, $userCompetency->getTargetLevel());
        
        // Check domain event
        $events = $userCompetency->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(TargetLevelSet::class, $events[0]);
    }
    
    public function testCannotSetTargetLevelBelowCurrent(): void
    {
        $userCompetency = UserCompetency::create(
            userId: UserId::generate(),
            competencyId: CompetencyId::generate(),
            currentLevel: CompetencyLevel::intermediate()
        );
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Target level cannot be below or equal to current level');
        
        $userCompetency->setTargetLevel(CompetencyLevel::beginner());
    }
    
    public function testUpdateProgress(): void
    {
        $userCompetency = $this->createSampleUserCompetency();
        $userCompetency->setTargetLevel(CompetencyLevel::advanced());
        $userCompetency->pullDomainEvents(); // Clear previous events
        
        $newLevel = CompetencyLevel::intermediate();
        $userCompetency->updateProgress($newLevel);
        
        $this->assertEquals($newLevel, $userCompetency->getCurrentLevel());
        $this->assertInstanceOf(\DateTimeImmutable::class, $userCompetency->getLastUpdated());
        
        // Check domain event
        $events = $userCompetency->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(UserCompetencyProgressUpdated::class, $events[0]);
    }
    
    public function testGetProgressPercentage(): void
    {
        // Beginner to Expert (1 to 5, gap of 4)
        $userCompetency = UserCompetency::create(
            userId: UserId::generate(),
            competencyId: CompetencyId::generate(),
            currentLevel: CompetencyLevel::beginner(),
            targetLevel: CompetencyLevel::expert()
        );
        
        $this->assertEquals(0, $userCompetency->getProgressPercentage());
        
        // Update to intermediate (3), should be 50% progress (2 out of 4 levels)
        $userCompetency->updateProgress(CompetencyLevel::intermediate());
        $this->assertEquals(50, $userCompetency->getProgressPercentage());
        
        // Update to advanced (4), should be 75% progress (3 out of 4 levels)
        $userCompetency->updateProgress(CompetencyLevel::advanced());
        $this->assertEquals(75, $userCompetency->getProgressPercentage());
        
        // Update to expert (5), should be 100% progress
        $userCompetency->updateProgress(CompetencyLevel::expert());
        $this->assertEquals(100, $userCompetency->getProgressPercentage());
    }
    
    public function testGetProgressPercentageWithoutTarget(): void
    {
        $userCompetency = UserCompetency::create(
            userId: UserId::generate(),
            competencyId: CompetencyId::generate(),
            currentLevel: CompetencyLevel::intermediate()
        );
        
        $this->assertEquals(0, $userCompetency->getProgressPercentage());
    }
    
    public function testIsTargetReached(): void
    {
        $userCompetency = UserCompetency::create(
            userId: UserId::generate(),
            competencyId: CompetencyId::generate(),
            currentLevel: CompetencyLevel::beginner(),
            targetLevel: CompetencyLevel::intermediate()
        );
        
        $this->assertFalse($userCompetency->isTargetReached());
        
        $userCompetency->updateProgress(CompetencyLevel::intermediate());
        $this->assertTrue($userCompetency->isTargetReached());
        
        $userCompetency->updateProgress(CompetencyLevel::advanced());
        $this->assertTrue($userCompetency->isTargetReached());
    }
    
    public function testGetGapToTarget(): void
    {
        $userCompetency = UserCompetency::create(
            userId: UserId::generate(),
            competencyId: CompetencyId::generate(),
            currentLevel: CompetencyLevel::beginner(),
            targetLevel: CompetencyLevel::advanced()
        );
        
        $this->assertEquals(3, $userCompetency->getGapToTarget());
        
        $userCompetency->updateProgress(CompetencyLevel::intermediate());
        $this->assertEquals(1, $userCompetency->getGapToTarget());
        
        $userCompetency->updateProgress(CompetencyLevel::advanced());
        $this->assertEquals(0, $userCompetency->getGapToTarget());
    }
    
    public function testGetGapToTargetWithoutTarget(): void
    {
        $userCompetency = UserCompetency::create(
            userId: UserId::generate(),
            competencyId: CompetencyId::generate(),
            currentLevel: CompetencyLevel::intermediate()
        );
        
        $this->assertNull($userCompetency->getGapToTarget());
    }
    
    public function testRemoveTargetLevel(): void
    {
        $userCompetency = $this->createSampleUserCompetency();
        $userCompetency->setTargetLevel(CompetencyLevel::expert());
        $userCompetency->pullDomainEvents(); // Clear previous events
        
        $userCompetency->removeTargetLevel();
        
        $this->assertNull($userCompetency->getTargetLevel());
        $this->assertFalse($userCompetency->hasTargetLevel());
    }
    
    public function testGetDaysSinceLastUpdate(): void
    {
        $lastUpdated = new \DateTimeImmutable('-15 days');
        
        $userCompetency = UserCompetency::createWithDate(
            userId: UserId::generate(),
            competencyId: CompetencyId::generate(),
            currentLevel: CompetencyLevel::intermediate(),
            lastUpdated: $lastUpdated
        );
        
        $daysSince = $userCompetency->getDaysSinceLastUpdate();
        $this->assertGreaterThanOrEqual(14, $daysSince);
        $this->assertLessThanOrEqual(16, $daysSince);
    }
    
    private function createSampleUserCompetency(): UserCompetency
    {
        return UserCompetency::create(
            userId: UserId::generate(),
            competencyId: CompetencyId::generate(),
            currentLevel: CompetencyLevel::beginner()
        );
    }
} 