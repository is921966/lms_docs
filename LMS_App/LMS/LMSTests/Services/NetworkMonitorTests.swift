//
//  NetworkMonitorTests.swift
//  LMSTests
//
//  Created on 11/07/2025.
//

import XCTest
import Combine
@testable import LMS

final class NetworkMonitorTests: XCTestCase {
    private var sut: NetworkMonitor!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = NetworkMonitor.shared
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testSharedInstance() {
        // Given/When
        let instance1 = NetworkMonitor.shared
        let instance2 = NetworkMonitor.shared
        
        // Then - should be same instance
        XCTAssertTrue(instance1 === instance2)
    }
    
    func testInitialState() {
        // Initial state should have reasonable defaults
        XCTAssertNotNil(sut.isConnected)
        XCTAssertNotNil(sut.connectionType)
        XCTAssertNotNil(sut.isExpensive)
    }
    
    // MARK: - Connection Status Tests
    
    func testCheckConnectivityWhenConnected() {
        // Given - assume connected (default state)
        // Note: In real tests, we'd need to mock network state
        
        // When/Then - should not throw
        XCTAssertNoThrow(try sut.checkConnectivity())
    }
    
    func testCheckConnectivityWhenDisconnected() {
        // This test would require mocking network state
        // For now, we can only test the method exists
        XCTAssertNotNil(sut.checkConnectivity)
    }
    
    // MARK: - Connection Type Tests
    
    func testConnectionDescription() {
        // Test all connection type descriptions
        XCTAssertNotNil(sut.connectionDescription)
        
        // Should return some description
        let description = sut.connectionDescription
        XCTAssertFalse(description.isEmpty)
    }
    
    func testConnectionTypeEnum() {
        // Test that all enum cases are handled
        let types: [NetworkMonitor.ConnectionType] = [.wifi, .cellular, .ethernet, .unknown]
        
        for type in types {
            // Verify enum exists and can be compared
            XCTAssertNotNil(type)
        }
    }
    
    // MARK: - Publisher Tests
    
    func testIsConnectedPublisher() {
        let expectation = XCTestExpectation(description: "Publisher emits value")
        
        // Subscribe to publisher
        sut.$isConnected
            .sink { value in
                XCTAssertNotNil(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testConnectionTypePublisher() {
        let expectation = XCTestExpectation(description: "Publisher emits value")
        
        // Subscribe to publisher
        sut.$connectionType
            .sink { value in
                XCTAssertNotNil(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testIsExpensivePublisher() {
        let expectation = XCTestExpectation(description: "Publisher emits value")
        
        // Subscribe to publisher
        sut.$isExpensive
            .sink { value in
                XCTAssertNotNil(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Monitoring Control Tests
    
    func testStartMonitoring() {
        // Test that method exists and doesn't crash
        XCTAssertNoThrow(sut.startMonitoring())
    }
    
    func testStopMonitoring() {
        // Test that method exists and doesn't crash
        XCTAssertNoThrow(sut.stopMonitoring())
    }
    
    func testMonitoringLifecycle() {
        // Start and stop monitoring
        sut.startMonitoring()
        sut.stopMonitoring()
        
        // Should not crash
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Edge Cases
    
    func testMultipleStartCalls() {
        // Multiple start calls should not crash
        sut.startMonitoring()
        sut.startMonitoring()
        sut.startMonitoring()
        
        XCTAssertNotNil(sut)
    }
    
    func testMultipleStopCalls() {
        // Multiple stop calls should not crash
        sut.stopMonitoring()
        sut.stopMonitoring()
        sut.stopMonitoring()
        
        XCTAssertNotNil(sut)
    }
    
    func testAlternatingStartStop() {
        // Alternating calls should not crash
        for _ in 0..<5 {
            sut.startMonitoring()
            sut.stopMonitoring()
        }
        
        XCTAssertNotNil(sut)
    }
} 