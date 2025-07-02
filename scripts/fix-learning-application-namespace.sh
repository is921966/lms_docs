#!/bin/bash

# Script to fix namespace in Learning Application classes
# Changes App\Learning\Application to Learning\Application

echo "🔧 Fixing namespace in Learning Application classes..."

# Fix namespace in all Application files
find src/Learning/Application -name "*.php" -type f | while read file; do
    echo "Fixing namespace in $file"
    # Fix namespace declarations
    sed -i '' 's/namespace App\\Learning\\Application\\Service;/namespace Learning\\Application\\Service;/g' "$file"
    sed -i '' 's/namespace App\\Learning\\Application\\DTO;/namespace Learning\\Application\\DTO;/g' "$file"
    sed -i '' 's/namespace App\\Learning\\Application\\Commands;/namespace Learning\\Application\\Commands;/g' "$file"
    sed -i '' 's/namespace App\\Learning\\Application\\Queries;/namespace Learning\\Application\\Queries;/g' "$file"
    sed -i '' 's/namespace App\\Learning\\Application\\Handlers;/namespace Learning\\Application\\Handlers;/g' "$file"
    sed -i '' 's/namespace App\\Learning\\Application\\/namespace Learning\\Application\\/g' "$file"
done

echo "✅ Application namespace fixes complete!" 