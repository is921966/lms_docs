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

    override func setUpWithError() throws {
        super.setUp()

        // Create sample device info
        sampleDeviceInfo = DeviceInfo(
            model: "iPhone 16 Pro",
            osVersion: "18.5",
            appVersion: "1.0.0",
            buildNumber: "100",
            screenSize: "414x896",
            locale: "en_US"
        )
    }

    // MARK: - FeedbackModel Tests

    func testFeedbackModelInitialization() {
        // Given
        let feedbackText = "Test feedback message"
        let feedbackType = "bug"
        let userId = "user123"
        let userEmail = "test@example.com"

        // When
        let feedback = FeedbackModel(
            type: feedbackType,
            text: feedbackText,
            deviceInfo: sampleDeviceInfo,
            userId: userId,
            userEmail: userEmail
        )

        // Then
        XCTAssertNotNil(feedback.id)
        XCTAssertEqual(feedback.type, feedbackType)
        XCTAssertEqual(feedback.text, feedbackText)
        XCTAssertEqual(feedback.deviceInfo.model, sampleDeviceInfo.model)
        XCTAssertEqual(feedback.userId, userId)
        XCTAssertEqual(feedback.userEmail, userEmail)
        XCTAssertNotNil(feedback.timestamp)
    }

    func testFeedbackModelCodable() throws {
        // Given
        let feedback = FeedbackModel(
            type: "bug",
            text: "Test encoding/decoding",
            deviceInfo: sampleDeviceInfo,
            userId: "test-user",
            userEmail: "test@test.com"
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
        XCTAssertEqual(decodedFeedback.userId, feedback.userId)
        XCTAssertEqual(decodedFeedback.userEmail, feedback.userEmail)
    }

    func testDeviceInfoInitialization() {
        // When
        let deviceInfo = DeviceInfo(
            model: "iPhone 16 Pro",
            osVersion: "18.5",
            appVersion: "1.0.0",
            buildNumber: "100"
        )

        // Then
        XCTAssertEqual(deviceInfo.model, "iPhone 16 Pro")
        XCTAssertEqual(deviceInfo.osVersion, "18.5")
        XCTAssertEqual(deviceInfo.appVersion, "1.0.0")
        XCTAssertEqual(deviceInfo.buildNumber, "100")
        XCTAssertNotNil(deviceInfo.screenSize)
        XCTAssertNotNil(deviceInfo.locale)
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
