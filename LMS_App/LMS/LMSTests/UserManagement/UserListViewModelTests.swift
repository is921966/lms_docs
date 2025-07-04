import XCTest
import Combine
@testable import LMS

@MainActor
class UserListViewModelTests: XCTestCase {
    var viewModel: UserListViewModel!
    var mockRepository: MockUserRepository!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Configure test factory
        RepositoryFactoryManager.shared.configureForTesting()
        
        // Create mock repository
        mockRepository = MockUserRepository()
        
        // Create view model with mock repository
        viewModel = UserListViewModel(userRepository: mockRepository)
        
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() async throws {
        cancellables = nil
        viewModel = nil
        mockRepository = nil
        
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertTrue(viewModel.users.isEmpty)
        XCTAssertTrue(viewModel.filteredUsers.isEmpty)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.selectedRole)
        XCTAssertNil(viewModel.selectedDepartment)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showError)
    }
    
    // MARK: - Loading Tests
    
    func testLoadUsers_Success() async {
        // Given
        let testUsers = createTestUsers()
        mockRepository.mockUsers = testUsers
        
        // When
        await viewModel.loadUsers()
        
        // Then
        XCTAssertEqual(viewModel.users.count, testUsers.count)
        XCTAssertEqual(viewModel.filteredUsers.count, testUsers.count)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showError)
    }
    
    func testLoadUsers_Error() async {
        // Given
        mockRepository.shouldFailNextOperation = true
        
        // When
        await viewModel.loadUsers()
        
        // Then
        XCTAssertTrue(viewModel.users.isEmpty)
        XCTAssertTrue(viewModel.filteredUsers.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.showError)
    }
    
    // MARK: - Search Tests
    
    func testSearchUsers() async {
        // Given
        let testUsers = createTestUsers()
        mockRepository.mockUsers = testUsers
        await viewModel.loadUsers()
        
        // When
        viewModel.searchText = "john"
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 400_000_000) // 400ms
        
        // Then
        let filteredUsers = viewModel.filteredUsers
        XCTAssertTrue(filteredUsers.allSatisfy { user in
            user.fullName.localizedCaseInsensitiveContains("john") ||
            user.email.localizedCaseInsensitiveContains("john")
        })
    }
    
    func testClearSearch() async {
        // Given
        let testUsers = createTestUsers()
        mockRepository.mockUsers = testUsers
        await viewModel.loadUsers()
        viewModel.searchText = "john"
        
        // When
        viewModel.searchText = ""
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 400_000_000) // 400ms
        
        // Then
        XCTAssertEqual(viewModel.filteredUsers.count, testUsers.count)
    }
    
    // MARK: - Filter Tests
    
    func testRoleFilter() async {
        // Given
        let testUsers = createTestUsers()
        mockRepository.mockUsers = testUsers
        await viewModel.loadUsers()
        
        // When
        viewModel.setRoleFilter(.teacher)
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
        
        // Then
        let filteredUsers = viewModel.filteredUsers
        XCTAssertTrue(filteredUsers.allSatisfy { $0.role == .teacher })
    }
    
    func testDepartmentFilter() async {
        // Given
        let testUsers = createTestUsers()
        mockRepository.mockUsers = testUsers
        await viewModel.loadUsers()
        
        // When
        viewModel.setDepartmentFilter("Engineering")
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
        
        // Then
        let filteredUsers = viewModel.filteredUsers
        XCTAssertTrue(filteredUsers.allSatisfy { $0.department == "Engineering" })
    }
    
    func testClearAllFilters() async {
        // Given
        let testUsers = createTestUsers()
        mockRepository.mockUsers = testUsers
        await viewModel.loadUsers()
        
        viewModel.searchText = "john"
        viewModel.setRoleFilter(.teacher)
        viewModel.setDepartmentFilter("Engineering")
        
        // When
        viewModel.clearAllFilters()
        
        // Then
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.selectedRole)
        XCTAssertNil(viewModel.selectedDepartment)
        XCTAssertFalse(viewModel.hasActiveFilters)
    }
    
    // MARK: - CRUD Operations Tests
    
    func testCreateUser_Success() async {
        // Given
        let createDTO = CreateUserDTO(
            email: "new.user@example.com",
            firstName: "New",
            lastName: "User",
            role: "student",
            phoneNumber: "+7 (999) 999-99-99",
            department: "Marketing",
            position: "Intern"
        )
        
        // When
        let result = await viewModel.createUser(createDTO)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showError)
    }
    
    func testCreateUser_ValidationError() async {
        // Given
        let invalidDTO = CreateUserDTO(
            email: "invalid-email",
            firstName: "",
            lastName: "User",
            role: "student",
            phoneNumber: nil,
            department: nil,
            position: nil
        )
        
        // When
        let result = await viewModel.createUser(invalidDTO)
        
        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(viewModel.errorMessage)
        
        // Verify that the error message contains "Ошибка валидации"
        XCTAssertTrue(viewModel.errorMessage?.contains("Ошибка валидации") ?? false)
        
        // The error message should contain validation details
        // It could contain email format error and/or first name error
        let errorMessage = viewModel.errorMessage ?? ""
        XCTAssertTrue(
            errorMessage.contains("Email format is invalid") || 
            errorMessage.contains("First name cannot be empty") ||
            errorMessage.contains("валидации"),
            "Error message should contain validation details"
        )
        
        XCTAssertTrue(viewModel.showError)
    }
    
    func testUpdateUser_Success() async {
        // Given
        let testUsers = createTestUsers()
        mockRepository.mockUsers = testUsers
        await viewModel.loadUsers()
        
        let userToUpdate = testUsers.first!
        let updateDTO = UpdateUserDTO(
            firstName: "Updated",
            lastName: userToUpdate.lastName,
            phoneNumber: userToUpdate.phoneNumber,
            department: userToUpdate.department,
            position: userToUpdate.position,
            isActive: userToUpdate.isActive
        )
        
        // When
        let result = await viewModel.updateUser(userToUpdate, with: updateDTO)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showError)
    }
    
    func testDeleteUser_Success() async {
        // Given
        let testUsers = createTestUsers()
        mockRepository.mockUsers = testUsers
        await viewModel.loadUsers()
        
        let userToDelete = testUsers.first!
        
        // When
        let result = await viewModel.deleteUser(userToDelete)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showError)
    }
    
    func testToggleUserActive_Success() async {
        // Given
        let testUsers = createTestUsers()
        mockRepository.mockUsers = testUsers
        await viewModel.loadUsers()
        
        let userToToggle = testUsers.first!
        let originalStatus = userToToggle.isActive
        
        // When
        let result = await viewModel.toggleUserActive(userToToggle)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showError)
    }
    
    // MARK: - Pagination Tests
    
    func testLoadMoreUsers() async {
        // Given
        let testUsers = createTestUsers()
        mockRepository.mockUsers = testUsers
        await viewModel.loadUsers()
        
        // Simulate having more pages
        viewModel.hasMorePages = true
        
        // When
        await viewModel.loadMoreUsers()
        
        // Then
        XCTAssertFalse(viewModel.isLoadingMore)
        // Additional assertions based on mock behavior
    }
    
    // MARK: - Statistics Tests
    
    func testUserStatistics() async {
        // Given
        let testUsers = createTestUsers()
        mockRepository.mockUsers = testUsers
        await viewModel.loadUsers()
        
        // When
        let stats = viewModel.userStatistics
        
        // Then
        XCTAssertEqual(stats.totalUsers, testUsers.count)
        XCTAssertEqual(stats.activeUsers, testUsers.filter { $0.isActive }.count)
        XCTAssertEqual(stats.inactiveUsers, testUsers.filter { !$0.isActive }.count)
        XCTAssertGreaterThanOrEqual(stats.activationRate, 0.0)
        XCTAssertLessThanOrEqual(stats.activationRate, 1.0)
    }
    
    // MARK: - Computed Properties Tests
    
    func testAvailableRoles() {
        // When
        let roles = viewModel.availableRoles
        
        // Then
        XCTAssertEqual(roles, DomainUserRole.allCases)
    }
    
    func testAvailableDepartments() async {
        // Given
        let testUsers = createTestUsers()
        mockRepository.mockUsers = testUsers
        await viewModel.loadUsers()
        
        // When
        let departments = viewModel.availableDepartments
        
        // Then
        let expectedDepartments = Set(testUsers.compactMap { $0.department }).sorted()
        XCTAssertEqual(departments, expectedDepartments)
    }
    
    func testActiveFiltersCount() {
        // Given
        viewModel.searchText = "test"
        viewModel.setRoleFilter(.teacher)
        viewModel.setDepartmentFilter("Engineering")
        
        // When
        let count = viewModel.activeFiltersCount
        
        // Then
        XCTAssertEqual(count, 3)
    }
    
    func testHasActiveFilters() {
        // Initially no filters
        XCTAssertFalse(viewModel.hasActiveFilters)
        
        // Add search text
        viewModel.searchText = "test"
        XCTAssertTrue(viewModel.hasActiveFilters)
        
        // Clear search text
        viewModel.searchText = ""
        XCTAssertFalse(viewModel.hasActiveFilters)
        
        // Add role filter
        viewModel.setRoleFilter(.teacher)
        XCTAssertTrue(viewModel.hasActiveFilters)
    }
    
    // MARK: - Helper Methods
    
    private func createTestUsers() -> [DomainUser] {
        return [
            DomainUser(
                id: UUID().uuidString,
                email: "john.doe@example.com",
                firstName: "John",
                lastName: "Doe",
                role: .teacher,
                isActive: true,
                profileImageUrl: nil,
                phoneNumber: "+7 (999) 123-45-67",
                department: "Engineering",
                position: "Senior Developer",
                lastLoginAt: Date(),
                createdAt: Date().addingTimeInterval(-86400 * 30),
                updatedAt: Date()
            ),
            DomainUser(
                id: UUID().uuidString,
                email: "jane.smith@example.com",
                firstName: "Jane",
                lastName: "Smith",
                role: .student,
                isActive: true,
                profileImageUrl: nil,
                phoneNumber: "+7 (999) 987-65-43",
                department: "Marketing",
                position: "Student",
                lastLoginAt: Date().addingTimeInterval(-3600),
                createdAt: Date().addingTimeInterval(-86400 * 15),
                updatedAt: Date().addingTimeInterval(-3600)
            ),
            DomainUser(
                id: UUID().uuidString,
                email: "bob.johnson@example.com",
                firstName: "Bob",
                lastName: "Johnson",
                role: .admin,
                isActive: false,
                profileImageUrl: nil,
                phoneNumber: nil,
                department: "Engineering",
                position: "System Administrator",
                lastLoginAt: Date().addingTimeInterval(-86400 * 7),
                createdAt: Date().addingTimeInterval(-86400 * 60),
                updatedAt: Date().addingTimeInterval(-86400)
            )
        ]
    }
}

