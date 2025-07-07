//
//  CacheServiceTests.swift
//  LMSTests
//
//  Created on Sprint 39 - TDD Excellence
//

import XCTest
@testable import LMS

final class CacheServiceTests: XCTestCase {
    
    var sut: CacheService!
    
    override func setUp() {
        super.setUp()
        sut = CacheService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Cache Storage Tests
    
    func testSetAndGetCachedValue() {
        // Arrange
        let key = "test-key"
        let value = "test-value"
        
        // Act
        sut.set(value, for: key)
        let retrieved = sut.get(String.self, for: key)
        
        // Assert
        XCTAssertEqual(retrieved, value)
    }
    
    // MARK: - Cache Expiration Tests
    
    func testCacheExpirationAfterTTL() {
        // Arrange
        let key = "expiring-key"
        let value = "will-expire"
        let ttl: TimeInterval = 0.1 // 100ms
        
        // Act
        sut.set(value, for: key, ttl: ttl)
        
        // Initial value should exist
        XCTAssertNotNil(sut.get(String.self, for: key))
        
        // Wait for expiration
        Thread.sleep(forTimeInterval: 0.2)
        
        // Assert - value should be nil after TTL
        XCTAssertNil(sut.get(String.self, for: key))
    }
    
    // MARK: - Cache Clearing Tests
    
    func testClearAllCache() {
        // Arrange
        sut.set("value1", for: "key1")
        sut.set("value2", for: "key2")
        sut.set("value3", for: "key3")
        
        // Act
        sut.clearAll()
        
        // Assert
        XCTAssertNil(sut.get(String.self, for: "key1"))
        XCTAssertNil(sut.get(String.self, for: "key2"))
        XCTAssertNil(sut.get(String.self, for: "key3"))
        XCTAssertEqual(sut.cacheSize, 0)
    }
} 