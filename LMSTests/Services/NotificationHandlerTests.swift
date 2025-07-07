import XCTest
@testable import LMS

final class NotificationHandlerTests: XCTestCase {
    
    var sut: NotificationHandler!
    
    override func setUp() {
        super.setUp()
        sut = NotificationHandler()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Success Handling Tests
    
    func testHandleSuccessfulPushNotification() async throws {
        // Arrange
        let notification = PushNotification(
            id: "test-1",
            title: "Test Notification",
            body: "Test body",
            data: ["key": "value"]
        )
        
        // Act
        let result = try await sut.handle(notification)
        
        // Assert
        XCTAssertTrue(result.isSuccess)
        XCTAssertEqual(result.notificationId, "test-1")
        XCTAssertNil(result.error)
    }
    
    // MARK: - Error Handling Tests
    
    func testHandleFailedPushNotification() async throws {
        // Arrange
        let notification = PushNotification(
            id: "test-fail",
            title: "Fail Test",
            body: "This should fail",
            data: ["fail": "true"]
        )
        
        // Act & Assert
        do {
            _ = try await sut.handle(notification)
            XCTFail("Expected error but got success")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Logging Tests
    
    func testNotificationHandlingIsLogged() async throws {
        // Arrange
        let notification = PushNotification(
            id: "test-log",
            title: "Log Test",
            body: "Test logging",
            data: [:]
        )
        
        // Act
        _ = try? await sut.handle(notification)
        
        // Assert
        let logs = sut.getRecentLogs()
        XCTAssertFalse(logs.isEmpty)
        XCTAssertTrue(logs.contains { $0.contains("test-log") })
    }
} 