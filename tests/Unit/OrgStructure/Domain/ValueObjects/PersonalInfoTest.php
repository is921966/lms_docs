<?php
declare(strict_types=1);

namespace Tests\Unit\OrgStructure\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Domain\ValueObjects\PersonalInfo;
use App\OrgStructure\Domain\Exceptions\InvalidPersonalInfoException;

class PersonalInfoTest extends TestCase
{
    public function test_create_personal_info_with_all_data(): void
    {
        // Act
        $info = PersonalInfo::create(
            'Иванов Иван Иванович',
            'ivanov@company.ru',
            '+7 (999) 123-45-67'
        );

        // Assert
        $this->assertEquals('Иванов Иван Иванович', $info->getFullName());
        $this->assertEquals('ivanov@company.ru', $info->getEmail());
        $this->assertEquals('+7 (999) 123-45-67', $info->getPhone());
    }

    public function test_create_personal_info_without_optional_fields(): void
    {
        // Act
        $info = PersonalInfo::create('Петров Петр Петрович', null, null);

        // Assert
        $this->assertEquals('Петров Петр Петрович', $info->getFullName());
        $this->assertNull($info->getEmail());
        $this->assertNull($info->getPhone());
    }

    public function test_full_name_cannot_be_empty(): void
    {
        // Assert
        $this->expectException(InvalidPersonalInfoException::class);
        $this->expectExceptionMessage('Full name cannot be empty');

        // Act
        PersonalInfo::create('', 'test@example.com', null);
    }

    public function test_email_must_be_valid_format(): void
    {
        // Assert
        $this->expectException(InvalidPersonalInfoException::class);
        $this->expectExceptionMessage('Invalid email format');

        // Act
        PersonalInfo::create('Test User', 'invalid-email', null);
    }

    public function test_full_name_is_trimmed(): void
    {
        // Act
        $info = PersonalInfo::create('  Сидоров Сидор Сидорович  ', null, null);

        // Assert
        $this->assertEquals('Сидоров Сидор Сидорович', $info->getFullName());
    }

    public function test_equals_returns_true_for_same_data(): void
    {
        // Arrange
        $info1 = PersonalInfo::create('Test User', 'test@example.com', '+1234567890');
        $info2 = PersonalInfo::create('Test User', 'test@example.com', '+1234567890');

        // Act & Assert
        $this->assertTrue($info1->equals($info2));
    }

    public function test_equals_returns_false_for_different_names(): void
    {
        // Arrange
        $info1 = PersonalInfo::create('User One', 'test@example.com', '+1234567890');
        $info2 = PersonalInfo::create('User Two', 'test@example.com', '+1234567890');

        // Act & Assert
        $this->assertFalse($info1->equals($info2));
    }
} 