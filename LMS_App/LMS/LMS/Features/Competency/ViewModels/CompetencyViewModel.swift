import Foundation
import Combine
import SwiftUI

// MARK: - Competency ViewModel
class CompetencyViewModel: ObservableObject {
    @Published var competencies: [Competency] = []
    @Published var filteredCompetencies: [Competency] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: CompetencyCategory?
    @Published var showInactiveCompetencies: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingCreateSheet: Bool = false
    @Published var showingEditSheet: Bool = false
    @Published var selectedCompetency: Competency?
    
    private let service = CompetencyMockService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadCompetencies()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Search and filter binding
        Publishers.CombineLatest3($searchText, $selectedCategory, $showInactiveCompetencies)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText, category, showInactive in
                self?.applyFilters(searchText: searchText, category: category, showInactive: showInactive)
            }
            .store(in: &cancellables)
        
        // Service competencies binding
        service.$competencies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] competencies in
                self?.competencies = competencies
                self?.applyFilters(
                    searchText: self?.searchText ?? "",
                    category: self?.selectedCategory,
                    showInactive: self?.showInactiveCompetencies ?? false
                )
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    func loadCompetencies() {
        isLoading = true
        errorMessage = nil
        
        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
        }
    }
    
    // MARK: - Filtering
    private func applyFilters(searchText: String, category: CompetencyCategory?, showInactive: Bool) {
        var filtered = competencies
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { competency in
                competency.name.localizedCaseInsensitiveContains(searchText) ||
                competency.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by active status
        if !showInactive {
            filtered = filtered.filter { $0.isActive }
        }
        
        filteredCompetencies = filtered
    }
    
    // MARK: - CRUD Operations
    func createCompetency(_ competency: Competency) {
        service.createCompetency(competency)
        showingCreateSheet = false
    }
    
    func updateCompetency(_ competency: Competency) {
        service.updateCompetency(competency)
        showingEditSheet = false
        selectedCompetency = nil
    }
    
    func deleteCompetency(_ competency: Competency) {
        service.deleteCompetency(competency.id)
    }
    
    func toggleCompetencyStatus(_ competency: Competency) {
        service.toggleCompetencyStatus(competency.id)
    }
    
    // MARK: - UI Actions
    func selectCompetencyForEdit(_ competency: Competency) {
        selectedCompetency = competency
        showingEditSheet = true
    }
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        showInactiveCompetencies = false
    }
    
    // MARK: - Statistics
    var statistics: CompetencyStatistics {
        CompetencyStatistics(
            total: competencies.count,
            active: competencies.filter { $0.isActive }.count,
            byCategory: Dictionary(grouping: competencies, by: { $0.category })
                .mapValues { $0.count }
        )
    }
    
    // MARK: - Export
    func exportCompetencies() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let data = try? encoder.encode(filteredCompetencies),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        
        return "[]"
    }
}

// MARK: - Supporting Types
struct CompetencyStatistics {
    let total: Int
    let active: Int
    let byCategory: [CompetencyCategory: Int]
    
    var inactive: Int {
        total - active
    }
    
    func count(for category: CompetencyCategory) -> Int {
        byCategory[category] ?? 0
    }
} 