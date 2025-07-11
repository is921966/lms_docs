//
//  Course.swift
//  LMSTests
//
//  Created by AI Assistant on 04/07/25.
//

import Foundation

// Test model for Course to use in tests
// Renamed from Course to TestCourse to avoid naming conflicts
struct TestCourse: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let duration: Int // in hours
    let level: String
    let competencies: [String]
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    let category: String
    let maxStudents: Int
    let currentStudents: Int
    
    // Computed properties
    var isFull: Bool {
        return currentStudents >= maxStudents
    }
    
    var availableSeats: Int {
        return max(0, maxStudents - currentStudents)
    }
    
    var enrollmentPercentage: Double {
        guard maxStudents > 0 else { return 0 }
        return Double(currentStudents) / Double(maxStudents) * 100
    }
    
    // Convenience initializer with defaults
    init(
        id: String = UUID().uuidString,
        title: String = "Test Course",
        description: String = "Test Description",
        duration: Int = 40,
        level: String = "beginner",
        competencies: [String] = [],
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        category: String = "Programming",
        maxStudents: Int = 30,
        currentStudents: Int = 0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.level = level
        self.competencies = competencies
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.category = category
        self.maxStudents = maxStudents
        self.currentStudents = currentStudents
    }
    
    // Static factory methods for common test scenarios
    static func mockCourses(count: Int = 5) -> [TestCourse] {
        return (1...count).map { index in
            TestCourse(
                id: "course-\(index)",
                title: "Course \(index)",
                description: "Description for course \(index)",
                duration: index * 10,
                level: index % 2 == 0 ? "intermediate" : "beginner",
                competencies: ["comp-\(index)", "comp-\(index + 1)"]
            )
        }
    }
}
