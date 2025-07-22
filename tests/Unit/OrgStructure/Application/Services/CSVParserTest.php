<?php
declare(strict_types=1);

namespace Tests\Unit\OrgStructure\Application\Services;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Application\Services\CSVParser;
use App\OrgStructure\Application\Exceptions\InvalidCSVException;

class CSVParserTest extends TestCase
{
    private CSVParser $parser;

    protected function setUp(): void
    {
        $this->parser = new CSVParser();
    }

    public function test_parse_valid_csv_content(): void
    {
        // Arrange
        $csvContent = "name,email,department\n" .
                     "John Doe,john@example.com,IT\n" .
                     "Jane Smith,jane@example.com,HR";

        // Act
        $result = $this->parser->parse($csvContent);

        // Assert
        $this->assertCount(2, $result);
        $this->assertEquals('John Doe', $result[0]['name']);
        $this->assertEquals('john@example.com', $result[0]['email']);
        $this->assertEquals('IT', $result[0]['department']);
    }

    public function test_parse_csv_with_different_delimiter(): void
    {
        // Arrange
        $csvContent = "name;email;department\n" .
                     "John Doe;john@example.com;IT";

        // Act
        $result = $this->parser->parse($csvContent, ';');

        // Assert
        $this->assertCount(1, $result);
        $this->assertEquals('John Doe', $result[0]['name']);
    }

    public function test_parse_csv_with_quotes(): void
    {
        // Arrange
        $csvContent = 'name,description' . "\n" .
                     '"John, Jr.","A person with, comma in name"';

        // Act
        $result = $this->parser->parse($csvContent);

        // Assert
        $this->assertEquals('John, Jr.', $result[0]['name']);
        $this->assertEquals('A person with, comma in name', $result[0]['description']);
    }

    public function test_parse_csv_with_utf8_characters(): void
    {
        // Arrange
        $csvContent = "имя,должность\n" .
                     "Иванов Иван,Разработчик\n" .
                     "Петров Пётр,Менеджер";

        // Act
        $result = $this->parser->parse($csvContent);

        // Assert
        $this->assertEquals('Иванов Иван', $result[0]['имя']);
        $this->assertEquals('Разработчик', $result[0]['должность']);
    }

    public function test_parse_empty_csv_throws_exception(): void
    {
        // Assert
        $this->expectException(InvalidCSVException::class);
        $this->expectExceptionMessage('CSV content is empty');

        // Act
        $this->parser->parse('');
    }

    public function test_parse_csv_without_headers_throws_exception(): void
    {
        // Assert
        $this->expectException(InvalidCSVException::class);
        $this->expectExceptionMessage('CSV must have headers');

        // Act
        $this->parser->parse("\n\n");
    }

    public function test_detect_delimiter(): void
    {
        // Test comma
        $this->assertEquals(',', $this->parser->detectDelimiter("a,b,c\n1,2,3"));
        
        // Test semicolon
        $this->assertEquals(';', $this->parser->detectDelimiter("a;b;c\n1;2;3"));
        
        // Test tab
        $this->assertEquals("\t", $this->parser->detectDelimiter("a\tb\tc\n1\t2\t3"));
    }

    public function test_validate_headers(): void
    {
        // Arrange
        $requiredHeaders = ['name', 'email'];
        
        // Act & Assert - valid
        $validCsv = "name,email,extra\nJohn,john@test.com,data";
        $this->assertTrue($this->parser->validateHeaders($validCsv, $requiredHeaders));
        
        // Act & Assert - invalid
        $invalidCsv = "name,phone\nJohn,12345";
        $this->assertFalse($this->parser->validateHeaders($invalidCsv, $requiredHeaders));
    }
} 