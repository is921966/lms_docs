import Foundation
import Combine
import SwiftUI

// MARK: - Position ViewModel
class PositionViewModel: ObservableObject {
    @Published var positions: [Position] = []
    @Published var filteredPositions: [Position] = []
    @Published var careerPaths: [CareerPath] = []
    @Published var searchText: String = ""
    @Published var selectedLevel: PositionLevel?
    @Published var selectedDepartment: String?
    @Published var showInactivePositions: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingCreateSheet: Bool = false
    @Published var showingEditSheet: Bool = false
    @Published var selectedPosition: Position?
    @Published var showingCareerPaths: Bool = false

    private let service = PositionMockService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
        loadData()
    }

    // MARK: - Setup
    private func setupBindings() {
        // Search and filter binding
        Publishers.CombineLatest4($searchText, $selectedLevel, $selectedDepartment, $showInactivePositions)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText, level, department, showInactive in
                self?.applyFilters(
                    searchText: searchText,
                    level: level,
                    department: department,
                    showInactive: showInactive
                )
            }
            .store(in: &cancellables)

        // Service positions binding
        service.$positions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] positions in
                self?.positions = positions
                self?.applyFilters(
                    searchText: self?.searchText ?? "",
                    level: self?.selectedLevel,
                    department: self?.selectedDepartment,
                    showInactive: self?.showInactivePositions ?? false
                )
            }
            .store(in: &cancellables)

        // Service career paths binding
        service.$careerPaths
            .receive(on: DispatchQueue.main)
            .assign(to: &$careerPaths)
    }

    // MARK: - Data Loading
    func loadData() {
        isLoading = true
        errorMessage = nil

        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
        }
    }

    // MARK: - Filtering
    private func applyFilters(searchText: String, level: PositionLevel?, department: String?, showInactive: Bool) {
        var filtered = positions

        // Filter by search text
        if !searchText.isEmpty {
            filtered = service.searchPositions(query: searchText)
        }

        // Filter by level
        if let level = level {
            filtered = filtered.filter { $0.level == level }
        }

        // Filter by department
        if let department = department {
            filtered = filtered.filter { $0.department == department }
        }

        // Filter by active status
        if !showInactive {
            filtered = filtered.filter { $0.isActive }
        }

        // Sort by level
        filtered.sort { $0.level.sortOrder < $1.level.sortOrder }

        filteredPositions = filtered
    }

    // MARK: - CRUD Operations
    func createPosition(_ position: Position) {
        service.createPosition(position)
        showingCreateSheet = false
    }

    func updatePosition(_ position: Position) {
        service.updatePosition(position)
        showingEditSheet = false
        selectedPosition = nil
    }

    func deletePosition(_ position: Position) {
        service.deletePosition(position.id)
    }

    func togglePositionStatus(_ position: Position) {
        var updated = position
        updated.isActive.toggle()
        service.updatePosition(updated)
    }

    // MARK: - Career Paths
    func getCareerPaths(for position: Position) -> [CareerPath] {
        service.getCareerPaths(for: position.id)
    }

    func getIncomingCareerPaths(for position: Position) -> [CareerPath] {
        service.getIncomingCareerPaths(for: position.id)
    }

    func createCareerPath(_ path: CareerPath) {
        service.createCareerPath(path)
    }

    // MARK: - UI Actions
    func selectPositionForEdit(_ position: Position) {
        selectedPosition = position
        showingEditSheet = true
    }

    func selectPositionForCareerPaths(_ position: Position) {
        selectedPosition = position
        showingCareerPaths = true
    }

    func clearFilters() {
        searchText = ""
        selectedLevel = nil
        selectedDepartment = nil
        showInactivePositions = false
    }

    // MARK: - Statistics
    var statistics: PositionStatistics {
        PositionStatistics(
            total: positions.count,
            active: positions.filter { $0.isActive }.count,
            totalEmployees: service.totalEmployees,
            byLevel: service.positionsByLevel,
            departments: service.departments
        )
    }

    // MARK: - Competency Matrix
    func getCompetencyMatrix(for position: Position) -> CompetencyMatrix {
        CompetencyMatrix(
            position: position,
            requirements: position.competencyRequirements.sorted {
                // Critical requirements first, then by level
                if $0.isCritical != $1.isCritical {
                    return $0.isCritical
                }
                return $0.requiredLevel > $1.requiredLevel
            }
        )
    }
}

// MARK: - Supporting Types
struct PositionStatistics {
    let total: Int
    let active: Int
    let totalEmployees: Int
    let byLevel: [PositionLevel: Int]
    let departments: [String]

    var inactive: Int {
        total - active
    }

    func count(for level: PositionLevel) -> Int {
        byLevel[level] ?? 0
    }
}

struct CompetencyMatrix {
    let position: Position
    let requirements: [CompetencyRequirement]

    var criticalRequirements: [CompetencyRequirement] {
        requirements.filter { $0.isCritical }
    }

    var optionalRequirements: [CompetencyRequirement] {
        requirements.filter { !$0.isCritical }
    }

    var averageRequiredLevel: Double {
        guard !requirements.isEmpty else { return 0 }
        let totalLevel = requirements.reduce(0) { $0 + $1.requiredLevel }
        return Double(totalLevel) / Double(requirements.count)
    }
}
