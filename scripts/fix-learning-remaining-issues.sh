#!/bin/bash

# Script to fix remaining issues in Learning module
# Fixes toString() calls, Common exceptions imports, and other issues

echo "🔧 Fixing remaining issues in Learning module..."

# Fix toString() calls to getValue()
echo "📝 Fixing toString() calls to getValue()..."
find src/Learning tests/Unit/Learning -name "*.php" -type f | while read file; do
    # CourseId toString() -> getValue()
    sed -i '' 's/->toString()/->getValue()/g' "$file"
    # Fix in DTO files specifically
    sed -i '' 's/\$courseId->toString()/\$courseId->getValue()/g' "$file"
    sed -i '' 's/\$enrollmentId->toString()/\$enrollmentId->getValue()/g' "$file"
    sed -i '' 's/\$certificateId->toString()/\$certificateId->getValue()/g' "$file"
    sed -i '' 's/\$moduleId->toString()/\$moduleId->getValue()/g' "$file"
    sed -i '' 's/\$lessonId->toString()/\$lessonId->getValue()/g' "$file"
    sed -i '' 's/\$progressId->toString()/\$progressId->getValue()/g' "$file"
    sed -i '' 's/getId()->toString()/getId()->getValue()/g' "$file"
done

# Fix Common exceptions imports
echo "📝 Fixing Common exceptions imports..."
find src/Learning tests/Unit/Learning -name "*.php" -type f | while read file; do
    sed -i '' 's/use App\\Common\\Exceptions\\BusinessLogicException;/use Common\\Exceptions\\BusinessLogicException;/g' "$file"
    sed -i '' 's/use App\\Common\\Exceptions\\NotFoundException;/use Common\\Exceptions\\NotFoundException;/g' "$file"
    sed -i '' 's/App\\Common\\Exceptions\\BusinessLogicException/Common\\Exceptions\\BusinessLogicException/g' "$file"
    sed -i '' 's/App\\Common\\Exceptions\\NotFoundException/Common\\Exceptions\\NotFoundException/g' "$file"
done

# Fix Learning\Domain\Entities\Course to Learning\Domain\Course
echo "📝 Fixing Domain\Entities references..."
find src/Learning tests/Unit/Learning -name "*.php" -type f | while read file; do
    sed -i '' 's/Learning\\Domain\\Entities\\Course/Learning\\Domain\\Course/g' "$file"
    sed -i '' 's/use Learning\\Domain\\Entities\\Course;/use Learning\\Domain\\Course;/g' "$file"
done

# Fix CourseDTO::fromArray method to constructor
echo "📝 Fixing CourseDTO::fromArray calls..."
find tests/Unit/Learning -name "*.php" -type f | while read file; do
    # This is more complex, need to check the actual usage
    if grep -q "CourseDTO::fromArray" "$file"; then
        echo "  Found fromArray usage in $file - needs manual fix"
    fi
done

# Fix remaining App\Learning\Domain\ValueObjects\EnrollmentId imports
echo "📝 Fixing remaining ValueObject imports..."
find src/Learning tests/Unit/Learning -name "*.php" -type f | while read file; do
    sed -i '' 's/App\\Learning\\Domain\\ValueObjects\\EnrollmentId/Learning\\Domain\\ValueObjects\\EnrollmentId/g' "$file"
done

echo "✅ Remaining issues fixes complete!"
echo ""
echo "⚠️  Note: Some issues may require manual fixes:"
echo "   - CourseDTO::fromArray() method calls"
echo "   - Course::create() parameter order issues"
echo "   - CourseDTO constructor parameter mismatches" 