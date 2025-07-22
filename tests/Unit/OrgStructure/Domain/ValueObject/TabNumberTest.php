<?php

namespace Tests\Unit\OrgStructure\Domain\ValueObject;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Domain\ValueObject\TabNumber;
use App\OrgStructure\Domain\Exception\InvalidTabNumberException;

class TabNumberTest extends TestCase
{
    /** @test */
    public function it_creates_valid_tab_number(): void
    {
        // Arrange & Act
        $tabNumber = new TabNumber('АР21000612');
        
        // Assert
        $this->assertEquals('АР21000612', $tabNumber->getValue());
        $this->assertEquals('АР21000612', (string)$tabNumber);
    }
    
    /** @test */
    public function it_validates_tab_number_format(): void
    {
        // Arrange
        $validNumbers = [
            'АР21000612',
            'АР00000001',
            'АР99999999',
            'АР12345678',
        ];
        
        // Act & Assert
        foreach ($validNumbers as $validNumber) {
            $tabNumber = new TabNumber($validNumber);
            $this->assertEquals($validNumber, $tabNumber->getValue());
        }
    }
    
    /** @test */
    public function it_throws_exception_for_invalid_format(): void
    {
        // Arrange
        $invalidNumbers = [
            '',
            'AP21000612', // Latin letters
            'АР2100061', // Too short
            'АР210006123', // Too long
            'АР2100061A', // Contains letter
            'АP21000612', // Mixed Cyrillic and Latin
            '2100612', // Missing prefix
            'АР', // Missing numbers
            'БР21000612', // Wrong prefix
            'ар21000612', // Lowercase
            'АР 21000612', // Contains space
            'АР-21000612', // Contains dash
        ];
        
        // Act & Assert
        foreach ($invalidNumbers as $invalidNumber) {
            try {
                new TabNumber($invalidNumber);
                $this->fail("Expected exception for tab number: $invalidNumber");
            } catch (InvalidTabNumberException $e) {
                $this->assertStringContainsString('Invalid tab number format', $e->getMessage());
            }
        }
    }
    
    /** @test */
    public function it_can_get_numeric_part(): void
    {
        // Arrange
        $tabNumber = new TabNumber('АР21000612');
        
        // Act
        $numericPart = $tabNumber->getNumericPart();
        
        // Assert
        $this->assertEquals('21000612', $numericPart);
    }
    
    /** @test */
    public function it_can_check_equality(): void
    {
        // Arrange
        $tabNumber1 = new TabNumber('АР21000612');
        $tabNumber2 = new TabNumber('АР21000612');
        $tabNumber3 = new TabNumber('АР21000613');
        
        // Act & Assert
        $this->assertTrue($tabNumber1->equals($tabNumber2));
        $this->assertFalse($tabNumber1->equals($tabNumber3));
    }
    
    /** @test */
    public function it_normalizes_input(): void
    {
        // Tab numbers should be uppercase and trimmed
        $tabNumber = new TabNumber('  АР21000612  ');
        
        $this->assertEquals('АР21000612', $tabNumber->getValue());
    }
    
    /** @test */
    public function it_can_be_used_as_array_key(): void
    {
        // Arrange
        $tabNumber = new TabNumber('АР21000612');
        $data = [];
        
        // Act
        $data[(string)$tabNumber] = 'Employee Data';
        
        // Assert
        $this->assertArrayHasKey('АР21000612', $data);
        $this->assertEquals('Employee Data', $data['АР21000612']);
    }
} 