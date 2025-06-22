<?php

declare(strict_types=1);

namespace App\Common\Middleware;

use App\Common\Exceptions\ValidationException;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Symfony\Component\Validator\Validator\ValidatorInterface;

/**
 * Request Validation Middleware
 */
class ValidationMiddleware implements MiddlewareInterface
{
    private ValidatorInterface $validator;
    private array $rules;
    
    public function __construct(
        ValidatorInterface $validator,
        array $rules = []
    ) {
        $this->validator = $validator;
        $this->rules = $rules;
    }
    
    /**
     * Process the request and validate data
     */
    public function process(
        ServerRequestInterface $request,
        RequestHandlerInterface $handler
    ): ResponseInterface {
        $route = $request->getAttribute('_route');
        
        // Check if validation rules exist for this route
        if (!$route || !isset($this->rules[$route])) {
            return $handler->handle($request);
        }
        
        $rules = $this->rules[$route];
        $data = $this->extractData($request, $rules);
        
        // Validate data
        $errors = $this->validateData($data, $rules);
        
        if (!empty($errors)) {
            throw new ValidationException('Validation failed', $errors);
        }
        
        // Add validated data to request
        $request = $request->withAttribute('validated_data', $data);
        
        return $handler->handle($request);
    }
    
    /**
     * Extract data from request based on rules
     */
    private function extractData(ServerRequestInterface $request, array $rules): array
    {
        $data = [];
        
        // Extract from different sources based on rule configuration
        foreach ($rules as $field => $rule) {
            $source = $rule['source'] ?? 'body';
            
            switch ($source) {
                case 'query':
                    $data[$field] = $request->getQueryParams()[$field] ?? null;
                    break;
                    
                case 'route':
                    $data[$field] = $request->getAttribute($field);
                    break;
                    
                case 'header':
                    $data[$field] = $request->getHeaderLine($rule['header'] ?? $field);
                    break;
                    
                case 'body':
                default:
                    $body = $this->getParsedBody($request);
                    $data[$field] = $this->getNestedValue($body, $field);
                    break;
            }
        }
        
        return $data;
    }
    
    /**
     * Get parsed body from request
     */
    private function getParsedBody(ServerRequestInterface $request): array
    {
        $contentType = $request->getHeaderLine('Content-Type');
        
        if (strpos($contentType, 'application/json') !== false) {
            $body = (string) $request->getBody();
            return json_decode($body, true) ?: [];
        }
        
        return $request->getParsedBody() ?: [];
    }
    
    /**
     * Get nested value from array using dot notation
     */
    private function getNestedValue(array $data, string $key)
    {
        if (strpos($key, '.') === false) {
            return $data[$key] ?? null;
        }
        
        $keys = explode('.', $key);
        $value = $data;
        
        foreach ($keys as $k) {
            if (!is_array($value) || !isset($value[$k])) {
                return null;
            }
            $value = $value[$k];
        }
        
        return $value;
    }
    
    /**
     * Validate data against rules
     */
    private function validateData(array $data, array $rules): array
    {
        $errors = [];
        
        foreach ($rules as $field => $rule) {
            $value = $data[$field] ?? null;
            $fieldErrors = [];
            
            // Required validation
            if (($rule['required'] ?? false) && $value === null) {
                $fieldErrors[] = sprintf('The %s field is required.', $field);
            }
            
            // Skip other validations if value is null and not required
            if ($value === null && !($rule['required'] ?? false)) {
                continue;
            }
            
            // Type validation
            if (isset($rule['type'])) {
                $typeError = $this->validateType($value, $rule['type'], $field);
                if ($typeError) {
                    $fieldErrors[] = $typeError;
                }
            }
            
            // Length validation
            if (isset($rule['min_length']) || isset($rule['max_length'])) {
                $lengthError = $this->validateLength(
                    $value,
                    $rule['min_length'] ?? null,
                    $rule['max_length'] ?? null,
                    $field
                );
                if ($lengthError) {
                    $fieldErrors[] = $lengthError;
                }
            }
            
            // Pattern validation
            if (isset($rule['pattern'])) {
                if (!preg_match($rule['pattern'], (string) $value)) {
                    $fieldErrors[] = sprintf(
                        'The %s field format is invalid.',
                        $field
                    );
                }
            }
            
            // Custom validation
            if (isset($rule['validator']) && is_callable($rule['validator'])) {
                $customError = $rule['validator']($value, $data);
                if ($customError) {
                    $fieldErrors[] = $customError;
                }
            }
            
            if (!empty($fieldErrors)) {
                $errors[$field] = $fieldErrors;
            }
        }
        
        return $errors;
    }
    
    /**
     * Validate value type
     */
    private function validateType($value, string $type, string $field): ?string
    {
        $valid = match ($type) {
            'string' => is_string($value),
            'int', 'integer' => is_int($value) || (is_string($value) && ctype_digit($value)),
            'float', 'double' => is_float($value) || is_int($value),
            'bool', 'boolean' => is_bool($value) || in_array($value, ['0', '1', 'true', 'false'], true),
            'array' => is_array($value),
            'email' => is_string($value) && filter_var($value, FILTER_VALIDATE_EMAIL),
            'url' => is_string($value) && filter_var($value, FILTER_VALIDATE_URL),
            'uuid' => is_string($value) && preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i', $value),
            default => true,
        };
        
        return $valid ? null : sprintf('The %s field must be a valid %s.', $field, $type);
    }
    
    /**
     * Validate value length
     */
    private function validateLength($value, ?int $min, ?int $max, string $field): ?string
    {
        $length = is_array($value) ? count($value) : strlen((string) $value);
        
        if ($min !== null && $length < $min) {
            return sprintf('The %s field must be at least %d characters.', $field, $min);
        }
        
        if ($max !== null && $length > $max) {
            return sprintf('The %s field must not exceed %d characters.', $field, $max);
        }
        
        return null;
    }
} 