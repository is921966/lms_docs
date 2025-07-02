<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Domain\ValueObjects;

use Program\Domain\ValueObjects\ProgramCode;
use PHPUnit\Framework\TestCase;

class ProgramCodeTest extends TestCase
{
    public function testCanBeCreatedFromValidString(): void
    {
        // Arrange
        $code = 'PROG-001';
        
        // Act
        $programCode = ProgramCode::fromString($code);
        
        // Assert
        $this->assertInstanceOf(ProgramCode::class, $programCode);
        $this->assertEquals($code, $programCode->getValue());
    }
    
    public function testThrowsExceptionForEmptyCode(): void
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Program code cannot be empty');
        
        // Act
        ProgramCode::fromString('');
    }
    
    public function testThrowsExceptionForInvalidFormat(): void
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid program code format');
        
        // Act
        ProgramCode::fromString('invalid-code');
    }
    
    public function testAcceptsValidFormats(): void
    {
        // Arrange & Act & Assert
        $validCodes = [
            'PROG-001',
            'PROG-999',
            'LEAD-101',
            'MGMT-001',
            'TECH-500'
        ];
        
        foreach ($validCodes as $code) {
            $programCode = ProgramCode::fromString($code);
            $this->assertEquals($code, $programCode->getValue());
        }
    }
    
    public function testCanBeCompared(): void
    {
        // Arrange
        $code1 = ProgramCode::fromString('PROG-001');
        $code2 = ProgramCode::fromString('PROG-001');
        $code3 = ProgramCode::fromString('PROG-002');
        
        // Act & Assert
        $this->assertTrue($code1->equals($code2));
        $this->assertFalse($code1->equals($code3));
    }
    
    public function testCanBeConvertedToString(): void
    {
        // Arrange
        $code = 'PROG-001';
        $programCode = ProgramCode::fromString($code);
        
        // Act & Assert
        $this->assertEquals($code, (string)$programCode);
        $this->assertEquals($code, $programCode->toString());
    }
    
    public function testIsJsonSerializable(): void
    {
        // Arrange
        $code = 'PROG-001';
        $programCode = ProgramCode::fromString($code);
        
        // Act
        $json = json_encode(['code' => $programCode]);
        
        // Assert
        $this->assertEquals('{"code":"' . $code . '"}', $json);
    }
} 