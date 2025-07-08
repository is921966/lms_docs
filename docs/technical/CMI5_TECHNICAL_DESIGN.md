# Technical Design: Cmi5 Integration for Course Management

**Version**: 1.0.0  
**Date**: January 8, 2025  
**Sprint**: 40-42

## Overview

This document describes the technical implementation of Cmi5 support integration into the existing Course Management system.

## Architecture Decisions

### 1. Integration Approach
We will extend the existing Course/Module/Lesson structure rather than creating a separate system:
- Lessons can have a new content type: `.cmi5(Cmi5Activity)`
- Course materials can include Cmi5 packages
- Unified player will handle all content types

### 2. Data Model Extensions

#### Lesson Content Type Addition
```swift
enum LessonContent: Codable {
    case video(url: String, subtitlesUrl: String?)
    case text(html: String)
    case interactive(url: String)
    case quiz(questions: [CourseQuizQuestion])
    case assignment(instructions: String, dueDate: Date?)
    case cmi5(activity: Cmi5Activity) // NEW
}
```

#### New Models
```swift
// Cmi5 Package - represents imported .zip file
struct Cmi5Package: Identifiable, Codable {
    let id: UUID
    let courseId: UUID?
    let packageName: String
    let packageVersion: String?
    let manifest: Cmi5Manifest
    let activities: [Cmi5Activity]
    let uploadedAt: Date
    let uploadedBy: UUID
    let fileSize: Int64
    let status: PackageStatus
    
    enum PackageStatus: String, Codable {
        case processing
        case valid
        case invalid
        case archived
    }
}

// Cmi5 Activity - individual learning activity
struct Cmi5Activity: Identifiable, Codable {
    let id: UUID
    let packageId: UUID
    let activityId: String // from manifest
    let title: String
    let description: String?
    let launchUrl: String
    let launchMethod: LaunchMethod
    let moveOn: MoveOnCriteria
    let masteryScore: Double?
    let activityType: String
    let duration: String? // ISO 8601
    
    enum LaunchMethod: String, Codable {
        case ownWindow = "OwnWindow"
        case anyWindow = "AnyWindow"
    }
    
    enum MoveOnCriteria: String, Codable {
        case passed = "Passed"
        case completed = "Completed"
        case completedAndPassed = "CompletedAndPassed"
        case completedOrPassed = "CompletedOrPassed"
        case notApplicable = "NotApplicable"
    }
}

// xAPI Statement - for tracking
struct XAPIStatement: Codable {
    let id: UUID
    let actor: XAPIActor
    let verb: XAPIVerb
    let object: XAPIObject
    let result: XAPIResult?
    let context: XAPIContext?
    let timestamp: Date
    let stored: Date
    let authority: XAPIActor?
}
```

### 3. Service Architecture

#### New Services
1. **Cmi5Service** - Package management and activity launching
2. **XAPIService** - Statement processing and LRS communication
3. **Cmi5Parser** - Package validation and parsing
4. **OfflineSyncService** - Statement queue management

#### Extended Services
1. **CourseService** - Add Cmi5 import methods
2. **LearningService** - Handle Cmi5 progress tracking

### 4. UI Integration

#### CourseDetailView Changes
- Add "Import Cmi5" button in content section
- Show Cmi5 icon for activities
- Display xAPI analytics tab

#### New Views
1. **Cmi5ImportView** - Drag & drop import UI
2. **Cmi5PlayerView** - WebView-based player
3. **XAPIAnalyticsView** - Statement visualization

### 5. Database Schema

#### New Tables
```sql
-- Cmi5 packages
CREATE TABLE cmi5_packages (
    id UUID PRIMARY KEY,
    course_id UUID REFERENCES courses(id),
    package_name VARCHAR(255) NOT NULL,
    package_version VARCHAR(50),
    manifest_data JSONB NOT NULL,
    file_path VARCHAR(500),
    file_size BIGINT,
    status VARCHAR(20),
    uploaded_by UUID NOT NULL,
    uploaded_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Cmi5 activities
CREATE TABLE cmi5_activities (
    id UUID PRIMARY KEY,
    package_id UUID REFERENCES cmi5_packages(id),
    activity_id VARCHAR(255) NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    launch_url VARCHAR(1000) NOT NULL,
    launch_method VARCHAR(20),
    move_on VARCHAR(30),
    mastery_score DECIMAL(5,2),
    activity_type VARCHAR(100),
    duration VARCHAR(50),
    metadata JSONB
);

-- xAPI statements
CREATE TABLE xapi_statements (
    id UUID PRIMARY KEY,
    statement_id UUID UNIQUE NOT NULL,
    actor JSONB NOT NULL,
    verb JSONB NOT NULL,
    object JSONB NOT NULL,
    result JSONB,
    context JSONB,
    timestamp TIMESTAMP NOT NULL,
    stored TIMESTAMP DEFAULT NOW(),
    authority JSONB,
    version VARCHAR(10),
    attachments JSONB[]
);

-- Link lessons to Cmi5 activities
ALTER TABLE lessons 
ADD COLUMN cmi5_activity_id UUID REFERENCES cmi5_activities(id),
ADD COLUMN content_type VARCHAR(20) DEFAULT 'standard';
```

### 6. API Endpoints

#### Course API Extensions
```
POST   /api/courses/{id}/cmi5/import
GET    /api/courses/{id}/cmi5/packages
DELETE /api/courses/{id}/cmi5/packages/{packageId}
```

#### xAPI Endpoints
```
POST   /xapi/statements
GET    /xapi/statements
POST   /xapi/activities/state
GET    /xapi/activities/state
```

### 7. Security Considerations

1. **Package Validation** - Scan for malicious content
2. **CORS Configuration** - For Cmi5 content
3. **Statement Signing** - Verify authenticity
4. **Data Privacy** - PII handling in statements

### 8. Performance Optimization

1. **Chunked Upload** - For large packages
2. **Background Processing** - Package extraction
3. **Statement Batching** - Reduce API calls
4. **CDN Integration** - For content delivery

### 9. Migration Strategy

1. **Phase 1** - Core functionality (Sprint 40)
2. **Phase 2** - Player and tracking (Sprint 41)
3. **Phase 3** - Analytics and optimization (Sprint 42)

### 10. Testing Strategy

1. **Unit Tests** - All new models and services
2. **Integration Tests** - API endpoints
3. **E2E Tests** - Complete workflows
4. **Performance Tests** - Large package handling
5. **Compatibility Tests** - Various Cmi5 packages

## Success Criteria

1. Import any valid Cmi5 package < 30s (up to 100MB)
2. Launch activities in unified player
3. Track all xAPI statements
4. Offline support with sync
5. No regression in existing functionality

---
*This design ensures seamless integration of Cmi5 while maintaining the existing Course Management architecture.* 