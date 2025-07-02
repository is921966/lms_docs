<?php

namespace User\Domain\Exceptions;

class UserNotFoundException extends \Exception
{
    public function __construct(string $message = 'User not found')
    {
        parent::__construct($message);
    }

    public static function withId(string $id): self
    {
        return new self(sprintf('User with ID %s not found', $id));
    }

    public static function withEmail(string $email): self
    {
        return new self(sprintf('User with email %s not found', $email));
    }
} 