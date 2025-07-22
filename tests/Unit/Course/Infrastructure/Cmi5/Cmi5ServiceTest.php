<?php

declare(strict_types=1);

namespace Tests\Unit\Course\Infrastructure\Cmi5;

use PHPUnit\Framework\TestCase;
use App\Course\Infrastructure\Cmi5\Cmi5Service;
use App\Course\Infrastructure\Cmi5\Cmi5Package;
use App\Course\Infrastructure\Cmi5\Cmi5CourseStructure;
use App\Course\Domain\ValueObjects\CourseId;

class Cmi5ServiceTest extends TestCase
{
    private Cmi5Service $service;
    
    protected function setUp(): void
    {
        $this->service = new Cmi5Service();
    }
    
    public function testCanImportCmi5Package(): void
    {
        // Skip this test for now - requires real ZIP file with ZipArchive extension
        $this->markTestSkipped('Requires ZipArchive extension and real CMI5 package');
    }
    
    public function testCanParseCmi5Manifest(): void
    {
        // Given
        $xmlContent = '<?xml version="1.0" encoding="UTF-8"?>
        <courseStructure xmlns="https://w3id.org/xapi/profiles/cmi5/v1/CourseStructure.xsd">
            <course id="course-123">
                <title>
                    <langstring lang="en">Sample CMI5 Course</langstring>
                </title>
                <description>
                    <langstring lang="en">A sample course for testing</langstring>
                </description>
            </course>
            <au id="au-001" moveOn="passed" masteryScore="0.8">
                <title>
                    <langstring lang="en">Introduction Module</langstring>
                </title>
                <description>
                    <langstring lang="en">Introduction to the course</langstring>
                </description>
                <url>content/intro.html</url>
            </au>
        </courseStructure>';
        
        // When
        $structure = $this->service->parseManifest($xmlContent);
        
        // Then
        $this->assertInstanceOf(Cmi5CourseStructure::class, $structure);
        $this->assertEquals('course-123', $structure->courseId());
        $this->assertEquals('Sample CMI5 Course', $structure->title());
        $this->assertCount(1, $structure->getAssignableUnits());
        
        $au = $structure->getAssignableUnits()[0];
        $this->assertEquals('au-001', $au->id());
        $this->assertEquals('Introduction Module', $au->title());
        $this->assertEquals('passed', $au->moveOn());
        $this->assertEquals(0.8, $au->masteryScore());
    }
    
    public function testCanValidateCmi5Package(): void
    {
        // Skip this test for now - requires ZipArchive extension
        $this->markTestSkipped('Requires ZipArchive extension');
    }
    
    public function testCanExtractPackageMetadata(): void
    {
        // Skip this test for now - requires real CMI5 package
        $this->markTestSkipped('Requires real CMI5 package');
    }
    
    public function testCanConvertCmi5ToCourseStructure(): void
    {
        // Given
        $cmi5Structure = new Cmi5CourseStructure(
            'course-123',
            'Test Course',
            'Test Description',
            []
        );
        $courseId = CourseId::generate();
        
        // When
        $courseData = $this->service->convertToCourseData($cmi5Structure, $courseId);
        
        // Then
        $this->assertEquals($courseId->value(), $courseData['id']);
        $this->assertEquals('Test Course', $courseData['title']);
        $this->assertEquals('Test Description', $courseData['description']);
        $this->assertArrayHasKey('modules', $courseData);
    }
} 