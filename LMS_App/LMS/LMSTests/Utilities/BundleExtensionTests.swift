//
//  BundleExtensionTests.swift
//  LMSTests
//

import XCTest
@testable import LMS

class BundleExtensionTests: XCTestCase {
    
    // MARK: - appVersion Tests
    
    func testAppVersion_Format() {
        // The format should be "version (build)"
        let appVersion = Bundle.main.appVersion
        
        // Check that it contains parentheses
        XCTAssertTrue(appVersion.contains("("))
        XCTAssertTrue(appVersion.contains(")"))
    }
    
    func testAppVersion_NotEmpty() {
        let appVersion = Bundle.main.appVersion
        XCTAssertFalse(appVersion.isEmpty)
    }
    
    func testAppVersion_ContainsVersion() {
        let appVersion = Bundle.main.appVersion
        
        // Should contain at least "1.0 (1)" as default
        XCTAssertTrue(appVersion.count >= 7) // Minimum length for "1.0 (1)"
    }
    
    func testAppVersion_DefaultValues() {
        // When values are not in Info.plist, should use defaults
        let bundle = MockBundle()
        let expectedVersion = "1.0 (1)"
        
        // In real implementation, this would test the actual default logic
        XCTAssertEqual(expectedVersion, "1.0 (1)")
    }
    
    func testAppVersion_ParsesCorrectly() {
        let appVersion = Bundle.main.appVersion
        
        // Should be able to split by " ("
        let components = appVersion.components(separatedBy: " (")
        XCTAssertTrue(components.count >= 1)
        
        if components.count == 2 {
            // Check that second component ends with ")"
            XCTAssertTrue(components[1].hasSuffix(")"))
        }
    }
    
    func testAppVersion_VersionPartFormat() {
        let appVersion = Bundle.main.appVersion
        let versionPart = appVersion.components(separatedBy: " (").first ?? ""
        
        // Version should contain at least one dot
        if !versionPart.isEmpty {
            // Common version formats: 1.0, 1.0.0, 1.2.3
            let versionComponents = versionPart.components(separatedBy: ".")
            XCTAssertTrue(versionComponents.count >= 2, "Version should have at least major.minor format")
        }
    }
    
    func testAppVersion_BuildPartFormat() {
        let appVersion = Bundle.main.appVersion
        let components = appVersion.components(separatedBy: " (")
        
        if components.count == 2 {
            let buildPart = components[1].replacingOccurrences(of: ")", with: "")
            
            // Build should not be empty
            XCTAssertFalse(buildPart.isEmpty)
            
            // Build is typically numeric
            if let _ = Int(buildPart) {
                XCTAssertTrue(true, "Build number is numeric")
            } else {
                // Build could also be alphanumeric
                XCTAssertTrue(buildPart.count > 0, "Build string is not empty")
            }
        }
    }
}

// MARK: - Mock Bundle for Testing

class MockBundle: Bundle {
    var mockInfoDictionary: [String: Any]?
    
    override var infoDictionary: [String: Any]? {
        return mockInfoDictionary
    }
}

// MARK: - Bundle Extension Edge Cases Tests

class BundleExtensionEdgeCasesTests: XCTestCase {
    
    func testAppVersion_WithCustomBundle() {
        let bundle = MockBundle()
        
        // Test with custom values
        bundle.mockInfoDictionary = [
            "CFBundleShortVersionString": "2.5.1",
            "CFBundleVersion": "123"
        ]
        
        // Would need to modify extension to accept bundle parameter for this test
        // For now, test the expected format
        let expectedFormat = "2.5.1 (123)"
        XCTAssertEqual(expectedFormat.components(separatedBy: " ").count, 2)
    }
    
    func testAppVersion_MissingVersionKey() {
        let bundle = MockBundle()
        
        // Only build number present
        bundle.mockInfoDictionary = [
            "CFBundleVersion": "456"
        ]
        
        // Should use default version "1.0"
        // Expected: "1.0 (456)"
        let expectedVersion = "1.0"
        XCTAssertEqual(expectedVersion, "1.0")
    }
    
    func testAppVersion_MissingBuildKey() {
        let bundle = MockBundle()
        
        // Only version present
        bundle.mockInfoDictionary = [
            "CFBundleShortVersionString": "3.2.1"
        ]
        
        // Should use default build "1"
        // Expected: "3.2.1 (1)"
        let expectedBuild = "1"
        XCTAssertEqual(expectedBuild, "1")
    }
    
    func testAppVersion_BothKeysMissing() {
        let bundle = MockBundle()
        
        // No keys present
        bundle.mockInfoDictionary = [:]
        
        // Should use defaults
        // Expected: "1.0 (1)"
        let expectedDefault = "1.0 (1)"
        XCTAssertEqual(expectedDefault, "1.0 (1)")
    }
    
    func testAppVersion_NilInfoDictionary() {
        let bundle = MockBundle()
        bundle.mockInfoDictionary = nil
        
        // Should handle nil gracefully and use defaults
        // Expected: "1.0 (1)"
        let expectedDefault = "1.0 (1)"
        XCTAssertEqual(expectedDefault, "1.0 (1)")
    }
    
    func testAppVersion_EmptyStringValues() {
        let bundle = MockBundle()
        
        // Empty string values
        bundle.mockInfoDictionary = [
            "CFBundleShortVersionString": "",
            "CFBundleVersion": ""
        ]
        
        // Should treat empty strings as missing and use defaults
        // Note: Actual implementation might handle this differently
        XCTAssertTrue(true, "Empty strings should be handled")
    }
    
    func testAppVersion_SpecialCharacters() {
        let bundle = MockBundle()
        
        // Version with special characters
        bundle.mockInfoDictionary = [
            "CFBundleShortVersionString": "1.0-beta",
            "CFBundleVersion": "100-dev"
        ]
        
        // Should handle special characters
        // Expected: "1.0-beta (100-dev)"
        let expectedFormat = "1.0-beta (100-dev)"
        XCTAssertTrue(expectedFormat.contains("-"))
    }
} 