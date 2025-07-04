//
//  CourseBuilder.swift
//  LMSTests
//
//  Created by AI Assistant on 03/07/2025.
//  Sprint 28: Test Quality Improvement
//

import Foundation
@testable import LMS

/// Builder pattern для создания тестовых курсов
class CourseBuilder {
    private var id: String = UUID().uuidString
    private var title: String = "Default Course"
    private var description: String = "Default Description"
    private var duration: Int = 40
    private var level: String = "beginner"
    private var competencies: [String] = []
    private var isActive: Bool = true
    private var createdAt: Date = Date()
    private var updatedAt: Date = Date()
    private var category: String = "Programming"
    private var maxStudents: Int = 30
    private var currentStudents: Int = 0
    
    // Builder methods
    func withId(_ id: String) -> CourseBuilder {
        self.id = id
        return self
    }
    
    func withTitle(_ title: String) -> CourseBuilder {
        self.title = title
        return self
    }
    
    func withDescription(_ description: String) -> CourseBuilder {
        self.description = description
        return self
    }
    
    func withDuration(_ duration: Int) -> CourseBuilder {
        self.duration = duration
        return self
    }
    
    func withLevel(_ level: String) -> CourseBuilder {
        self.level = level
        return self
    }
    
    func withCompetencies(_ competencies: [String]) -> CourseBuilder {
        self.competencies = competencies
        return self
    }
    
    func withActive(_ isActive: Bool) -> CourseBuilder {
        self.isActive = isActive
        return self
    }
    
    func withCreatedAt(_ date: Date) -> CourseBuilder {
        self.createdAt = date
        return self
    }
    
    func withUpdatedAt(_ date: Date) -> CourseBuilder {
        self.updatedAt = date
        return self
    }
    
    func withCategory(_ category: String) -> CourseBuilder {
        self.category = category
        return self
    }
    
    func withMaxStudents(_ max: Int) -> CourseBuilder {
        self.maxStudents = max
        return self
    }
    
    func withCurrentStudents(_ current: Int) -> CourseBuilder {
        self.currentStudents = current
        return self
    }
    
    // Convenience methods
    func asProgrammingCourse() -> CourseBuilder {
        self.category = "Programming"
        return self
    }
    
    func beginner() -> CourseBuilder {
        self.level = "beginner"
        self.duration = 20
        return self
    }
    
    func intermediate() -> CourseBuilder {
        self.level = "intermediate"
        self.duration = 40
        return self
    }
    
    func advanced() -> CourseBuilder {
        self.level = "advanced"
        self.duration = 60
        return self
    }
    
    func full() -> CourseBuilder {
        self.currentStudents = self.maxStudents
        return self
    }
    
    func inactive() -> CourseBuilder {
        self.isActive = false
        return self
    }
    
    // Build method
    func build() -> TestCourse {
        return TestCourse(
            id: id,
            title: title,
            description: description,
            duration: duration,
            level: level,
            competencies: competencies,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            category: category,
            maxStudents: maxStudents,
            currentStudents: currentStudents
        )
    }
    
    // Convenience factory methods
    static func beginnerCourse(title: String = "Beginner Course") -> TestCourse {
        return CourseBuilder()
            .withTitle(title)
            .withLevel("beginner")
            .withDuration(20)
            .build()
    }
    
    static func advancedCourse(title: String = "Advanced Course") -> TestCourse {
        return CourseBuilder()
            .withTitle(title)
            .withLevel("advanced")
            .withDuration(80)
            .withCompetencies(["advanced-skill-1", "advanced-skill-2"])
            .build()
    }
    
    static func inactiveCourse(title: String = "Inactive Course") -> TestCourse {
        return CourseBuilder()
            .withTitle(title)
            .withActive(false)
            .build()
    }
    
    static func courseWithCompetencies(_ competencies: [String]) -> TestCourse {
        return CourseBuilder()
            .withTitle("Course with \(competencies.count) competencies")
            .withCompetencies(competencies)
            .build()
    }
}

 