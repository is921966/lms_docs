<?php

declare(strict_types=1);

namespace Learning\Domain\Cmi5;

use Learning\Domain\ValueObjects\Cmi5PackageId;
use Learning\Domain\ValueObjects\CourseId;
use User\Domain\ValueObjects\UserId;

/**
 * Cmi5Package Aggregate Root
 * 
 * Represents a Cmi5 content package imported into the LMS
 */
class Cmi5Package
{
    private Cmi5PackageId $id;
    private ?CourseId $courseId;
    private string $packageName;
    private ?string $packageVersion;
    private ?string $publisher;
    private array $manifestData;
    private ?string $entryPoint;
    private string $moveOn;
    private ?float $masteryScore;
    private string $launchMethod;
    private ?string $launchParameters;
    private string $status;
    private \DateTimeImmutable $importedAt;
    private UserId $importedBy;
    private array $metadata;
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    
    /** @var Cmi5Activity[] */
    private array $activities = [];
    
    private function __construct(
        Cmi5PackageId $id,
        string $packageName,
        array $manifestData,
        UserId $importedBy
    ) {
        $this->id = $id;
        $this->packageName = $packageName;
        $this->manifestData = $manifestData;
        $this->importedBy = $importedBy;
        $this->importedAt = new \DateTimeImmutable();
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
        
        // Set defaults
        $this->status = 'active';
        $this->moveOn = 'CompletedAndPassed';
        $this->launchMethod = 'OwnWindow';
        $this->metadata = [];
    }
    
    public static function import(
        string $packageName,
        array $manifestData,
        UserId $importedBy
    ): self {
        $package = new self(
            Cmi5PackageId::generate(),
            $packageName,
            $manifestData,
            $importedBy
        );
        
        // Extract manifest data
        if (isset($manifestData['course'])) {
            $course = $manifestData['course'];
            $package->packageVersion = $course['version'] ?? null;
            $package->publisher = $course['publisher'] ?? null;
            $package->entryPoint = $course['entryPoint'] ?? null;
            $package->moveOn = $course['moveOn'] ?? 'CompletedAndPassed';
            $package->masteryScore = isset($course['masteryScore']) 
                ? (float)$course['masteryScore'] : null;
        }
        
        return $package;
    }
    
    public function attachToCourse(CourseId $courseId): void
    {
        $this->courseId = $courseId;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function addActivity(Cmi5Activity $activity): void
    {
        $this->activities[] = $activity;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function updateLaunchSettings(
        string $launchMethod,
        ?string $launchParameters = null
    ): void {
        if (!in_array($launchMethod, ['OwnWindow', 'AnyWindow'])) {
            throw new \InvalidArgumentException('Invalid launch method');
        }
        
        $this->launchMethod = $launchMethod;
        $this->launchParameters = $launchParameters;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function archive(): void
    {
        if ($this->status === 'archived') {
            throw new \DomainException('Package is already archived');
        }
        
        $this->status = 'archived';
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function activate(): void
    {
        if ($this->status === 'active') {
            throw new \DomainException('Package is already active');
        }
        
        $this->status = 'active';
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    // Getters
    public function getId(): Cmi5PackageId
    {
        return $this->id;
    }
    
    public function getCourseId(): ?CourseId
    {
        return $this->courseId;
    }
    
    public function getPackageName(): string
    {
        return $this->packageName;
    }
    
    public function getManifestData(): array
    {
        return $this->manifestData;
    }
    
    public function getActivities(): array
    {
        return $this->activities;
    }
    
    public function isActive(): bool
    {
        return $this->status === 'active';
    }
} 