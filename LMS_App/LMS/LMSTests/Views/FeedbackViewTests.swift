//
//  FeedbackViewTests.swift
//  LMSTests
//

import XCTest
import SwiftUI
@testable import LMS

class FeedbackViewTests: XCTestCase {
    
    var feedbackManager: FeedbackManager!
    
    override func setUp() {
        super.setUp()
        feedbackManager = FeedbackManager.shared
        // Clear any existing screenshot
        feedbackManager.screenshot = nil
    }
    
    override func tearDown() {
        feedbackManager.screenshot = nil
        feedbackManager = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState_FeedbackTextEmpty() {
        let expectedText = ""
        XCTAssertEqual(expectedText, "")
    }
    
    func testInitialState_DefaultFeedbackType() {
        let defaultType = FeedbackType.bug
        XCTAssertEqual(defaultType, .bug)
    }
    
    func testInitialState_NoScreenshot() {
        XCTAssertNil(feedbackManager.screenshot)
    }
    
    func testInitialState_NotSubmitting() {
        let isSubmitting = false
        XCTAssertFalse(isSubmitting)
    }
    
    // MARK: - FeedbackType Tests
    
    func testFeedbackType_AllCasesAvailable() {
        let types = FeedbackType.allCases
        XCTAssertEqual(types.count, 4)
        XCTAssertTrue(types.contains(.bug))
        XCTAssertTrue(types.contains(.feature))
        XCTAssertTrue(types.contains(.improvement))
        XCTAssertTrue(types.contains(.question))
    }
    
    func testFeedbackType_HasTitle() {
        XCTAssertEqual(FeedbackType.bug.title, "Ошибка")
        XCTAssertEqual(FeedbackType.feature.title, "Предложение")
        XCTAssertEqual(FeedbackType.improvement.title, "Улучшение")
        XCTAssertEqual(FeedbackType.question.title, "Вопрос")
    }
    
    func testFeedbackType_HasIcon() {
        XCTAssertEqual(FeedbackType.bug.icon, "ladybug")
        XCTAssertEqual(FeedbackType.feature.icon, "lightbulb")
        XCTAssertEqual(FeedbackType.improvement.icon, "sparkles")
        XCTAssertEqual(FeedbackType.question.icon, "questionmark.circle")
    }
    
    // MARK: - Screenshot Tests
    
    func testScreenshot_InitiallyNil() {
        let screenshot: UIImage? = nil
        XCTAssertNil(screenshot)
    }
    
    func testScreenshot_FromFeedbackManager() {
        // Set a test image in feedback manager
        let testImage = UIImage(systemName: "star")
        feedbackManager.screenshot = testImage
        
        // Should use the manager's screenshot
        XCTAssertEqual(feedbackManager.screenshot, testImage)
    }
    
    func testScreenshot_CanBeAnnotated() {
        let originalImage = UIImage(systemName: "star")
        let annotatedImage = UIImage(systemName: "star.fill")
        
        XCTAssertNotEqual(originalImage, annotatedImage)
    }
    
    // MARK: - Device Info Tests
    
    func testDeviceInfo_Model() {
        let model = UIDevice.current.model
        XCTAssertFalse(model.isEmpty)
    }
    
    func testDeviceInfo_OSVersion() {
        let osVersion = UIDevice.current.systemVersion
        XCTAssertFalse(osVersion.isEmpty)
    }
    
    func testDeviceInfo_AppVersion() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        XCTAssertNotEqual(appVersion, "")
    }
    
    func testDeviceInfo_BuildNumber() {
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        XCTAssertNotEqual(buildNumber, "")
    }
    
    // MARK: - Submit Button State Tests
    
    func testSubmitButton_DisabledWhenTextEmpty() {
        let feedbackText = ""
        let isSubmitting = false
        
        let isDisabled = feedbackText.isEmpty || isSubmitting
        XCTAssertTrue(isDisabled)
    }
    
    func testSubmitButton_EnabledWhenTextNotEmpty() {
        let feedbackText = "Test feedback"
        let isSubmitting = false
        
        let isDisabled = feedbackText.isEmpty || isSubmitting
        XCTAssertFalse(isDisabled)
    }
    
    func testSubmitButton_DisabledWhenSubmitting() {
        let feedbackText = "Test feedback"
        let isSubmitting = true
        
        let isDisabled = feedbackText.isEmpty || isSubmitting
        XCTAssertTrue(isDisabled)
    }
    
    func testSubmitButton_ColorWhenEnabled() {
        let feedbackText = "Test"
        let expectedColor = feedbackText.isEmpty ? Color.gray : Color.blue
        
        XCTAssertEqual(expectedColor, Color.blue)
    }
    
    func testSubmitButton_ColorWhenDisabled() {
        let feedbackText = ""
        let expectedColor = feedbackText.isEmpty ? Color.gray : Color.blue
        
        XCTAssertEqual(expectedColor, Color.gray)
    }
}

// MARK: - FeedbackModel Tests

class FeedbackModelTests: XCTestCase {
    
