import XCTest

final class CourseCreateUITests: UITestBase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        // Login as admin for course management
        login(as: .admin)

        // Navigate to Courses
        app.tabBars.buttons["Курсы"].tap()
    }

    // MARK: - Course Creation Tests

    func testCreateCourseWithAllFields() throws {
        // Tap add course button
        let addButton = app.navigationBars.buttons[AccessibilityIdentifiers.Courses.addCourseButton]
        waitForElement(addButton)
        addButton.tap()

        // Fill course form
        let titleField = app.textFields[AccessibilityIdentifiers.Courses.courseTitleField]
        let descriptionField = app.textViews[AccessibilityIdentifiers.Courses.courseDescriptionField]

        waitForElement(titleField)

        // Enter title
        let courseTitle = "Test Course \(Date().timeIntervalSince1970)"
        titleField.tap()
        titleField.typeText(courseTitle)

        // Enter description
        descriptionField.tap()
        descriptionField.typeText("This is a comprehensive test course created through UI tests. It covers various topics and includes practical exercises.")

        // Select category
        if app.buttons["Выбрать категорию"].exists {
            app.buttons["Выбрать категорию"].tap()
            let categoryPicker = app.pickers.firstMatch
            waitForElement(categoryPicker)
            categoryPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "Технические навыки")
            app.buttons["Готово"].tap()
        }

        // Set duration
        if app.textFields["Длительность"].exists {
            let durationField = app.textFields["Длительность"]
            durationField.tap()
            durationField.typeText("40")
        }

        // Set difficulty
        if app.segmentedControls["Сложность"].exists {
            app.segmentedControls["Сложность"].buttons["Средний"].tap()
        }

        // Add course image
        if app.buttons["Добавить изображение"].exists {
            app.buttons["Добавить изображение"].tap()

            // In simulator, select from photo library
            if app.sheets.firstMatch.waitForExistence(timeout: 2) {
                app.sheets.buttons["Выбрать из галереи"].tap()

                // Select first image
                if app.scrollViews.otherElements.images.firstMatch.waitForExistence(timeout: 3) {
                    app.scrollViews.otherElements.images.firstMatch.tap()
                    app.buttons["Choose"].tap()
                }
            }
        }

        takeScreenshot(name: "Course_Form_Filled")

        // Save course
        let saveButton = app.navigationBars.buttons[AccessibilityIdentifiers.Courses.saveCourseButton]
        saveButton.tap()

        // Verify success
        checkAlert(title: "Успешно", message: "Курс создан")

        // Verify course appears in list
        let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]
        waitForElement(coursesList)

        // Search for created course
        let searchField = app.searchFields[AccessibilityIdentifiers.Courses.searchField]
        searchField.tap()
        searchField.typeText(courseTitle)

        // Verify course exists
        let createdCourse = coursesList.cells.containing(.staticText, identifier: courseTitle).firstMatch
        waitForElement(createdCourse)

        takeScreenshot(name: "Course_Created_In_List")
    }

    func testCreateCourseValidation() throws {
        // Tap add course button
        let addButton = app.navigationBars.buttons[AccessibilityIdentifiers.Courses.addCourseButton]
        addButton.tap()

        // Try to save without filling required fields
        let saveButton = app.navigationBars.buttons[AccessibilityIdentifiers.Courses.saveCourseButton]
        saveButton.tap()

        // Should show validation error
        checkAlert(title: "Ошибка", message: "Заполните обязательные поля")

        // Fill only title
        let titleField = app.textFields[AccessibilityIdentifiers.Courses.courseTitleField]
        titleField.tap()
        titleField.typeText("Course without description")

        // Try to save again
        saveButton.tap()

        // Should show error for missing description
        checkAlert(title: "Ошибка", message: "Введите описание курса")

        // Add very short description
        let descriptionField = app.textViews[AccessibilityIdentifiers.Courses.courseDescriptionField]
        descriptionField.tap()
        descriptionField.typeText("Short")

        saveButton.tap()

        // Should show error for too short description
        checkAlert(title: "Ошибка", message: "Описание должно содержать минимум 20 символов")
    }

    func testAddCourseImage() throws {
        // Create course first
        let addButton = app.navigationBars.buttons[AccessibilityIdentifiers.Courses.addCourseButton]
        addButton.tap()

        // Fill basic info
        let titleField = app.textFields[AccessibilityIdentifiers.Courses.courseTitleField]
        titleField.tap()
        titleField.typeText("Course with Image")

        let descriptionField = app.textViews[AccessibilityIdentifiers.Courses.courseDescriptionField]
        descriptionField.tap()
        descriptionField.typeText("This course will have a custom image for better visual appeal")

        // Add image
        app.buttons["Добавить изображение"].tap()

        // Test camera option (will fail in simulator)
        if app.sheets.buttons["Сделать фото"].exists {
            app.sheets.buttons["Сделать фото"].tap()

            // Should show error in simulator
            if app.alerts.firstMatch.waitForExistence(timeout: 2) {
                XCTAssertTrue(app.alerts.staticTexts["Камера недоступна"].exists ||
                            app.alerts.staticTexts["Camera not available"].exists)
                app.alerts.buttons.firstMatch.tap()
            }
        }

        // Try gallery option
        app.buttons["Добавить изображение"].tap()
        app.sheets.buttons["Выбрать из галереи"].tap()

        // In real device, would select image
        // In simulator, might show empty gallery
        if app.navigationBars["Photos"].waitForExistence(timeout: 3) {
            // Cancel if no photos
            app.navigationBars.buttons["Cancel"].tap()
        }

        takeScreenshot(name: "Course_Image_Options")
    }

    func testCancelCourseCreation() throws {
        // Start creating course
        let addButton = app.navigationBars.buttons[AccessibilityIdentifiers.Courses.addCourseButton]
        addButton.tap()

        // Fill some fields
        let titleField = app.textFields[AccessibilityIdentifiers.Courses.courseTitleField]
        titleField.tap()
        titleField.typeText("Course to be cancelled")

        // Cancel
        let cancelButton = app.navigationBars.buttons[AccessibilityIdentifiers.Courses.cancelButton]
        cancelButton.tap()

        // Should show confirmation
        let alert = app.alerts["Отменить создание?"]
        waitForElement(alert)
        XCTAssertTrue(alert.staticTexts["Все введенные данные будут потеряны"].exists)

        // Confirm cancellation
        alert.buttons["Отменить создание"].tap()

        // Should be back at courses list
        let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]
        waitForElement(coursesList)

        // Verify course was not created
        let searchField = app.searchFields[AccessibilityIdentifiers.Courses.searchField]
        searchField.tap()
        searchField.typeText("Course to be cancelled")

        // Should not find the course
        XCTAssertEqual(coursesList.cells.count, 0)
    }

    func testDuplicateCourseCheck() throws {
        // First create a course
        let courseTitle = "Unique Course \(Int.random(in: 1_000...9_999))"
        createQuickCourse(title: courseTitle)

        // Try to create another course with same title
        let addButton = app.navigationBars.buttons[AccessibilityIdentifiers.Courses.addCourseButton]
        addButton.tap()

        let titleField = app.textFields[AccessibilityIdentifiers.Courses.courseTitleField]
        titleField.tap()
        titleField.typeText(courseTitle)

        let descriptionField = app.textViews[AccessibilityIdentifiers.Courses.courseDescriptionField]
        descriptionField.tap()
        descriptionField.typeText("This is a duplicate course that should not be allowed")

        // Try to save
        let saveButton = app.navigationBars.buttons[AccessibilityIdentifiers.Courses.saveCourseButton]
        saveButton.tap()

        // Should show duplicate error
        checkAlert(title: "Ошибка", message: "Курс с таким названием уже существует")

        takeScreenshot(name: "Duplicate_Course_Error")
    }

    // MARK: - Helper Methods

    private func createQuickCourse(title: String) {
        let addButton = app.navigationBars.buttons[AccessibilityIdentifiers.Courses.addCourseButton]
        addButton.tap()

        let titleField = app.textFields[AccessibilityIdentifiers.Courses.courseTitleField]
        titleField.tap()
        titleField.typeText(title)

        let descriptionField = app.textViews[AccessibilityIdentifiers.Courses.courseDescriptionField]
        descriptionField.tap()
        descriptionField.typeText("Quick course for testing purposes with sufficient description")

        let saveButton = app.navigationBars.buttons[AccessibilityIdentifiers.Courses.saveCourseButton]
        saveButton.tap()

        // Dismiss success alert
        if app.alerts.firstMatch.waitForExistence(timeout: 2) {
            app.alerts.buttons.firstMatch.tap()
        }
    }
}
