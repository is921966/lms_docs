# Sprint 23 - Learning Management Module - Plan

**Sprint Duration**: Условные дни 108-112 (July 2-6, 2025)  
**Goal**: Implement comprehensive learning management system  
**Approach**: TDD + Vertical Slice  

## 🎯 Sprint Goals

1. Create complete learning management backend
2. Achieve 95%+ test coverage
3. Design scalable course structure
4. Prepare for iOS integration

## 📋 User Stories

### Story 1: Course Management
**As a** course administrator  
**I need** to create and manage courses  
**So that** learners can access structured learning content

**Acceptance Criteria**:
- Create course with title, description, duration
- Update course details
- Activate/deactivate courses
- Set course prerequisites
- Define course modules

### Story 2: Lesson Management
**As a** content creator  
**I need** to create lessons within courses  
**So that** content is organized in digestible units

**Acceptance Criteria**:
- Create lessons with various content types (video, text, quiz)
- Order lessons within modules
- Set lesson duration and difficulty
- Mark lessons as mandatory/optional

### Story 3: Learning Progress
**As a** learner  
**I need** to track my learning progress  
**So that** I know what I've completed and what's remaining

**Acceptance Criteria**:
- Track lesson completion
- Calculate course progress percentage
- Record time spent on lessons
- Generate completion certificates

## 🏗️ Technical Architecture

### Domain Model:
```
Learning/
├── Domain/
│   ├── Course.php              # Aggregate root
│   ├── Module.php              # Course modules
│   ├── Lesson.php              # Individual lessons
│   ├── LearningPath.php       # Learning journey
│   ├── Progress.php            # User progress tracking
│   ├── Certificate.php         # Completion certificates
│   ├── ValueObjects/
│   │   ├── CourseId.php
│   │   ├── CourseCode.php
│   │   ├── Duration.php
│   │   ├── ContentType.php
│   │   └── ProgressStatus.php
│   ├── Events/
│   │   ├── CourseCreated.php
│   │   ├── LessonCompleted.php
│   │   └── CertificateIssued.php
│   └── Repositories/
│       ├── CourseRepositoryInterface.php
│       ├── ProgressRepositoryInterface.php
│       └── CertificateRepositoryInterface.php
```

## 📅 Daily Plan

### День 108 (Domain Layer)
- [ ] Course aggregate with tests (15 tests)
- [ ] Module and Lesson entities (10 tests)
- [ ] ValueObjects (10 tests)
- [ ] Domain events (5 tests)
- **Target**: 40 tests

### День 109 (Domain + Application)
- [ ] Progress tracking entity (10 tests)
- [ ] Certificate entity (5 tests)
- [ ] CQRS Commands (10 tests)
- [ ] Command Handlers (15 tests)
- **Target**: 40 tests

### День 110 (Application + Infrastructure)
- [ ] Query handlers (10 tests)
- [ ] DTOs (5 tests)
- [ ] In-memory repositories (15 tests)
- [ ] Integration tests (10 tests)
- **Target**: 40 tests

### День 111 (HTTP Layer)
- [ ] CourseController (10 tests)
- [ ] LessonController (10 tests)
- [ ] ProgressController (8 tests)
- [ ] Request/Response classes (7 tests)
- **Target**: 35 tests

### День 112 (Integration & Polish)
- [ ] OpenAPI specification
- [ ] Middleware integration
- [ ] E2E tests (10 tests)
- [ ] Documentation
- [ ] Fix any failing tests
- **Target**: 10+ tests

## 🎯 Success Metrics

- **Test Coverage**: 95%+
- **Total Tests**: 165+
- **All Tests Passing**: 100%
- **API Documentation**: Complete OpenAPI spec
- **Ready for Integration**: iOS app can connect

## 💡 Technical Decisions

1. **Content Storage**: References only (actual content in separate service)
2. **Progress Tracking**: Event-sourced for audit trail
3. **Certificates**: Generated as immutable records
4. **Prerequisites**: Graph-based dependency system

## 🚀 Definition of Done

- [ ] All tests written and passing
- [ ] Code review completed
- [ ] API documentation updated
- [ ] Integration tests passing
- [ ] Performance benchmarks met
- [ ] Security scan passed

---

**Note**: Learning from Sprint 22, we'll focus on architectural consistency from the start to avoid namespace issues. 