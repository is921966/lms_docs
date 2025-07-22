<?php

namespace App\OrgStructure\Application\Exception;

class DepartmentHasChildrenException extends \Exception
{
    public function __construct(string $id)
    {
        parent::__construct("Cannot delete department '$id' because it has child departments");
    }
} 