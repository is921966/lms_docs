#!/bin/bash

# Script to fix namespace in Learning Domain classes
# Changes App\Learning\Domain to Learning\Domain

echo "🔧 Fixing namespace in Learning Domain classes..."

# Fix namespace in Domain entity files
find src/Learning/Domain -name "*.php" -type f -maxdepth 1 | while read file; do
    echo "Fixing namespace in $file"
    sed -i '' 's/namespace App\\Learning\\Domain;/namespace Learning\\Domain;/g' "$file"
done

# Fix namespace in Domain subdirectories
for dir in Events Services Repository Repositories Service; do
    if [ -d "src/Learning/Domain/$dir" ]; then
        find "src/Learning/Domain/$dir" -name "*.php" -type f | while read file; do
            echo "Fixing namespace in $file"
            sed -i '' 's/namespace App\\Learning\\Domain\\/namespace Learning\\Domain\\/g' "$file"
        done
    fi
done

# Fix imports in all test files
find tests/Unit/Learning -name "*.php" -type f | while read file; do
    echo "Fixing imports in test $file"
    # Fix Domain class imports
    sed -i '' 's/use App\\Learning\\Domain\\Course;/use Learning\\Domain\\Course;/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Module;/use Learning\\Domain\\Module;/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Lesson;/use Learning\\Domain\\Lesson;/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Certificate;/use Learning\\Domain\\Certificate;/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\CertificateTemplate;/use Learning\\Domain\\CertificateTemplate;/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Enrollment;/use Learning\\Domain\\Enrollment;/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Progress;/use Learning\\Domain\\Progress;/g' "$file"
    
    # Fix subdirectory imports
    sed -i '' 's/use App\\Learning\\Domain\\Events\\/use Learning\\Domain\\Events\\/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Services\\/use Learning\\Domain\\Services\\/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Repository\\/use Learning\\Domain\\Repository\\/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Repositories\\/use Learning\\Domain\\Repositories\\/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Service\\/use Learning\\Domain\\Service\\/g' "$file"
done

# Fix imports in all source files
find src/Learning -name "*.php" -type f | while read file; do
    echo "Fixing imports in source $file"
    # Fix Domain class imports
    sed -i '' 's/use App\\Learning\\Domain\\Course;/use Learning\\Domain\\Course;/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Module;/use Learning\\Domain\\Module;/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Lesson;/use Learning\\Domain\\Lesson;/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Certificate;/use Learning\\Domain\\Certificate;/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\CertificateTemplate;/use Learning\\Domain\\CertificateTemplate;/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Enrollment;/use Learning\\Domain\\Enrollment;/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Progress;/use Learning\\Domain\\Progress;/g' "$file"
    
    # Fix subdirectory imports
    sed -i '' 's/use App\\Learning\\Domain\\Events\\/use Learning\\Domain\\Events\\/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Services\\/use Learning\\Domain\\Services\\/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Repository\\/use Learning\\Domain\\Repository\\/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Repositories\\/use Learning\\Domain\\Repositories\\/g' "$file"
    sed -i '' 's/use App\\Learning\\Domain\\Service\\/use Learning\\Domain\\Service\\/g' "$file"
done

# Also fix the User\Domain\ValueObjects\UserId import since tests are looking for it
find tests/Unit/Learning -name "*.php" -type f | while read file; do
    echo "Fixing User imports in test $file"
    sed -i '' 's/use App\\User\\Domain\\ValueObjects\\UserId;/use User\\Domain\\ValueObjects\\UserId;/g' "$file"
done

echo "✅ Domain namespace fixes complete!" 