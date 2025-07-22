//
//  CourseDetailViewModel.swift
//  LMS
//
//  Created on Sprint 40 - Course Management Enhancement
//

import Foundation
import Combine

@MainActor
class CourseDetailViewModel: ObservableObject {
    @Published var course: ManagedCourse?
    @Published var isLoading = false
    @Published var error: String?
    
    private let courseId: UUID
    private let courseService: CourseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(courseId: UUID, courseService: CourseServiceProtocol = CourseService()) {
        self.courseId = courseId
        self.courseService = courseService
    }
    
    func loadCourse() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let loadedCourse = try await courseService.fetchCourse(id: courseId)
                self.course = loadedCourse
                self.isLoading = false
                print("📚 CourseDetailViewModel: Loaded course '\(loadedCourse.title)'")
            } catch {
                self.error = error.localizedDescription
                self.isLoading = false
                print("📚 CourseDetailViewModel: Failed to load course: \(error)")
            }
        }
    }
    
    func updateCourse(_ updatedCourse: ManagedCourse) {
        Task {
            do {
                let result = try await courseService.updateCourse(updatedCourse)
                self.course = result
                print("📚 CourseDetailViewModel: Updated course '\(result.title)'")
            } catch {
                self.error = error.localizedDescription
                print("📚 CourseDetailViewModel: Failed to update course: \(error)")
            }
        }
    }
    
    func deleteCourse() {
        Task {
            do {
                try await courseService.deleteCourse(id: courseId)
                print("📚 CourseDetailViewModel: Deleted course")
            } catch {
                self.error = error.localizedDescription
                print("📚 CourseDetailViewModel: Failed to delete course: \(error)")
            }
        }
    }
    
    func publishCourse() {
        guard var currentCourse = course else { return }
        currentCourse.status = .published
        updateCourse(currentCourse)
    }
    
    func archiveCourse() {
        guard var currentCourse = course else { return }
        currentCourse.status = .archived
        updateCourse(currentCourse)
    }
    
    func duplicateCourse() {
        guard let currentCourse = course else { return }
        
        let duplicatedCourse = ManagedCourse(
            id: UUID(),
            title: "\(currentCourse.title) (копия)",
            description: currentCourse.description,
            duration: currentCourse.duration,
            status: .draft,
            competencies: currentCourse.competencies,
            modules: currentCourse.modules,
            createdAt: Date(),
            updatedAt: Date(),
            cmi5PackageId: currentCourse.cmi5PackageId
        )
        
        Task {
            do {
                let newCourse = try await courseService.createCourse(duplicatedCourse)
                print("📚 CourseDetailViewModel: Duplicated course as '\(newCourse.title)'")
                // Optionally navigate to the new course
            } catch {
                self.error = error.localizedDescription
                print("📚 CourseDetailViewModel: Failed to duplicate course: \(error)")
            }
        }
    }
} 