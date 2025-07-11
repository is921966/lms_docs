//
//  FeedbackModelTests.swift
//  LMSTests
//
//  Created on 01.07.2025.
//

@testable import LMS
import XCTest

class FeedbackModelTests: XCTestCase {
    // MARK: - Test Properties
    private var sampleDeviceInfo: DeviceInfo!
    private var sampleAppContext: AppContext!

    override func setUpWithError() throws {
        super.setUp()

        // Create sample device info
        sampleDeviceInfo = DeviceInfo(
            model: "iPhone 16 Pro",
            osVersion: "18.5",
            appVersion: "1.0.0",
            buildNumber: "100",
            locale: "en_US",
            screenSize: "414x896"
        )
        
        // Create sample app context
        sampleAppContext = AppContext(
            currentScreen: "Home",
            previousScreen: "Login",
            sessionDuration: 300,
            memoryUsage: 1024 * 1024 * 50, // 50MB
            batteryLevel: 0.75
        )
    }

    // MARK: - FeedbackModel Tests

    func testFeedbackModelInitialization() {
        // Given
        let feedbackText = "Test feedback message"
        let feedbackType = "bug"
        let userId = "user123"
        let userEmail = "test@example.com"
        let screenshot = "base64encodedscreenshot"

        // When
        let feedback = FeedbackModel(
            type: feedbackType,
            text: feedbackText,
            screenshot: screenshot,
            deviceInfo: sampleDeviceInfo,
            userId: userId,
            userEmail: userEmail,
            appContext: sampleAppContext
        )

        // Then
        XCTAssertNotNil(feedback.id)
        XCTAssertEqual(feedback.type, feedbackType)
        XCTAssertEqual(feedback.text, feedbackText)
        XCTAssertEqual(feedback.screenshot, screenshot)
        XCTAssertEqual(feedback.deviceInfo.model, sampleDeviceInfo.model)
        XCTAssertEqual(feedback.userId, userId)
        XCTAssertEqual(feedback.userEmail, userEmail)
        XCTAssertNotNil(feedback.timestamp)
        XCTAssertNotNil(feedback.appContext)
        XCTAssertEqual(feedback.appContext?.currentScreen, "Home")
    }

    func testFeedbackModelCodable() throws {
        // Given
        let feedback = FeedbackModel(
            type: "bug",
            text: "Test encoding/decoding",
            screenshot: "base64screenshot",
            deviceInfo: sampleDeviceInfo,
            userId: "test-user",
            userEmail: "test@test.com",
            appContext: sampleAppContext
        )

        // When - Encode
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let encodedData = try encoder.encode(feedback)

        // Then - Verify encoding
        XCTAssertFalse(encodedData.isEmpty)

        // When - Decode
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedFeedback = try decoder.decode(FeedbackModel.self, from: encodedData)

        // Then - Verify decoding
        XCTAssertEqual(decodedFeedback.id, feedback.id)
        XCTAssertEqual(decodedFeedback.type, feedback.type)
        XCTAssertEqual(decodedFeedback.text, feedback.text)
        XCTAssertEqual(decodedFeedback.screenshot, feedback.screenshot)
        XCTAssertEqual(decodedFeedback.userId, feedback.userId)
        XCTAssertEqual(decodedFeedback.userEmail, feedback.userEmail)
        XCTAssertEqual(decodedFeedback.appContext?.currentScreen, feedback.appContext?.currentScreen)
    }

    func testDeviceInfoInitialization() {
        // When
        let deviceInfo = DeviceInfo(
            model: "iPhone 16 Pro",
            osVersion: "18.5",
            appVersion: "1.0.0",
            buildNumber: "100",
            locale: "en_US",
            screenSize: "414x896"
        )

        // Then
        XCTAssertEqual(deviceInfo.model, "iPhone 16 Pro")
        XCTAssertEqual(deviceInfo.osVersion, "18.5")
        XCTAssertEqual(deviceInfo.appVersion, "1.0.0")
        XCTAssertEqual(deviceInfo.buildNumber, "100")
        XCTAssertEqual(deviceInfo.locale, "en_US")
        XCTAssertEqual(deviceInfo.screenSize, "414x896")
    }
    
    func testAppContextInitialization() {
        // When
        let appContext = AppContext(
            currentScreen: "Settings",
            previousScreen: "Profile",
            sessionDuration: 600,
            memoryUsage: 1024 * 1024 * 100,
            batteryLevel: 0.5
        )
        
        // Then
        XCTAssertEqual(appContext.currentScreen, "Settings")
        XCTAssertEqual(appContext.previousScreen, "Profile")
        XCTAssertEqual(appContext.sessionDuration, 600)
        XCTAssertEqual(appContext.memoryUsage, 1024 * 1024 * 100)
        XCTAssertEqual(appContext.batteryLevel, 0.5)
    }
    
    func testFeedbackModelWithoutOptionalFields() {
        // When
        let feedback = FeedbackModel(
            type: "suggestion",
            text: "Minimal feedback",
            deviceInfo: sampleDeviceInfo
        )
        
        // Then
        XCTAssertNil(feedback.screenshot)
        XCTAssertNil(feedback.userId)
        XCTAssertNil(feedback.userEmail)
        XCTAssertNil(feedback.appContext)
    }

    func testFeedbackModelPerformance() {
        measure {
            for i in 0..<10 {
                let feedback = FeedbackModel(
                    type: "performance_test",
                    text: "Performance test \(i)",
                    deviceInfo: sampleDeviceInfo
                )
                XCTAssertNotNil(feedback.id)
            }
        }
    }
}
