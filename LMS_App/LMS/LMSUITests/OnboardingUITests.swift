import XCTest

final class OnboardingUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launchArguments.append("--reset-state")
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Test: Create New Onboarding Program

    func test045_CreateOnboardingProgramFromTemplate() throws {
        app.launch()

        // Navigate to onboarding
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Адаптация"].tap()

        // Wait for dashboard to load
        let onboardingDashboard = app.scrollViews["onboardingStatsView"]
        XCTAssertTrue(onboardingDashboard.waitForExistence(timeout: 5))

        // Tap create new program button
        app.buttons["Новая программа"].tap()

        // Select employee
        let employeeSection = app.cells.containing(.staticText, identifier: "Сотрудник").firstMatch
        XCTAssertTrue(employeeSection.waitForExistence(timeout: 3))
        employeeSection.buttons["Выбрать сотрудника"].tap()

        // Search and select employee
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        searchField.tap()
        searchField.typeText("Иван")

        let employeeCell = app.cells.containing(.staticText, identifier: "Иван Иванов").firstMatch
        XCTAssertTrue(employeeCell.waitForExistence(timeout: 3))
        employeeCell.tap()

        app.buttons["Готово"].tap()

        // Select template
        let templateSection = app.cells.containing(.staticText, identifier: "Шаблон программы").firstMatch
        XCTAssertTrue(templateSection.exists)
        templateSection.buttons["Выбрать шаблон"].tap()

        // Select first template
        let templateCell = app.cells.containing(.staticText, identifier: "Адаптация продавца-консультанта").firstMatch
        XCTAssertTrue(templateCell.waitForExistence(timeout: 3))
        templateCell.tap()

        app.buttons["Готово"].tap()

        // Fill in mentor
        let mentorField = app.textFields["ID наставника"]
        XCTAssertTrue(mentorField.waitForExistence(timeout: 3))
        mentorField.tap()
        mentorField.typeText("mentor123")

        // Create program
        app.navigationBars.buttons["Создать"].tap()

        // Verify success
        let successAlert = app.alerts["Программа создана"]
        XCTAssertTrue(successAlert.waitForExistence(timeout: 5))
        successAlert.buttons["OK"].tap()

        // Verify program appears in list
        let programCard = app.buttons.containing(.staticText, identifier: "Иван Иванов").firstMatch
        XCTAssertTrue(programCard.waitForExistence(timeout: 3))
    }

    // MARK: - Test: View and Complete Tasks

    func test046_ViewAndCompleteOnboardingTasks() throws {
        app.launch()

        // Navigate to onboarding
        navigateToOnboarding()

        // Open first program
        let programCard = app.buttons.containing(.staticText, identifier: "Адаптация продавца-консультанта").firstMatch
        XCTAssertTrue(programCard.waitForExistence(timeout: 5))
        programCard.tap()

        // Verify program details
        let programTitle = app.navigationBars["Программа адаптации"].firstMatch
        XCTAssertTrue(programTitle.waitForExistence(timeout: 3))

        // Open first stage
        let stageCard = app.buttons.containing(.staticText, identifier: "Знакомство с компанией").firstMatch
        XCTAssertTrue(stageCard.waitForExistence(timeout: 3))
        stageCard.tap()

        // Verify stage details
        let stageTitle = app.navigationBars["Этап 1"].firstMatch
        XCTAssertTrue(stageTitle.waitForExistence(timeout: 3))

        // Complete a task
        let taskCheckbox = app.buttons.matching(identifier: "circle").firstMatch
        XCTAssertTrue(taskCheckbox.waitForExistence(timeout: 3))
        taskCheckbox.tap()

        // Verify task is completed
        let completedCheckbox = app.images["checkmark.circle.fill"].firstMatch
        XCTAssertTrue(completedCheckbox.waitForExistence(timeout: 3))

        // Go back
        app.navigationBars.buttons["Готово"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    // MARK: - Test: Edit Onboarding Program

    func test047_EditOnboardingProgram() throws {
        app.launch()

        // Navigate to onboarding
        navigateToOnboarding()

        // Open program
        let programCard = app.buttons.containing(.staticText, identifier: "Адаптация продавца-консультанта").firstMatch
        XCTAssertTrue(programCard.waitForExistence(timeout: 5))
        programCard.tap()

        // Open actions menu
        app.navigationBars.buttons["ellipsis.circle"].tap()

        // Select edit
        let editButton = app.sheets.buttons["Редактировать программу"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 3))
        editButton.tap()

        // Change status
        let statusPicker = app.pickers["Статус"].firstMatch
        XCTAssertTrue(statusPicker.waitForExistence(timeout: 3))
        statusPicker.tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: "Завершен")

        // Save changes
        app.navigationBars.buttons["Сохранить"].tap()

        // Verify success
        let successAlert = app.alerts["Изменения сохранены"]
        XCTAssertTrue(successAlert.waitForExistence(timeout: 3))
        successAlert.buttons["OK"].tap()
    }

    // MARK: - Test: View Onboarding Analytics

    func test048_ViewOnboardingAnalytics() throws {
        app.launch()

        // Navigate to onboarding
        navigateToOnboarding()

        // Open reports
        app.buttons["Отчеты"].tap()

        // Verify reports view
        let reportsTitle = app.navigationBars["Отчеты по адаптации"].firstMatch
        XCTAssertTrue(reportsTitle.waitForExistence(timeout: 3))

        // Check summary cards
        let activeCard = app.staticTexts["Активные программы"].firstMatch
        XCTAssertTrue(activeCard.exists)

        let completedCard = app.staticTexts["Завершенные программы"].firstMatch
        XCTAssertTrue(completedCard.exists)

        // Check charts
        let progressChart = app.otherElements["Прогресс по времени"].firstMatch
        XCTAssertTrue(progressChart.exists)

        let statusChart = app.otherElements["Распределение по статусам"].firstMatch
        XCTAssertTrue(statusChart.exists)

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    // MARK: - Test: Filter Onboarding Programs

    func test049_FilterOnboardingPrograms() throws {
        app.launch()

        // Navigate to onboarding
        navigateToOnboarding()

        // Use search
        let searchField = app.textFields["searchTextField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        searchField.tap()
        searchField.typeText("кассир")

        // Verify filtered results
        let cashierProgram = app.staticTexts["Адаптация кассира"].firstMatch
        XCTAssertTrue(cashierProgram.waitForExistence(timeout: 3))

        let sellerProgram = app.staticTexts["Адаптация продавца-консультанта"].firstMatch
        XCTAssertFalse(sellerProgram.exists)

        // Clear search
        searchField.buttons["Clear text"].tap()

        // Verify all programs visible again
        XCTAssertTrue(sellerProgram.waitForExistence(timeout: 3))
    }

    // MARK: - Test: My Onboarding Programs (Employee View)

    func test050_ViewMyOnboardingPrograms() throws {
        app.launch()

        // Navigate to profile
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Профиль"].tap()

        // Check if user has onboarding programs
        let onboardingSection = app.buttons["Программа адаптации"].firstMatch
        if onboardingSection.waitForExistence(timeout: 3) {
            onboardingSection.tap()

            // Verify my programs view
            let myProgramsTitle = app.navigationBars["Мои программы адаптации"].firstMatch
            XCTAssertTrue(myProgramsTitle.waitForExistence(timeout: 3))

            // Check program card
            let programCard = app.scrollViews.descendants(matching: .button).element(boundBy: 0)
            if programCard.exists {
                programCard.tap()

                // Verify program details
                let programView = app.scrollViews.firstMatch
                XCTAssertTrue(programView.waitForExistence(timeout: 3))

                // Close modal
                app.navigationBars.buttons["Готово"].tap()
            }
        }
    }

    // MARK: - Test: Onboarding Templates Management

    func test051_ManageOnboardingTemplates() throws {
        app.launch()

        // Navigate to onboarding
        navigateToOnboarding()

        // Open templates
        app.buttons["createFromTemplateIcon"].tap()

        // Verify templates list
        let templatesTitle = app.navigationBars["Шаблоны адаптации"].firstMatch
        XCTAssertTrue(templatesTitle.waitForExistence(timeout: 3))

        // Check template categories
        let sellerTemplate = app.staticTexts["Адаптация продавца-консультанта"].firstMatch
        XCTAssertTrue(sellerTemplate.exists)

        let cashierTemplate = app.staticTexts["Адаптация кассира"].firstMatch
        XCTAssertTrue(cashierTemplate.exists)

        // Open template details
        let templateCard = app.scrollViews.descendants(matching: .button).element(boundBy: 0)
        if templateCard.exists {
            templateCard.tap()

            // Verify template structure
            let stagesSection = app.staticTexts["Этапы программы"].firstMatch
            XCTAssertTrue(stagesSection.waitForExistence(timeout: 3))

            // Go back
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }

    // MARK: - Helper Methods

    private func navigateToOnboarding() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Адаптация"].tap()

        let onboardingDashboard = app.scrollViews["onboardingStatsView"]
        XCTAssertTrue(onboardingDashboard.waitForExistence(timeout: 5))
    }

    private func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 5) {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        wait(for: [expectation], timeout: timeout)
    }
}
