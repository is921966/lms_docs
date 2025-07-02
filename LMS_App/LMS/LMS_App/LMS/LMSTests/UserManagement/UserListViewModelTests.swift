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
    
    // MARK: - Basic Tests
    
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
    
    func testCreateUser_Success() async {
        // Given
        let createDTO = CreateUserDTO(
            email: "new.user@example.com",
            firstName: "New",
            lastName: "User",
            role: "student",
            department: "Marketing",
            position: "Intern",
            phoneNumber: "+7 (999) 999-99-99",
            isActive: true
        )
        
        // When
        let result = await viewModel.createUser(createDTO)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showError)
    }
    
    // MARK: - Helper Methods
    
    private func createTestUsers() -> [DomainUser] {
        return [
            DomainUser(
                id: UUID(),
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
                id: UUID(),
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
    
    func findById(_ id: UUID) async throws -> DomainUser? {
        return mockUsers.first { $0.id == id }
    }
    
    func findAll(pagination: PaginationRequest?) async throws -> PaginatedResult<DomainUser> {
        if shouldFailNextOperation {
            shouldFailNextOperation = false
            throw RepositoryError.networkError(nil)
        }
        
        return PaginatedResult(
            items: mockUsers,
            page: 1,
            limit: 20,
            totalItems: mockUsers.count,
            hasNextPage: false
        )
    }
    
    func save(_ entity: DomainUser) async throws -> DomainUser {
        if let index = mockUsers.firstIndex(where: { $0.id == entity.id }) {
            mockUsers[index] = entity
        } else {
            mockUsers.append(entity)
        }
        return entity
    }
    
    func deleteById(_ id: UUID) async throws {
        mockUsers.removeAll { $0.id == id }
    }
    
    func exists(_ id: UUID) async throws -> Bool {
        return mockUsers.contains { $0.id == id }
    }
    
    func count() async throws -> Int {
        return mockUsers.count
    }
    
    func search(query: String?, filters: [UserListViewModel.UserSearchFilter], pagination: PaginationRequest?) async throws -> PaginatedResult<DomainUser> {
        return try await findAll(pagination: pagination)
    }
    
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
        let newUser = DomainUser(
            id: UUID(),
            email: createDTO.email,
            firstName: createDTO.firstName,
            lastName: createDTO.lastName,
            role: DomainUserRole(rawValue: createDTO.role) ?? .student,
            isActive: createDTO.isActive,
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
    
    func updateUser(_ id: UUID, _ updateDTO: UpdateUserDTO) async throws -> DomainUser {
        guard let existingUser = try await findById(id) else {
            throw RepositoryError.notFound
        }
        
        let updatedUser = DomainUser(
            id: existingUser.id,
            email: updateDTO.email,
            firstName: updateDTO.firstName,
            lastName: updateDTO.lastName,
            role: DomainUserRole(rawValue: updateDTO.role) ?? existingUser.role,
            isActive: updateDTO.isActive,
            profileImageUrl: existingUser.profileImageUrl,
            phoneNumber: updateDTO.phoneNumber,
            department: updateDTO.department,
            position: updateDTO.position,
            lastLoginAt: existingUser.lastLoginAt,
            createdAt: existingUser.createdAt,
            updatedAt: Date()
        )
        
        return try await save(updatedUser)
    }
    
    func setUserActive(_ id: UUID, isActive: Bool) async throws {
        // Mock implementation
    }
    
    func updateLastLogin(_ id: UUID) async throws {
        // Mock implementation
    }
    
    func createUsers(_ createDTOs: [CreateUserDTO]) async throws -> [DomainUser] {
        return []
    }
    
    func updateUsers(_ updates: [(UUID, UpdateUserDTO)]) async throws -> [DomainUser] {
        return []
    }
    
    func deleteUsers(_ ids: [UUID]) async throws {
        // Mock implementation
    }
    
    func getUserCountByRole() async throws -> [DomainUserRole: Int] {
        return [:]
    }
    
    func getUserCountByDepartment() async throws -> [String: Int] {
        return [:]
    }
    
    func getRecentlyActiveUsers(since: Date) async throws -> [DomainUser] {
        return []
    }
}
