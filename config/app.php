<?php

return [
    'name' => env('APP_NAME', 'LMS Corporate University'),
    'env' => env('APP_ENV', 'production'),
    'debug' => (bool) env('APP_DEBUG', false),
    'url' => env('APP_URL', 'http://localhost'),
    'timezone' => env('APP_TIMEZONE', 'Europe/Moscow'),
    'locale' => env('APP_LOCALE', 'ru'),
    
    'version' => '1.0.0',
    
    'providers' => [
        // Service providers will be registered here
    ],
    
    'aliases' => [
        // Class aliases will be registered here
    ],
    
    'security' => [
        'bcrypt_rounds' => env('BCRYPT_ROUNDS', 10),
        'argon_memory' => env('ARGON_MEMORY', 1024),
        'argon_threads' => env('ARGON_THREADS', 2),
        'argon_time' => env('ARGON_TIME', 2),
    ],
    
    'cors' => [
        'allowed_origins' => explode(',', env('CORS_ALLOWED_ORIGINS', '*')),
        'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
        'allowed_headers' => ['Content-Type', 'Authorization', 'X-Requested-With'],
        'exposed_headers' => ['X-Total-Count'],
        'max_age' => env('CORS_MAX_AGE', 3600),
        'supports_credentials' => (bool) env('CORS_SUPPORTS_CREDENTIALS', false),
    ],
    
    'pagination' => [
        'default_limit' => env('PAGINATION_DEFAULT_LIMIT', 20),
        'max_limit' => env('PAGINATION_MAX_LIMIT', 100),
    ],
    
    'uploads' => [
        'max_size' => env('UPLOAD_MAX_SIZE', 10485760), // 10MB
        'allowed_extensions' => [
            'documents' => ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'],
            'images' => ['jpg', 'jpeg', 'png', 'gif', 'svg'],
            'videos' => ['mp4', 'avi', 'mov', 'wmv'],
        ],
    ],
]; 