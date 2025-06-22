<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Domain\ValueObjects;

use App\Competency\Domain\ValueObjects\CompetencyCode;
use PHPUnit\Framework\TestCase;

class CompetencyCodeTest extends TestCase
{
    public function test_it_creates_valid_code(): void
    {
        $code = new CompetencyCode('TECH-PHP-001');
        
        $this->assertEquals('TECH-PHP-001', $code->getValue());
        $this->assertEquals('TECH-PHP-001', (string) $code);
    }
    
    public function test_it_normalizes_code_to_uppercase(): void
    {
        $code = new CompetencyCode('tech-php-001');
        
        $this->assertEquals('TECH-PHP-001', $code->getValue());
    }
    
    public function test_it_trims_whitespace(): void
    {
        $code = new CompetencyCode('  TECH-PHP-001  ');
        
        $this->assertEquals('TECH-PHP-001', $code->getValue());
    }
    
    public function test_it_throws_exception_for_empty_code(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Competency code cannot be empty');
        
        new CompetencyCode('');
    }
    
    public function test_it_throws_exception_for_whitespace_only_code(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Competency code cannot be empty');
        
        new CompetencyCode('   ');
    }
    
    public function test_it_throws_exception_for_too_long_code(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Competency code cannot exceed 50 characters');
        
        new CompetencyCode(str_repeat('A', 51));
    }
    
    public function test_it_validates_code_format(): void
    {
        // Valid formats
        $this->assertInstanceOf(CompetencyCode::class, new CompetencyCode('TECH-001'));
        $this->assertInstanceOf(CompetencyCode::class, new CompetencyCode('SOFT-COMM-01'));
        $this->assertInstanceOf(CompetencyCode::class, new CompetencyCode('LEAD_MGT_001'));
        $this->assertInstanceOf(CompetencyCode::class, new CompetencyCode('BUS.FIN.2024.01'));
    }
    
    public function test_it_throws_exception_for_invalid_characters(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Competency code contains invalid characters');
        
        new CompetencyCode('TECH@PHP#001');
    }
    
    public function test_it_throws_exception_for_spaces_in_code(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Competency code contains invalid characters');
        
        new CompetencyCode('TECH PHP 001');
    }
    
    public function test_it_compares_codes(): void
    {
        $code1 = new CompetencyCode('TECH-PHP-001');
        $code2 = new CompetencyCode('TECH-PHP-001');
        $code3 = new CompetencyCode('TECH-PHP-002');
        
        $this->assertTrue($code1->equals($code2));
        $this->assertFalse($code1->equals($code3));
    }
    
    public function test_it_extracts_parts(): void
    {
        $code = new CompetencyCode('TECH-PHP-001');
        
        $this->assertEquals('TECH', $code->getPrefix());
        $this->assertEquals('PHP', $code->getCategory());
        $this->assertEquals('001', $code->getSequence());
    }
    
    public function test_it_generates_next_sequence(): void
    {
        $code = new CompetencyCode('TECH-PHP-001');
        $next = $code->nextSequence();
        
        $this->assertEquals('TECH-PHP-002', $next->getValue());
        
        // Test with larger numbers
        $code99 = new CompetencyCode('TECH-PHP-099');
        $next100 = $code99->nextSequence();
        
        $this->assertEquals('TECH-PHP-100', $next100->getValue());
    }
} 