<?php

declare(strict_types=1);

namespace Common\Exceptions;

/**
 * Exception for validation errors with field-specific details
 */
class ValidationException extends \Exception implements \JsonSerializable
{
    /**
     * @var array<string, array<string>>
     */
    private array $errors = [];
    
    /**
     * @param string $message
     * @param array<string, array<string>> $errors
     * @param int $code
     * @param \Throwable|null $previous
     */
    public function __construct(
        string $message = 'Validation failed',
        array $errors = [],
        int $code = 422,
        ?\Throwable $previous = null
    ) {
        parent::__construct($message, $code, $previous);
        $this->errors = $errors;
    }
    
    /**
     * Create exception with errors
     */
    public static function withErrors(array $errors): self
    {
        return new self('Validation failed', $errors);
    }
    
    /**
     * Get validation errors
     * 
     * @return array<string, array<string>>
     */
    public function getErrors(): array
    {
        return $this->errors;
    }
    
    /**
     * Add error for specific field
     * 
     * @param string $field
     * @param string $error
     * @return void
     */
    public function addError(string $field, string $error): void
    {
        if (!isset($this->errors[$field])) {
            $this->errors[$field] = [];
        }
        
        $this->errors[$field][] = $error;
    }
    
    /**
     * Check if has errors
     * 
     * @return bool
     */
    public function hasErrors(): bool
    {
        return !empty($this->errors);
    }
    
    /**
     * Get errors for specific field
     * 
     * @param string $field
     * @return array<string>
     */
    public function getFieldErrors(string $field): array
    {
        return $this->errors[$field] ?? [];
    }
    
    /**
     * {@inheritdoc}
     */
    public function jsonSerialize(): mixed
    {
        return [
            'message' => $this->getMessage(),
            'errors' => $this->errors,
            'code' => $this->getCode()
        ];
    }
} 