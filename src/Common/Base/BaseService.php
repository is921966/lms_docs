<?php

declare(strict_types=1);

namespace Common\Base;

use Common\Interfaces\ServiceInterface;
use Common\Interfaces\ValidatorInterface;
use Common\Exceptions\ValidationException;
use Doctrine\ORM\EntityManagerInterface;
use Psr\Log\LoggerInterface;

/**
 * Base service implementation with common functionality
 */
abstract class BaseService implements ServiceInterface
{
    protected EntityManagerInterface $entityManager;
    protected ValidatorInterface $validator;
    protected LoggerInterface $logger;
    
    public function __construct(
        EntityManagerInterface $entityManager,
        ValidatorInterface $validator,
        LoggerInterface $logger
    ) {
        $this->entityManager = $entityManager;
        $this->validator = $validator;
        $this->logger = $logger;
    }
    
    /**
     * {@inheritdoc}
     */
    public function validate(array $data): bool
    {
        $rules = $this->getValidationRules();
        
        if (!$this->validator->validate($data, $rules)) {
            throw new ValidationException(
                'Validation failed',
                $this->validator->getErrors()
            );
        }
        
        return true;
    }
    
    /**
     * {@inheritdoc}
     */
    public function beginTransaction(): void
    {
        $this->entityManager->beginTransaction();
    }
    
    /**
     * {@inheritdoc}
     */
    public function commit(): void
    {
        $this->entityManager->commit();
    }
    
    /**
     * {@inheritdoc}
     */
    public function rollback(): void
    {
        $this->entityManager->rollback();
    }
    
    /**
     * Execute operation in transaction
     * 
     * @param callable $operation
     * @return mixed
     * @throws \Throwable
     */
    protected function transactional(callable $operation): mixed
    {
        $this->beginTransaction();
        
        try {
            $result = $operation();
            $this->commit();
            
            return $result;
        } catch (\Throwable $e) {
            $this->rollback();
            $this->logger->error('Transaction failed', [
                'exception' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            throw $e;
        }
    }
    
    /**
     * Get validation rules for the service
     * 
     * @return array<string, mixed>
     */
    abstract protected function getValidationRules(): array;
} 