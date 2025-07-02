<?php

declare(strict_types=1);

namespace Learning\Domain\ValueObjects;

use InvalidArgumentException;

final class ContentType
{
    private const TYPES = [
        'video' => [
            'display' => 'Video',
            'interactive' => false,
            'assessable' => false
        ],
        'text' => [
            'display' => 'Text',
            'interactive' => false,
            'assessable' => false
        ],
        'quiz' => [
            'display' => 'Quiz',
            'interactive' => true,
            'assessable' => true
        ],
        'assignment' => [
            'display' => 'Assignment',
            'interactive' => true,
            'assessable' => true
        ],
        'document' => [
            'display' => 'Document',
            'interactive' => false,
            'assessable' => false
        ]
    ];
    
    private function __construct(
        private readonly string $value
    ) {
        if (!array_key_exists($value, self::TYPES)) {
            throw new InvalidArgumentException("Invalid content type: {$value}");
        }
    }
    
    public static function video(): self
    {
        return new self('video');
    }
    
    public static function text(): self
    {
        return new self('text');
    }
    
    public static function quiz(): self
    {
        return new self('quiz');
    }
    
    public static function assignment(): self
    {
        return new self('assignment');
    }
    
    public static function document(): self
    {
        return new self('document');
    }
    
    public static function fromString(string $value): self
    {
        return new self(strtolower(trim($value)));
    }
    
    public static function getAllTypes(): array
    {
        return array_keys(self::TYPES);
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function getDisplayName(): string
    {
        return self::TYPES[$this->value]['display'];
    }
    
    public function isVideo(): bool
    {
        return $this->value === 'video';
    }
    
    public function isText(): bool
    {
        return $this->value === 'text';
    }
    
    public function isQuiz(): bool
    {
        return $this->value === 'quiz';
    }
    
    public function isAssignment(): bool
    {
        return $this->value === 'assignment';
    }
    
    public function isDocument(): bool
    {
        return $this->value === 'document';
    }
    
    public function isInteractive(): bool
    {
        return self::TYPES[$this->value]['interactive'];
    }
    
    public function isAssessable(): bool
    {
        return self::TYPES[$this->value]['assessable'];
    }
    
    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 