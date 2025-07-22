<?php

namespace App\OrgStructure\Application\Exception;

class DuplicateCodeException extends \Exception
{
    public function __construct(string $code)
    {
        parent::__construct("Department with code '$code' already exists");
    }
} 