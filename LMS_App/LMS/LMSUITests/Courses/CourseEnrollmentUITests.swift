import XCTest

final class CourseEnrollmentUITests: UITestBase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        // Login as student for enrollment tests
        login(as: .student)
    }

    // MARK: - Course Enrollment Tests

    func testEnrollInCourse() throws {
        // Navigate to Courses
        app.tabBars.buttons["Курсы"].tap()

        // Find first available course
        let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]
        waitForElement(coursesList)

        let firstCourse = coursesList.cells.element(boundBy: 0)
        XCTAssertTrue(firstCourse.exists, "No courses available")

        // Remember course name
        let courseName = firstCourse.staticTexts.firstMatch.label

        // Open course details
        firstCourse.tap()

        // Check enroll button exists
        let enrollButton = app.buttons[AccessibilityIdentifiers.Courses.enrollButton]
        waitForElement(enrollButton)

        // Take screenshot before enrollment
        takeScreenshot(name: "Course_Details_Before_Enrollment")

        // Enroll
        enrollButton.tap()

        // Check success message
        checkAlert(title: "Успешно", message: "Вы записаны на курс")

        // Verify button changed to "Начать обучение"
        let startButton = app.buttons["Начать обучение"]
        waitForElement(startButton)

        takeScreenshot(name: "Course_Details_After_Enrollment")

        // Navigate to My Courses
        app.navigationBars.buttons.firstMatch.tap() // Back
        app.segmentedControls.buttons["Мои курсы"].tap()

        // Verify course appears in My Courses
        let myCourse = coursesList.cells.containing(.staticText, identifier: courseName).firstMatch
        waitForElement(myCourse)

        takeScreenshot(name: "My_Courses_After_Enrollment")
    }

    func testUnenrollFromCourse() throws {
        // First enroll in a course
        try testEnrollInCourse()

        // Go to My Courses
        app.tabBars.buttons["Курсы"].tap()
        app.segmentedControls.buttons["Мои курсы"].tap()

        // Open first enrolled course
        let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]
        let enrolledCourse = coursesList.cells.element(boundBy: 0)

        let courseName = enrolledCourse.staticTexts.firstMatch.label
        enrolledCourse.tap()

        // Find unenroll button (usually in menu)
        app.navigationBars.buttons["more"].tap()
        app.sheets.buttons["Отписаться от курса"].tap()

        // Confirm unenrollment
        app.alerts.buttons["Отписаться"].tap()

        // Check success message
        checkAlert(title: "Успешно", message: "Вы отписались от курса")

        // Verify enroll button is back
        let enrollButton = app.buttons[AccessibilityIdentifiers.Courses.enrollButton]
        waitForElement(enrollButton)

        // Go back and verify course is not in My Courses
        app.navigationBars.buttons.firstMatch.tap()

        // Course should not be in My Courses anymore
        let myCourse = coursesList.cells.staticTexts[courseName].firstMatch
        XCTAssertFalse(myCourse.exists)
    }

    func testCourseProgressTracking() throws {
        // Enroll in course
        try testEnrollInCourse()

        // Go to My Courses
        app.tabBars.buttons["Курсы"].tap()
        app.segmentedControls.buttons["Мои курсы"].tap()

        // Open enrolled course
        let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]
        let enrolledCourse = coursesList.cells.element(boundBy: 0)
        enrolledCourse.tap()

        // Start learning
        app.buttons["Начать обучение"].tap()

        // Verify lesson view loaded
        let lessonView = app.otherElements["lessonView"]
        waitForElement(lessonView)

        // Complete first lesson
        if app.buttons["Далее"].exists {
            app.buttons["Далее"].tap()
        }

        // Mark lesson as complete
        if app.buttons["Завершить урок"].exists {
            app.buttons["Завершить урок"].tap()
        }

        // Go back to course details
        app.navigationBars.buttons.firstMatch.tap()

        // Check progress is updated
        let progressLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '1'")).firstMatch
        XCTAssertTrue(progressLabel.exists, "Progress should show at least 1 completed lesson")

        takeScreenshot(name: "Course_Progress_Updated")
    }

    func testCompleteCourse() throws {
        // This is a simplified test - in real scenario would complete all lessons

        // Enroll in a short course
        app.tabBars.buttons["Курсы"].tap()

        // Search for a demo course
        let searchField = app.searchFields[AccessibilityIdentifiers.Courses.searchField]
        searchField.tap()
        searchField.typeText("Demo")

        // Select demo course
        let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]
        let demoCourse = coursesList.cells.element(boundBy: 0)

        if demoCourse.exists {
            demoCourse.tap()

            // Enroll
            let enrollButton = app.buttons[AccessibilityIdentifiers.Courses.enrollButton]
            if enrollButton.exists {
                enrollButton.tap()
                checkAlert(title: "Успешно", message: "Вы записаны на курс")
            }

            // Start course
            app.buttons["Начать обучение"].tap()

            // Complete all lessons (simplified)
            for _ in 0..<3 {
                if app.buttons["Далее"].exists {
                    app.buttons["Далее"].tap()
                } else if app.buttons["Завершить урок"].exists {
                    app.buttons["Завершить урок"].tap()
                }
            }

            // Check completion certificate or message
            if app.staticTexts["Поздравляем!"].waitForExistence(timeout: 5) {
                takeScreenshot(name: "Course_Completion_Certificate")
                XCTAssertTrue(app.buttons["Получить сертификат"].exists)
            }
        }
    }

    // MARK: - Error Handling Tests

    func testEnrollmentWhenCourseIsFull() throws {
        // Search for a course that might be full
        app.tabBars.buttons["Курсы"].tap()

        let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]

        // Look for a course with "Мест нет" label
        let fullCourse = coursesList.cells.containing(.staticText, identifier: "Мест нет").firstMatch

        if fullCourse.exists {
            fullCourse.tap()

            // Try to enroll
            let enrollButton = app.buttons[AccessibilityIdentifiers.Courses.enrollButton]
            if enrollButton.exists && enrollButton.isEnabled {
                enrollButton.tap()

                // Should show error
                checkAlert(title: "Ошибка", message: "На курсе нет свободных мест")
            } else {
                // Button should be disabled
                XCTAssertFalse(enrollButton.isEnabled, "Enroll button should be disabled for full course")
            }
        }
    }

    func testEnrollmentWithPrerequisites() throws {
        // Search for advanced course
        app.tabBars.buttons["Курсы"].tap()

        let searchField = app.searchFields[AccessibilityIdentifiers.Courses.searchField]
        searchField.tap()
        searchField.typeText("Advanced")

        let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]
        let advancedCourse = coursesList.cells.element(boundBy: 0)

        if advancedCourse.exists {
            advancedCourse.tap()

            // Check if prerequisites are shown
            if app.staticTexts["Требования"].exists {
                takeScreenshot(name: "Course_Prerequisites")

                // Try to enroll without meeting prerequisites
                let enrollButton = app.buttons[AccessibilityIdentifiers.Courses.enrollButton]
                if enrollButton.exists && enrollButton.isEnabled {
                    enrollButton.tap()

                    // Should show prerequisite warning
                    let alert = app.alerts.firstMatch
                    if alert.waitForExistence(timeout: 2) {
                        XCTAssertTrue(alert.label.contains("требования") || alert.label.contains("Prerequisites"))
                        alert.buttons.firstMatch.tap()
                    }
                }
            }
        }
    }
}
