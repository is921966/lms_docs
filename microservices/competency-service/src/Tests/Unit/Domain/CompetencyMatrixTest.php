<?php

namespace CompetencyService\Tests\Unit\Domain;

use PHPUnit\Framework\TestCase;
use CompetencyService\Domain\Entities\CompetencyMatrix;
use CompetencyService\Domain\ValueObjects\MatrixId;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\MatrixRequirement;

class CompetencyMatrixTest extends TestCase
{
    public function testCreateMatrix(): void
    {
        // Arrange
        $id = MatrixId::generate();
        $positionId = 'position-123';
        $name = 'Senior Developer Matrix';
        
        // Act
        $matrix = new CompetencyMatrix($id, $positionId, $name);
        
        // Assert
        $this->assertEquals($id, $matrix->getId());
        $this->assertEquals($positionId, $matrix->getPositionId());
        $this->assertEquals($name, $matrix->getName());
        $this->assertEmpty($matrix->getRequirements());
        $this->assertTrue($matrix->isActive());
    }
    
    public function testAddRequirement(): void
    {
        // Arrange
        $matrix = $this->createMatrix();
        $competencyId = CompetencyId::generate();
        $requirement = new MatrixRequirement(
            $competencyId,
            3, // required level
            'core' // type: core, nice-to-have, optional
        );
        
        // Act
        $matrix->addRequirement($requirement);
        
        // Assert
        $requirements = $matrix->getRequirements();
        $this->assertCount(1, $requirements);
        $this->assertEquals($requirement, $requirements[0]);
    }
    
    public function testGetCoreCompetencies(): void
    {
        // Arrange
        $matrix = $this->createMatrix();
        
        $coreReq = new MatrixRequirement(CompetencyId::generate(), 3, 'core');
        $niceToHaveReq = new MatrixRequirement(CompetencyId::generate(), 2, 'nice-to-have');
        $optionalReq = new MatrixRequirement(CompetencyId::generate(), 1, 'optional');
        
        $matrix->addRequirement($coreReq);
        $matrix->addRequirement($niceToHaveReq);
        $matrix->addRequirement($optionalReq);
        
        // Act
        $coreCompetencies = $matrix->getCoreCompetencies();
        
        // Assert
        $this->assertCount(1, $coreCompetencies);
        $this->assertEquals($coreReq, $coreCompetencies[0]);
    }
    
    public function testRemoveRequirement(): void
    {
        // Arrange
        $matrix = $this->createMatrix();
        $competencyId = CompetencyId::generate();
        $requirement = new MatrixRequirement($competencyId, 3, 'core');
        
        $matrix->addRequirement($requirement);
        
        // Act
        $matrix->removeRequirement($competencyId);
        
        // Assert
        $this->assertEmpty($matrix->getRequirements());
    }
    
    public function testCalculateCompleteness(): void
    {
        // Arrange
        $matrix = $this->createMatrix();
        
        // Add 3 core and 2 nice-to-have requirements
        for ($i = 0; $i < 3; $i++) {
            $matrix->addRequirement(new MatrixRequirement(
                CompetencyId::generate(),
                3,
                'core'
            ));
        }
        
        for ($i = 0; $i < 2; $i++) {
            $matrix->addRequirement(new MatrixRequirement(
                CompetencyId::generate(),
                2,
                'nice-to-have'
            ));
        }
        
        // Act - simulate user assessments
        $userAssessments = [
            // 2 core competencies met
            ['competency_id' => $matrix->getRequirements()[0]->getCompetencyId()->toString(), 'level' => 3],
            ['competency_id' => $matrix->getRequirements()[1]->getCompetencyId()->toString(), 'level' => 3],
            // 1 nice-to-have met
            ['competency_id' => $matrix->getRequirements()[3]->getCompetencyId()->toString(), 'level' => 2],
        ];
        
        $completeness = $matrix->calculateCompleteness($userAssessments);
        
        // Assert
        $this->assertEquals(66.67, $completeness['core_percentage']); // 2/3 = 66.67%
        $this->assertEquals(50.0, $completeness['nice_to_have_percentage']); // 1/2 = 50%
        $this->assertEquals(60.0, $completeness['overall_percentage']); // 3/5 = 60%
    }
    
    private function createMatrix(): CompetencyMatrix
    {
        return new CompetencyMatrix(
            MatrixId::generate(),
            'position-123',
            'Test Matrix'
        );
    }
} 