import XCTest

final class CourseEditUITests: UITestBase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        // Login as admin
        login(as: .admin)

        // Navigate to Courses
        app.tabBars.buttons["Курсы"].tap()
    }

    // MARK: - Course Edit Tests

    func testEditCourseDetails() throws {
        // Find and open first course
        let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]
        waitForElement(coursesList)

        let firstCourse = coursesList.cells.element(boundBy: 0)
        let originalTitle = firstCourse.staticTexts.firstMatch.label
        firstCourse.tap()

        // Tap edit button
        app.navigationBars.buttons["Редактировать"].tap()

        // Wait for edit form
        let titleField = app.textFields[AccessibilityIdentifiers.Courses.courseTitleField]
        waitForElement(titleField)

        // Clear and update title
        clearAndTypeText(titleField, text: "\(originalTitle) - Updated")

        // Update description
        let descriptionField = app.textViews[AccessibilityIdentifiers.Courses.courseDescriptionField]
        let currentDescription = descriptionField.value as? String ?? ""
        descriptionField.tap()

        // Select all and replace
        descriptionField.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        descriptionField.typeText("\(currentDescription)\n\nUpdated: This course has been modified through UI tests.")

        // Change difficulty if available
        if app.segmentedControls["Сложность"].exists {
            let difficultyControl = app.segmentedControls["Сложность"]
            let currentSelection = difficultyControl.buttons.allElementsBoundByIndex.first { $0.isSelected }

            // Select different difficulty
            if currentSelection?.label == "Начальный" {
                difficultyControl.buttons["Средний"].tap()
            } else {
                difficultyControl.buttons["Начальный"].tap()
            }
        }

        takeScreenshot(name: "Course_Edit_Form")

        // Save changes
        app.navigationBars.buttons["Сохранить"].tap()

        // Verify success
        checkAlert(title: "Успешно", message: "Изменения сохранены")

        // Verify changes in details view
        XCTAssertTrue(app.staticTexts["\(originalTitle) - Updated"].exists)

        takeScreenshot(name: "Course_Updated")
    }

    func testDeleteCourse() throws {
        // First create a course to delete
        let courseTitle = "Course to Delete \(Date().timeIntervalSince1970)"
        createTestCourse(title: courseTitle)

        // Find the created course
        let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]
        let searchField = app.searchFields[AccessibilityIdentifiers.Courses.searchField]

        searchField.tap()
        searchField.typeText(courseTitle)

        // Open course
        let courseCell = coursesList.cells.containing(.staticText, identifier: courseTitle).firstMatch
        waitForElement(courseCell)
        courseCell.tap()

        // Open menu
        app.navigationBars.buttons["more"].tap()

        // Tap delete
        app.sheets.buttons["Удалить курс"].tap()

        // Confirm deletion
        let deleteAlert = app.alerts["Удалить курс?"]
        waitForElement(deleteAlert)
        XCTAssertTrue(deleteAlert.staticTexts["Это действие нельзя отменить"].exists)

        takeScreenshot(name: "Delete_Course_Confirmation")

        deleteAlert.buttons["Удалить"].tap()

        // Verify success
        checkAlert(title: "Успешно", message: "Курс удален")

        // Verify course is removed from list
        waitForElement(coursesList)

        // Clear search and search again
        clearAndTypeText(searchField, text: courseTitle)

        // Should not find the course
        XCTAssertEqual(coursesList.cells.count, 0)

        takeScreenshot(name: "Course_Deleted")
    }

    func testArchiveCourse() throws {
        // Find active course
        let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]
        waitForElement(coursesList)

        // Filter active courses
        if app.buttons["Фильтр"].exists {
            app.buttons["Фильтр"].tap()
            app.switches["Активные"].tap()
            app.buttons["Применить"].tap()
        }

        let firstCourse = coursesList.cells.element(boundBy: 0)
        let courseTitle = firstCourse.staticTexts.firstMatch.label
        firstCourse.tap()

        // Open menu
        app.navigationBars.buttons["more"].tap()

        // Archive course
        app.sheets.buttons["Архивировать курс"].tap()

        // Confirm
        let archiveAlert = app.alerts["Архивировать курс?"]
        waitForElement(archiveAlert)
        archiveAlert.buttons["Архивировать"].tap()

        checkAlert(title: "Успешно", message: "Курс архивирован")

        // Go back to list
        app.navigationBars.buttons.firstMatch.tap()

        // Switch to archived courses
        if app.segmentedControls.buttons["Архив"].exists {
            app.segmentedControls.buttons["Архив"].tap()
        } else if app.buttons["Фильтр"].exists {
            app.buttons["Фильтр"].tap()
            app.switches["Архивные"].tap()
            app.switches["Активные"].tap() // Deselect active
            app.buttons["Применить"].tap()
        }

        // Find archived course
        let searchField = app.searchFields[AccessibilityIdentifiers.Courses.searchField]
        searchField.tap()
        searchField.typeText(courseTitle)

        // Should find in archive
        let archivedCourse = coursesList.cells.containing(.staticText, identifier: courseTitle).firstMatch
        waitForElement(archivedCourse)

        takeScreenshot(name: "Course_Archived")

        // Test restoring from archive
        archivedCourse.tap()
        app.navigationBars.buttons["more"].tap()
        app.sheets.buttons["Восстановить курс"].tap()

        checkAlert(title: "Успешно", message: "Курс восстановлен")
    }

    func testCourseVersioning() throws {
        // Open course
        let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]
        waitForElement(coursesList)

        let firstCourse = coursesList.cells.element(boundBy: 0)
        firstCourse.tap()

        // Check version info if available
        if app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Версия'")).firstMatch.exists {
            let versionLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Версия'")).firstMatch
            let currentVersion = versionLabel.label

            // Edit course
            app.navigationBars.buttons["Редактировать"].tap()

            // Make changes
            let descriptionField = app.textViews[AccessibilityIdentifiers.Courses.courseDescriptionField]
            descriptionField.tap()
            descriptionField.typeText("\n\nVersion update test")

            // Save
            app.navigationBars.buttons["Сохранить"].tap()
            checkAlert(title: "Успешно", message: "Изменения сохранены")

            // Check version updated
            let newVersionLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Версия'")).firstMatch
            XCTAssertNotEqual(currentVersion, newVersionLabel.label)

            // Check version history if available
            if app.buttons["История версий"].exists {
                app.buttons["История версий"].tap()

                // Should show at least 2 versions
                let versionsList = app.tables.firstMatch
                waitForElement(versionsList)
                XCTAssertGreaterThanOrEqual(versionsList.cells.count, 2)

                takeScreenshot(name: "Course_Version_History")

                // Go back
                app.navigationBars.buttons.firstMatch.tap()
            }
        }
    }

    // MARK: - Helper Methods

    private func createTestCourse(title: String) {
        let addButton = app.navigationBars.buttons[AccessibilityIdentifiers.Courses.addCourseButton]
        addButton.tap()

        let titleField = app.textFields[AccessibilityIdentifiers.Courses.courseTitleField]
        titleField.tap()
        titleField.typeText(title)

        let descriptionField = app.textViews[AccessibilityIdentifiers.Courses.courseDescriptionField]
        descriptionField.tap()
        descriptionField.typeText("Test course created for deletion testing purposes")

        app.navigationBars.buttons[AccessibilityIdentifiers.Courses.saveCourseButton].tap()

        // Dismiss alert
        if app.alerts.firstMatch.waitForExistence(timeout: 2) {
            app.alerts.buttons.firstMatch.tap()
        }

        // Wait for course list
        waitForElement(app.collectionViews[AccessibilityIdentifiers.Courses.coursesList])
    }
}
