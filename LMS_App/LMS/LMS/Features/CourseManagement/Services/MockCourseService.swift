//
//  MockCourseService.swift
//  LMS
//
//  Mock implementation of CourseService for development
//

import Foundation

@MainActor
class MockCourseService: CourseServiceProtocol, ObservableObject {
    @Published var courses: [ManagedCourse] = []
    @Published var isLoading = false
    
    init() {
        loadSampleCourses()
    }
    
    // MARK: - CourseServiceProtocol
    
    func fetchCourses() async throws -> [ManagedCourse] {
        return courses
    }
    
    func fetchCourse(id: UUID) async throws -> ManagedCourse {
        guard let course = courses.first(where: { $0.id == id }) else {
            throw CourseError.courseNotFound
        }
        return course
    }
    
    func createCourse(_ course: ManagedCourse) async throws -> ManagedCourse {
        courses.append(course)
        return course
    }
    
    func updateCourse(_ course: ManagedCourse) async throws -> ManagedCourse {
        guard let index = courses.firstIndex(where: { $0.id == course.id }) else {
            throw CourseError.courseNotFound
        }
        courses[index] = course
        return course
    }
    
    func deleteCourse(id: UUID) async throws {
        guard courses.contains(where: { $0.id == id }) else {
            throw CourseError.courseNotFound
        }
        courses.removeAll { $0.id == id }
    }
    
    func assignCourseToUsers(courseId: UUID, userIds: [UUID]) async throws {
        // Mock implementation
        print("📚 MockCourseService: Assigning course \(courseId) to \(userIds.count) users")
    }
    
    // MARK: - Duplication
    
    func duplicateCourse(_ id: UUID) async throws -> ManagedCourse {
        // Find original course
        guard let originalCourse = courses.first(where: { $0.id == id }) else {
            throw CourseError.courseNotFound
        }
        
        // Generate new title
        let newTitle = generateDuplicateTitle(for: originalCourse.title)
        
        // Create duplicated modules with new IDs
        let duplicatedModules = originalCourse.modules.map { module in
            ManagedCourseModule(
                id: UUID(),
                title: module.title,
                description: module.description,
                order: module.order,
                contentType: module.contentType,
                contentUrl: module.contentUrl,
                duration: module.duration
            )
        }
        
        // Create duplicated course
        let duplicatedCourse = ManagedCourse(
            id: UUID(),
            title: newTitle,
            description: originalCourse.description,
            duration: originalCourse.duration,
            status: .draft, // Always draft for duplicates
            competencies: originalCourse.competencies, // Same competencies
            modules: duplicatedModules,
            createdAt: Date(),
            updatedAt: Date(),
            cmi5PackageId: originalCourse.cmi5PackageId
        )
        
        // Add to courses
        courses.append(duplicatedCourse)
        
        return duplicatedCourse
    }
    
    private func generateDuplicateTitle(for originalTitle: String) -> String {
        // Check if title already has (копия) suffix
        let copyPattern = #" \(копия(?: (\d+))?\)$"#
        
        if let regex = try? NSRegularExpression(pattern: copyPattern) {
            let range = NSRange(location: 0, length: originalTitle.count)
            
            // If it already has (копия), increment the number
            if let match = regex.firstMatch(in: originalTitle, range: range) {
                let baseTitle = String(originalTitle.prefix(match.range.location))
                
                // Extract the number if present
                if match.numberOfRanges > 1,
                   let numberRange = Range(match.range(at: 1), in: originalTitle),
                   let currentNumber = Int(originalTitle[numberRange]) {
                    return "\(baseTitle) (копия \(currentNumber + 1))"
                } else {
                    // First copy doesn't have number, so add 2
                    return "\(baseTitle) (копия 2)"
                }
            }
        }
        
        // No (копия) suffix found, add it
        return "\(originalTitle) (копия)"
    }
    
    // MARK: - Sample Data
    
    private func loadSampleCourses() {
        courses = [
            ManagedCourse(
                title: "Swift для начинающих",
                description: "Основы языка программирования Swift",
                duration: 40,
                status: .published,
                competencies: [UUID()],
                modules: [
                    ManagedCourseModule(
                        id: UUID(),
                        title: "Введение в Swift",
                        description: "Основные концепции языка",
                        order: 1,
                        contentType: .video,
                        contentUrl: nil,
                        duration: 60
                    )
                ]
            ),
            ManagedCourse(
                title: "UIKit Fundamentals",
                description: "Основы разработки интерфейсов с UIKit",
                duration: 60,
                status: .draft
            ),
            ManagedCourse(
                title: "SwiftUI Essentials",
                description: "Современный подход к созданию UI",
                duration: 50,
                status: .published,
                cmi5PackageId: UUID()
            )
        ]
    }
} 