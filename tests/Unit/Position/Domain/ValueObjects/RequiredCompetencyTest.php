<?php

declare(strict_types=1);

namespace Tests\Unit\Position\Domain\ValueObjects;

use App\Position\Domain\ValueObjects\RequiredCompetency;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;
use PHPUnit\Framework\TestCase;

class RequiredCompetencyTest extends TestCase
{
    public function testCreateRequiredCompetency(): void
    {
        $competencyId = CompetencyId::generate();
        $level = CompetencyLevel::intermediate();
        
        $requirement = new RequiredCompetency($competencyId, $level, true);
        
        $this->assertEquals($competencyId, $requirement->getCompetencyId());
        $this->assertEquals($level, $requirement->getMinimumLevel());
        $this->assertTrue($requirement->isRequired());
        $this->assertFalse($requirement->isDesired());
    }
    
    public function testCreateDesiredCompetency(): void
    {
        $competencyId = CompetencyId::generate();
        $level = CompetencyLevel::advanced();
        
        $requirement = new RequiredCompetency($competencyId, $level, false);
        
        $this->assertEquals($competencyId, $requirement->getCompetencyId());
        $this->assertEquals($level, $requirement->getMinimumLevel());
        $this->assertFalse($requirement->isRequired());
        $this->assertTrue($requirement->isDesired());
    }
    
    public function testStaticRequiredFactory(): void
    {
        $competencyId = CompetencyId::generate();
        $level = CompetencyLevel::expert();
        
        $requirement = RequiredCompetency::required($competencyId, $level);
        
        $this->assertEquals($competencyId, $requirement->getCompetencyId());
        $this->assertEquals($level, $requirement->getMinimumLevel());
        $this->assertTrue($requirement->isRequired());
        $this->assertFalse($requirement->isDesired());
    }
    
    public function testStaticDesiredFactory(): void
    {
        $competencyId = CompetencyId::generate();
        $level = CompetencyLevel::beginner();
        
        $requirement = RequiredCompetency::desired($competencyId, $level);
        
        $this->assertEquals($competencyId, $requirement->getCompetencyId());
        $this->assertEquals($level, $requirement->getMinimumLevel());
        $this->assertFalse($requirement->isRequired());
        $this->assertTrue($requirement->isDesired());
    }
    
    public function testEquals(): void
    {
        $competencyId = CompetencyId::generate();
        $level = CompetencyLevel::intermediate();
        
        $requirement1 = RequiredCompetency::required($competencyId, $level);
        $requirement2 = RequiredCompetency::required($competencyId, $level);
        
        $this->assertTrue($requirement1->equals($requirement2));
    }
    
    public function testNotEqualsDifferentCompetency(): void
    {
        $level = CompetencyLevel::intermediate();
        
        $requirement1 = RequiredCompetency::required(CompetencyId::generate(), $level);
        $requirement2 = RequiredCompetency::required(CompetencyId::generate(), $level);
        
        $this->assertFalse($requirement1->equals($requirement2));
    }
    
    public function testNotEqualsDifferentLevel(): void
    {
        $competencyId = CompetencyId::generate();
        
        $requirement1 = RequiredCompetency::required($competencyId, CompetencyLevel::beginner());
        $requirement2 = RequiredCompetency::required($competencyId, CompetencyLevel::expert());
        
        $this->assertFalse($requirement1->equals($requirement2));
    }
    
    public function testNotEqualsDifferentType(): void
    {
        $competencyId = CompetencyId::generate();
        $level = CompetencyLevel::intermediate();
        
        $requirement1 = RequiredCompetency::required($competencyId, $level);
        $requirement2 = RequiredCompetency::desired($competencyId, $level);
        
        $this->assertFalse($requirement1->equals($requirement2));
    }
} 