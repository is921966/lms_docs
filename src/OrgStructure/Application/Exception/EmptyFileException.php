<?php

namespace App\OrgStructure\Application\Exception;

class EmptyFileException extends \Exception
{
    public function __construct()
    {
        parent::__construct("Excel file is empty or contains no data");
    }
} 