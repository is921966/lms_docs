#!/bin/bash

echo "🧪 Running Phase 2 UI Tests..."
echo "==============================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to run test and report result
run_test() {
    local test_name=$1
    echo -n "Running $test_name... "
    
    if xcodebuild test \
        -scheme LMS \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
        -only-testing:LMSUITests/$test_name \
        -quiet 2>/dev/null; then
        echo -e "${GREEN}✅ PASSED${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

# Track results
total_tests=0
passed_tests=0

echo "📋 User Management Tests"
echo "------------------------"
tests=(
    "UserManagementUITests/testViewUsersList"
    "UserManagementUITests/testSearchUsers"
    "UserManagementUITests/testCreateNewUser"
    "UserManagementUITests/testEditUserDetails"
    "UserManagementUITests/testDeactivateUser"
    "UserManagementUITests/testBulkUserImport"
)

for test in "${tests[@]}"; do
    ((total_tests++))
    if run_test "$test"; then
        ((passed_tests++))
    fi
done

echo ""
echo "📋 Position Management Tests"
echo "-------------------------"
tests=(
    "PositionManagementUITests/testViewPositionsList"
    "PositionManagementUITests/testCreateNewPosition"
    "PositionManagementUITests/testEditPositionRequirements"
    "PositionManagementUITests/testPositionHierarchy"
    "PositionManagementUITests/testCareerPathCreation"
)

for test in "${tests[@]}"; do
    ((total_tests++))
    if run_test "$test"; then
        ((passed_tests++))
    fi
done

echo ""
echo "📋 Competency Management Tests"
echo "-----------------------------"
tests=(
    "CompetencyManagementUITests/testViewCompetenciesList"
    "CompetencyManagementUITests/testCreateNewCompetency"
    "CompetencyManagementUITests/testEditCompetencyLevels"
    "CompetencyManagementUITests/testAssignCompetencyToUser"
    "CompetencyManagementUITests/testCompetencyMatrix"
    "CompetencyManagementUITests/testCompetencyAssessment"
    "CompetencyManagementUITests/testCompetencyGapAnalysis"
)

for test in "${tests[@]}"; do
    ((total_tests++))
    if run_test "$test"; then
        ((passed_tests++))
    fi
done

echo ""
echo "==============================="
echo "📊 Phase 2 Test Results:"
echo "Total Tests: $total_tests"
echo -e "Passed: ${GREEN}$passed_tests${NC}"
echo -e "Failed: ${RED}$((total_tests - passed_tests))${NC}"
echo -e "Success Rate: ${GREEN}$(( passed_tests * 100 / total_tests ))%${NC}"
echo "==============================="

# Exit with error if any tests failed
if [ $passed_tests -ne $total_tests ]; then
    exit 1
fi 