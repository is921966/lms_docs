<?php

declare(strict_types=1);

namespace Common\Exceptions;

/**
 * Exception thrown when user is not authorized to perform action
 */
class AuthorizationException extends \Exception
{
    private ?string $action = null;
    private ?string $resource = null;
    private ?string $reason = null;
    
    /**
     * @param string $message
     * @param string|null $action
     * @param string|null $resource
     * @param string|null $reason
     * @param int $code
     * @param \Throwable|null $previous
     */
    public function __construct(
        string $message = 'Access denied',
        ?string $action = null,
        ?string $resource = null,
        ?string $reason = null,
        int $code = 403,
        ?\Throwable $previous = null
    ) {
        parent::__construct($message, $code, $previous);
        $this->action = $action;
        $this->resource = $resource;
        $this->reason = $reason;
    }
    
    /**
     * Create exception for specific action and resource
     * 
     * @param string $action
     * @param string $resource
     * @param string|null $reason
     * @return self
     */
    public static function forAction(string $action, string $resource, ?string $reason = null): self
    {
        $message = sprintf('Not authorized to %s %s', $action, $resource);
        
        if ($reason !== null) {
            $message .= ': ' . $reason;
        }
        
        return new self($message, $action, $resource, $reason);
    }
    
    /**
     * Get action that was denied
     * 
     * @return string|null
     */
    public function getAction(): ?string
    {
        return $this->action;
    }
    
    /**
     * Get resource that access was denied to
     * 
     * @return string|null
     */
    public function getResource(): ?string
    {
        return $this->resource;
    }
    
    /**
     * Get reason for denial
     * 
     * @return string|null
     */
    public function getReason(): ?string
    {
        return $this->reason;
    }
} 