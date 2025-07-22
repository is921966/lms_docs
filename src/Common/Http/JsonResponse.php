<?php

namespace App\Common\Http;

use Symfony\Component\HttpFoundation\JsonResponse as BaseJsonResponse;

class JsonResponse extends BaseJsonResponse
{
    /**
     * Create a successful response with data
     */
    public static function success($data = null, int $status = 200): self
    {
        return new self([
            'success' => true,
            'data' => $data
        ], $status);
    }
    
    /**
     * Create an error response
     */
    public static function error(string $message, int $status = 400, array $errors = []): self
    {
        $response = [
            'success' => false,
            'error' => $message
        ];
        
        if (!empty($errors)) {
            $response['errors'] = $errors;
        }
        
        return new self($response, $status);
    }
    
    /**
     * Create a validation error response
     */
    public static function validationError(array $errors): self
    {
        return self::error('Validation failed', 422, $errors);
    }
    
    /**
     * Create a not found response
     */
    public static function notFound(string $message = 'Resource not found'): self
    {
        return self::error($message, 404);
    }
    
    /**
     * Create an unauthorized response
     */
    public static function unauthorized(string $message = 'Unauthorized'): self
    {
        return self::error($message, 401);
    }
    
    /**
     * Create a forbidden response
     */
    public static function forbidden(string $message = 'Forbidden'): self
    {
        return self::error($message, 403);
    }
} 