#!/bin/bash

# Test script for full Cmi5 import functionality with ZIPFoundation
# This script runs integration tests for Cmi5 import

set -e

echo "🧪 Testing Full Cmi5 Import Functionality"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Change to project directory
cd "$(dirname "$0")/.."

echo "📁 Working directory: $(pwd)"
echo ""

# Function to run tests with timeout
run_test() {
    local test_name=$1
    local timeout=${2:-60}
    
    echo -n "Running $test_name... "
    
    if timeout $timeout xcodebuild test \
        -scheme LMS \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
        -only-testing:"$test_name" \
        -quiet 2>&1 | tail -20; then
        echo -e "${GREEN}✅ PASSED${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

# Clean DerivedData
echo "🧹 Cleaning DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*
echo ""

# Build the project first
echo "🔨 Building project..."
if xcodebuild build-for-testing \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -quiet; then
    echo -e "${GREEN}✅ Build successful${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi
echo ""

# Run Cmi5 specific tests
echo "🧪 Running Cmi5 Tests..."
echo "------------------------"

# Test Archive Handler
run_test "LMSTests/Cmi5ArchiveHandlerTests"

# Test Parser
run_test "LMSTests/Cmi5ParserTests"

# Test Service
run_test "LMSTests/Cmi5ServiceTests"

# Test Import Integration
run_test "LMSTests/Cmi5ImportIntegrationTests"

echo ""
echo "🧪 Running UI Tests..."
echo "----------------------"

# Test Import UI
run_test "LMSUITests/Cmi5ImportUITests" 120

echo ""
echo "✨ Test Summary"
echo "==============="
echo ""

# Check if ZIPFoundation is properly linked
echo -n "Checking ZIPFoundation integration... "
if grep -q "ZIPFoundation" LMS.xcodeproj/project.pbxproj; then
    echo -e "${GREEN}✅ Found${NC}"
else
    echo -e "${RED}❌ Not found${NC}"
fi

# Check if Package.swift has ZIPFoundation
echo -n "Checking Package.swift... "
if grep -q "ZIPFoundation" Package.swift; then
    echo -e "${GREEN}✅ Configured${NC}"
else
    echo -e "${RED}❌ Missing${NC}"
fi

# Check if import statements are present
echo -n "Checking ZIPFoundation imports... "
if grep -r "import ZIPFoundation" LMS/Features/Cmi5/ > /dev/null; then
    echo -e "${GREEN}✅ Found${NC}"
else
    echo -e "${RED}❌ Not found${NC}"
fi

echo ""
echo "🎉 Cmi5 import testing complete!"
echo ""

# Optional: Create a demo ZIP for manual testing
echo "Would you like to create a demo ZIP package for manual testing? (y/n)"
read -r response
if [[ "$response" == "y" ]]; then
    echo "Creating demo package..."
    
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    
    # Create cmi5.xml
    cat > "$TEMP_DIR/cmi5.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<courseStructure xmlns="https://w3id.org/xapi/profiles/cmi5/v1/coursestructure.xsd">
    <course id="test-course-001">
        <title>
            <langstring lang="ru">Тестовый курс Cmi5</langstring>
        </title>
        <description>
            <langstring lang="ru">Демонстрационный курс для тестирования импорта</langstring>
        </description>
    </course>
    <au id="lesson-1" moveOn="Passed" launchMethod="OwnWindow">
        <title>
            <langstring lang="ru">Урок 1: Введение</langstring>
        </title>
        <url>content/lesson1.html</url>
    </au>
</courseStructure>
EOF
    
    # Create content directory
    mkdir -p "$TEMP_DIR/content"
    
    # Create lesson HTML
    cat > "$TEMP_DIR/content/lesson1.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Урок 1: Введение</title>
    <meta charset="utf-8">
    <style>
        body { font-family: -apple-system, system-ui; padding: 20px; }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>Добро пожаловать в тестовый курс!</h1>
    <p>Это демонстрационный урок для проверки импорта Cmi5.</p>
    <button onclick="alert('Урок завершен!')">Завершить урок</button>
</body>
</html>
EOF
    
    # Create ZIP
    cd "$TEMP_DIR"
    zip -r ~/Desktop/test-cmi5-course.zip .
    cd - > /dev/null
    
    # Cleanup
    rm -rf "$TEMP_DIR"
    
    echo -e "${GREEN}✅ Demo package created at ~/Desktop/test-cmi5-course.zip${NC}"
    echo "You can now test importing this file in the app!"
fi 