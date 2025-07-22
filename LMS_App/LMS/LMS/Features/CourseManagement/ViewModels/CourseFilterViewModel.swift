//
//  CourseFilterViewModel.swift
//  LMS
//
//  ViewModel for course filtering functionality
//

import Foundation
import SwiftUI

@MainActor
class CourseFilterViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published private var allCourses: [ManagedCourse]
    
    // Status filter
    @Published var selectedStatus: ManagedCourseStatus?
    
    // Type filters
    @Published var showOnlyCmi5 = false
    @Published var showOnlyRegular = false
    
    // Module filters
    @Published var showOnlyWithModules = false
    @Published var showOnlyWithoutModules = false
    
    // Competency filters
    @Published var showOnlyWithCompetencies = false
    @Published var showOnlyWithoutCompetencies = false
    
    // MARK: - Computed Properties
    
    var filteredCourses: [ManagedCourse] {
        var result = allCourses
        
        // Apply status filter
        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }
        
        // Apply type filters
        if showOnlyCmi5 {
            result = result.filter { $0.cmi5PackageId != nil }
        } else if showOnlyRegular {
            result = result.filter { $0.cmi5PackageId == nil }
        }
        
        // Apply module filters
        if showOnlyWithModules {
            result = result.filter { !$0.modules.isEmpty }
        } else if showOnlyWithoutModules {
            result = result.filter { $0.modules.isEmpty }
        }
        
        // Apply competency filters
        if showOnlyWithCompetencies {
            result = result.filter { !$0.competencies.isEmpty }
        } else if showOnlyWithoutCompetencies {
            result = result.filter { $0.competencies.isEmpty }
        }
        
        return result
    }
    
    var hasActiveFilters: Bool {
        selectedStatus != nil ||
        showOnlyCmi5 ||
        showOnlyRegular ||
        showOnlyWithModules ||
        showOnlyWithoutModules ||
        showOnlyWithCompetencies ||
        showOnlyWithoutCompetencies
    }
    
    var activeFilterCount: Int {
        var count = 0
        if selectedStatus != nil { count += 1 }
        if showOnlyCmi5 { count += 1 }
        if showOnlyRegular { count += 1 }
        if showOnlyWithModules { count += 1 }
        if showOnlyWithoutModules { count += 1 }
        if showOnlyWithCompetencies { count += 1 }
        if showOnlyWithoutCompetencies { count += 1 }
        return count
    }
    
    // MARK: - Initialization
    
    init(courses: [ManagedCourse]) {
        self.allCourses = courses
        restoreFilterState()
    }
    
    // MARK: - Methods
    
    func clearFilters() {
        selectedStatus = nil
        showOnlyCmi5 = false
        showOnlyRegular = false
        showOnlyWithModules = false
        showOnlyWithoutModules = false
        showOnlyWithCompetencies = false
        showOnlyWithoutCompetencies = false
    }
    
    func updateCourses(_ courses: [ManagedCourse]) {
        self.allCourses = courses
    }
    
    // MARK: - Persistence
    
    private let filterStateKey = "CourseFilter.state"
    private let hasStateKey = "CourseFilter.hasState"
    
    func saveFilterState() {
        let state = CourseFilterState(
            selectedStatus: selectedStatus,
            showOnlyCmi5: showOnlyCmi5,
            showOnlyRegular: showOnlyRegular,
            showOnlyWithModules: showOnlyWithModules,
            showOnlyWithoutModules: showOnlyWithoutModules,
            showOnlyWithCompetencies: showOnlyWithCompetencies,
            showOnlyWithoutCompetencies: showOnlyWithoutCompetencies
        )
        
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: filterStateKey)
            UserDefaults.standard.set(true, forKey: hasStateKey)
        }
    }
    
    func restoreFilterState() {
        guard UserDefaults.standard.bool(forKey: hasStateKey),
              let data = UserDefaults.standard.data(forKey: filterStateKey),
              let state = try? JSONDecoder().decode(CourseFilterState.self, from: data) else {
            return
        }
        
        selectedStatus = state.selectedStatus
        showOnlyCmi5 = state.showOnlyCmi5
        showOnlyRegular = state.showOnlyRegular
        showOnlyWithModules = state.showOnlyWithModules
        showOnlyWithoutModules = state.showOnlyWithoutModules
        showOnlyWithCompetencies = state.showOnlyWithCompetencies
        showOnlyWithoutCompetencies = state.showOnlyWithoutCompetencies
    }
}

// MARK: - Filter State Model

struct CourseFilterState: Codable {
    let selectedStatus: ManagedCourseStatus?
    let showOnlyCmi5: Bool
    let showOnlyRegular: Bool
    let showOnlyWithModules: Bool
    let showOnlyWithoutModules: Bool
    let showOnlyWithCompetencies: Bool
    let showOnlyWithoutCompetencies: Bool
} 