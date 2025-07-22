<?php
declare(strict_types=1);

namespace Tests\Unit\OrgStructure\Domain\Models;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Domain\Models\Position;
use App\OrgStructure\Domain\ValueObjects\PositionId;
use App\OrgStructure\Domain\Exceptions\InvalidPositionException;

class PositionTest extends TestCase
{
    public function test_create_position_with_valid_data(): void
    {
        // Arrange
        $id = PositionId::generate();
        $title = 'Senior Developer';
        $category = 'Technical';

        // Act
        $position = new Position($id, $title, $category);

        // Assert
        $this->assertEquals($id, $position->getId());
        $this->assertEquals($title, $position->getTitle());
        $this->assertEquals($category, $position->getCategory());
        $this->assertEmpty($position->getRequiredCompetencies());
    }

    public function test_position_title_cannot_be_empty(): void
    {
        // Assert
        $this->expectException(InvalidPositionException::class);
        $this->expectExceptionMessage('Position title cannot be empty');

        // Act
        new Position(PositionId::generate(), '', 'Technical');
    }

    public function test_create_position_from_csv_data(): void
    {
        // Arrange
        $csvData = [
            'position' => 'Product Manager',
            'category' => 'Management',
            'level' => 'Senior',
            'department' => 'Product'
        ];

        // Act
        $position = Position::createFromCsvData($csvData);

        // Assert
        $this->assertEquals('Product Manager', $position->getTitle());
        $this->assertEquals('Management', $position->getCategory());
        $this->assertArrayHasKey('level', $position->getMetadata());
    }

    public function test_add_required_competency(): void
    {
        // Arrange
        $position = new Position(
            PositionId::generate(),
            'Developer',
            'Technical'
        );
        $competencyId = 'comp-123';

        // Act
        $position->addRequiredCompetency($competencyId);

        // Assert
        $this->assertContains($competencyId, $position->getRequiredCompetencies());
    }

    public function test_cannot_add_duplicate_competency(): void
    {
        // Arrange
        $position = new Position(
            PositionId::generate(),
            'Developer', 
            'Technical'
        );
        $competencyId = 'comp-123';

        // Act
        $position->addRequiredCompetency($competencyId);
        $position->addRequiredCompetency($competencyId); // Try to add again

        // Assert
        $this->assertCount(1, $position->getRequiredCompetencies());
    }
} 