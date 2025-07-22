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
        // Create mock courses
        courses = [
            Course(
                title: "iOS Development Basics",
                description: "Основы разработки под iOS",
                categoryId: CourseCategory.technical.rawValue,
                status: .published,
                type: .optional,
                modules: [],
                duration: "40 часов",
                createdBy: UUID()
            ),
            Course(
                title: "SwiftUI Advanced",
                description: "Продвинутые техники SwiftUI",
                categoryId: CourseCategory.technical.rawValue,
                status: .published,
                type: .optional,
                modules: [],
                duration: "60 часов",
                createdBy: UUID()
            )
        ]

        // Split into enrolled and available
        enrolledCourses = [courses[0]]
        availableCourses = [courses[1]]
    }

    func getAllCourses() -> [Course] {
        courses
    }

    func getEnrolledCourses() -> [Course] {
        enrolledCourses
    }

    func getAvailableCourses() -> [Course] {
        availableCourses
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
