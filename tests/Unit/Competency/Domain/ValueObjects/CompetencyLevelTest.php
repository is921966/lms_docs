<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Domain\ValueObjects;

use App\Competency\Domain\ValueObjects\CompetencyLevel;
use PHPUnit\Framework\TestCase;

class CompetencyLevelTest extends TestCase
{
    public function test_it_creates_beginner_level(): void
    {
        $level = CompetencyLevel::beginner();
        
        $this->assertEquals(1, $level->getValue());
        $this->assertEquals('Beginner', $level->getName());
        $this->assertEquals('Basic knowledge, requires supervision', $level->getDescription());
    }
    
    public function test_it_creates_elementary_level(): void
    {
        $level = CompetencyLevel::elementary();
        
        $this->assertEquals(2, $level->getValue());
        $this->assertEquals('Elementary', $level->getName());
        $this->assertEquals('Can perform simple tasks independently', $level->getDescription());
    }
    
    public function test_it_creates_intermediate_level(): void
    {
        $level = CompetencyLevel::intermediate();
        
        $this->assertEquals(3, $level->getValue());
        $this->assertEquals('Intermediate', $level->getName());
        $this->assertEquals('Can handle standard tasks and solve common problems', $level->getDescription());
    }
    
    public function test_it_creates_advanced_level(): void
    {
        $level = CompetencyLevel::advanced();
        
        $this->assertEquals(4, $level->getValue());
        $this->assertEquals('Advanced', $level->getName());
        $this->assertEquals('Can handle complex tasks and mentor others', $level->getDescription());
    }
    
    public function test_it_creates_expert_level(): void
    {
        $level = CompetencyLevel::expert();
        
        $this->assertEquals(5, $level->getValue());
        $this->assertEquals('Expert', $level->getName());
        $this->assertEquals('Deep expertise, can innovate and lead initiatives', $level->getDescription());
    }
    
    public function test_it_creates_from_value(): void
    {
        $level = CompetencyLevel::fromValue(3);
        
        $this->assertEquals(3, $level->getValue());
        $this->assertEquals('Intermediate', $level->getName());
    }
    
    public function test_it_throws_exception_for_invalid_value(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid competency level: 6. Valid levels are 1-5');
        
        CompetencyLevel::fromValue(6);
    }
    
    public function test_it_compares_levels(): void
    {
        $beginner = CompetencyLevel::beginner();
        $intermediate = CompetencyLevel::intermediate();
        $expert = CompetencyLevel::expert();
        
        $this->assertTrue($beginner->isLowerThan($intermediate));
        $this->assertTrue($intermediate->isLowerThan($expert));
        $this->assertFalse($expert->isLowerThan($intermediate));
        
        $this->assertTrue($expert->isHigherThan($intermediate));
        $this->assertTrue($intermediate->isHigherThan($beginner));
        $this->assertFalse($beginner->isHigherThan($intermediate));
        
        $this->assertTrue($intermediate->equals(CompetencyLevel::intermediate()));
        $this->assertFalse($intermediate->equals($beginner));
    }
    
    public function test_it_checks_if_meets_required_level(): void
    {
        $currentLevel = CompetencyLevel::intermediate();
        $requiredLevel = CompetencyLevel::elementary();
        $higherRequiredLevel = CompetencyLevel::advanced();
        
        $this->assertTrue($currentLevel->meetsRequirement($requiredLevel));
        $this->assertFalse($currentLevel->meetsRequirement($higherRequiredLevel));
        $this->assertTrue($currentLevel->meetsRequirement($currentLevel));
    }
    
    public function test_it_converts_to_string(): void
    {
        $level = CompetencyLevel::advanced();
        
        $this->assertEquals('Advanced (4)', (string) $level);
    }
    
    public function test_it_provides_all_levels(): void
    {
        $levels = CompetencyLevel::getAllLevels();
        
        $this->assertCount(5, $levels);
        $this->assertEquals(1, $levels[0]->getValue());
        $this->assertEquals(5, $levels[4]->getValue());
    }
    
    public function test_it_calculates_gap(): void
    {
        $current = CompetencyLevel::elementary();
        $required = CompetencyLevel::advanced();
        
        $this->assertEquals(2, $current->gapTo($required));
        $this->assertEquals(-2, $required->gapTo($current));
        $this->assertEquals(0, $current->gapTo($current));
    }
} 