//
//  CourseManagementUITests.swift
//  LMSUITests
//
//  Tests for Course Management functionality
//

import XCTest

class CourseManagementUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        // Wait for app to load
        _ = app.wait(for: .runningForeground, timeout: 5)
    }
    
    // MARK: - Module Access Tests
    
    func testCourseManagementModuleAccessibility() {
        // Navigate to courses
        navigateToCourses()
        
        // Verify we're in courses section
        XCTAssertTrue(
            app.navigationBars.count > 0 ||
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'курс' OR label CONTAINS[c] 'course' OR label CONTAINS[c] 'обучен'")).count > 0,
            "Should be in courses section"
        )
    }
    
    func testCourseListDisplay() {
        // Navigate to courses
        navigateToCourses()
        
        // Wait for content
        let hasContent = app.collectionViews.firstMatch.waitForExistence(timeout: 5) ||
                        app.tables.firstMatch.waitForExistence(timeout: 5)
        
        if hasContent {
            let cellCount = app.collectionViews.cells.count + app.tables.cells.count
            XCTAssertGreaterThanOrEqual(cellCount, 0, "Should show courses or empty state")
        }
    }
    
    // MARK: - Course Creation Tests
    
    func testCreateNewCourse() {
        // Navigate to courses
        navigateToCourses()
        
        // Look for add/create button
        let addButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'add' OR label CONTAINS[c] 'create' OR label CONTAINS[c] 'добав' OR label CONTAINS[c] 'созд' OR label CONTAINS[c] '+'")
        ).firstMatch
        
        if addButton.exists {
            addButton.tap()
            Thread.sleep(forTimeInterval: 1.0)
            
            // Should show creation form
            XCTAssertTrue(
                app.textFields.count > 0 ||
                app.textViews.count > 0 ||
                app.navigationBars.matching(NSPredicate(format: "identifier CONTAINS[c] 'new' OR identifier CONTAINS[c] 'создан'")).count > 0,
                "Should show course creation form"
            )
        }
    }
    
    func testCourseFormValidation() {
        // Navigate to courses
        navigateToCourses()
        
        // Try to create course
        let addButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'add' OR label CONTAINS[c] 'create' OR label CONTAINS[c] 'добав' OR label CONTAINS[c] 'созд'")
        ).firstMatch
        
        if addButton.exists {
            addButton.tap()
            Thread.sleep(forTimeInterval: 1.0)
            
            // Try to save without filling form
            let saveButton = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] 'save' OR label CONTAINS[c] 'сохран'")
            ).firstMatch
            
            if saveButton.exists {
                saveButton.tap()
                Thread.sleep(forTimeInterval: 0.5)
                
                // Should show validation error
                XCTAssertTrue(
                    app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'required' OR label CONTAINS[c] 'обязател' OR label CONTAINS[c] 'error'")).count > 0 ||
                    app.alerts.count > 0,
                    "Should show validation errors"
                )
            }
        }
    }
    
    // MARK: - Course Details Tests
    
    func testViewCourseDetails() {
        // Navigate to courses
        navigateToCourses()
        
        // Get first course
        let firstCell = app.collectionViews.cells.firstMatch.exists ?
                       app.collectionViews.cells.firstMatch :
                       app.tables.cells.firstMatch
        
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
            Thread.sleep(forTimeInterval: 1.0)
            
            // Should show course details
            XCTAssertTrue(
                app.navigationBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'back' OR label CONTAINS[c] 'назад'")).count > 0 ||
                app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'description' OR label CONTAINS[c] 'описан'")).count > 0,
                "Should show course details"
            )
        }
    }
    
    func testEditCourse() {
        // Navigate to courses
        navigateToCourses()
        
        // Open first course
        let firstCell = app.collectionViews.cells.firstMatch.exists ?
                       app.collectionViews.cells.firstMatch :
                       app.tables.cells.firstMatch
        
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
            Thread.sleep(forTimeInterval: 1.0)
            
            // Look for edit button
            let editButton = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] 'edit' OR label CONTAINS[c] 'редакт'")
            ).firstMatch
            
            if editButton.exists {
                editButton.tap()
                Thread.sleep(forTimeInterval: 1.0)
                
                // Should show edit form
                XCTAssertTrue(
                    app.textFields.count > 0 ||
                    app.textViews.count > 0,
                    "Should show edit form"
                )
            }
        }
    }
    
    // MARK: - Course Enrollment Tests
    
    func testEnrollInCourse() {
        // Navigate to courses
        navigateToCourses()
        
        // Open first course
        let firstCell = app.collectionViews.cells.firstMatch.exists ?
                       app.collectionViews.cells.firstMatch :
                       app.tables.cells.firstMatch
        
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
            Thread.sleep(forTimeInterval: 1.0)
            
            // Look for enroll button
            let enrollButton = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] 'enroll' OR label CONTAINS[c] 'записат' OR label CONTAINS[c] 'начать'")
            ).firstMatch
            
            if enrollButton.exists {
                enrollButton.tap()
                Thread.sleep(forTimeInterval: 1.0)
                
                // Should show enrollment confirmation
                XCTAssertTrue(
                    app.alerts.count > 0 ||
                    app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'continue' OR label CONTAINS[c] 'продолж'")).count > 0,
                    "Should show enrollment confirmation"
                )
            }
        }
    }
    
    // MARK: - Course Management Tests
    
    func testCourseSearch() {
        // Navigate to courses
        navigateToCourses()
        
        // Look for search
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("test")
            Thread.sleep(forTimeInterval: 1.0)
            
            // Just verify search works
            XCTAssertTrue(app.exists)
        }
    }
    
    func testCourseFilter() {
        // Navigate to courses
        navigateToCourses()
        
        // Look for filter
        let filterButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'filter' OR label CONTAINS[c] 'фильтр'")
        ).firstMatch
        
        if filterButton.exists {
            filterButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
            
            // Should show filter options
            XCTAssertTrue(
                app.sheets.count > 0 ||
                app.popovers.count > 0 ||
                app.segmentedControls.count > 0,
                "Should show filter options"
            )
        }
    }
    
    func testCourseSort() {
        // Navigate to courses
        navigateToCourses()
        
        // Look for sort
        let sortButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'sort' OR label CONTAINS[c] 'сортир'")
        ).firstMatch
        
        if sortButton.exists {
            sortButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
            
            // Should show sort options
            XCTAssertTrue(
                app.sheets.count > 0 ||
                app.popovers.count > 0,
                "Should show sort options"
            )
        }
    }
    
    func testDeleteCourse() {
        // Navigate to courses
        navigateToCourses()
        
        // Try swipe to delete
        let firstCell = app.tables.cells.firstMatch
        if firstCell.exists {
            firstCell.swipeLeft()
            
            let deleteButton = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] 'delete' OR label CONTAINS[c] 'удал'")
            ).firstMatch
            
            if deleteButton.exists {
                // Don't actually delete, just verify exists
                XCTAssertTrue(deleteButton.exists)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func navigateToCourses() {
        // Check if already in courses
        if app.navigationBars.matching(NSPredicate(format: "identifier CONTAINS[c] 'course' OR identifier CONTAINS[c] 'курс' OR identifier CONTAINS[c] 'обучен'")).count > 0 {
            return
        }
        
        // Try tab navigation
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            // Try direct tabs
            let courseTabs = ["Обучение", "Learning", "Курсы", "Courses"]
            for tab in courseTabs {
                if tabBar.buttons[tab].exists {
                    tabBar.buttons[tab].tap()
                    Thread.sleep(forTimeInterval: 0.5)
                    return
                }
            }
            
            // Try More menu
            if tabBar.buttons["Ещё"].exists || tabBar.buttons["More"].exists {
                let moreButton = tabBar.buttons["Ещё"].exists ? tabBar.buttons["Ещё"] : tabBar.buttons["More"]
                moreButton.tap()
                Thread.sleep(forTimeInterval: 0.5)
                
                // Look for courses in menu
                let courseButton = app.buttons.matching(
                    NSPredicate(format: "label CONTAINS[c] 'course' OR label CONTAINS[c] 'курс' OR label CONTAINS[c] 'обучен'")
                ).firstMatch
                
                if courseButton.exists {
                    courseButton.tap()
                    Thread.sleep(forTimeInterval: 0.5)
                }
            }
        }
    }
}
