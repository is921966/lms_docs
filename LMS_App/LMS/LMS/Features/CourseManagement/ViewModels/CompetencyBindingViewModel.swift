//
//  CompetencyBindingViewModel.swift
//  LMS
//
//  ViewModel for binding competencies to courses
//

import Foundation
import SwiftUI

@MainActor
class CompetencyBindingViewModel: ObservableObject {
    @Published var availableCompetencies: [Competency] = []
    @Published var selectedCompetencies: Set<UUID> = []
    @Published var searchText = ""
    @Published var selectedLevel: Int? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let course: ManagedCourse
    private let competencyService: CompetencyServiceProtocol
    
    var filteredCompetencies: [Competency] {
        var result = availableCompetencies
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { competency in
                competency.name.localizedCaseInsensitiveContains(searchText) ||
                competency.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by level
        if let level = selectedLevel {
            result = result.filter { $0.currentLevel == level }
        }
        
        return result
    }
    
    init(course: ManagedCourse, competencyService: CompetencyServiceProtocol = MockCompetencyService()) {
        self.course = course
        self.competencyService = competencyService
        self.selectedCompetencies = Set(course.competencies)
    }
    
    // MARK: - Public Methods
    
    func loadCompetencies() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await competencyService.getCompetencies(page: 1, limit: 100, filters: nil)
            
            // Convert CompetencyResponse to local Competency model
            self.availableCompetencies = response.competencies.map { response in
                var competency = Competency(
                    id: UUID(uuidString: response.id) ?? UUID(),
                    name: response.name,
                    description: response.description,
                    category: .technical // Default category
                )
                competency.currentLevel = 1 // Default level
                competency.requiredLevel = 3 // Default required level
                return competency
            }
            
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.availableCompetencies = []
            self.isLoading = false
        }
    }
    
    func toggleCompetency(_ competency: Competency) {
        if selectedCompetencies.contains(competency.id) {
            selectedCompetencies.remove(competency.id)
        } else {
            selectedCompetencies.insert(competency.id)
        }
    }
    
    func isSelected(_ competency: Competency) -> Bool {
        selectedCompetencies.contains(competency.id)
    }
    
    func saveCompetencies() async -> ManagedCourse {
        var updatedCourse = course
        updatedCourse.competencies = Array(selectedCompetencies)
        updatedCourse.updatedAt = Date()
        return updatedCourse
    }
    
    func getCompetencyDetails(_ competency: Competency) -> String {
        """
        \(competency.description)
        Текущий уровень: \(competency.currentLevel)
        Требуемый уровень: \(competency.requiredLevel)
        """
    }
    
    // MARK: - Convenience Properties
    
    var availableLevels: [Int] {
        Array(Set(availableCompetencies.map { $0.currentLevel })).sorted()
    }
    
    var selectedCount: Int {
        selectedCompetencies.count
    }
    
    var hasChanges: Bool {
        Set(course.competencies) != selectedCompetencies
    }
} 