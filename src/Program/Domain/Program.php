<?php

declare(strict_types=1);

namespace Program\Domain;

use Common\Domain\AggregateRoot;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\ProgramCode;
use Program\Domain\ValueObjects\ProgramStatus;
use Program\Domain\ValueObjects\CompletionCriteria;
use Program\Domain\ValueObjects\TrackId;
use Program\Domain\Events\ProgramCreated;
use Program\Domain\Events\ProgramPublished;

class Program extends AggregateRoot
{
    private ProgramId $id;
    private ProgramCode $code;
    private string $title;
    private string $description;
    private ProgramStatus $status;
    private CompletionCriteria $completionCriteria;
    private array $metadata = [];
    private array $trackIds = [];
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    
    private function __construct(
        ProgramId $id,
        ProgramCode $code,
        string $title,
        string $description
    ) {
        $this->id = $id;
        $this->code = $code;
        $this->setTitle($title);
        $this->description = $description;
        $this->status = ProgramStatus::draft();
        $this->completionCriteria = CompletionCriteria::requireAll();
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public static function create(
        ProgramId $id,
        ProgramCode $code,
        string $title,
        string $description
    ): self {
        $program = new self($id, $code, $title, $description);
        
        $program->recordThat(new ProgramCreated(
            $id,
            $code,
            $title,
            $description
        ));
        
        return $program;
    }
    
    public function updateBasicInfo(string $title, string $description): void
    {
        $this->setTitle($title);
        $this->description = $description;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function setCompletionCriteria(CompletionCriteria $criteria): void
    {
        $this->completionCriteria = $criteria;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function publish(): void
    {
        if (!$this->status->canBePublished()) {
            throw new \DomainException('Program cannot be published in current status');
        }
        
        if ($this->isEmpty()) {
            throw new \DomainException('Cannot publish program without tracks');
        }
        
        $this->status = ProgramStatus::active();
        $this->updatedAt = new \DateTimeImmutable();
        
        $this->recordThat(new ProgramPublished(
            $this->id,
            new \DateTimeImmutable()
        ));
    }
    
    public function archive(): void
    {
        if ($this->status->isDraft()) {
            throw new \DomainException('Cannot archive program from draft status');
        }
        
        $this->status = ProgramStatus::archived();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function forceStatus(ProgramStatus $status): void
    {
        $this->status = $status;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function isEmpty(): bool
    {
        return count($this->trackIds) === 0;
    }
    
    public function addTrack(TrackId $trackId): void
    {
        if (!in_array($trackId->getValue(), $this->trackIds)) {
            $this->trackIds[] = $trackId->getValue();
            $this->updatedAt = new \DateTimeImmutable();
        }
    }
    
    public function removeTrack(TrackId $trackId): void
    {
        $this->trackIds = array_filter(
            $this->trackIds,
            fn($id) => $id !== $trackId->getValue()
        );
        $this->trackIds = array_values($this->trackIds);
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function getTrackIds(): array
    {
        return array_map(
            fn($id) => TrackId::fromString($id),
            $this->trackIds
        );
    }
    
    public function setMetadata(array $metadata): void
    {
        $this->metadata = $metadata;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    private function setTitle(string $title): void
    {
        if (empty($title)) {
            throw new \InvalidArgumentException('Program title cannot be empty');
        }
        
        $this->title = $title;
    }
    
    // Getters
    public function getId(): ProgramId
    {
        return $this->id;
    }
    
    public function getCode(): ProgramCode
    {
        return $this->code;
    }
    
    public function getTitle(): string
    {
        return $this->title;
    }
    
    public function getDescription(): string
    {
        return $this->description;
    }
    
    public function getStatus(): ProgramStatus
    {
        return $this->status;
    }
    
    public function getCompletionCriteria(): CompletionCriteria
    {
        return $this->completionCriteria;
    }
    
    public function getMetadata(): array
    {
        return $this->metadata;
    }
    
    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getUpdatedAt(): \DateTimeImmutable
    {
        return $this->updatedAt;
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id->getValue(),
            'code' => $this->code->getValue(),
            'title' => $this->title,
            'description' => $this->description,
            'status' => $this->status->getValue(),
            'completionCriteria' => $this->completionCriteria->jsonSerialize(),
            'metadata' => $this->metadata,
            'createdAt' => $this->createdAt->format('Y-m-d H:i:s'),
            'updatedAt' => $this->updatedAt->format('Y-m-d H:i:s')
        ];
    }
} 