//
//  CourseViewModel.swift
//  LMS
//
//  Created on 27/01/2025.
//

import Foundation
import SwiftUI

class CourseViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var searchText = ""
    @Published var selectedCategory: String = "Все"
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Student specific properties
    @Published var enrolledCourses: [Course] = []
    @Published var availableCourses: [Course] = []
    
    private let service = CourseMockService.shared
    
    init() {
        loadCourses()
    }
    
    func loadCourses() {
        isLoading = true
        errorMessage = nil
        
        // In real app this would be an API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.courses = self?.service.getAllCourses() ?? []
            self?.enrolledCourses = self?.service.getEnrolledCourses() ?? []
            self?.availableCourses = self?.service.getAvailableCourses() ?? []
            self?.isLoading = false
        }
    }
    
    func enrollInCourse(_ course: Course) {
        service.enrollInCourse(course)
        loadCourses()
    }
    
    func leaveCourse(_ course: Course) {
        service.leaveCourse(course)
        loadCourses()
    }
}
