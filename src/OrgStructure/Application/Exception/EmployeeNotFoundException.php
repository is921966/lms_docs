<?php

namespace App\OrgStructure\Application\Exception;

class EmployeeNotFoundException extends \Exception
{
    public function __construct(string $id)
    {
        parent::__construct("Employee with ID '$id' not found");
    }
} 