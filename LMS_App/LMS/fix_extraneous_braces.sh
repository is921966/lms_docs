#!/bin/bash

# Function to remove extraneous closing braces at the end of test files
fix_file() {
    local file=$1
    # Remove trailing whitespace and empty lines, then check for extra }
    # Create temp file
    temp=$(mktemp)
    
    # Get all content except last non-empty line if it's just }
    awk 'NF {p=NR; lines[NR]=$0} END {for(i=1; i<=p; i++) print lines[i]}' "$file" | \
    awk '{if (NR==1 || prev!="}" || $0!="}" || NF>1) print; prev=$0}' > "$temp"
    
    # Replace original file
    mv "$temp" "$file"
}

# Fix the files with extraneous braces
fix_file "LMSTests/Views/PositionListViewTests.swift"
fix_file "LMSTests/Views/StudentDashboardViewTests.swift"
fix_file "LMSTests/Views/CompetencyListViewTests.swift"

echo "Fixed extraneous braces in test files"
