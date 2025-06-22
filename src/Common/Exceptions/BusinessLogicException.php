<?php

declare(strict_types=1);

namespace App\Common\Exceptions;

/**
 * Exception thrown when business logic rules are violated
 */
class BusinessLogicException extends \Exception
{
    private ?string $rule = null;
    private array $context = [];
    
    /**
     * @param string $message
     * @param string|null $rule
     * @param array<string, mixed> $context
     * @param int $code
     * @param \Throwable|null $previous
     */
    public function __construct(
        string $message,
        ?string $rule = null,
        array $context = [],
        int $code = 400,
        ?\Throwable $previous = null
    ) {
        parent::__construct($message, $code, $previous);
        $this->rule = $rule;
        $this->context = $context;
    }
    
    /**
     * Create exception for specific business rule
     * 
     * @param string $rule
     * @param string $message
     * @param array<string, mixed> $context
     * @return self
     */
    public static function forRule(string $rule, string $message, array $context = []): self
    {
        return new self($message, $rule, $context);
    }
    
    /**
     * Get business rule that was violated
     * 
     * @return string|null
     */
    public function getRule(): ?string
    {
        return $this->rule;
    }
    
    /**
     * Get context data
     * 
     * @return array<string, mixed>
     */
    public function getContext(): array
    {
        return $this->context;
    }
    
    /**
     * Add context data
     * 
     * @param string $key
     * @param mixed $value
     * @return self
     */
    public function withContext(string $key, mixed $value): self
    {
        $this->context[$key] = $value;
        return $this;
    }
} 