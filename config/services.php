<?php

return [
    'mailgun' => [
        'domain' => env('MAILGUN_DOMAIN'),
        'secret' => env('MAILGUN_SECRET'),
        'endpoint' => env('MAILGUN_ENDPOINT', 'api.mailgun.net'),
        'scheme' => 'https',
    ],
    
    'smtp' => [
        'host' => env('MAIL_HOST', 'smtp.mailtrap.io'),
        'port' => env('MAIL_PORT', 2525),
        'from' => [
            'address' => env('MAIL_FROM_ADDRESS', 'noreply@lms.company.ru'),
            'name' => env('MAIL_FROM_NAME', 'LMS Corporate University'),
        ],
        'encryption' => env('MAIL_ENCRYPTION', 'tls'),
        'username' => env('MAIL_USERNAME'),
        'password' => env('MAIL_PASSWORD'),
    ],
    
    'rabbitmq' => [
        'host' => env('RABBITMQ_HOST', 'localhost'),
        'port' => env('RABBITMQ_PORT', 5672),
        'user' => env('RABBITMQ_USER', 'guest'),
        'password' => env('RABBITMQ_PASSWORD', 'guest'),
        'vhost' => env('RABBITMQ_VHOST', '/'),
        'exchange' => env('RABBITMQ_EXCHANGE', 'lms_events'),
        'queue_prefix' => env('RABBITMQ_QUEUE_PREFIX', 'lms_'),
        'ssl' => [
            'enabled' => env('RABBITMQ_SSL_ENABLED', false),
            'verify_peer' => env('RABBITMQ_SSL_VERIFY_PEER', true),
        ],
    ],
    
    's3' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
        'bucket' => env('AWS_BUCKET'),
        'url' => env('AWS_URL'),
        'endpoint' => env('AWS_ENDPOINT'),
        'use_path_style_endpoint' => env('AWS_USE_PATH_STYLE_ENDPOINT', false),
    ],
    
    'elasticsearch' => [
        'hosts' => explode(',', env('ELASTICSEARCH_HOSTS', 'localhost:9200')),
        'username' => env('ELASTICSEARCH_USERNAME'),
        'password' => env('ELASTICSEARCH_PASSWORD'),
        'cloud_id' => env('ELASTICSEARCH_CLOUD_ID'),
        'api_key' => env('ELASTICSEARCH_API_KEY'),
        'index_prefix' => env('ELASTICSEARCH_INDEX_PREFIX', 'lms_'),
    ],
    
    'sentry' => [
        'dsn' => env('SENTRY_DSN'),
        'environment' => env('APP_ENV', 'production'),
        'traces_sample_rate' => env('SENTRY_TRACES_SAMPLE_RATE', 0.1),
        'profiles_sample_rate' => env('SENTRY_PROFILES_SAMPLE_RATE', 0.1),
    ],
    
    'clickhouse' => [
        'host' => env('CLICKHOUSE_HOST', 'localhost'),
        'port' => env('CLICKHOUSE_PORT', 8123),
        'database' => env('CLICKHOUSE_DATABASE', 'lms_analytics'),
        'username' => env('CLICKHOUSE_USERNAME', 'default'),
        'password' => env('CLICKHOUSE_PASSWORD'),
        'timeout' => env('CLICKHOUSE_TIMEOUT', 10),
    ],
]; 