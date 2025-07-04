#!/bin/bash
#
# run-mutation-tests.sh
# Sprint 28: Mutation Testing Runner
# Created: 03/07/2025
#
# This script runs mutation testing for both iOS and PHP codebases

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create reports directory if it doesn't exist
mkdir -p reports/mutation

# Banner
echo "================================================"
echo "       LMS Mutation Testing Runner"
echo "       Sprint 28: Test Quality Improvement"
echo "================================================"
echo ""

# Check what to run
RUN_IOS=false
RUN_PHP=false

if [ "$1" == "ios" ]; then
    RUN_IOS=true
elif [ "$1" == "php" ]; then
    RUN_PHP=true
elif [ "$1" == "all" ] || [ -z "$1" ]; then
    RUN_IOS=true
    RUN_PHP=true
else
    print_error "Invalid argument. Usage: $0 [ios|php|all]"
    exit 1
fi

# iOS Mutation Testing with Muter
if [ "$RUN_IOS" = true ]; then
    echo ""
    echo "🍎 Running iOS Mutation Testing with Muter..."
    echo "============================================"
    
    # Check if muter is installed
    if ! command_exists muter; then
        print_warning "Muter not found. Installing..."
        brew install muter-mutation-testing/formulae/muter
    fi
    
    # Check if we're in the iOS project directory
    if [ -f "LMS.xcodeproj/project.pbxproj" ]; then
        MUTER_DIR="."
    elif [ -f "LMS_App/LMS/LMS.xcodeproj/project.pbxproj" ]; then
        MUTER_DIR="LMS_App/LMS"
    else
        print_error "iOS project not found. Please run from project root."
        exit 1
    fi
    
    cd "$MUTER_DIR"
    
    # Run mutation testing
    print_info "Starting mutation testing for iOS..."
    print_info "This may take several minutes..."
    
    if muter run; then
        print_success "iOS mutation testing completed!"
        
        # Parse results
        if [ -f "muter-report.json" ]; then
            MUTATION_SCORE=$(jq -r '.mutationScore' muter-report.json 2>/dev/null || echo "N/A")
            KILLED_MUTANTS=$(jq -r '.killedMutants' muter-report.json 2>/dev/null || echo "N/A")
            TOTAL_MUTANTS=$(jq -r '.totalMutants' muter-report.json 2>/dev/null || echo "N/A")
            
            echo ""
            echo "📊 iOS Mutation Testing Results:"
            echo "   Mutation Score: ${MUTATION_SCORE}%"
            echo "   Killed Mutants: ${KILLED_MUTANTS}/${TOTAL_MUTANTS}"
            
            # Check threshold
            if [ "$MUTATION_SCORE" != "N/A" ] && [ $(echo "$MUTATION_SCORE >= 60" | bc) -eq 1 ]; then
                print_success "✅ Mutation score meets threshold (≥60%)"
            else
                print_warning "⚠️  Mutation score below threshold (<60%)"
            fi
        fi
    else
        print_error "iOS mutation testing failed"
    fi
    
    cd - > /dev/null
fi

# PHP Mutation Testing with Infection
if [ "$RUN_PHP" = true ]; then
    echo ""
    echo "🐘 Running PHP Mutation Testing with Infection..."
    echo "================================================"
    
    # Check if infection is installed
    if [ ! -f "vendor/bin/infection" ]; then
        print_warning "Infection not found. Installing..."
        composer require --dev infection/infection
    fi
    
    # Run mutation testing
    print_info "Starting mutation testing for PHP..."
    print_info "This may take several minutes..."
    
    # First, ensure tests pass
    print_info "Running PHPUnit tests first..."
    if ./vendor/bin/phpunit --stop-on-failure > /dev/null 2>&1; then
        print_success "PHPUnit tests passed!"
        
        # Run infection
        if ./vendor/bin/infection --threads=4 --show-mutations; then
            print_success "PHP mutation testing completed!"
            
            # Parse results
            if [ -f "reports/mutation/infection.json" ]; then
                MSI=$(jq -r '.stats.msi' reports/mutation/infection.json 2>/dev/null || echo "N/A")
                COVERED_MSI=$(jq -r '.stats.coveredMsi' reports/mutation/infection.json 2>/dev/null || echo "N/A")
                KILLED=$(jq -r '.stats.killedCount' reports/mutation/infection.json 2>/dev/null || echo "N/A")
                TOTAL=$(jq -r '.stats.totalMutantsCount' reports/mutation/infection.json 2>/dev/null || echo "N/A")
                
                echo ""
                echo "📊 PHP Mutation Testing Results:"
                echo "   Mutation Score Indicator (MSI): ${MSI}%"
                echo "   Covered Code MSI: ${COVERED_MSI}%"
                echo "   Killed Mutants: ${KILLED}/${TOTAL}"
                
                # Check threshold
                if [ "$MSI" != "N/A" ] && [ $(echo "$MSI >= 80" | bc) -eq 1 ]; then
                    print_success "✅ MSI meets threshold (≥80%)"
                else
                    print_warning "⚠️  MSI below threshold (<80%)"
                fi
            fi
        else
            print_error "PHP mutation testing failed"
        fi
    else
        print_error "PHPUnit tests failed. Fix tests before running mutation testing."
        exit 1
    fi
fi

# Summary
echo ""
echo "================================================"
echo "       Mutation Testing Complete!"
echo "================================================"
echo ""
echo "📁 Reports generated in:"
if [ "$RUN_IOS" = true ]; then
    echo "   - iOS: reports/mutation/index.html"
fi
if [ "$RUN_PHP" = true ]; then
    echo "   - PHP: reports/mutation/infection.html"
fi
echo ""
print_info "View detailed reports for improvement suggestions"

# Tips for improvement
echo ""
echo "💡 Tips to improve mutation scores:"
echo "   1. Add tests for edge cases and error conditions"
echo "   2. Test all conditional branches"
echo "   3. Verify boundary conditions (off-by-one errors)"
echo "   4. Test exception handling"
echo "   5. Ensure assertions are specific and meaningful" 