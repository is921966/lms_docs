<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use App\Learning\Domain\ValueObjects\CourseStatus;
use PHPUnit\Framework\TestCase;

class CourseStatusTest extends TestCase
{
    public function testCanBeCreatedFromValidStatus(): void
    {
        $draft = CourseStatus::DRAFT;
        $published = CourseStatus::PUBLISHED;
        $archived = CourseStatus::ARCHIVED;
        
        $this->assertEquals('DRAFT', $draft->value);
        $this->assertEquals('PUBLISHED', $published->value);
        $this->assertEquals('ARCHIVED', $archived->value);
    }
    
    public function testCanGetAllValues(): void
    {
        $values = CourseStatus::values();
        
        $this->assertCount(3, $values);
        $this->assertContains('DRAFT', $values);
        $this->assertContains('PUBLISHED', $values);
        $this->assertContains('ARCHIVED', $values);
    }
    
    public function testCanGetLabel(): void
    {
        $this->assertEquals('Draft', CourseStatus::DRAFT->getLabel());
        $this->assertEquals('Published', CourseStatus::PUBLISHED->getLabel());
        $this->assertEquals('Archived', CourseStatus::ARCHIVED->getLabel());
    }
    
    public function testCanCheckIfActive(): void
    {
        $this->assertFalse(CourseStatus::DRAFT->isActive());
        $this->assertTrue(CourseStatus::PUBLISHED->isActive());
        $this->assertFalse(CourseStatus::ARCHIVED->isActive());
    }
    
    public function testCanCheckIfEditable(): void
    {
        $this->assertTrue(CourseStatus::DRAFT->isEditable());
        $this->assertFalse(CourseStatus::PUBLISHED->isEditable());
        $this->assertFalse(CourseStatus::ARCHIVED->isEditable());
    }
    
    public function testCanGetAllowedTransitions(): void
    {
        $draftTransitions = CourseStatus::DRAFT->getAllowedTransitions();
        $this->assertCount(1, $draftTransitions);
        $this->assertContains(CourseStatus::PUBLISHED, $draftTransitions);
        
        $publishedTransitions = CourseStatus::PUBLISHED->getAllowedTransitions();
        $this->assertCount(2, $publishedTransitions);
        $this->assertContains(CourseStatus::DRAFT, $publishedTransitions);
        $this->assertContains(CourseStatus::ARCHIVED, $publishedTransitions);
        
        $archivedTransitions = CourseStatus::ARCHIVED->getAllowedTransitions();
        $this->assertCount(1, $archivedTransitions);
        $this->assertContains(CourseStatus::DRAFT, $archivedTransitions);
    }
    
    public function testCanCheckAllowedTransition(): void
    {
        $draft = CourseStatus::DRAFT;
        
        $this->assertTrue($draft->canTransitionTo(CourseStatus::PUBLISHED));
        $this->assertFalse($draft->canTransitionTo(CourseStatus::ARCHIVED));
        $this->assertFalse($draft->canTransitionTo(CourseStatus::DRAFT));
    }
} 