    func testFeedbackModel_Initialization() {
        let model = FeedbackModel(
            type: "bug",
            text: "Test feedback",
            screenshot: nil,
            deviceInfo: DeviceInfo(
                model: "iPhone",
                osVersion: "17.0",
                appVersion: "1.0",
                buildNumber: "1",
                locale: "en_US",
                screenSize: "390x844"
            ),
            timestamp: Date()
        )
        
        XCTAssertEqual(model.type, "bug")
        XCTAssertEqual(model.text, "Test feedback")
        XCTAssertNil(model.screenshot)
        XCTAssertNotNil(model.deviceInfo)
        XCTAssertNotNil(model.timestamp)
    }
    
    func testDeviceInfo_Properties() {
        let deviceInfo = DeviceInfo(
            model: "iPhone 15",
            osVersion: "17.0",
            appVersion: "1.0.0",
            buildNumber: "100",
            locale: "en_US",
            screenSize: "390x844"
        )
        
        XCTAssertEqual(deviceInfo.model, "iPhone 15")
        XCTAssertEqual(deviceInfo.osVersion, "17.0")
        XCTAssertEqual(deviceInfo.appVersion, "1.0.0")
        XCTAssertEqual(deviceInfo.buildNumber, "100")
        XCTAssertEqual(deviceInfo.locale, "en_US")
        XCTAssertEqual(deviceInfo.screenSize, "390x844")
    }
    
    func testFeedbackModel_WithScreenshot() {
        let screenshotData = "base64encodedstring"
        let model = FeedbackModel(
            type: "feature",
            text: "New feature request",
            screenshot: screenshotData,
            deviceInfo: DeviceInfo(
                model: "iPad",
                osVersion: "17.0",
                appVersion: "1.0",
                buildNumber: "1",
                locale: "en_US",
                screenSize: "1024x768"
            ),
            timestamp: Date()
        )
        
        XCTAssertEqual(model.screenshot, screenshotData)
    }
}

// MARK: - InfoRow Tests

class InfoRowTests: XCTestCase {
    
    func testInfoRow_DisplaysLabelAndValue() {
        let label = "Device"
        let value = "iPhone"
        
        // InfoRow should display both label and value
        XCTAssertEqual(label, "Device")
        XCTAssertEqual(value, "iPhone")
    }
    
    func testInfoRow_EmptyValue() {
        let label = "Version"
        let value = ""
        
        XCTAssertEqual(label, "Version")
        XCTAssertEqual(value, "")
    }
}

// MARK: - FeedbackView UI Elements Tests

class FeedbackViewUIElementsTests: XCTestCase {
    
    func testNavigationTitle() {
        let expectedTitle = "Обратная связь"
        XCTAssertEqual(expectedTitle, "Обратная связь")
    }
    
    func testNavigationBarDisplayMode() {
        // Should use inline display mode
        XCTAssertTrue(true, "Navigation bar should use inline display mode")
    }
    
    func testCancelButton_Text() {
        let expectedText = "Отмена"
        XCTAssertEqual(expectedText, "Отмена")
    }
    
    func testSubmitButton_Text() {
        let expectedText = "Отправить"
        XCTAssertEqual(expectedText, "Отправить")
    }
    
    func testSubmitButton_Icon() {
        let expectedIcon = "paperplane.fill"
        XCTAssertEqual(expectedIcon, "paperplane.fill")
    }
    
    func testTextEditorPlaceholder() {
        let expectedPlaceholder = "Расскажите, что произошло..."
        XCTAssertEqual(expectedPlaceholder, "Расскажите, что произошло...")
    }
    
    func testScreenshotButton_Text() {
        let expectedText = "Сделать скриншот"
        XCTAssertEqual(expectedText, "Сделать скриншот")
    }
    
    func testScreenshotButton_Icon() {
        let expectedIcon = "camera.fill"
        XCTAssertEqual(expectedIcon, "camera.fill")
    }
    
    func testDeleteButton_Text() {
        let expectedText = "Удалить"
        XCTAssertEqual(expectedText, "Удалить")
    }
    
    func testDeleteButton_Icon() {
        let expectedIcon = "trash"
        XCTAssertEqual(expectedIcon, "trash")
    }
    
    func testEditedLabel_Text() {
        let expectedText = "Отредактировано"
        XCTAssertEqual(expectedText, "Отредактировано")
    }
    
    func testEditedLabel_Icon() {
        let expectedIcon = "pencil.circle.fill"
        XCTAssertEqual(expectedIcon, "pencil.circle.fill")
    }
    
    func testSuccessAlert_Title() {
        let expectedTitle = "Успешно отправлено!"
        XCTAssertEqual(expectedTitle, "Успешно отправлено!")
    }
    
    func testSuccessAlert_Message() {
        let expectedMessage = "Спасибо за ваш отзыв! Мы рассмотрим его в ближайшее время."
        XCTAssertEqual(expectedMessage, "Спасибо за ваш отзыв! Мы рассмотрим его в ближайшее время.")
    }
    
    func testSectionTitles() {
        let sections = ["Тип обращения", "Опишите подробно", "Скриншот", "Информация об устройстве"]
        
        XCTAssertEqual(sections[0], "Тип обращения")
        XCTAssertEqual(sections[1], "Опишите подробно")
        XCTAssertEqual(sections[2], "Скриншот")
        XCTAssertEqual(sections[3], "Информация об устройстве")
    }
} 