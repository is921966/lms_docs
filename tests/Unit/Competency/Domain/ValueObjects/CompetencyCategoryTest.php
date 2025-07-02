<?php

namespace Tests\Unit\Competency\Domain\ValueObjects;

use Tests\TestCase;
use Competency\Domain\ValueObjects\CompetencyCategory;

class CompetencyCategoryTest extends TestCase
{
    /**
     * @test
     */
    public function it_creates_category_from_valid_values(): void
    {
        $technical = CompetencyCategory::fromString('technical');
        $this->assertEquals('technical', $technical->getValue());
        $this->assertEquals('Technical', $technical->getDisplayName());
        
        $soft = CompetencyCategory::fromString('soft');
        $this->assertEquals('soft', $soft->getValue());
        $this->assertEquals('Soft Skills', $soft->getDisplayName());
    }
    
    /**
     * @test
     */
    public function it_provides_predefined_categories(): void
    {
        $technical = CompetencyCategory::technical();
        $this->assertEquals('technical', $technical->getValue());
        
        $soft = CompetencyCategory::soft();
        $this->assertEquals('soft', $soft->getValue());
        
        $leadership = CompetencyCategory::leadership();
        $this->assertEquals('leadership', $leadership->getValue());
        
        $business = CompetencyCategory::business();
        $this->assertEquals('business', $business->getValue());
    }
    
    /**
     * @test
     */
    public function it_validates_category_value(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid competency category: invalid');
        
        CompetencyCategory::fromString('invalid');
    }
    
    /**
     * @test
     */
    public function it_returns_all_valid_categories(): void
    {
        $categories = CompetencyCategory::validCategories();
        
        $this->assertContains('technical', $categories);
        $this->assertContains('soft', $categories);
        $this->assertContains('leadership', $categories);
        $this->assertContains('business', $categories);
        $this->assertCount(4, $categories);
    }
    
    /**
     * @test
     */
    public function it_compares_categories(): void
    {
        $tech1 = CompetencyCategory::technical();
        $tech2 = CompetencyCategory::fromString('technical');
        $soft = CompetencyCategory::soft();
        
        $this->assertTrue($tech1->equals($tech2));
        $this->assertFalse($tech1->equals($soft));
    }
    
    /**
     * @test
     */
    public function it_provides_color_for_category(): void
    {
        $technical = CompetencyCategory::technical();
        $this->assertEquals('#3B82F6', $technical->getColor()); // Blue
        
        $soft = CompetencyCategory::soft();
        $this->assertEquals('#10B981', $soft->getColor()); // Green
        
        $leadership = CompetencyCategory::leadership();
        $this->assertEquals('#8B5CF6', $leadership->getColor()); // Purple
        
        $business = CompetencyCategory::business();
        $this->assertEquals('#F59E0B', $business->getColor()); // Amber
    }
} 