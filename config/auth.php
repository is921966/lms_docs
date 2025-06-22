<?php

return [
    'defaults' => [
        'guard' => 'api',
        'passwords' => 'users',
    ],
    
    'guards' => [
        'api' => [
            'driver' => 'jwt',
            'provider' => 'users',
        ],
    ],
    
    'providers' => [
        'users' => [
            'driver' => 'eloquent',
            'model' => App\User\Domain\User::class,
        ],
    ],
    
    'passwords' => [
        'users' => [
            'provider' => 'users',
            'table' => 'password_resets',
            'expire' => 60,
            'throttle' => 60,
        ],
    ],
    
    'jwt' => [
        'secret' => env('JWT_SECRET'),
        'ttl' => env('JWT_TTL', 60), // minutes
        'refresh_ttl' => env('JWT_REFRESH_TTL', 20160), // 2 weeks
        'algo' => env('JWT_ALGO', 'HS256'),
        'required_claims' => [
            'iss',
            'iat',
            'exp',
            'nbf',
            'sub',
            'jti',
        ],
    ],
    
    'ldap' => [
        'connection' => [
            'hosts' => explode(',', env('LDAP_HOSTS', 'ldap.company.local')),
            'port' => env('LDAP_PORT', 389),
            'use_ssl' => env('LDAP_USE_SSL', false),
            'use_tls' => env('LDAP_USE_TLS', false),
            'version' => env('LDAP_VERSION', 3),
            'timeout' => env('LDAP_TIMEOUT', 5),
            'follow_referrals' => env('LDAP_FOLLOW_REFERRALS', false),
        ],
        
        'bind' => [
            'dn' => env('LDAP_BIND_DN', 'cn=admin,dc=company,dc=local'),
            'password' => env('LDAP_BIND_PASSWORD'),
        ],
        
        'base_dn' => env('LDAP_BASE_DN', 'dc=company,dc=local'),
        
        'filters' => [
            'user' => env('LDAP_USER_FILTER', '(&(objectClass=user)(sAMAccountName={username}))'),
            'group' => env('LDAP_GROUP_FILTER', '(&(objectClass=group)(member={dn}))'),
        ],
        
        'attributes' => [
            'username' => 'sAMAccountName',
            'email' => 'mail',
            'first_name' => 'givenName',
            'last_name' => 'sn',
            'display_name' => 'displayName',
            'department' => 'department',
            'title' => 'title',
            'manager' => 'manager',
            'groups' => 'memberOf',
        ],
        
        'sync' => [
            'enabled' => env('LDAP_SYNC_ENABLED', true),
            'interval' => env('LDAP_SYNC_INTERVAL', 3600), // seconds
            'fields' => ['email', 'first_name', 'last_name', 'department', 'manager'],
        ],
    ],
    
    'password_policy' => [
        'min_length' => env('PASSWORD_MIN_LENGTH', 8),
        'require_uppercase' => env('PASSWORD_REQUIRE_UPPERCASE', true),
        'require_lowercase' => env('PASSWORD_REQUIRE_LOWERCASE', true),
        'require_numbers' => env('PASSWORD_REQUIRE_NUMBERS', true),
        'require_symbols' => env('PASSWORD_REQUIRE_SYMBOLS', true),
    ],
]; 