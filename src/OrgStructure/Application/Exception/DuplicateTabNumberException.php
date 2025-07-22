<?php

namespace App\OrgStructure\Application\Exception;

class DuplicateTabNumberException extends \Exception
{
    public function __construct(string $tabNumber)
    {
        parent::__construct("Employee with tab number '$tabNumber' already exists");
    }
} 