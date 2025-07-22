<?php

declare(strict_types=1);

namespace App\OrgStructure\Application\DTO;

final class ImportResult
{
    /** @var ImportError[] */
    private array $errors;
    
    public function __construct(
        private int $totalProcessed,
        private int $successful,
        private int $errorCount,
        private int $employeesCreated,
        private int $positionsCreated,
        array $errors = [],
        private int $departmentsCreated = 0,
        private int $employeesUpdated = 0
    ) {
        $this->errors = $errors;
    }

    public function getTotalProcessed(): int
    {
        return $this->totalProcessed;
    }

    public function getSuccessful(): int
    {
        return $this->successful;
    }

    public function getErrors(): int
    {
        return $this->errorCount;
    }

    public function getEmployeesCreated(): int
    {
        return $this->employeesCreated;
    }

    public function isPartialSuccess(): bool
    {
        return $this->importedCount > 0 && $this->failedCount > 0;
    }

    public function getImportedCount(): int
    {
        return $this->importedCount;
    }

    public function getFailedCount(): int
    {
        return $this->failedCount;
    }

    /**
     * @return ImportError[]
     */
    public function getErrorList(): array
    {
        return $this->errors;
    }

    public function addError(ImportError $error): void
    {
        $this->errors[] = $error;
    }

    public function incrementImported(): void
    {
        $this->importedCount++;
    }

    public function getPositionsCreated(): int
    {
        return $this->positionsCreated;
    }

    public function getDepartmentsCreated(): int
    {
        return $this->departmentsCreated;
    }

    public function getEmployeesUpdated(): int
    {
        return $this->employeesUpdated;
    }

    public function hasErrors(): bool
    {
        return !empty($this->errors);
    }

    public function incrementFailed(): void
    {
        $this->failedCount++;
    }

    public function getDetails(): array
    {
        return $this->details;
    }

    public function setDetails(array $details): void
    {
        $this->details = $details;
    }

    public function merge(ImportResult $other): self
    {
        $merged = new self(
            $this->importedCount + $other->importedCount,
            $this->failedCount + $other->failedCount,
            array_merge($this->errors, $other->errors)
        );
        
        $merged->setDetails(array_merge($this->details, $other->details));
        
        return $merged;
    }

    public function getSuccessRate(): float
    {
        $total = $this->importedCount + $this->failedCount;
        
        if ($total === 0) {
            return 100.0;
        }
        
        return round(($this->importedCount / $total) * 100, 2);
    }

    public function toArray(): array
    {
        return [
            'success' => $this->isSuccess(),
            'partial_success' => $this->isPartialSuccess(),
            'imported_count' => $this->importedCount,
            'failed_count' => $this->failedCount,
            'success_rate' => $this->getSuccessRate(),
            'errors' => array_map(fn(ImportError $error) => $error->toArray(), $this->errors),
            'details' => $this->details
        ];
    }
} 