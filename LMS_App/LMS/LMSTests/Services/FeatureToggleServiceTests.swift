//
//  FeatureToggleServiceTests.swift
//  LMSTests
//
//  Created on Sprint 39 - TDD Excellence
//

import XCTest
@testable import LMS

final class FeatureToggleServiceTests: XCTestCase {
    
    var sut: FeatureToggleService!
    
    override func setUp() {
        super.setUp()
        sut = FeatureToggleService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Feature Flag Tests
    
    func testIsFeatureEnabledReturnsTrueForEnabledFeature() {
        // Arrange
        let featureName = "new-dashboard"
        sut.enableFeature(featureName)
        
        // Act
        let isEnabled = sut.isFeatureEnabled(featureName)
        
        // Assert
        XCTAssertTrue(isEnabled)
    }
    
    func testIsFeatureEnabledReturnsFalseForDisabledFeature() {
        // Arrange
        let featureName = "experimental-ai"
        // Feature is not enabled by default
        
        // Act
        let isEnabled = sut.isFeatureEnabled(featureName)
        
        // Assert
        XCTAssertFalse(isEnabled)
    }
    
    func testDisableFeatureTurnsOffEnabledFeature() {
        // Arrange
        let featureName = "analytics-v2"
        sut.enableFeature(featureName)
        
        // Act
        sut.disableFeature(featureName)
        let isEnabled = sut.isFeatureEnabled(featureName)
        
        // Assert
        XCTAssertFalse(isEnabled)
    }
} 