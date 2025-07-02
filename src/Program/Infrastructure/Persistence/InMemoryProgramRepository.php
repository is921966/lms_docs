<?php

declare(strict_types=1);

namespace Program\Infrastructure\Persistence;

use Program\Domain\Repository\ProgramRepositoryInterface;
use Program\Domain\Program;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\ProgramCode;

final class InMemoryProgramRepository implements ProgramRepositoryInterface
{
    /**
     * @var array<string, Program>
     */
    private array $programs = [];
    
    public function save(Program $program): void
    {
        $this->programs[$program->getId()->getValue()] = clone $program;
    }
    
    public function findById(ProgramId $id): ?Program
    {
        $key = $id->getValue();
        
        if (!isset($this->programs[$key])) {
            return null;
        }
        
        return clone $this->programs[$key];
    }
    
    public function findByCode(ProgramCode $code): ?Program
    {
        foreach ($this->programs as $program) {
            if ($program->getCode()->equals($code)) {
                return clone $program;
            }
        }
        
        return null;
    }
    
    /**
     * @return Program[]
     */
    public function findAll(): array
    {
        return array_map(
            fn(Program $program) => clone $program,
            array_values($this->programs)
        );
    }
    
    /**
     * @return Program[]
     */
    public function findActive(): array
    {
        return array_values(
            array_filter(
                $this->findAll(),
                fn(Program $program) => $program->getStatus()->isActive()
            )
        );
    }
    
    public function delete(ProgramId $id): void
    {
        unset($this->programs[$id->getValue()]);
    }
    
    public function nextIdentity(): ProgramId
    {
        return ProgramId::generate();
    }
} 