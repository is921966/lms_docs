import Foundation
import SwiftUI
import Combine

@MainActor
class UserListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var users: [DomainUser] = []
    @Published var filteredUsers: [DomainUser] = []
    @Published var searchText: String = ""
    @Published var selectedRole: DomainUserRole? = nil
    @Published var selectedDepartment: String? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showError: Bool = false
    
    // MARK: - Pagination
    @Published var currentPage: Int = 1
    @Published var hasMorePages: Bool = true
    @Published var isLoadingMore: Bool = false
    
    // MARK: - Dependencies
    private let userRepository: any DomainUserRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Search Configuration
    private let searchDebounceTime: TimeInterval = 0.3
    private let pageSize: Int = 20
    
    // MARK: - Computed Properties
    var availableRoles: [DomainUserRole] {
        DomainUserRole.allCases
    }
    
    var availableDepartments: [String] {
        Array(Set(users.compactMap { $0.department })).sorted()
    }
    
    var activeFiltersCount: Int {
        var count = 0
        if !searchText.isEmpty { count += 1 }
        if selectedRole != nil { count += 1 }
        if selectedDepartment != nil { count += 1 }
        return count
    }
    
    var hasActiveFilters: Bool {
        activeFiltersCount > 0
    }
    
    // MARK: - Initialization
    init(userRepository: any DomainUserRepositoryProtocol = RepositoryFactoryManager.shared.userRepository) {
        self.userRepository = userRepository
        setupObservers()
        setupSearchDebouncing()
    }
    
    // MARK: - Setup
    private func setupObservers() {
        // Listen to repository changes for reactive updates
        userRepository.entityChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] change in
                self?.handleRepositoryChange(change)
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchDebouncing() {
        // Debounce search text changes
        $searchText
            .debounce(for: .seconds(searchDebounceTime), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task {
                    await self?.performSearch()
                }
            }
            .store(in: &cancellables)
        
        // React to filter changes
        Publishers.CombineLatest($selectedRole, $selectedDepartment)
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _ in
                Task {
                    await self?.performSearch()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func loadUsers() async {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage = 1
        hasMorePages = true
        clearError()
        
        do {
            let pagination = PaginationRequest(page: currentPage, limit: pageSize)
            let result = try await userRepository.findAll(pagination: pagination)
            
            users = result.items
            filteredUsers = users
            hasMorePages = result.hasNextPage
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func loadMoreUsers() async {
        guard !isLoadingMore && hasMorePages && !isLoading else { return }
        
        isLoadingMore = true
        
        do {
            let nextPage = currentPage + 1
            let pagination = PaginationRequest(page: nextPage, limit: pageSize)
            
            let result: PaginatedResult<DomainUser>
            
            if hasActiveFilters {
                // Load more with current filters
                result = try await performFilteredSearch(pagination: pagination)
            } else {
                // Load more without filters
                result = try await userRepository.findAll(pagination: pagination)
            }
            
            users.append(contentsOf: result.items)
            filteredUsers.append(contentsOf: result.items)
            currentPage = nextPage
            hasMorePages = result.hasNextPage
            
        } catch {
            handleError(error)
        }
        
        isLoadingMore = false
    }
    
    func refreshUsers() async {
        await loadUsers()
    }
    
    func createUser(_ createDTO: CreateUserDTO) async -> Bool {
        clearError()
        
        do {
            _ = try await userRepository.createUser(createDTO)
            // Repository change observer will handle UI update
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    func updateUser(_ user: DomainUser, with updateDTO: UpdateUserDTO) async -> Bool {
        clearError()
        
        do {
            _ = try await userRepository.updateUser(user.id, with: updateDTO)
            // Repository change observer will handle UI update
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    func deleteUser(_ user: DomainUser) async -> Bool {
        clearError()
        
        do {
            _ = try await userRepository.deleteById(user.id)
            // Repository change observer will handle UI update
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    func toggleUserActive(_ user: DomainUser) async -> Bool {
        clearError()
        
        do {
            _ = try await userRepository.setUserActive(user.id, isActive: !user.isActive)
            // Repository change observer will handle UI update
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    // MARK: - Filter Methods
    func clearAllFilters() {
        searchText = ""
        selectedRole = nil
        selectedDepartment = nil
    }
    
    func setRoleFilter(_ role: DomainUserRole?) {
        selectedRole = role
    }
    
    func setDepartmentFilter(_ department: String?) {
        selectedDepartment = department
    }
    
    // MARK: - Private Methods
    private func performSearch() async {
        guard !isLoading else { return }
        
        // Reset pagination for new search
        currentPage = 1
        hasMorePages = true
        
        do {
            let pagination = PaginationRequest(page: currentPage, limit: pageSize)
            let result = try await performFilteredSearch(pagination: pagination)
            
            filteredUsers = result.items
            hasMorePages = result.hasNextPage
            
        } catch {
            handleError(error)
        }
    }
    
    private func performFilteredSearch(pagination: PaginationRequest) async throws -> PaginatedResult<DomainUser> {
        if hasActiveFilters {
            // Use search with query text if available
            if !searchText.isEmpty {
                return try await userRepository.search(searchText, pagination: pagination)
            } else {
                // Apply filters manually for now (simplified approach)
                let allResult = try await userRepository.findAll(pagination: pagination)
                var filtered = allResult.items
                
                // Apply role filter
                if let role = selectedRole {
                    filtered = filtered.filter { $0.role == role }
                }
                
                // Apply department filter
                if let department = selectedDepartment {
                    filtered = filtered.filter { $0.department == department }
                }
                
                return PaginatedResult(items: filtered, totalCount: filtered.count, pagination: pagination)
            }
        } else {
            // No filters, load all users
            return try await userRepository.findAll(pagination: pagination)
        }
    }
    
    private func handleRepositoryChange(_ change: RepositoryChange<DomainUser>) {
        switch change {
        case .created(let user):
            if !users.contains(where: { $0.id == user.id }) {
                users.append(user)
                applyCurrentFilters()
            }
            
        case .updated(let user):
            if let index = users.firstIndex(where: { $0.id == user.id }) {
                users[index] = user
                applyCurrentFilters()
            }
            
        case .deleted(let user):
            users.removeAll { $0.id == user.id }
            filteredUsers.removeAll { $0.id == user.id }
        }
    }
    
    private func applyCurrentFilters() {
        var filtered = users
        
        // Apply search text filter
        if !searchText.isEmpty {
            filtered = filtered.filter { user in
                user.fullName.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText) ||
                (user.department?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Apply role filter
        if let role = selectedRole {
            filtered = filtered.filter { $0.role == role }
        }
        
        // Apply department filter
        if let department = selectedDepartment {
            filtered = filtered.filter { $0.department == department }
        }
        
        filteredUsers = filtered
    }
    
    private func handleError(_ error: Error) {
        if let repositoryError = error as? RepositoryError {
            switch repositoryError {
            case .notFound:
                errorMessage = "Пользователь не найден"
            case .validationError(let details):
                errorMessage = "Ошибка валидации: \(details.joined(separator: ", "))"
            case .networkError(let underlying):
                errorMessage = "Ошибка сети: \(underlying.localizedDescription)"
            case .cacheError:
                errorMessage = "Ошибка кэша. Попробуйте обновить данные"
            case .invalidData:
                errorMessage = "Некорректные данные"
            case .unknownError(let message):
                errorMessage = "Неизвестная ошибка: \(message)"
            }
        } else {
            errorMessage = error.localizedDescription
        }
        
        showError = true
    }
    
    private func clearError() {
        errorMessage = nil
        showError = false
    }
}

// MARK: - UserSearchFilter Extension
extension UserListViewModel {
    enum UserSearchFilter {
        case role(DomainUserRole)
        case department(String)
        case isActive(Bool)
    }
}

// MARK: - Statistics and Analytics
extension UserListViewModel {
    var userStatistics: UserStatistics {
        UserStatistics(
            totalUsers: users.count,
            activeUsers: users.filter { $0.isActive }.count,
            usersByRole: Dictionary(grouping: users, by: { $0.role })
                .mapValues { $0.count },
            usersByDepartment: Dictionary(grouping: users.compactMap { user in
                user.department.map { (department: $0, user: user) }
            }, by: { $0.department })
                .mapValues { $0.count }
        )
    }
    
    struct UserStatistics {
        let totalUsers: Int
        let activeUsers: Int
        let usersByRole: [DomainUserRole: Int]
        let usersByDepartment: [String: Int]
        
        var inactiveUsers: Int {
            totalUsers - activeUsers
        }
        
        var activationRate: Double {
            guard totalUsers > 0 else { return 0 }
            return Double(activeUsers) / Double(totalUsers)
        }
    }
} 