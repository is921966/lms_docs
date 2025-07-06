//
//  OnboardingViewModel.swift
//  LMS
//
//  Created on 08/07/2025.
//

import Foundation
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var programs: [OnboardingProgram] = []
    @Published var filteredPrograms: [OnboardingProgram] = []
    @Published var selectedFilter: FilterType = .all
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let onboardingService: OnboardingMockService
    private var cancellables = Set<AnyCancellable>()
    
    enum FilterType: String, CaseIterable {
        case all = "Все"
        case inProgress = "Активные"
        case notStarted = "Не начаты"
        case completed = "Завершены"
        case overdue = "Просроченные"
    }
    
    // Statistics
    var activePrograms: Int {
        programs.filter { $0.status == .inProgress }.count
    }
    
    var completedPrograms: Int {
        programs.filter { $0.status == .completed }.count
    }
    
    var totalPrograms: Int {
        programs.count
    }
    
    var completionRate: Double {
        guard !programs.isEmpty else { return 0 }
        return Double(completedPrograms) / Double(programs.count) * 100
    }
    
    var averageProgress: Double {
        guard !programs.isEmpty else { return 0 }
        let totalProgress = programs.reduce(0) { $0 + $1.overallProgress }
        return totalProgress / Double(programs.count) * 100
    }
    
    init(onboardingService: OnboardingMockService = .shared) {
        self.onboardingService = onboardingService
        setupBindings()
        loadPrograms()
    }
    
    private func setupBindings() {
        // Subscribe to service programs updates
        onboardingService.$programs
            .sink { [weak self] programs in
                self?.programs = programs
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        // React to filter changes
        $selectedFilter
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        // React to search text changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    func loadPrograms() {
        isLoading = true
        errorMessage = nil
        
        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.programs = self?.onboardingService.getPrograms() ?? []
            self?.applyFilters()
            self?.isLoading = false
        }
    }
    
    func applyFilters() {
        var filtered = programs
        
        // Apply status filter
        switch selectedFilter {
        case .all:
            break
        case .inProgress:
            filtered = filtered.filter { $0.status == .inProgress }
        case .notStarted:
            filtered = filtered.filter { $0.status == .notStarted }
        case .completed:
            filtered = filtered.filter { $0.status == .completed }
        case .overdue:
            filtered = filtered.filter { $0.isOverdue }
        }
        
        // Apply search
        if !searchText.isEmpty {
            filtered = filtered.filter { program in
                program.employeeName.localizedCaseInsensitiveContains(searchText) ||
                program.title.localizedCaseInsensitiveContains(searchText) ||
                program.employeeDepartment.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        filteredPrograms = filtered
    }
    
    func updateProgram(_ program: OnboardingProgram) {
        onboardingService.updateProgram(program)
    }
    
    func deleteProgram(_ program: OnboardingProgram) {
        onboardingService.deleteProgram(by: program.id)
    }
    
    func countForFilter(_ filter: FilterType) -> Int {
        switch filter {
        case .all:
            return programs.count
        case .inProgress:
            return programs.filter { $0.status == .inProgress }.count
        case .notStarted:
            return programs.filter { $0.status == .notStarted }.count
        case .completed:
            return programs.filter { $0.status == .completed }.count
        case .overdue:
            return programs.filter { $0.isOverdue }.count
        }
    }
} 