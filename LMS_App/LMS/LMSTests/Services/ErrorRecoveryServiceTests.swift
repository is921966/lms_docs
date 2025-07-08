//
//  ErrorRecoveryServiceTests.swift
//  LMSTests
//
//  Created on Sprint 39 Day 2 - TDD Excellence
//

import XCTest
@testable import LMS

final class ErrorRecoveryServiceTests: XCTestCase {
    
    var sut: ErrorRecoveryService!
    
    override func setUp() {
        super.setUp()
        sut = ErrorRecoveryService.shared
        sut.resetAllCircuits() // Очищаем состояние перед каждым тестом
    }
    
    override func tearDown() {
        sut.resetAllCircuits()
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Recovery Strategy Tests
    
    func testRetryWithExponentialBackoff() async throws {
        // Arrange
        var attemptCount = 0
        let failingOperation = {
            attemptCount += 1
            if attemptCount < 3 {
                throw RecoverableError.networkTimeout
            }
            return "Success"
        }
        
        // Act
        let result = try await sut.retry(
            operation: failingOperation,
            maxAttempts: 3,
            strategy: .exponentialBackoff(),
            context: "Test Operation"
        )
        
        // Assert
        XCTAssertEqual(result, "Success")
        XCTAssertEqual(attemptCount, 3)
    }
    
    func testRecoveryFromNetworkError() async {
        // Arrange
        let error = RecoverableError.connectionLost
        
        // Act
        let recovery = await sut.recoverFrom(error: error)
        
        // Assert
        XCTAssertEqual(recovery.action, .retry)
        XCTAssertEqual(recovery.delay, 1.0)
        XCTAssertTrue(recovery.shouldNotifyUser)
        XCTAssertEqual(recovery.message, "Проверьте подключение к интернету")
    }
    
    func testCircuitBreakerOpensAfterFailures() async {
        // Arrange
        let operation = { throw RecoverableError.serverError(statusCode: 500) }
        
        // Act
        for _ in 0..<5 {
            _ = try? await sut.executeWithCircuitBreaker(
                operation: operation,
                resourceId: "api-endpoint"
            )
        }
        
        // Assert
        let isOpen = sut.isCircuitOpen(for: "api-endpoint")
        XCTAssertTrue(isOpen)
    }
    
    // MARK: - Additional Tests for Refactored Functionality
    
    func testMetricsTracking() async throws {
        // Arrange
        let failThenSucceed = {
            @Sendable () async throws -> String in
            if self.sut.getMetrics().totalOperations < 2 {
                throw RecoverableError.networkTimeout
            }
            return "Success"
        }
        
        // Act
        _ = try? await sut.retry(
            operation: failThenSucceed,
            maxAttempts: 3,
            context: "Metrics Test"
        )
        
        // Assert
        let metrics = sut.getMetrics()
        XCTAssertGreaterThan(metrics.totalOperations, 0)
        XCTAssertGreaterThan(metrics.successfulRetries, 0)
    }
    
    func testCustomRetryStrategy() async throws {
        // Arrange
        var delays: [TimeInterval] = []
        let customStrategy = RetryStrategy.custom { attempt in
            let delay = Double(attempt) * 0.01
            delays.append(delay)
            return delay
        }
        
        var attemptCount = 0
        let operation = {
            attemptCount += 1
            if attemptCount < 3 {
                throw RecoverableError.networkTimeout
            }
            return "Success"
        }
        
        // Act
        _ = try await sut.retry(
            operation: operation,
            strategy: customStrategy,
            context: "Custom Strategy Test"
        )
        
        // Assert
        XCTAssertEqual(delays.count, 2)
        XCTAssertEqual(delays[0], 0.0)
        XCTAssertEqual(delays[1], 0.01)
    }
} 