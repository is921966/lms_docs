# Sprint 37 Plan - Fix Tests & Achieve 15% Coverage

## 📅 Sprint Information
- **Sprint Number**: 37
- **Duration**: 5 days (Days 170-174)
- **Start Date**: July 7, 2025
- **Goal**: Fix service tests and achieve real 15% code coverage

## 🎯 Sprint Goals

### Primary Goals:
1. **Fix all 6 Service tests** written in Sprint 36
2. **Achieve 15% code coverage** (currently 11.63%)
3. **Create test infrastructure** for async testing
4. **Document testing best practices**

### Stretch Goals:
- Reach 17% coverage if time permits
- Add integration tests
- Set up coverage monitoring

## 📋 Sprint Backlog

### Day 170 - Fix Async Service Tests
- [ ] Fix NotificationServiceTests (async/await)
- [ ] Fix AnalyticsServiceTests 
- [ ] Update all UUID types
- [ ] Run and verify execution

### Day 171 - Fix Remaining Service Tests
- [ ] Fix FeedbackServiceTests
- [ ] Fix NetworkServiceTests
- [ ] Fix APIClientTests
- [ ] Fix OnboardingNotificationServiceTests

### Day 172 - Add Model & Extension Tests
- [ ] Add tests for remaining models
- [ ] Test data transformations
- [ ] Test utility extensions
- [ ] Focus on high-coverage targets

### Day 173 - Integration & E2E Tests
- [ ] Create integration test suite
- [ ] Test service interactions
- [ ] Add mock infrastructure
- [ ] Test error scenarios

### Day 174 - Finalize & Document
- [ ] Final coverage measurement
- [ ] Create testing guide
- [ ] Document lessons learned
- [ ] Set up CI/CD integration

## 🎯 Success Metrics

### Coverage Targets:
- **Minimum**: 15% (from 11.63%)
- **Target**: 17%
- **Stretch**: 20%

### Quality Metrics:
- All tests passing ✅
- No flaky tests
- < 5 second test execution
- Clear test documentation

## 🔧 Technical Approach

### Fix Strategy for Service Tests:
1. Update all `async/await` patterns
2. Change `String` to `UUID` where needed
3. Add proper test extensions
4. Use dependency injection for testing

### Coverage Focus Areas:
```
High ROI Targets:
├── Services/ (1,762 lines to fix)
├── Models/ (500+ lines available)
├── ViewModels/ (already good coverage)
└── Utilities/ (quick wins)

Avoid:
├── Views/ (0% coverage always)
├── UI Components/ (ViewInspector doesn't help)
└── SwiftUI Modifiers/ (untestable)
```

## ⚡ Risk Mitigation

### Identified Risks:
1. **API Drift** - Services may have changed more
   - Mitigation: Review current APIs first
   
2. **Async Complexity** - Testing async code is harder
   - Mitigation: Create async test helpers
   
3. **Time Investment** - May take longer than expected
   - Mitigation: Focus on highest ROI first

## 📝 Daily Success Criteria

Each day should:
- Fix at least 2 test files
- Add 1-2% coverage
- All tests must pass
- Document any API changes

## 🎯 Definition of Done

Sprint is complete when:
1. ✅ All 6 Service tests are working
2. ✅ Code coverage ≥ 15%
3. ✅ All tests pass consistently
4. ✅ Test guide documented
5. ✅ No compilation warnings in tests

---

## Summary

Sprint 37 focuses on fixing the technical debt from Sprint 36 and achieving the original 15% coverage goal. By fixing the already-written Service tests and adding targeted Model tests, we should easily surpass 15% coverage.

**Key Learning Applied**: Focus only on business logic, completely ignore UI testing. 