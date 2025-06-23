<?php

declare(strict_types=1);

namespace Tests\Unit\Position\Domain;

use App\Position\Domain\PositionProfile;
use App\Position\Domain\ValueObjects\PositionId;
use App\Position\Domain\ValueObjects\RequiredCompetency;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;
use PHPUnit\Framework\TestCase;

class PositionProfileTest extends TestCase
{
    public function testCreatePositionProfile(): void
    {
        $positionId = PositionId::generate();
        
        $profile = PositionProfile::create(
            positionId: $positionId,
            responsibilities: ['Develop software', 'Code review'],
            requirements: ['5 years experience', 'Bachelor degree']
        );
        
        $this->assertEquals($positionId, $profile->getPositionId());
        $this->assertCount(2, $profile->getResponsibilities());
        $this->assertContains('Develop software', $profile->getResponsibilities());
        $this->assertCount(2, $profile->getRequirements());
        $this->assertContains('5 years experience', $profile->getRequirements());
        $this->assertCount(0, $profile->getRequiredCompetencies());
        $this->assertCount(0, $profile->getDesiredCompetencies());
    }
    
    public function testAddRequiredCompetency(): void
    {
        $profile = PositionProfile::create(
            positionId: PositionId::generate(),
            responsibilities: [],
            requirements: []
        );
        
        $competencyId = CompetencyId::generate();
        $minLevel = CompetencyLevel::intermediate();
        
        $profile->addRequiredCompetency($competencyId, $minLevel);
        
        $requiredCompetencies = $profile->getRequiredCompetencies();
        $this->assertCount(1, $requiredCompetencies);
        
        $requirement = $requiredCompetencies[0];
        $this->assertEquals($competencyId, $requirement->getCompetencyId());
        $this->assertEquals($minLevel, $requirement->getMinimumLevel());
        $this->assertTrue($requirement->isRequired());
    }
    
    public function testAddDesiredCompetency(): void
    {
        $profile = PositionProfile::create(
            positionId: PositionId::generate(),
            responsibilities: [],
            requirements: []
        );
        
        $competencyId = CompetencyId::generate();
        $preferredLevel = CompetencyLevel::advanced();
        
        $profile->addDesiredCompetency($competencyId, $preferredLevel);
        
        $desiredCompetencies = $profile->getDesiredCompetencies();
        $this->assertCount(1, $desiredCompetencies);
        
        $desired = $desiredCompetencies[0];
        $this->assertEquals($competencyId, $desired->getCompetencyId());
        $this->assertEquals($preferredLevel, $desired->getMinimumLevel());
        $this->assertFalse($desired->isRequired());
    }
    
    public function testCannotAddDuplicateRequiredCompetency(): void
    {
        $profile = PositionProfile::create(
            positionId: PositionId::generate(),
            responsibilities: [],
            requirements: []
        );
        
        $competencyId = CompetencyId::generate();
        $profile->addRequiredCompetency($competencyId, CompetencyLevel::intermediate());
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Competency already exists in required list');
        
        $profile->addRequiredCompetency($competencyId, CompetencyLevel::advanced());
    }
    
    public function testRemoveRequiredCompetency(): void
    {
        $profile = PositionProfile::create(
            positionId: PositionId::generate(),
            responsibilities: [],
            requirements: []
        );
        
        $competencyId = CompetencyId::generate();
        $profile->addRequiredCompetency($competencyId, CompetencyLevel::intermediate());
        
        $profile->removeRequiredCompetency($competencyId);
        
        $this->assertCount(0, $profile->getRequiredCompetencies());
    }
    
    public function testUpdateResponsibilities(): void
    {
        $profile = PositionProfile::create(
            positionId: PositionId::generate(),
            responsibilities: ['Old responsibility'],
            requirements: []
        );
        
        $newResponsibilities = ['New responsibility 1', 'New responsibility 2'];
        $profile->updateResponsibilities($newResponsibilities);
        
        $this->assertCount(2, $profile->getResponsibilities());
        $this->assertEquals($newResponsibilities, $profile->getResponsibilities());
    }
    
    public function testUpdateRequirements(): void
    {
        $profile = PositionProfile::create(
            positionId: PositionId::generate(),
            responsibilities: [],
            requirements: ['Old requirement']
        );
        
        $newRequirements = ['New requirement 1', 'New requirement 2'];
        $profile->updateRequirements($newRequirements);
        
        $this->assertCount(2, $profile->getRequirements());
        $this->assertEquals($newRequirements, $profile->getRequirements());
    }
    
    public function testGetCompetencyRequirement(): void
    {
        $profile = PositionProfile::create(
            positionId: PositionId::generate(),
            responsibilities: [],
            requirements: []
        );
        
        $competencyId = CompetencyId::generate();
        $level = CompetencyLevel::advanced();
        
        $profile->addRequiredCompetency($competencyId, $level);
        
        $requirement = $profile->getCompetencyRequirement($competencyId);
        $this->assertNotNull($requirement);
        $this->assertEquals($competencyId, $requirement->getCompetencyId());
        $this->assertEquals($level, $requirement->getMinimumLevel());
    }
    
    public function testGetCompetencyRequirementReturnsNullForNonExistent(): void
    {
        $profile = PositionProfile::create(
            positionId: PositionId::generate(),
            responsibilities: [],
            requirements: []
        );
        
        $requirement = $profile->getCompetencyRequirement(CompetencyId::generate());
        $this->assertNull($requirement);
    }
    
    public function testHasCompetencyRequirement(): void
    {
        $profile = PositionProfile::create(
            positionId: PositionId::generate(),
            responsibilities: [],
            requirements: []
        );
        
        $competencyId = CompetencyId::generate();
        $profile->addRequiredCompetency($competencyId, CompetencyLevel::intermediate());
        
        $this->assertTrue($profile->hasCompetencyRequirement($competencyId));
        $this->assertFalse($profile->hasCompetencyRequirement(CompetencyId::generate()));
    }
} 