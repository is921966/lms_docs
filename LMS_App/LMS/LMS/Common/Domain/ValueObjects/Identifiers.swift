//
//  Identifiers.swift
//  LMS
//
//  Created by AI Assistant on 01/31/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation

// MARK: - Base Identifier

/// Base protocol for all identifiers in the system
public protocol Identifier: StringValueObject {
    static var prefix: String { get }
}

public extension Identifier {
    static var minLength: Int { 3 }
    static var maxLength: Int { 50 }
    static var pattern: String? { "^[A-Za-z0-9_-]+$" }
    
    static func isValid(_ value: String) -> Bool {
        // First check basic string validation
        guard value.count >= minLength && value.count <= maxLength else {
            return false
        }
        
        // Check prefix if required
        if !prefix.isEmpty && !value.hasPrefix(prefix) {
            return false
        }
        
        // Check pattern
        if let pattern = pattern {
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: value.utf16.count)
            return regex?.firstMatch(in: value, options: [], range: range) != nil
        }
        
        return true
    }
}

// MARK: - Course Identifier

/// Unique identifier for a Course
public struct CourseId: Identifier {
    public let value: String
    public static let prefix = "COURSE_"
    
    public init?(_ value: String) {
        guard Self.isValid(value) else { return nil }
        self.value = value
    }
    
    /// Creates a new unique CourseId
    public static func generate() -> CourseId {
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return CourseId("\(prefix)\(uuid)")!
    }
}

// MARK: - Lesson Identifier

/// Unique identifier for a Lesson
public struct LessonId: Identifier {
    public let value: String
    public static let prefix = "LESSON_"
    
    public init?(_ value: String) {
        guard Self.isValid(value) else { return nil }
        self.value = value
    }
    
    /// Creates a new unique LessonId
    public static func generate() -> LessonId {
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return LessonId("\(prefix)\(uuid)")!
    }
}

// MARK: - Test Identifier

/// Unique identifier for a Test
public struct TestId: Identifier {
    public let value: String
    public static let prefix = "TEST_"
    
    public init?(_ value: String) {
        guard Self.isValid(value) else { return nil }
        self.value = value
    }
    
    /// Creates a new unique TestId
    public static func generate() -> TestId {
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return TestId("\(prefix)\(uuid)")!
    }
}

// MARK: - User Identifier

/// Unique identifier for a User
public struct UserId: Identifier {
    public let value: String
    public static let prefix = "USER_"
    
    public init?(_ value: String) {
        guard Self.isValid(value) else { return nil }
        self.value = value
    }
    
    /// Creates a new unique UserId
    public static func generate() -> UserId {
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return UserId("\(prefix)\(uuid)")!
    }
}

// MARK: - Competency Identifier

/// Unique identifier for a Competency
public struct CompetencyId: Identifier {
    public let value: String
    public static let prefix = "COMP_"
    
    public init?(_ value: String) {
        guard Self.isValid(value) else { return nil }
        self.value = value
    }
    
    /// Creates a new unique CompetencyId
    public static func generate() -> CompetencyId {
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return CompetencyId("\(prefix)\(uuid)")!
    }
}

// MARK: - Position Identifier

/// Unique identifier for a Position
public struct PositionId: Identifier {
    public let value: String
    public static let prefix = "POS_"
    
    public init?(_ value: String) {
        guard Self.isValid(value) else { return nil }
        self.value = value
    }
    
    /// Creates a new unique PositionId
    public static func generate() -> PositionId {
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return PositionId("\(prefix)\(uuid)")!
    }
} 