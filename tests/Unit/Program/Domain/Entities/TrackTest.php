<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Domain\Entities;

use Program\Domain\Track;
use Program\Domain\ValueObjects\TrackId;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\TrackOrder;
use Learning\Domain\ValueObjects\CourseId;
use PHPUnit\Framework\TestCase;

class TrackTest extends TestCase
{
    public function testCanBeCreated(): void
    {
        // Arrange
        $id = TrackId::generate();
        $programId = ProgramId::generate();
        $title = 'Foundation Track';
        $description = 'Basic knowledge track';
        $order = TrackOrder::first();
        
        // Act
        $track = Track::create($id, $programId, $title, $description, $order);
        
        // Assert
        $this->assertInstanceOf(Track::class, $track);
        $this->assertTrue($id->equals($track->getId()));
        $this->assertTrue($programId->equals($track->getProgramId()));
        $this->assertEquals($title, $track->getTitle());
        $this->assertEquals($description, $track->getDescription());
        $this->assertTrue($order->equals($track->getOrder()));
        $this->assertFalse($track->isRequired());
    }
    
    public function testCanAddCourse(): void
    {
        // Arrange
        $track = $this->createTrack();
        $courseId = CourseId::generate();
        
        // Act
        $track->addCourse($courseId);
        
        // Assert
        $courses = $track->getCourseIds();
        $this->assertCount(1, $courses);
        $this->assertTrue($courseId->equals($courses[0]));
    }
    
    public function testCannotAddDuplicateCourse(): void
    {
        // Arrange
        $track = $this->createTrack();
        $courseId = CourseId::generate();
        $track->addCourse($courseId);
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Course already exists in track');
        
        // Act
        $track->addCourse($courseId);
    }
    
    public function testCanRemoveCourse(): void
    {
        // Arrange
        $track = $this->createTrack();
        $courseId = CourseId::generate();
        $track->addCourse($courseId);
        
        // Act
        $track->removeCourse($courseId);
        
        // Assert
        $this->assertCount(0, $track->getCourseIds());
    }
    
    public function testCannotRemoveNonExistentCourse(): void
    {
        // Arrange
        $track = $this->createTrack();
        $courseId = CourseId::generate();
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Course not found in track');
        
        // Act
        $track->removeCourse($courseId);
    }
    
    public function testCanUpdateBasicInfo(): void
    {
        // Arrange
        $track = $this->createTrack();
        $newTitle = 'Advanced Track';
        $newDescription = 'Advanced knowledge track';
        
        // Act
        $track->updateBasicInfo($newTitle, $newDescription);
        
        // Assert
        $this->assertEquals($newTitle, $track->getTitle());
        $this->assertEquals($newDescription, $track->getDescription());
    }
    
    public function testCannotUpdateTitleToEmpty(): void
    {
        // Arrange
        $track = $this->createTrack();
        
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Track title cannot be empty');
        
        // Act
        $track->updateBasicInfo('', 'Description');
    }
    
    public function testCanSetAsRequired(): void
    {
        // Arrange
        $track = $this->createTrack();
        
        // Act
        $track->setRequired(true);
        
        // Assert
        $this->assertTrue($track->isRequired());
    }
    
    public function testCanChangeOrder(): void
    {
        // Arrange
        $track = $this->createTrack();
        $newOrder = TrackOrder::fromInt(3);
        
        // Act
        $track->changeOrder($newOrder);
        
        // Assert
        $this->assertTrue($newOrder->equals($track->getOrder()));
    }
    
    public function testCanCheckIfEmpty(): void
    {
        // Arrange
        $track = $this->createTrack();
        
        // Assert - empty initially
        $this->assertTrue($track->isEmpty());
        
        // Act - add course
        $track->addCourse(CourseId::generate());
        
        // Assert - not empty
        $this->assertFalse($track->isEmpty());
    }
    
    public function testCanGetCourseCount(): void
    {
        // Arrange
        $track = $this->createTrack();
        
        // Assert
        $this->assertEquals(0, $track->getCourseCount());
        
        // Act
        $track->addCourse(CourseId::generate());
        $track->addCourse(CourseId::generate());
        
        // Assert
        $this->assertEquals(2, $track->getCourseCount());
    }
    
    public function testCanBeConvertedToArray(): void
    {
        // Arrange
        $track = $this->createTrack();
        $courseId = CourseId::generate();
        $track->addCourse($courseId);
        
        // Act
        $array = $track->toArray();
        
        // Assert
        $this->assertArrayHasKey('id', $array);
        $this->assertArrayHasKey('programId', $array);
        $this->assertArrayHasKey('title', $array);
        $this->assertArrayHasKey('description', $array);
        $this->assertArrayHasKey('order', $array);
        $this->assertArrayHasKey('isRequired', $array);
        $this->assertArrayHasKey('courseIds', $array);
        $this->assertCount(1, $array['courseIds']);
    }
    
    private function createTrack(): Track
    {
        return Track::create(
            TrackId::generate(),
            ProgramId::generate(),
            'Test Track',
            'Test Description',
            TrackOrder::first()
        );
    }
} 