import XCTest
@testable import LMS

final class PreCommitHookTests: XCTestCase {
    
    func testTDDInfrastructureIsReady() {
        // Arrange
        let tddCompliance = TDDInfrastructure()
        
        // Act
        let isReady = tddCompliance.isInfrastructureReady()
        
        // Assert
        XCTAssertTrue(isReady, "TDD Infrastructure должна быть готова")
    }
    
    func testPreCommitHookExists() {
        // Arrange
        let hookPath = ".git/hooks/pre-commit"
        let fileManager = FileManager.default
        
        // Act
        let hookExists = fileManager.fileExists(atPath: hookPath)
        
        // Assert
        XCTAssertTrue(hookExists, "Pre-commit hook должен существовать")
    }
    
    func testMaximumTestsPerDayLimit() {
        // Arrange
        let tddCompliance = TDDInfrastructure()
        let maxTestsPerDay = 10
        
        // Act
        let actualLimit = tddCompliance.maximumTestsPerDay
        
        // Assert
        XCTAssertEqual(actualLimit, maxTestsPerDay, "Максимум 10 тестов в день согласно TDD правилам")
    }
} 