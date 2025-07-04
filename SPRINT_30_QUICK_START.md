# Sprint 30 - Quick Start Guide

**Sprint Goal**: Fix all tests + Setup CI/CD  
**Duration**: July 4-8, 2025

## 🚀 Day 1 Quick Start (July 4)

### 1. Update Project Time
```bash
python3 scripts/project-time.py set-day 140
```

### 2. Create Daily Report
```bash
./scripts/report.sh daily-create
```

### 3. Start with Mappers

#### Create UserMapper
```swift
// File: LMS_App/LMS/LMS/Common/Data/Mappers/UserMapper.swift
import Foundation

struct UserMapper {
    static func toDTO(from domain: DomainUser) -> UserDTO {
        // Implementation
    }
    
    static func toDomain(from dto: UserDTO) -> DomainUser? {
        // Implementation
    }
    
    static func toDTOs(from domains: [DomainUser]) -> [UserDTO] {
        // Implementation
    }
    
    static func toDomains(from dtos: [UserDTO]) -> [DomainUser] {
        // Implementation
    }
}
```

### 4. Test Your Mappers
```bash
cd LMS_App/LMS
./scripts/test-quick-ui.sh LMSTests/Common/Data/UserDTOTests/testUserMapper
```

## 📝 Daily Checklist

### Morning
- [ ] Check yesterday's test results
- [ ] Update project time
- [ ] Create daily report
- [ ] Review remaining test files

### During Development
- [ ] Write mapper implementation
- [ ] Run tests immediately
- [ ] Fix compilation errors
- [ ] Commit working code

### End of Day
- [ ] Run all tests
- [ ] Update progress in daily report
- [ ] Commit all changes
- [ ] Plan tomorrow's tasks

## 🔧 Common Commands

### Run Specific Test
```bash
./scripts/test-quick-ui.sh LMSTests/Path/To/Test
```

### Run All Tests
```bash
xcodebuild test -scheme LMS -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Check Compilation
```bash
xcodebuild -scheme LMS -destination 'generic/platform=iOS' -configuration Release clean build
```

### Generate Coverage Report
```bash
xcodebuild test -scheme LMS -enableCodeCoverage YES
```

## 📋 Files to Fix (Priority Order)

1. **UserDTOTests** - Needs UserMapper
2. **TestBuildersExampleTests** - Update examples
3. **EmailValidatorTests** - Parameterized tests
4. **DTOProtocolTests** - Protocol conformance
5. **UserListViewModelTests** - ViewModel updates
6. **APIClientIntegrationTests** - Integration fixes
7. **OnboardingTests** - Model updates
8. **AdminEditTests** - UI updates

## 🚨 Common Issues & Solutions

### Issue: "Cannot find 'UserMapper' in scope"
**Solution**: Create the mapper file first

### Issue: "Cannot convert value of type"
**Solution**: Check if model structure changed

### Issue: "Value of type has no member"
**Solution**: Update to new property names

### Issue: Test timeout
**Solution**: Use test-quick scripts with timeout

## 📞 Help & Resources

- **Methodology**: `technical_requirements/TDD_MANDATORY_GUIDE.md`
- **Test Patterns**: `docs/TESTING_GUIDE.md`
- **Architecture**: `technical_requirements/v1.0/technical_architecture.md`
- **Previous Issues**: `SPRINT_28_TEST_ISSUES_TECHNICAL_DEBT.md`

## ⚡ Pro Tips

1. **Fix one file at a time** - Don't try to fix everything at once
2. **Run tests immediately** - Don't wait to see if it works
3. **Commit frequently** - Small, working commits
4. **Use the Testing framework** - Not XCTest for new tests
5. **Check imports** - Foundation, XCTest, Testing as needed

---

**Remember**: The goal is 100% passing tests by end of sprint! 