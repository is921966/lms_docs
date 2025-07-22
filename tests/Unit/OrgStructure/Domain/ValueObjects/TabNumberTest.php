<?php
declare(strict_types=1);

namespace Tests\Unit\OrgStructure\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Domain\ValueObjects\TabNumber;
use App\OrgStructure\Domain\Exceptions\InvalidTabNumberException;

class TabNumberTest extends TestCase
{
    public function test_create_valid_tab_number(): void
    {
        // Arrange & Act
        $tabNumber = new TabNumber('12345');

        // Assert
        $this->assertEquals('12345', $tabNumber->getValue());
    }

    public function test_tab_number_cannot_be_empty(): void
    {
        // Assert
        $this->expectException(InvalidTabNumberException::class);
        $this->expectExceptionMessage('Tab number cannot be empty');

        // Act
        new TabNumber('');
    }

    public function test_tab_number_cannot_contain_only_spaces(): void
    {
        // Assert
        $this->expectException(InvalidTabNumberException::class);
        $this->expectExceptionMessage('Tab number cannot be empty');

        // Act
        new TabNumber('   ');
    }

    public function test_tab_number_is_trimmed(): void
    {
        // Act
        $tabNumber = new TabNumber('  12345  ');

        // Assert
        $this->assertEquals('12345', $tabNumber->getValue());
    }

    public function test_equals_returns_true_for_same_value(): void
    {
        // Arrange
        $tabNumber1 = new TabNumber('12345');
        $tabNumber2 = new TabNumber('12345');

        // Act & Assert
        $this->assertTrue($tabNumber1->equals($tabNumber2));
    }

    public function test_equals_returns_false_for_different_values(): void
    {
        // Arrange
        $tabNumber1 = new TabNumber('12345');
        $tabNumber2 = new TabNumber('54321');

        // Act & Assert
        $this->assertFalse($tabNumber1->equals($tabNumber2));
    }
} 