<?php

namespace Tests\Unit\Competency\Domain\ValueObjects;

use Tests\TestCase;
use App\Competency\Domain\ValueObjects\CompetencyId;

class CompetencyIdTest extends TestCase
{
    /**
     * @test
     */
    public function it_creates_competency_id_from_string(): void
    {
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $competencyId = new CompetencyId($uuid);
        
        $this->assertEquals($uuid, $competencyId->getValue());
        $this->assertEquals($uuid, (string) $competencyId);
    }
    
    /**
     * @test
     */
    public function it_generates_new_competency_id(): void
    {
        $competencyId = CompetencyId::generate();
        
        $this->assertInstanceOf(CompetencyId::class, $competencyId);
        $this->assertNotEmpty($competencyId->getValue());
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i',
            $competencyId->getValue()
        );
    }
    
    /**
     * @test
     */
    public function it_validates_uuid_format(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid UUID format');
        
        new CompetencyId('invalid-uuid');
    }
    
    /**
     * @test
     */
    public function it_compares_competency_ids(): void
    {
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $id1 = new CompetencyId($uuid);
        $id2 = new CompetencyId($uuid);
        $id3 = CompetencyId::generate();
        
        $this->assertTrue($id1->equals($id2));
        $this->assertFalse($id1->equals($id3));
    }
} 