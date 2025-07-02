<?php

declare(strict_types=1);

namespace Program\Domain;

use Program\Domain\ValueObjects\TrackId;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\TrackOrder;
use Learning\Domain\ValueObjects\CourseId;

class Track
{
    private TrackId $id;
    private ProgramId $programId;
    private string $title;
    private string $description;
    private TrackOrder $order;
    private bool $isRequired;
    /** @var CourseId[] */
    private array $courseIds = [];
    
    private function __construct(
        TrackId $id,
        ProgramId $programId,
        string $title,
        string $description,
        TrackOrder $order
    ) {
        $this->id = $id;
        $this->programId = $programId;
        $this->setTitle($title);
        $this->description = $description;
        $this->order = $order;
        $this->isRequired = false;
    }
    
    public static function create(
        TrackId $id,
        ProgramId $programId,
        string $title,
        string $description,
        TrackOrder $order
    ): self {
        return new self($id, $programId, $title, $description, $order);
    }
    
    public function addCourse(CourseId $courseId): void
    {
        if ($this->hasCourse($courseId)) {
            throw new \DomainException('Course already exists in track');
        }
        
        $this->courseIds[] = $courseId;
    }
    
    public function removeCourse(CourseId $courseId): void
    {
        $key = $this->findCourseKey($courseId);
        
        if ($key === null) {
            throw new \DomainException('Course not found in track');
        }
        
        unset($this->courseIds[$key]);
        $this->courseIds = array_values($this->courseIds);
    }
    
    public function updateBasicInfo(string $title, string $description): void
    {
        $this->setTitle($title);
        $this->description = $description;
    }
    
    public function setRequired(bool $isRequired): void
    {
        $this->isRequired = $isRequired;
    }
    
    public function changeOrder(TrackOrder $order): void
    {
        $this->order = $order;
    }
    
    public function isEmpty(): bool
    {
        return count($this->courseIds) === 0;
    }
    
    public function getCourseCount(): int
    {
        return count($this->courseIds);
    }
    
    private function setTitle(string $title): void
    {
        if (empty($title)) {
            throw new \InvalidArgumentException('Track title cannot be empty');
        }
        
        $this->title = $title;
    }
    
    private function hasCourse(CourseId $courseId): bool
    {
        return $this->findCourseKey($courseId) !== null;
    }
    
    private function findCourseKey(CourseId $courseId): ?int
    {
        foreach ($this->courseIds as $key => $existingCourseId) {
            if ($existingCourseId->equals($courseId)) {
                return $key;
            }
        }
        
        return null;
    }
    
    // Getters
    public function getId(): TrackId
    {
        return $this->id;
    }
    
    public function getProgramId(): ProgramId
    {
        return $this->programId;
    }
    
    public function getTitle(): string
    {
        return $this->title;
    }
    
    public function getDescription(): string
    {
        return $this->description;
    }
    
    public function getOrder(): TrackOrder
    {
        return $this->order;
    }
    
    public function isRequired(): bool
    {
        return $this->isRequired;
    }
    
    /**
     * @return CourseId[]
     */
    public function getCourseIds(): array
    {
        return $this->courseIds;
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id->getValue(),
            'programId' => $this->programId->getValue(),
            'title' => $this->title,
            'description' => $this->description,
            'order' => $this->order->getValue(),
            'isRequired' => $this->isRequired,
            'courseIds' => array_map(
                fn(CourseId $courseId) => $courseId->getValue(),
                $this->courseIds
            )
        ];
    }
} 