import XCTest
import Combine
@testable import LMS

@MainActor
final class UserViewModelTests: XCTestCase {
    private var viewModel: UserViewModel!
    private var mockService: MockUserServiceForTesting!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockUserServiceForTesting()
        viewModel = UserViewModel(userService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Load Users Tests
    
    func testLoadUsersSuccess() async {
        // Given
        let expectedUsers = createTestUsers()
        mockService.usersToReturn = expectedUsers
        
        // When
        await viewModel.loadUsers()
        
        // Then
        XCTAssertEqual(viewModel.users.count, expectedUsers.count)
        XCTAssertEqual(viewModel.filteredUsers.count, expectedUsers.count)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadUsersFailure() async {
        // Given
        mockService.shouldThrowError = true
        
        // When
        await viewModel.loadUsers()
        
        // Then
        XCTAssertTrue(viewModel.users.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    // MARK: - Search Tests
    
    func testSearchByName() async {
        // Given
        await viewModel.loadUsers()
        
        // When
        viewModel.searchText = "John"
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(viewModel.filteredUsers.allSatisfy { user in
            user.name.localizedCaseInsensitiveContains("John")
        })
    }
    
    func testSearchByEmail() async {
        // Given
        await viewModel.loadUsers()
        
        // When
        viewModel.searchText = "@example.com"
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(viewModel.filteredUsers.allSatisfy { user in
            user.email.localizedCaseInsensitiveContains("@example.com")
        })
    }
    
    // MARK: - Filter Tests
    
    func testFilterByRole() async {
        // Given
        await viewModel.loadUsers()
        
        // When
        viewModel.selectedRole = .student
        
        // Then
        XCTAssertTrue(viewModel.filteredUsers.allSatisfy { $0.role == .student })
    }
    
    func testCombinedSearchAndFilter() async {
        // Given
        await viewModel.loadUsers()
        
        // When
        viewModel.searchText = "John"
        viewModel.selectedRole = .student
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(viewModel.filteredUsers.allSatisfy { user in
            user.name.localizedCaseInsensitiveContains("John") && user.role == .student
        })
    }
    
    // MARK: - Selection Tests
    
    func testToggleUserSelection() async {
        // Given
        await viewModel.loadUsers()
        let user = viewModel.users.first!
        
        // When - Select
        viewModel.toggleUserSelection(user)
        
        // Then
        XCTAssertTrue(viewModel.selectedUsers.contains(user.id))
        
        // When - Deselect
        viewModel.toggleUserSelection(user)
        
        // Then
        XCTAssertFalse(viewModel.selectedUsers.contains(user.id))
    }
    
    func testSelectAll() async {
        // Given
        await viewModel.loadUsers()
        
        // When
        viewModel.selectAll()
        
        // Then
        XCTAssertEqual(viewModel.selectedUsers.count, viewModel.filteredUsers.count)
    }
    
    func testDeselectAll() async {
        // Given
        await viewModel.loadUsers()
        viewModel.selectAll()
        
        // When
        viewModel.deselectAll()
        
        // Then
        XCTAssertTrue(viewModel.selectedUsers.isEmpty)
    }
    
    // MARK: - Delete Tests
    
    func testDeleteUser() async {
        // Given
        await viewModel.loadUsers()
        let userToDelete = viewModel.users.first!
        let initialCount = viewModel.users.count
        
        // When
        await viewModel.deleteUser(userToDelete)
        
        // Then
        XCTAssertEqual(viewModel.users.count, initialCount - 1)
        XCTAssertFalse(viewModel.users.contains { $0.id == userToDelete.id })
    }
    
    func testDeleteSelectedUsers() async {
        // Given
        await viewModel.loadUsers()
        viewModel.toggleUserSelection(viewModel.users[0])
        viewModel.toggleUserSelection(viewModel.users[1])
        let initialCount = viewModel.users.count
        
        // When
        await viewModel.deleteSelectedUsers()
        
        // Then
        XCTAssertEqual(viewModel.users.count, initialCount - 2)
        XCTAssertTrue(viewModel.selectedUsers.isEmpty)
        XCTAssertFalse(viewModel.isSelectionMode)
    }
    
    // MARK: - Helper Methods
    
    private func createTestUsers() -> [User] {
        return [
            User(id: UUID(), email: "john.doe@example.com", name: "John Doe", role: .student, avatarURL: nil),
            User(id: UUID(), email: "jane.smith@example.com", name: "Jane Smith", role: .instructor, avatarURL: nil),
            User(id: UUID(), email: "admin@example.com", name: "Admin User", role: .admin, avatarURL: nil)
        ]
    }
}

// MARK: - Mock Service for Testing
class MockUserServiceForTesting: UserServiceProtocol {
    var usersToReturn: [User] = []
    var shouldThrowError = false
    var deletedUserIds: [UUID] = []
    
    func fetchUsers() async throws -> [User] {
        if shouldThrowError {
            throw UserError.networkError
        }
        return usersToReturn
    }
    
    func fetchUser(id: UUID) async throws -> User {
        guard let user = usersToReturn.first(where: { $0.id == id }) else {
            throw UserError.notFound
        }
        return user
    }
    
    func createUser(_ user: User) async throws -> User {
        usersToReturn.append(user)
        return user
    }
    
    func updateUser(_ user: User) async throws -> User {
        guard let index = usersToReturn.firstIndex(where: { $0.id == user.id }) else {
            throw UserError.notFound
        }
        usersToReturn[index] = user
        return user
    }
    
    func deleteUser(_ id: UUID) async throws {
        deletedUserIds.append(id)
        usersToReturn.removeAll { $0.id == id }
    }
} 