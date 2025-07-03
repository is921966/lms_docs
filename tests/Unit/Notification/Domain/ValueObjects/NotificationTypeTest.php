<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use Notification\Domain\ValueObjects\NotificationType;

class NotificationTypeTest extends TestCase
{
    public function testCanBeCreatedWithValidType(): void
    {
        $type = NotificationType::fromString('course_assigned');
        
        $this->assertInstanceOf(NotificationType::class, $type);
        $this->assertEquals('course_assigned', $type->getValue());
    }
    
    public function testPredefinedTypesCanBeCreated(): void
    {
        $courseAssigned = NotificationType::courseAssigned();
        $courseCompleted = NotificationType::courseCompleted();
        $programEnrolled = NotificationType::programEnrolled();
        $certificateIssued = NotificationType::certificateIssued();
        $reminderCourse = NotificationType::reminderCourse();
        $systemAnnouncement = NotificationType::systemAnnouncement();
        
        $this->assertEquals('course_assigned', $courseAssigned->getValue());
        $this->assertEquals('course_completed', $courseCompleted->getValue());
        $this->assertEquals('program_enrolled', $programEnrolled->getValue());
        $this->assertEquals('certificate_issued', $certificateIssued->getValue());
        $this->assertEquals('reminder_course', $reminderCourse->getValue());
        $this->assertEquals('system_announcement', $systemAnnouncement->getValue());
    }
    
    public function testThrowsExceptionForEmptyType(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Notification type cannot be empty');
        
        NotificationType::fromString('');
    }
    
    public function testThrowsExceptionForInvalidFormat(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid notification type format');
        
        NotificationType::fromString('Invalid Type!');
    }
    
    public function testCanBeCompared(): void
    {
        $type1 = NotificationType::fromString('course_assigned');
        $type2 = NotificationType::fromString('course_assigned');
        $type3 = NotificationType::fromString('course_completed');
        
        $this->assertTrue($type1->equals($type2));
        $this->assertFalse($type1->equals($type3));
    }
    
    public function testCanBeConvertedToString(): void
    {
        $type = NotificationType::fromString('course_assigned');
        
        $this->assertEquals('course_assigned', (string) $type);
    }
    
    public function testCanGetDisplayName(): void
    {
        $courseAssigned = NotificationType::courseAssigned();
        $systemAnnouncement = NotificationType::systemAnnouncement();
        
        $this->assertEquals('Course Assigned', $courseAssigned->getDisplayName());
        $this->assertEquals('System Announcement', $systemAnnouncement->getDisplayName());
    }
} 