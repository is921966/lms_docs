import XCTest
@testable import LMS

final class AdminServiceTests: XCTestCase {
    
    // MARK: - Properties
    var sut: AdminService!
    var mockAdminService: MockAdminService!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        sut = AdminService.shared
        mockAdminService = MockAdminService.shared
    }
    
    override func tearDown() {
        sut = nil
        mockAdminService = nil
        super.tearDown()
    }
    
    // MARK: - AdminService Tests
    
    func testAdminServiceSingleton() {
        // Given
        let firstInstance = AdminService.shared
        let secondInstance = AdminService.shared
        
        // Then
        XCTAssertTrue(firstInstance === secondInstance, "AdminService should be a singleton")
    }
    
    func testAdminServiceInitialization() {
        // Then
        XCTAssertNotNil(sut, "AdminService should be initialized")
    }
    
    // MARK: - MockAdminService Tests
    
    func testMockAdminServiceSingleton() {
        // Given
        let firstInstance = MockAdminService.shared
        let secondInstance = MockAdminService.shared
        
        // Then
        XCTAssertTrue(firstInstance === secondInstance, "MockAdminService should be a singleton")
    }
    
    func testMockAdminServiceInitialization() {
        // Then
        XCTAssertNotNil(mockAdminService, "MockAdminService should be initialized")
        XCTAssertFalse(mockAdminService.isLoading, "isLoading should be false initially")
        XCTAssertNil(mockAdminService.error, "error should be nil initially")
    }
    
    func testMockAdminServicePendingUsersInitialization() {
        // Then
        XCTAssertEqual(mockAdminService.pendingUsers.count, 3, "Should have 3 pending users initially")
        
        // Verify first user
        let firstUser = mockAdminService.pendingUsers[0]
        XCTAssertEqual(firstUser.id, "pending_1")
        XCTAssertEqual(firstUser.vkId, "123456789")
        XCTAssertEqual(firstUser.email, "petrov@example.com")
        XCTAssertEqual(firstUser.firstName, "Петр")
        XCTAssertEqual(firstUser.lastName, "Петров")
        
        // Verify second user
        let secondUser = mockAdminService.pendingUsers[1]
        XCTAssertEqual(secondUser.id, "pending_2")
        XCTAssertEqual(secondUser.vkId, "987654321")
        XCTAssertEqual(secondUser.email, "sidorova@example.com")
        XCTAssertEqual(secondUser.firstName, "Мария")
        XCTAssertEqual(secondUser.lastName, "Сидорова")
        
        // Verify third user
        let thirdUser = mockAdminService.pendingUsers[2]
        XCTAssertEqual(thirdUser.id, "pending_3")
        XCTAssertEqual(thirdUser.vkId, "555666777")
        XCTAssertEqual(thirdUser.email, "kozlov@example.com")
        XCTAssertEqual(thirdUser.firstName, "Алексей")
        XCTAssertEqual(thirdUser.lastName, "Козлов")
    }
    
    func testFetchPendingUsers() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch pending users")
        
        // When
        mockAdminService.fetchPendingUsers()
        
        // Then - immediate state
        XCTAssertTrue(mockAdminService.isLoading, "Should be loading immediately after fetch")
        XCTAssertNil(mockAdminService.error, "Error should be nil during fetch")
        
        // Wait for async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            // Then - after loading
            XCTAssertFalse(self.mockAdminService.isLoading, "Should not be loading after fetch completes")
            XCTAssertNil(self.mockAdminService.error, "Error should remain nil after successful fetch")
            XCTAssertEqual(self.mockAdminService.pendingUsers.count, 3, "Should still have 3 pending users")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testApproveSelectedUsersWithEmptyList() {
        // Given
        let expectation = XCTestExpectation(description: "Approve with empty list")
        var completionCalled = false
        var completionResult = true
        
        // When
        mockAdminService.approveSelectedUsers(userIds: []) { success in
            completionCalled = true
            completionResult = success
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(completionCalled, "Completion should be called")
        XCTAssertFalse(completionResult, "Should return false for empty list")
        XCTAssertEqual(mockAdminService.error, "Выберите хотя бы одного пользователя")
        XCTAssertEqual(mockAdminService.pendingUsers.count, 3, "Pending users should not change")
    }
    
    func testApproveSelectedUsersWithSingleUser() {
        // Given
        let expectation = XCTestExpectation(description: "Approve single user")
        let initialCount = mockAdminService.pendingUsers.count
        let userIdToApprove = "pending_1"
        var completionResult = false
        
        // When
        mockAdminService.approveSelectedUsers(userIds: [userIdToApprove]) { success in
            completionResult = success
        }
        
        // Then - immediate state
        XCTAssertTrue(mockAdminService.isLoading, "Should be loading during approval")
        
        // Wait for async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            // Then - after approval
            XCTAssertFalse(self.mockAdminService.isLoading, "Should not be loading after approval")
            XCTAssertTrue(completionResult, "Should return true for successful approval")
            XCTAssertEqual(self.mockAdminService.pendingUsers.count, initialCount - 1, "Should have one less pending user")
            XCTAssertFalse(self.mockAdminService.pendingUsers.contains { $0.id == userIdToApprove }, "Approved user should be removed")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testApproveSelectedUsersWithMultipleUsers() {
        // Given
        let expectation = XCTestExpectation(description: "Approve multiple users")
        let userIdsToApprove = ["pending_1", "pending_3"]
        var completionResult = false
        
        // When
        mockAdminService.approveSelectedUsers(userIds: userIdsToApprove) { success in
            completionResult = success
        }
        
        // Wait for async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            // Then
            XCTAssertTrue(completionResult, "Should return true for successful approval")
            XCTAssertEqual(self.mockAdminService.pendingUsers.count, 1, "Should have only one pending user left")
            XCTAssertEqual(self.mockAdminService.pendingUsers[0].id, "pending_2", "Only pending_2 should remain")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testApproveAllPendingUsers() {
        // Given
        let expectation = XCTestExpectation(description: "Approve all users")
        let allUserIds = mockAdminService.pendingUsers.map { $0.id }
        var completionResult = false
        
        // When
        mockAdminService.approveSelectedUsers(userIds: allUserIds) { success in
            completionResult = success
        }
        
        // Wait for async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            // Then
            XCTAssertTrue(completionResult, "Should return true for successful approval")
            XCTAssertEqual(self.mockAdminService.pendingUsers.count, 0, "Should have no pending users left")
            XCTAssertTrue(self.mockAdminService.pendingUsers.isEmpty, "Pending users array should be empty")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testPendingUserPropertiesValidation() {
        // Given
        let pendingUsers = mockAdminService.pendingUsers
        
        // Then
        for user in pendingUsers {
            XCTAssertFalse(user.id.isEmpty, "User ID should not be empty")
            XCTAssertFalse(user.vkId.isEmpty, "VK ID should not be empty")
            XCTAssertFalse(user.email.isEmpty, "Email should not be empty")
            XCTAssertFalse(user.firstName.isEmpty, "First name should not be empty")
            XCTAssertFalse(user.lastName.isEmpty, "Last name should not be empty")
            XCTAssertNil(user.avatar, "Avatar should be nil for mock users")
            XCTAssertFalse(user.registeredAt.isEmpty, "Registration date should not be empty")
            XCTAssertTrue(user.email.contains("@"), "Email should contain @")
        }
    }
    
    func testConcurrentApprovalRequests() {
        // Given
        let expectation1 = XCTestExpectation(description: "First approval")
        let expectation2 = XCTestExpectation(description: "Second approval")
        var result1 = false
        var result2 = false
        
        // When - simulate concurrent requests
        mockAdminService.approveSelectedUsers(userIds: ["pending_1"]) { success in
            result1 = success
            expectation1.fulfill()
        }
        
        mockAdminService.approveSelectedUsers(userIds: ["pending_2"]) { success in
            result2 = success
            expectation2.fulfill()
        }
        
        // Then
        wait(for: [expectation1, expectation2], timeout: 3.0)
        
        // At least one should succeed (depends on timing)
        XCTAssertTrue(result1 || result2, "At least one approval should succeed")
    }
    
    func testErrorStateReset() {
        // Given
        mockAdminService.error = "Test error"
        
        // When
        mockAdminService.fetchPendingUsers()
        
        // Then
        XCTAssertNil(mockAdminService.error, "Error should be reset when starting new operation")
    }
    
    func testLoadingStateTransitions() {
        // Given
        let expectation = XCTestExpectation(description: "Loading state transitions")
        var loadingStates: [Bool] = []
        
        // Observe loading state changes
        let cancellable = mockAdminService.$isLoading.sink { isLoading in
            loadingStates.append(isLoading)
        }
        
        // When
        mockAdminService.fetchPendingUsers()
        
        // Wait and check
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Then
            XCTAssertGreaterThanOrEqual(loadingStates.count, 2, "Should have at least 2 state changes")
            if loadingStates.count >= 2 {
                XCTAssertFalse(loadingStates[0], "Initial state should be false")
                XCTAssertTrue(loadingStates[1], "Should transition to true when loading starts")
                if loadingStates.count >= 3 {
                    XCTAssertFalse(loadingStates.last!, "Should transition back to false when loading ends")
                }
            }
            cancellable.cancel()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}

// MARK: - Performance Tests
extension AdminServiceTests {
    
    func testFetchPendingUsersPerformance() {
        measure {
            mockAdminService.fetchPendingUsers()
            
            // Wait for completion
            let expectation = XCTestExpectation(description: "Performance test")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 2.0)
        }
    }
    
    func testApprovalPerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Performance test")
            
            mockAdminService.approveSelectedUsers(userIds: ["pending_1"]) { _ in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }
} 