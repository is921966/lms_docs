//
//  AssignCourseViewModel.swift
//  LMS
//
//  Created on Sprint 40 - Course Management Enhancement
//

import Foundation
import Combine

@MainActor
class AssignCourseViewModel: ObservableObject {
    @Published var students: [Student] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let courseService: CourseServiceProtocol
    
    init(courseService: CourseServiceProtocol = CourseService()) {
        self.courseService = courseService
    }
    
    func loadStudents() {
        isLoading = true
        error = nil
        
        // В реальном приложении здесь будет вызов UserService
        // Пока используем моковые данные
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            self.students = Student.mockStudents
            self.isLoading = false
            print("📚 AssignCourseViewModel: Loaded \(students.count) students")
        }
    }
    
    func assignCourse(courseId: UUID, studentIds: [UUID], deadline: Date) {
        Task {
            do {
                try await courseService.assignCourseToUsers(courseId: courseId, userIds: studentIds)
                print("📚 AssignCourseViewModel: Assigned course to \(studentIds.count) students")
                
                // Отправляем уведомление об успешном назначении
                NotificationCenter.default.post(
                    name: NSNotification.Name("CourseAssigned"),
                    object: nil,
                    userInfo: [
                        "courseId": courseId,
                        "studentCount": studentIds.count,
                        "deadline": deadline
                    ]
                )
            } catch {
                self.error = error.localizedDescription
                print("📚 AssignCourseViewModel: Failed to assign course: \(error)")
            }
        }
    }
} 