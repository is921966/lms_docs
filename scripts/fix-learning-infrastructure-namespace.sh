#!/bin/bash

# Script to fix namespace in Learning Infrastructure classes
# Changes App\Learning\Infrastructure to Learning\Infrastructure

echo "🔧 Fixing namespace in Learning Infrastructure classes..."

# Fix namespace in Repository files
find src/Learning/Infrastructure/Repository -name "*.php" -type f | while read file; do
    echo "Fixing namespace in $file"
    sed -i '' 's/namespace App\\Learning\\Infrastructure\\Repository;/namespace Learning\\Infrastructure\\Repository;/g' "$file"
done

# Fix namespace in Http/Controllers files
find src/Learning/Infrastructure/Http/Controllers -name "*.php" -type f | while read file; do
    echo "Fixing namespace in $file"
    sed -i '' 's/namespace App\\Learning\\Infrastructure\\Http\\Controllers;/namespace Learning\\Infrastructure\\Http\\Controllers;/g' "$file"
done

# Fix imports in all test files
find tests/Unit/Learning/Infrastructure -name "*.php" -type f | while read file; do
    echo "Fixing imports in test $file"
    # Fix Repository imports
    sed -i '' 's/use App\\Learning\\Infrastructure\\Repository\\/use Learning\\Infrastructure\\Repository\\/g' "$file"
    # Fix Http/Controllers imports
    sed -i '' 's/use App\\Learning\\Infrastructure\\Http\\Controllers\\/use Learning\\Infrastructure\\Http\\Controllers\\/g' "$file"
    # Fix general Infrastructure imports
    sed -i '' 's/use App\\Learning\\Infrastructure\\/use Learning\\Infrastructure\\/g' "$file"
done

# Fix imports in all source files
find src/Learning -name "*.php" -type f | while read file; do
    echo "Fixing imports in source $file"
    # Fix Repository imports
    sed -i '' 's/use App\\Learning\\Infrastructure\\Repository\\/use Learning\\Infrastructure\\Repository\\/g' "$file"
    # Fix Http/Controllers imports
    sed -i '' 's/use App\\Learning\\Infrastructure\\Http\\Controllers\\/use Learning\\Infrastructure\\Http\\Controllers\\/g' "$file"
    # Fix general Infrastructure imports
    sed -i '' 's/use App\\Learning\\Infrastructure\\/use Learning\\Infrastructure\\/g' "$file"
done

# Also fix Application namespace imports if needed
find src/Learning -name "*.php" -type f | while read file; do
    echo "Fixing Application imports in $file"
    sed -i '' 's/use App\\Learning\\Application\\/use Learning\\Application\\/g' "$file"
done

find tests/Unit/Learning -name "*.php" -type f | while read file; do
    echo "Fixing Application imports in test $file"
    sed -i '' 's/use App\\Learning\\Application\\/use Learning\\Application\\/g' "$file"
done

echo "✅ Infrastructure namespace fixes complete!" 