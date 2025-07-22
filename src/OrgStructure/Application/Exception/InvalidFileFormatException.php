<?php

namespace App\OrgStructure\Application\Exception;

class InvalidFileFormatException extends \Exception
{
    public function __construct(string $filename)
    {
        parent::__construct("File '$filename' is not a valid Excel file");
    }
} 