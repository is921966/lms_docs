<?php

return [
    'default' => env('DB_CONNECTION', 'pgsql'),
    
    'connections' => [
        'pgsql' => [
            'driver' => 'pgsql',
            'url' => env('DATABASE_URL'),
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', '5432'),
            'database' => env('DB_DATABASE', 'lms'),
            'username' => env('DB_USERNAME', 'postgres'),
            'password' => env('DB_PASSWORD', ''),
            'charset' => 'utf8',
            'prefix' => '',
            'prefix_indexes' => true,
            'schema' => env('DB_SCHEMA', 'public'),
            'sslmode' => env('DB_SSLMODE', 'prefer'),
            'options' => [
                'connect_timeout' => 10,
                'application_name' => 'LMS_Corporate_University',
            ],
            'pool' => [
                'min' => env('DB_POOL_MIN', 2),
                'max' => env('DB_POOL_MAX', 10),
            ],
        ],
        
        'pgsql_read' => [
            'driver' => 'pgsql',
            'host' => env('DB_READ_HOST', env('DB_HOST', '127.0.0.1')),
            'port' => env('DB_READ_PORT', env('DB_PORT', '5432')),
            'database' => env('DB_DATABASE', 'lms'),
            'username' => env('DB_READ_USERNAME', env('DB_USERNAME', 'postgres')),
            'password' => env('DB_READ_PASSWORD', env('DB_PASSWORD', '')),
            'charset' => 'utf8',
            'prefix' => '',
            'schema' => env('DB_SCHEMA', 'public'),
        ],
    ],
    
    'migrations' => [
        'table' => 'migrations',
        'path' => 'database/migrations',
    ],
    
    'redis' => [
        'client' => env('REDIS_CLIENT', 'phpredis'),
        
        'default' => [
            'host' => env('REDIS_HOST', '127.0.0.1'),
            'password' => env('REDIS_PASSWORD'),
            'port' => env('REDIS_PORT', 6379),
            'database' => env('REDIS_DB', 0),
            'prefix' => env('REDIS_PREFIX', 'lms_'),
        ],
        
        'cache' => [
            'host' => env('REDIS_HOST', '127.0.0.1'),
            'password' => env('REDIS_PASSWORD'),
            'port' => env('REDIS_PORT', 6379),
            'database' => env('REDIS_CACHE_DB', 1),
            'prefix' => env('REDIS_PREFIX', 'lms_cache_'),
        ],
        
        'session' => [
            'host' => env('REDIS_HOST', '127.0.0.1'),
            'password' => env('REDIS_PASSWORD'),
            'port' => env('REDIS_PORT', 6379),
            'database' => env('REDIS_SESSION_DB', 2),
            'prefix' => env('REDIS_PREFIX', 'lms_session_'),
        ],
        
        'queue' => [
            'host' => env('REDIS_HOST', '127.0.0.1'),
            'password' => env('REDIS_PASSWORD'),
            'port' => env('REDIS_PORT', 6379),
            'database' => env('REDIS_QUEUE_DB', 3),
            'prefix' => env('REDIS_PREFIX', 'lms_queue_'),
        ],
    ],
]; 