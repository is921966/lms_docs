<?php

declare(strict_types=1);

namespace App\Common\Traits;

use Doctrine\ORM\Mapping as ORM;

/**
 * Trait for entities with created/updated timestamps
 */
trait HasTimestamps
{
    #[ORM\Column(type: 'datetime_immutable')]
    private \DateTimeImmutable $createdAt;
    
    #[ORM\Column(type: 'datetime_immutable')]
    private \DateTimeImmutable $updatedAt;
    
    /**
     * @ORM\PrePersist
     */
    public function setCreatedAtValue(): void
    {
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * @ORM\PreUpdate
     */
    public function setUpdatedAtValue(): void
    {
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getUpdatedAt(): \DateTimeImmutable
    {
        return $this->updatedAt;
    }
    
    /**
     * Update timestamps manually
     */
    public function updateTimestamps(): void
    {
        $this->updatedAt = new \DateTimeImmutable();
    }
} 