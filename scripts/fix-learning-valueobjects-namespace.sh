#!/bin/bash

# Script to fix namespace in Learning Domain Value Objects
# Changes App\Learning\Domain\ValueObjects to Learning\Domain\ValueObjects

echo "🔧 Fixing namespace in Learning Domain Value Objects..."

# Fix namespace in source files
find src/Learning/Domain/ValueObjects -name "*.php" -type f | while read file; do
    echo "Fixing $file"
    sed -i '' 's/namespace App\\Learning\\Domain\\ValueObjects;/namespace Learning\\Domain\\ValueObjects;/g' "$file"
done

# Fix imports in test files
find tests/Unit/Learning/Domain/ValueObjects -name "*.php" -type f | while read file; do
    echo "Fixing imports in $file"
    sed -i '' 's/use App\\Learning\\Domain\\ValueObjects\\/use Learning\\Domain\\ValueObjects\\/g' "$file"
done

# Fix imports in all other Learning module files
find src/Learning -name "*.php" -type f | while read file; do
    echo "Checking imports in $file"
    sed -i '' 's/use App\\Learning\\Domain\\ValueObjects\\/use Learning\\Domain\\ValueObjects\\/g' "$file"
done

find tests/Unit/Learning -name "*.php" -type f | while read file; do
    echo "Checking imports in test $file"
    sed -i '' 's/use App\\Learning\\Domain\\ValueObjects\\/use Learning\\Domain\\ValueObjects\\/g' "$file"
done

echo "✅ Namespace fixes complete!" 