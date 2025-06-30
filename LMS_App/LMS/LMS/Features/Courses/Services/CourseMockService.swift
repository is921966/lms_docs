//
//  CourseMockService.swift
//  LMS
//
//  Created on 27/01/2025.
//

import Foundation
import SwiftUI

class CourseMockService: ObservableObject {
    static let shared = CourseMockService()

    @Published var courses: [Course] = []
    @Published var enrolledCourses: [Course] = []
    @Published var availableCourses: [Course] = []

    init() {
        loadMockCourses()
    }

    private func loadMockCourses() {
        // Get categories
        let programmingCategory = CourseCategory.categories.first { $0.name == "IT" } ?? CourseCategory.categories[4]

        // Create mock courses
        courses = [
            Course(
                title: "iOS Development Basics",
                description: "Основы разработки под iOS",
                categoryId: programmingCategory.id,
                status: .published,
                type: .optional,
                modules: [],
                materials: [],
                testId: nil,
                competencyIds: [],
                positionIds: [],
                prerequisiteCourseIds: [],
                duration: "40 часов",
                estimatedHours: 40,
                passingScore: 70,
                certificateTemplateId: nil,
                maxAttempts: nil,
                createdBy: UUID(),
                createdAt: Date().addingTimeInterval(-86_400 * 30),
                updatedAt: Date().addingTimeInterval(-86_400 * 5),
                publishedAt: Date().addingTimeInterval(-86_400 * 30)
            ),
            Course(
                title: "SwiftUI Advanced",
                description: "Продвинутые техники SwiftUI",
                categoryId: programmingCategory.id,
                status: .published,
                type: .optional,
                modules: [],
                materials: [],
                testId: nil,
                competencyIds: [],
                positionIds: [],
                prerequisiteCourseIds: [],
                duration: "60 часов",
                estimatedHours: 60,
                passingScore: 80,
                certificateTemplateId: nil,
                maxAttempts: nil,
                createdBy: UUID(),
                createdAt: Date().addingTimeInterval(-86_400 * 60),
                updatedAt: Date().addingTimeInterval(-86_400 * 2),
                publishedAt: Date().addingTimeInterval(-86_400 * 60)
            )
        ]

        // Split into enrolled and available
        enrolledCourses = [courses[0]]
        availableCourses = [courses[1]]
    }

    func getAllCourses() -> [Course] {
        return courses
    }

    func getEnrolledCourses() -> [Course] {
        return enrolledCourses
    }

    func getAvailableCourses() -> [Course] {
        return availableCourses
    }

    func enrollInCourse(_ course: Course) {
        if let index = availableCourses.firstIndex(where: { $0.id == course.id }) {
            var enrolledCourse = availableCourses[index]
            enrolledCourses.append(enrolledCourse)
            availableCourses.remove(at: index)
        }
    }

    func leaveCourse(_ course: Course) {
        if let index = enrolledCourses.firstIndex(where: { $0.id == course.id }) {
            var leftCourse = enrolledCourses[index]
            availableCourses.append(leftCourse)
            enrolledCourses.remove(at: index)
        }
    }
}
