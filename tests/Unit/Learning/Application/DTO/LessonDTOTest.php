<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\DTO;

use Learning\Application\DTO\LessonDTO;
use Learning\Domain\Lesson;
use Learning\Domain\ValueObjects\ModuleId;
use Learning\Domain\ValueObjects\LessonType;
use PHPUnit\Framework\TestCase;

class LessonDTOTest extends TestCase
{
    public function testCanBeCreatedFromArray(): void
    {
        $data = [
            'id' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'moduleId' => 'm1d2e3f4-a5b6-4789-0123-456789abcdef',
            'title' => 'PHP Variables',
            'type' => 'video',
            'content' => 'https://video.url/lesson1.mp4',
            'orderIndex' => 1,
            'durationMinutes' => 15,
            'isCompleted' => false,
            'completionPercentage' => 0.0,
            'resources' => [
                'slides' => 'https://resources.url/slides.pdf',
                'code' => 'https://resources.url/examples.zip'
            ]
        ];
        
        $dto = LessonDTO::fromArray($data);
        
        $this->assertEquals($data['id'], $dto->id);
        $this->assertEquals($data['moduleId'], $dto->moduleId);
        $this->assertEquals($data['title'], $dto->title);
        $this->assertEquals($data['type'], $dto->type);
        $this->assertEquals($data['content'], $dto->content);
        $this->assertEquals($data['orderIndex'], $dto->orderIndex);
        $this->assertEquals($data['durationMinutes'], $dto->durationMinutes);
        $this->assertFalse($dto->isCompleted);
        $this->assertEquals(0.0, $dto->completionPercentage);
        $this->assertEquals($data['resources'], $dto->resources);
    }
    
    public function testCanBeCreatedFromDomainEntity(): void
    {
        $lesson = $this->createTestLesson();
        $lesson->addResource('slides.pdf', 'https://resources.url/slides.pdf');
        $lesson->addResource('examples.zip', 'https://resources.url/examples.zip');
        
        $dto = LessonDTO::fromEntity($lesson);
        
        $this->assertEquals($lesson->getId()->getValue(), $dto->id);
        $this->assertEquals($lesson->getModuleId()->getValue(), $dto->moduleId);
        $this->assertEquals($lesson->getTitle(), $dto->title);
        $this->assertEquals('video', $dto->type); // Lowercase
        $this->assertEquals($lesson->getContent(), $dto->content);
        $this->assertEquals($lesson->getOrderIndex(), $dto->orderIndex);
        $this->assertEquals($lesson->getDurationMinutes(), $dto->durationMinutes);
        $this->assertFalse($dto->isCompleted);
        $this->assertEquals(0.0, $dto->completionPercentage);
        $this->assertCount(2, $dto->resources);
    }
    
    public function testCanConvertToArray(): void
    {
        $dto = new LessonDTO(
            id: 'lesson-123',
            moduleId: 'module-456',
            title: 'Test Lesson',
            type: 'text',
            content: 'Lesson content here',
            orderIndex: 3,
            durationMinutes: 20,
            isCompleted: true,
            completionPercentage: 100.0,
            resources: ['doc' => 'https://doc.url'],
            isInteractive: false,
            isGradable: false,
            createdAt: '2024-01-01T00:00:00+00:00',
            updatedAt: '2024-01-01T00:00:00+00:00'
        );
        
        $array = $dto->toArray();
        
        $this->assertIsArray($array);
        $this->assertEquals($dto->id, $array['id']);
        $this->assertEquals($dto->title, $array['title']);
        $this->assertEquals('text', $array['type']);
        $this->assertTrue($array['isCompleted']);
        $this->assertEquals(100.0, $array['completionPercentage']);
        $this->assertFalse($array['isInteractive']);
    }
    
    public function testCanDetermineInteractiveAndGradableFromType(): void
    {
        // Video - not interactive, not gradable
        $videoDto = LessonDTO::fromArray([
            'id' => '1',
            'moduleId' => 'm1',
            'title' => 'Video',
            'type' => 'video',
            'content' => 'url',
            'orderIndex' => 1,
            'durationMinutes' => 10
        ]);
        $this->assertFalse($videoDto->isInteractive);
        $this->assertFalse($videoDto->isGradable);
        
        // Quiz - interactive and gradable
        $quizDto = LessonDTO::fromArray([
            'id' => '2',
            'moduleId' => 'm1',
            'title' => 'Quiz',
            'type' => 'quiz',
            'content' => 'questions',
            'orderIndex' => 2,
            'durationMinutes' => 15
        ]);
        $this->assertTrue($quizDto->isInteractive);
        $this->assertTrue($quizDto->isGradable);
    }
    
    private function createTestLesson(): Lesson
    {
        return Lesson::create(
            moduleId: ModuleId::generate(),
            title: 'Test Lesson',
            type: LessonType::VIDEO,
            content: 'https://video.url/test.mp4',
            orderIndex: 1,
            durationMinutes: 30
        );
    }
} 