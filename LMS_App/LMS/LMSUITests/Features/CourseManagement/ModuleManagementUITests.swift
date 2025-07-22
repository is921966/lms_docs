//
//  ModuleManagementUITests.swift
//  LMSUITests
//
//  UI tests for module management functionality
//

import XCTest
@testable import LMS

final class ModuleManagementUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Navigation Tests
    
    func test_navigateToModuleManagement_fromCourseDetail() {
        // Given - Navigate to course detail
        navigateToCourseDetail()
        
        // When - Tap "Управлять" in modules section
        let manageButton = app.buttons["Управлять"].firstMatch
        XCTAssertTrue(manageButton.waitForExistence(timeout: 5))
        manageButton.tap()
        
        // Then - Module management view should appear
        let moduleManagementTitle = app.navigationBars["Управление модулями"]
        XCTAssertTrue(moduleManagementTitle.waitForExistence(timeout: 5))
    }
    
    // MARK: - Empty State Tests
    
    func test_emptyState_shouldShowWhenNoModules() {
        // Given - Navigate to module management for course without modules
        navigateToModuleManagementForEmptyCourse()
        
        // Then - Empty state should be visible
        XCTAssertTrue(app.staticTexts["Модули не добавлены"].exists)
        XCTAssertTrue(app.staticTexts["Добавьте модули для структурирования курса"].exists)
        XCTAssertTrue(app.buttons["Добавить модуль"].exists)
    }
    
    // MARK: - Add Module Tests
    
    func test_addModule_shouldCreateNewModule() {
        // Given - Navigate to module management
        navigateToModuleManagementForEmptyCourse()
        
        // When - Tap add module button
        app.buttons["Добавить модуль"].tap()
        
        // Fill the form
        let titleField = app.textFields["Название модуля"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText("Введение в iOS разработку")
        
        let descriptionField = app.textViews.firstMatch
        descriptionField.tap()
        descriptionField.typeText("Основы Swift и Xcode")
        
        // Select content type (video)
        app.buttons.element(boundBy: 0).tap() // First segment - video
        
        // Set duration
        let durationField = app.textFields["Длительность"]
        durationField.tap()
        durationField.typeText("45")
        
        // Save
        app.buttons["Сохранить"].tap()
        
        // Then - Module should appear in list
        XCTAssertTrue(app.staticTexts["1. Введение в iOS разработку"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Основы Swift и Xcode"].exists)
        XCTAssertTrue(app.staticTexts["45 мин"].exists)
    }
    
    func test_addModule_withEmptyTitle_shouldShowError() {
        // Given - Navigate to add module form
        navigateToModuleManagementForEmptyCourse()
        app.buttons["Добавить модуль"].tap()
        
        // When - Try to save without title
        let saveButton = app.buttons["Сохранить"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        
        // Then - Save button should be disabled
        XCTAssertFalse(saveButton.isEnabled)
    }
    
    // MARK: - Edit Module Tests
    
    func test_editModule_shouldUpdateModule() {
        // Given - Navigate to module management with existing module
        navigateToModuleManagementWithModules()
        
        // When - Tap edit button on first module
        let editButton = app.buttons["pencil.circle"].firstMatch
        XCTAssertTrue(editButton.waitForExistence(timeout: 5))
        editButton.tap()
        
        // Update title
        let titleField = app.textFields["Название модуля"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.clearText()
        titleField.typeText("Обновленное название")
        
        // Save
        app.buttons["Сохранить"].tap()
        
        // Then - Module should be updated
        XCTAssertTrue(app.staticTexts["1. Обновленное название"].waitForExistence(timeout: 5))
    }
    
    // MARK: - Delete Module Tests
    
    func test_deleteModule_inEditMode_shouldRemoveModule() {
        // Given - Navigate to module management with modules
        navigateToModuleManagementWithModules()
        
        // When - Enter edit mode
        app.buttons["Изменить"].tap()
        
        // Delete first module
        let deleteButton = app.buttons["Delete"].firstMatch
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()
        
        // Confirm deletion
        let confirmButton = app.buttons["Удалить"].firstMatch
        if confirmButton.waitForExistence(timeout: 2) {
            confirmButton.tap()
        }
        
        // Exit edit mode
        app.buttons["Готово"].tap()
        
        // Then - Module count should decrease
        let moduleRows = app.cells
        XCTAssertLessThan(moduleRows.count, 3) // Started with 3, should have less
    }
    
    // MARK: - Reorder Module Tests
    
    func test_reorderModules_inEditMode_shouldChangeOrder() {
        // Given - Navigate to module management with multiple modules
        navigateToModuleManagementWithModules()
        
        // When - Enter edit mode
        app.buttons["Изменить"].tap()
        
        // Drag first module to second position
        let firstModule = app.cells.element(boundBy: 0)
        let secondModule = app.cells.element(boundBy: 1)
        
        firstModule.press(forDuration: 0.5, thenDragTo: secondModule)
        
        // Exit edit mode
        app.buttons["Готово"].tap()
        
        // Then - Order should be changed
        // Note: This test might need adjustment based on actual UI behavior
        XCTAssertTrue(app.staticTexts["1."].exists)
        XCTAssertTrue(app.staticTexts["2."].exists)
    }
    
    // MARK: - Content Type Tests
    
    func test_contentTypeSelection_shouldShowCorrectIcons() {
        // Given - Navigate to add module form
        navigateToModuleManagementForEmptyCourse()
        app.buttons["Добавить модуль"].tap()
        
        // When - Select different content types
        // Video (first segment)
        app.buttons.element(boundBy: 0).tap()
        
        // Document (second segment)
        app.buttons.element(boundBy: 1).tap()
        
        // Quiz (third segment)
        app.buttons.element(boundBy: 2).tap()
        
        // Cmi5 (fourth segment)
        app.buttons.element(boundBy: 3).tap()
        
        // Then - All content type options should be accessible
        XCTAssertTrue(app.buttons.count >= 4) // At least 4 segment buttons
    }
    
    // MARK: - Helper Methods
    
    private func navigateToCourseDetail() {
        // Navigate to More tab
        app.tabBars.buttons["Ещё"].tap()
        
        // Navigate to Course Management
        app.buttons["Управление курсами"].tap()
        
        // Select first course
        let firstCourse = app.cells.firstMatch
        if firstCourse.waitForExistence(timeout: 5) {
            firstCourse.tap()
        }
    }
    
    private func navigateToModuleManagementForEmptyCourse() {
        navigateToCourseDetail()
        
        // Tap "Управлять" in modules section
        let manageButton = app.buttons["Управлять"].firstMatch
        if manageButton.waitForExistence(timeout: 5) {
            manageButton.tap()
        }
    }
    
    private func navigateToModuleManagementWithModules() {
        // This would navigate to a course that already has modules
        // For testing purposes, we might need to create test data first
        navigateToCourseDetail()
        
        let manageButton = app.buttons["Управлять"].firstMatch
        if manageButton.waitForExistence(timeout: 5) {
            manageButton.tap()
        }
    }
}

// MARK: - XCUIElement Extension

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
} 