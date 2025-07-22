#!/usr/bin/env php
<?php

$dsn = 'pgsql:host=85.209.53.188;port=5432;dbname=lms_backend';
$username = 'lms_backend';
$password = '9jY6L9yx3tqJx9ov7LPz';

try {
    $pdo = new PDO($dsn, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Применяем миграции
    $migrations = [
        '024_create_departments_table.sql',
        '025_create_positions_table.sql',
        '026_create_employees_table.sql'
    ];
    
    foreach ($migrations as $migration) {
        $file = __DIR__ . '/../database/migrations/' . $migration;
        if (file_exists($file)) {
            $sql = file_get_contents($file);
            echo "Applying migration: $migration\n";
            $pdo->exec($sql);
            echo "✅ Applied successfully\n\n";
        } else {
            echo "❌ File not found: $file\n";
        }
    }
    
    echo "All migrations applied successfully!\n";
    
} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
} 