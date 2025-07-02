#!/bin/bash

# Script to add getValue() method to ID value objects that are missing it

echo "🔧 Adding getValue() method to ID value objects..."

# List of files that need getValue method
files=(
    "src/Learning/Domain/ValueObjects/EnrollmentId.php"
    "src/Learning/Domain/ValueObjects/CertificateId.php"
    "src/Learning/Domain/ValueObjects/ProgressId.php"
    "src/Learning/Domain/ValueObjects/ModuleId.php"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "Processing $file..."
        
        # Check if getValue method already exists
        if ! grep -q "public function getValue()" "$file"; then
            # Add getValue method after toString method
            sed -i '' '/public function toString(): string/,/^[[:space:]]*}/ {
                /^[[:space:]]*}/ a\
\
    public function getValue(): string\
    {\
        return $this->value;\
    }
            }' "$file"
            echo "✅ Added getValue() to $file"
        else
            echo "⏭️  getValue() already exists in $file"
        fi
    fi
done

echo "✅ ID value objects fixes complete!" 