// MARK: - Mock Repository

class MockUserRepository: DomainUserRepositoryProtocol {
    var mockUsers: [DomainUser] = []
    var shouldFailNextOperation = false
    
    private let changeSubject = PassthroughSubject<RepositoryChange<DomainUser>, Never>()
    
    var entityChanges: AnyPublisher<RepositoryChange<DomainUser>, Never> {
        changeSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Repository Protocol
    
    func findById(_ id: String) async throws -> DomainUser? {
        if shouldFailNextOperation {
            shouldFailNextOperation = false
            throw RepositoryError.notFound("User not found")
        }
        return mockUsers.first { $0.id == id }
    }
    
    func findAll() async throws -> [DomainUser] {
        if shouldFailNextOperation {
            shouldFailNextOperation = false
            throw RepositoryError.networkError(NSError(domain: "Mock", code: 0, userInfo: nil))
        }
        return mockUsers
    }
    
    func findAll(pagination: PaginationRequest) async throws -> PaginatedResult<DomainUser> {
        if shouldFailNextOperation {
            shouldFailNextOperation = false
            throw RepositoryError.networkError(NSError(domain: "Mock", code: 0, userInfo: nil))
        }
        
        let page = pagination.page
        let limit = pagination.pageSize
        let startIndex = (page - 1) * limit
        let endIndex = min(startIndex + limit, mockUsers.count)
        
        guard startIndex < mockUsers.count else {
            return PaginatedResult(items: [], totalCount: mockUsers.count, pagination: pagination)
        }
        
        let items = Array(mockUsers[startIndex..<endIndex])
        
        return PaginatedResult(
            items: items,
            totalCount: mockUsers.count,
            page: page,
            pageSize: limit
        )
    }
    
    func findAll(page: Int, pageSize: Int) async throws -> PaginatedResult<DomainUser> {
        let pagination = PaginationRequest(page: page, pageSize: pageSize)
        return try await findAll(pagination: pagination)
    }
    
    func save(_ entity: DomainUser) async throws -> DomainUser {
        if shouldFailNextOperation {
            shouldFailNextOperation = false
            throw RepositoryError.validationError(["Mock validation error"])
        }
        
        if let index = mockUsers.firstIndex(where: { $0.id == entity.id }) {
            mockUsers[index] = entity
            changeSubject.send(.updated(entity))
        } else {
            mockUsers.append(entity)
            changeSubject.send(.created(entity))
        }
        
        return entity
    }
    
    func deleteById(_ id: String) async throws -> Bool {
        if shouldFailNextOperation {
            shouldFailNextOperation = false
            throw RepositoryError.notFound("User not found")
        }
        
        if let index = mockUsers.firstIndex(where: { $0.id == id }) {
            let user = mockUsers[index]
            mockUsers.remove(at: index)
            changeSubject.send(.deleted(user))
            return true
        }
        return false
    }
    
    func exists(_ id: String) async throws -> Bool {
        return mockUsers.contains { $0.id == id }
    }
    
    func count() async throws -> Int {
        return mockUsers.count
    }
    
    // MARK: - Searchable Protocol
    
    func search(_ query: String) async throws -> [DomainUser] {
        return mockUsers.filter { user in
            user.fullName.localizedCaseInsensitiveContains(query) ||
            user.email.localizedCaseInsensitiveContains(query) ||
            (user.department?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
    
    func search(_ query: String, pagination: PaginationRequest) async throws -> PaginatedResult<DomainUser> {
        let filtered = try await search(query)
        
        let page = pagination.page
        let limit = pagination.pageSize
        let startIndex = (page - 1) * limit
        let endIndex = min(startIndex + limit, filtered.count)
        
        guard startIndex < filtered.count else {
            return PaginatedResult(items: [], totalCount: filtered.count, pagination: pagination)
        }
        
        let items = Array(filtered[startIndex..<endIndex])
        
        return PaginatedResult(
            items: items,
            totalCount: filtered.count,
            page: page,
            pageSize: limit
        )
    }
    
    func search(_ query: String, page: Int, pageSize: Int) async throws -> PaginatedResult<DomainUser> {
        let pagination = PaginationRequest(page: page, pageSize: pageSize)
        return try await search(query, pagination: pagination)
    }
    
    // MARK: - Cache Protocol
    
    func clearCache() async {
        // No-op for mock
    }
    
    func clearCache(for id: String) async {
        // No-op for mock
    }
    
    func refreshCache(for id: String) async throws -> DomainUser? {
        return try await findById(id)
    }
    
    // MARK: - Observable Protocol
    
    func observeEntity(_ id: String) -> AnyPublisher<DomainUser?, Never> {
        entityChanges
            .filter { change in
                switch change {
                case .created(let user), .updated(let user), .deleted(let user):
                    return user.id == id
                }
            }
            .map { change in
                switch change {
                case .created(let user), .updated(let user):
                    return user
                case .deleted:
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - User-specific methods
    
    func findByEmail(_ email: String) async throws -> DomainUser? {
        return mockUsers.first { $0.email == email }
    }
    
    func findByRole(_ role: DomainUserRole) async throws -> [DomainUser] {
        return mockUsers.filter { $0.role == role }
    }
    
    func findByDepartment(_ department: String) async throws -> [DomainUser] {
        return mockUsers.filter { $0.department == department }
    }
    
    func findActiveUsers() async throws -> [DomainUser] {
        return mockUsers.filter { $0.isActive }
    }
    
    func createUser(_ createDTO: CreateUserDTO) async throws -> DomainUser {
        // Perform validation first
        if !createDTO.isValid() {
            throw RepositoryError.validationError(createDTO.validationErrors())
        }
        
        // Check if email is already taken
        if let _ = try await findByEmail(createDTO.email) {
            throw RepositoryError.invalidData("Email \(createDTO.email) is already taken")
        }
        
        let newUser = DomainUser(
            id: UUID().uuidString,
            email: createDTO.email,
            firstName: createDTO.firstName,
            lastName: createDTO.lastName,
            role: DomainUserRole(rawValue: createDTO.role) ?? .student,
            isActive: true,  // Default to active for new users
            profileImageUrl: nil,
            phoneNumber: createDTO.phoneNumber,
            department: createDTO.department,
            position: createDTO.position,
            lastLoginAt: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        return try await save(newUser)
    }
    
    func updateUser(_ id: String, with updateDTO: UpdateUserDTO) async throws -> DomainUser {
        guard let existingUser = try await findById(id) else {
            throw RepositoryError.notFound("User not found")
        }
        
        let updatedUser = DomainUser(
            id: existingUser.id,
            email: existingUser.email,  // Keep existing email
            firstName: updateDTO.firstName ?? existingUser.firstName,
            lastName: updateDTO.lastName ?? existingUser.lastName,
            role: existingUser.role,  // Keep existing role
            isActive: updateDTO.isActive ?? existingUser.isActive,
            profileImageUrl: updateDTO.profileImageUrl ?? existingUser.profileImageUrl,
            phoneNumber: updateDTO.phoneNumber ?? existingUser.phoneNumber,
            department: updateDTO.department ?? existingUser.department,
            position: updateDTO.position ?? existingUser.position,
            lastLoginAt: existingUser.lastLoginAt,
            createdAt: existingUser.createdAt,
            updatedAt: Date()
        )
        
        return try await save(updatedUser)
    }
    
    func setUserActive(_ id: String, isActive: Bool) async throws -> DomainUser {
        guard let user = try await findById(id) else {
            throw RepositoryError.notFound("User not found")
        }
        
        let updatedUser = DomainUser(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role,
            isActive: isActive,
            profileImageUrl: user.profileImageUrl,
            phoneNumber: user.phoneNumber,
            department: user.department,
            position: user.position,
            lastLoginAt: user.lastLoginAt,
            createdAt: user.createdAt,
            updatedAt: Date()
        )
        
        return try await save(updatedUser)
    }
    
    func updateLastLogin(_ id: String) async throws -> DomainUser {
        guard let user = try await findById(id) else {
            throw RepositoryError.notFound("User not found")
        }
        
        let updatedUser = DomainUser(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role,
            isActive: user.isActive,
            profileImageUrl: user.profileImageUrl,
            phoneNumber: user.phoneNumber,
            department: user.department,
            position: user.position,
            lastLoginAt: Date(),
            createdAt: user.createdAt,
            updatedAt: Date()
        )
        
        return try await save(updatedUser)
    }
    
    func isEmailAvailable(_ email: String) async throws -> Bool {
        let user = try await findByEmail(email)
        return user == nil
    }
    
    func getUserProfile(_ id: String) async throws -> UserProfileDTO? {
        guard let user = try await findById(id) else { return nil }
        return UserProfileMapper.toProfileDTO(from: user)
    }
    
    // MARK: - Batch operations
    
    func createUsers(_ createDTOs: [CreateUserDTO]) async throws -> [DomainUser] {
        var createdUsers: [DomainUser] = []
        for dto in createDTOs {
            let user = try await createUser(dto)
            createdUsers.append(user)
        }
        return createdUsers
    }
    
    func updateUsers(_ updates: [String: UpdateUserDTO]) async throws -> [DomainUser] {
        var updatedUsers: [DomainUser] = []
        for (id, dto) in updates {
            let user = try await updateUser(id, with: dto)
            updatedUsers.append(user)
        }
        return updatedUsers
    }
    
    func deleteUsers(_ ids: [String]) async throws -> Int {
        var deletedCount = 0
        for id in ids {
            if try await deleteById(id) {
                deletedCount += 1
            }
        }
        return deletedCount
    }
    
    // MARK: - Statistics
    
    func getUserCountByRole() async throws -> [DomainUserRole: Int] {
        let groupedUsers = Dictionary(grouping: mockUsers, by: { $0.role })
        return groupedUsers.mapValues { $0.count }
    }
    
    func getUserCountByDepartment() async throws -> [String: Int] {
        let usersWithDepartment = mockUsers.compactMap { user in
            user.department.map { (department: $0, user: user) }
        }
        let groupedUsers = Dictionary(grouping: usersWithDepartment, by: { $0.department })
        return groupedUsers.mapValues { $0.count }
    }
    
    func getRecentlyActiveUsers(days: Int) async throws -> [DomainUser] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return mockUsers.filter { user in
            guard let lastLogin = user.lastLoginAt else { return false }
            return lastLogin >= cutoffDate
        }
    }
} 