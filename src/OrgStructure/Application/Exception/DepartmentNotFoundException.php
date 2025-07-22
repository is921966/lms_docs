<?php

namespace App\OrgStructure\Application\Exception;

class DepartmentNotFoundException extends \Exception
{
    public function __construct(string $id)
    {
        parent::__construct("Department with ID '$id' not found");
    }
} 