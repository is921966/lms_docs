<?php

declare(strict_types=1);

namespace Common\Http;

use Common\Exceptions\ValidationException;
use Common\Exceptions\NotFoundException;
use Common\Exceptions\AuthorizationException;
use Common\Exceptions\BusinessLogicException;
use Psr\Log\LoggerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;

/**
 * Central error handler for converting exceptions to HTTP responses
 */
class ErrorHandler
{
    private LoggerInterface $logger;
    private bool $debug;
    
    public function __construct(LoggerInterface $logger, bool $debug = false)
    {
        $this->logger = $logger;
        $this->debug = $debug;
    }
    
    /**
     * Handle exception and return JSON response
     * 
     * @param \Throwable $exception
     * @return JsonResponse
     */
    public function handle(\Throwable $exception): JsonResponse
    {
        $response = match (true) {
            $exception instanceof ValidationException => $this->handleValidation($exception),
            $exception instanceof NotFoundException => $this->handleNotFound($exception),
            $exception instanceof AuthorizationException => $this->handleAuthorization($exception),
            $exception instanceof BusinessLogicException => $this->handleBusinessLogic($exception),
            default => $this->handleGeneric($exception),
        };
        
        // Log error if it's server error
        if ($response->getStatusCode() >= 500) {
            $this->logger->error($exception->getMessage(), [
                'exception' => get_class($exception),
                'file' => $exception->getFile(),
                'line' => $exception->getLine(),
                'trace' => $exception->getTraceAsString(),
            ]);
        }
        
        return $response;
    }
    
    private function handleValidation(ValidationException $exception): JsonResponse
    {
        return new JsonResponse([
            'error' => [
                'code' => 'VALIDATION_ERROR',
                'message' => $exception->getMessage(),
                'errors' => $exception->getErrors(),
            ]
        ], 422);
    }
    
    private function handleNotFound(NotFoundException $exception): JsonResponse
    {
        $data = [
            'error' => [
                'code' => 'NOT_FOUND',
                'message' => $exception->getMessage(),
            ]
        ];
        
        if ($exception->getEntityType()) {
            $data['error']['entity_type'] = $exception->getEntityType();
            $data['error']['entity_id'] = $exception->getEntityId();
        }
        
        return new JsonResponse($data, 404);
    }
    
    private function handleAuthorization(AuthorizationException $exception): JsonResponse
    {
        $data = [
            'error' => [
                'code' => 'ACCESS_DENIED',
                'message' => $exception->getMessage(),
            ]
        ];
        
        if ($this->debug) {
            $data['error']['action'] = $exception->getAction();
            $data['error']['resource'] = $exception->getResource();
            $data['error']['reason'] = $exception->getReason();
        }
        
        return new JsonResponse($data, 403);
    }
    
    private function handleBusinessLogic(BusinessLogicException $exception): JsonResponse
    {
        $data = [
            'error' => [
                'code' => 'BUSINESS_RULE_VIOLATION',
                'message' => $exception->getMessage(),
            ]
        ];
        
        if ($exception->getRule()) {
            $data['error']['rule'] = $exception->getRule();
        }
        
        if ($this->debug && !empty($exception->getContext())) {
            $data['error']['context'] = $exception->getContext();
        }
        
        return new JsonResponse($data, 400);
    }
    
    private function handleGeneric(\Throwable $exception): JsonResponse
    {
        $data = [
            'error' => [
                'code' => 'INTERNAL_ERROR',
                'message' => 'An internal error occurred',
            ]
        ];
        
        if ($this->debug) {
            $data['error']['message'] = $exception->getMessage();
            $data['error']['exception'] = get_class($exception);
            $data['error']['file'] = $exception->getFile();
            $data['error']['line'] = $exception->getLine();
        }
        
        return new JsonResponse($data, 500);
    }
} 