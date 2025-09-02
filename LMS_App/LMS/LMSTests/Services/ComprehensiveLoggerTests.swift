import XCTest
@testable import LMS

class ComprehensiveLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear logs before each test
        ComprehensiveLogger.shared.clearLogs()
    }
    
    func test_logWithUUID_doesNotCrash() {
        // Given
        let testUUID = UUID()
        let details: [String: Any] = [
            "userId": testUUID,
            "sessionId": UUID(),
            "postId": "test-post-123"
        ]
        
        // When
        ComprehensiveLogger.shared.log(.ui, .info, "Test event with UUID", details: details)
        
        // Then - no crash should occur
        XCTAssertEqual(ComprehensiveLogger.shared.logs.count, 1)
        
        // Verify the log was properly serialized
        let log = ComprehensiveLogger.shared.logs.first!
        XCTAssertEqual(log.event, "Test event with UUID")
        
        // Check that details were preserved
        if let loggedUserId = log.details["userId"] as? String {
            XCTAssertEqual(loggedUserId, testUUID.uuidString)
        } else {
            XCTFail("UUID should have been converted to string")
        }
    }
    
    func test_logWithComplexTypes_doesNotCrash() {
        // Given
        let complexDetails: [String: Any] = [
            "date": Date(),
            "url": URL(string: "https://example.com")!,
            "data": Data("test".utf8),
            "null": NSNull(),
            "array": [UUID(), Date(), "string"],
            "dict": ["nested": UUID()],
            "number": 42,
            "bool": true
        ]
        
        // When
        ComprehensiveLogger.shared.log(.network, .debug, "Complex types test", details: complexDetails)
        
        // Then - no crash should occur
        XCTAssertEqual(ComprehensiveLogger.shared.logs.count, 1)
    }
    
    func test_logPerformance() {
        // Measure performance of logging
        self.measure {
            for i in 0..<100 {
                ComprehensiveLogger.shared.log(.ui, .info, "Performance test \(i)", details: [
                    "index": i,
                    "uuid": UUID(),
                    "timestamp": Date()
                ])
            }
        }
    }
} 