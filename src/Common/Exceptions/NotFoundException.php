<?php

declare(strict_types=1);

namespace App\Common\Exceptions;

/**
 * Exception thrown when requested entity is not found
 */
class NotFoundException extends \Exception
{
    private ?string $entityType = null;
    private int|string|null $entityId = null;
    
    /**
     * @param string $message
     * @param string|null $entityType
     * @param int|string|null $entityId
     * @param int $code
     * @param \Throwable|null $previous
     */
    public function __construct(
        string $message = 'Resource not found',
        ?string $entityType = null,
        int|string|null $entityId = null,
        int $code = 404,
        ?\Throwable $previous = null
    ) {
        parent::__construct($message, $code, $previous);
        $this->entityType = $entityType;
        $this->entityId = $entityId;
    }
    
    /**
     * Create exception for specific entity
     * 
     * @param string $entityType
     * @param int|string $id
     * @return self
     */
    public static function forEntity(string $entityType, int|string $id): self
    {
        return new self(
            sprintf('%s with ID %s not found', $entityType, $id),
            $entityType,
            $id
        );
    }
    
    /**
     * Get entity type
     * 
     * @return string|null
     */
    public function getEntityType(): ?string
    {
        return $this->entityType;
    }
    
    /**
     * Get entity ID
     * 
     * @return int|string|null
     */
    public function getEntityId(): int|string|null
    {
        return $this->entityId;
    }
} 