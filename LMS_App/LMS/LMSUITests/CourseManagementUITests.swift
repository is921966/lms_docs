import XCTest

final class CourseManagementUITests: UITestBase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Login as admin
        loginAsAdmin()
        
        // Navigate to Course Management
        navigateToCourseManagement()
    }
    
    // MARK: - Helper Methods
    
    private func loginAsAdmin() {
        // Wait for login screen
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        
        // Enter admin credentials
        emailField.tap()
        emailField.typeText("admin@test.com")
        
        let passwordField = app.secureTextFields["Пароль"]
        passwordField.tap()
        passwordField.typeText("password")
        
        // Login
        app.buttons["Войти"].tap()
        
        // Wait for main screen
        XCTAssertTrue(app.navigationBars["Главная"].waitForExistence(timeout: 5))
    }
    
    private func navigateToCourseManagement() {
        // Navigate to More tab
        app.tabBars.buttons["Ещё"].tap()
        
        // Find and tap "Управление курсами"
        let courseManagementCell = app.buttons.containing(.staticText, identifier: "Управление курсами").firstMatch
        XCTAssertTrue(courseManagementCell.waitForExistence(timeout: 5))
        courseManagementCell.tap()
        
        // Wait for course list
        XCTAssertTrue(app.navigationBars["Курсы"].waitForExistence(timeout: 5))
    }
    
    // MARK: - Test Cases
    
    func testCourseListDisplay() throws {
        // Verify course list is displayed
        XCTAssertTrue(app.scrollViews.firstMatch.exists)
        
        // Check for search field
        let searchField = app.textFields["Поиск курсов"]
        XCTAssertTrue(searchField.exists)
        
        // Check for add button
        let addButton = app.buttons["plus.circle.fill"]
        XCTAssertTrue(addButton.exists)
        
        // Verify at least one course card exists
        let firstCourseCard = app.scrollViews.descendants(matching: .button).firstMatch
        XCTAssertTrue(firstCourseCard.waitForExistence(timeout: 5))
    }
    
    func testCourseSearch() throws {
        let searchField = app.textFields["Поиск курсов"]
        searchField.tap()
        searchField.typeText("Swift")
        
        // Wait for search results
        sleep(1)
        
        // Verify filtered results
        let swiftCourse = app.staticTexts["Swift для начинающих"]
        XCTAssertTrue(swiftCourse.exists || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Swift")).firstMatch.exists)
        
        // Clear search
        if searchField.buttons["Clear text"].exists {
            searchField.buttons["Clear text"].tap()
        } else {
            clearAndTypeText(searchField, text: "")
        }
        
        // Verify all courses are shown again
        sleep(1)
        XCTAssertTrue(app.scrollViews.descendants(matching: .button).count > 1)
    }
    
    func testCreateNewCourse() throws {
        // Tap add button
        app.buttons["plus.circle.fill"].tap()
        
        // Wait for create course form
        XCTAssertTrue(app.navigationBars["Новый курс"].waitForExistence(timeout: 5))
        
        // Fill in course details
        let titleField = app.textFields["Название курса"]
        titleField.tap()
        titleField.typeText("Тестовый курс UI")
        
        let descriptionField = app.textViews["Описание курса"]
        descriptionField.tap()
        descriptionField.typeText("Описание тестового курса для UI тестов")
        
        // Select category
        app.buttons["Выберите категорию"].tap()
        app.buttons["Программирование"].tap()
        
        // Set duration
        let durationField = app.textFields["Длительность"]
        durationField.tap()
        durationField.typeText("2 часа")
        
        // Save course
        app.buttons["Сохранить"].tap()
        
        // Verify course was created
        XCTAssertTrue(app.navigationBars["Курсы"].waitForExistence(timeout: 5))
        
        // Search for new course
        let searchField = app.textFields["Поиск курсов"]
        searchField.tap()
        searchField.typeText("Тестовый курс UI")
        
        sleep(1)
        XCTAssertTrue(app.staticTexts["Тестовый курс UI"].exists)
    }
    
    func testEditCourse() throws {
        // Find and tap edit button on first course
        let editButton = app.buttons["pencil.circle.fill"].firstMatch
        XCTAssertTrue(editButton.waitForExistence(timeout: 5))
        editButton.tap()
        
        // Wait for edit form
        XCTAssertTrue(app.navigationBars.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Редактирование")).firstMatch.waitForExistence(timeout: 5))
        
        // Modify title
        let titleField = app.textFields.firstMatch
        titleField.tap()
        clearAndTypeText(titleField, text: " (Обновлено)")
        
        // Save changes
        app.buttons["Сохранить"].tap()
        
        // Verify changes were saved
        XCTAssertTrue(app.navigationBars["Курсы"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "(Обновлено)")).firstMatch.exists)
    }
    
    func testCourseModuleManagement() throws {
        // Open first course for editing
        let editButton = app.buttons["pencil.circle.fill"].firstMatch
        editButton.tap()
        
        // Navigate to modules section
        app.buttons["Модули курса"].tap()
        
        // Add new module
        app.buttons["Добавить модуль"].tap()
        
        // Fill module details
        let moduleTitle = app.textFields["Название модуля"]
        moduleTitle.tap()
        moduleTitle.typeText("Новый модуль")
        
        // Add lesson to module
        app.buttons["Добавить урок"].tap()
        
        let lessonTitle = app.textFields["Название урока"]
        lessonTitle.tap()
        lessonTitle.typeText("Урок 1")
        
        // Save module
        app.buttons["Сохранить модуль"].tap()
        
        // Verify module was added
        XCTAssertTrue(app.staticTexts["Новый модуль"].exists)
        XCTAssertTrue(app.staticTexts["1 урок"].exists)
    }
    
    func testCourseAssignment() throws {
        // Open course details
        let firstCourse = app.scrollViews.descendants(matching: .button).firstMatch
        firstCourse.tap()
        
        // Tap assign button
        app.buttons["person.badge.plus"].tap()
        
        // Wait for assignment view
        XCTAssertTrue(app.navigationBars["Назначение курса"].waitForExistence(timeout: 5))
        
        // Select users
        let firstUserToggle = app.switches.firstMatch
        firstUserToggle.tap()
        
        let secondUserToggle = app.switches.element(boundBy: 1)
        if secondUserToggle.exists {
            secondUserToggle.tap()
        }
        
        // Assign course
        app.buttons["Назначить выбранным"].tap()
        
        // Verify success message
        XCTAssertTrue(app.alerts["Успешно"].waitForExistence(timeout: 5))
        app.alerts.buttons["OK"].tap()
    }
    
    func testCourseCompetencyLink() throws {
        // Open course for editing
        let editButton = app.buttons["pencil.circle.fill"].firstMatch
        editButton.tap()
        
        // Navigate to competencies
        app.buttons["Связанные компетенции"].tap()
        
        // Add competency
        app.buttons["Добавить компетенцию"].tap()
        
        // Select competency
        let firstCompetency = app.tables.cells.firstMatch
        firstCompetency.tap()
        
        // Set level
        app.buttons["Базовый"].tap()
        
        // Save
        app.buttons["Сохранить"].tap()
        
        // Verify competency was linked
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "компетенц")).firstMatch.exists)
    }
    
    func testCourseStatusChange() throws {
        // Open course for editing
        let editButton = app.buttons["pencil.circle.fill"].firstMatch
        editButton.tap()
        
        // Change status
        app.buttons["Статус курса"].tap()
        
        // Select published status
        app.buttons["Опубликован"].tap()
        
        // Save
        app.buttons["Сохранить"].tap()
        
        // Verify status changed
        XCTAssertTrue(app.staticTexts["Опубликован"].exists)
    }
    
    func testCourseDeletion() throws {
        // Create test course first
        app.buttons["plus.circle.fill"].tap()
        
        let titleField = app.textFields["Название курса"]
        titleField.tap()
        titleField.typeText("Курс для удаления")
        
        app.buttons["Сохранить"].tap()
        
        // Search for the course
        let searchField = app.textFields["Поиск курсов"]
        searchField.tap()
        searchField.typeText("Курс для удаления")
        
        sleep(1)
        
        // Open course for editing
        app.buttons["pencil.circle.fill"].firstMatch.tap()
        
        // Scroll to delete button
        app.scrollViews.firstMatch.swipeUp()
        
        // Delete course
        app.buttons["Удалить курс"].tap()
        
        // Confirm deletion
        app.alerts.buttons["Удалить"].tap()
        
        // Verify course was deleted
        XCTAssertTrue(app.navigationBars["Курсы"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Курс для удаления"].exists)
    }
    
    func testBulkOperations() throws {
        // Enable selection mode
        app.buttons["Выбрать"].tap()
        
        // Select multiple courses
        let firstCheckbox = app.buttons["square"].firstMatch
        firstCheckbox.tap()
        
        let secondCheckbox = app.buttons.matching(identifier: "square").element(boundBy: 1)
        if secondCheckbox.exists {
            secondCheckbox.tap()
        }
        
        // Open bulk actions
        app.buttons["Действия"].tap()
        
        // Archive selected courses
        app.buttons["Архивировать"].tap()
        
        // Confirm action
        app.alerts.buttons["Архивировать"].tap()
        
        // Verify success
        XCTAssertTrue(app.alerts["Успешно"].waitForExistence(timeout: 5))
        app.alerts.buttons["OK"].tap()
    }
} 