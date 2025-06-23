<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use App\Learning\Domain\ValueObjects\CourseCode;
use PHPUnit\Framework\TestCase;

class CourseCodeTest extends TestCase
{
    public function testCanBeCreatedFromValidCode(): void
    {
        $code = CourseCode::fromString('CRS-001');
        
        $this->assertInstanceOf(CourseCode::class, $code);
        $this->assertEquals('CRS-001', $code->toString());
    }
    
    public function testAcceptsVariousValidFormats(): void
    {
        $validCodes = [
            'CRS-001',
            'CRS-999',
            'TECH-101',
            'MGMT-042',
            'DEV-2023'
        ];
        
        foreach ($validCodes as $validCode) {
            $code = CourseCode::fromString($validCode);
            $this->assertEquals($validCode, $code->toString());
        }
    }
    
    public function testThrowsExceptionForInvalidFormat(): void
    {
        $invalidCodes = [
            'CRS001',      // Missing hyphen
            'crs-001',     // Lowercase
            'C-001',       // Too short prefix
            'COURSE-001',  // Too long prefix
            'CRS-',        // Missing number
            'CRS-00',      // Too short number
            'CRS-ABC',     // Letters in number part
            '-001',        // Missing prefix
            'CRS--001',    // Double hyphen
            ''             // Empty string
        ];
        
        foreach ($invalidCodes as $invalidCode) {
            try {
                CourseCode::fromString($invalidCode);
                $this->fail("Expected exception for invalid code: $invalidCode");
            } catch (\InvalidArgumentException $e) {
                $this->assertStringContainsString('Invalid course code format', $e->getMessage());
            }
        }
    }
    
    public function testCanBeCompared(): void
    {
        $code1 = CourseCode::fromString('CRS-001');
        $code2 = CourseCode::fromString('CRS-001');
        $code3 = CourseCode::fromString('CRS-002');
        
        $this->assertTrue($code1->equals($code2));
        $this->assertFalse($code1->equals($code3));
    }
    
    public function testCanBeSerializedToJson(): void
    {
        $code = CourseCode::fromString('CRS-001');
        $json = json_encode(['code' => $code]);
        
        $this->assertJson($json);
        $decoded = json_decode($json, true);
        $this->assertEquals('CRS-001', $decoded['code']);
    }
    
    public function testCanBeUsedAsString(): void
    {
        $code = CourseCode::fromString('CRS-001');
        
        $this->assertEquals('CRS-001', (string)$code);
    }
} 