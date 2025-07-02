<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Domain\ValueObjects;

use Competency\Domain\ValueObjects\AssessmentScore;
use PHPUnit\Framework\TestCase;

class AssessmentScoreTest extends TestCase
{
    public function test_it_creates_score_from_percentage(): void
    {
        $score = AssessmentScore::fromPercentage(85.5);
        
        $this->assertEquals(85.5, $score->getPercentage());
        $this->assertEquals(86, $score->getRoundedPercentage());
        $this->assertTrue($score->isPassing());
    }
    
    public function test_it_creates_score_from_points(): void
    {
        $score = AssessmentScore::fromPoints(17, 20);
        
        $this->assertEquals(17, $score->getPoints());
        $this->assertEquals(20, $score->getMaxPoints());
        $this->assertEquals(85.0, $score->getPercentage());
        $this->assertTrue($score->isPassing());
    }
    
    public function test_it_throws_exception_for_invalid_percentage(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Score percentage must be between 0 and 100');
        
        AssessmentScore::fromPercentage(101);
    }
    
    public function test_it_throws_exception_for_negative_percentage(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Score percentage must be between 0 and 100');
        
        AssessmentScore::fromPercentage(-1);
    }
    
    public function test_it_throws_exception_for_invalid_points(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Points cannot exceed max points');
        
        AssessmentScore::fromPoints(21, 20);
    }
    
    public function test_it_throws_exception_for_negative_points(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Points cannot be negative');
        
        AssessmentScore::fromPoints(-1, 20);
    }
    
    public function test_it_throws_exception_for_zero_max_points(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Max points must be greater than 0');
        
        AssessmentScore::fromPoints(0, 0);
    }
    
    public function test_it_determines_passing_scores(): void
    {
        $passing = AssessmentScore::fromPercentage(70);
        $failing = AssessmentScore::fromPercentage(69.9);
        $borderline = AssessmentScore::fromPercentage(70.0);
        
        $this->assertTrue($passing->isPassing());
        $this->assertFalse($failing->isPassing());
        $this->assertTrue($borderline->isPassing());
        
        // Custom passing threshold
        $this->assertTrue($failing->isPassing(60));
        $this->assertFalse($passing->isPassing(80));
    }
    
    public function test_it_provides_grade_letters(): void
    {
        $a = AssessmentScore::fromPercentage(95);
        $b = AssessmentScore::fromPercentage(85);
        $c = AssessmentScore::fromPercentage(75);
        $d = AssessmentScore::fromPercentage(65);
        $f = AssessmentScore::fromPercentage(55);
        
        $this->assertEquals('A', $a->getGradeLetter());
        $this->assertEquals('B', $b->getGradeLetter());
        $this->assertEquals('C', $c->getGradeLetter());
        $this->assertEquals('D', $d->getGradeLetter());
        $this->assertEquals('F', $f->getGradeLetter());
    }
    
    public function test_it_compares_scores(): void
    {
        $higher = AssessmentScore::fromPercentage(90);
        $lower = AssessmentScore::fromPercentage(80);
        $equal = AssessmentScore::fromPercentage(90.0);
        $equal2 = AssessmentScore::fromPercentage(80.0);
        
        $this->assertTrue($higher->isHigherThan($lower));
        $this->assertFalse($lower->isHigherThan($higher));
        $this->assertFalse($higher->isHigherThan($equal));
        
        $this->assertTrue($lower->isLowerThan($higher));
        $this->assertFalse($higher->isLowerThan($lower));
        $this->assertFalse($lower->isLowerThan($equal2));
        
        $this->assertTrue($higher->equals($equal));
        $this->assertFalse($higher->equals($lower));
    }
    
    public function test_it_converts_to_string(): void
    {
        $score = AssessmentScore::fromPercentage(85.7);
        
        $this->assertEquals('85.7%', (string) $score);
    }
    
    public function test_it_handles_perfect_score(): void
    {
        $perfect = AssessmentScore::fromPercentage(100);
        
        $this->assertTrue($perfect->isPerfect());
        $this->assertEquals('A', $perfect->getGradeLetter());
        
        $notPerfect = AssessmentScore::fromPercentage(99.9);
        $this->assertFalse($notPerfect->isPerfect());
    }
} 