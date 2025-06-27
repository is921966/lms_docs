import XCTest

final class TestTakingUITests: UITestBase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Login as student
        login(as: .student)
        
        // Navigate to Tests
        app.tabBars.buttons["Тесты"].tap()
    }
    
    // MARK: - Start Test Flow
    
    func testStartTest() throws {
        // Find available test
        let testsList = app.collectionViews[AccessibilityIdentifiers.Tests.testsList]
        waitForElement(testsList)
        
        let firstTest = testsList.cells.element(boundBy: 0)
        XCTAssertTrue(firstTest.exists, "No tests available")
        
        // Remember test name
        let testName = firstTest.staticTexts.firstMatch.label
        
        // Open test details
        firstTest.tap()
        
        // Check test info is displayed
        XCTAssertTrue(app.staticTexts[testName].exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'вопрос'")).firstMatch.exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'минут'")).firstMatch.exists)
        
        takeScreenshot(name: "Test_Details_Before_Start")
        
        // Start test
        let startButton = app.buttons[AccessibilityIdentifiers.Tests.startTestButton]
        waitForElement(startButton)
        startButton.tap()
        
        // Verify test player loaded
        let questionView = app.otherElements["questionView"]
        waitForElement(questionView)
        
        // Check question number indicator
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Вопрос 1'")).firstMatch.exists)
        
        takeScreenshot(name: "Test_First_Question")
    }
    
    // MARK: - Answer Questions
    
    func testAnswerSingleChoiceQuestion() throws {
        try navigateToTestPlayer()
        
        // Find single choice question
        if app.staticTexts["Выберите один вариант ответа"].exists {
            // Select first answer option
            let answerOptions = app.buttons.matching(identifier: AccessibilityIdentifiers.Tests.answerOption)
            let answerOption = answerOptions.element(boundBy: 0)
            answerOption.tap()
            
            // Verify selection
            XCTAssertTrue(answerOption.isSelected)
            
            // Try to select another option
            let secondOption = answerOptions.element(boundBy: 1)
            secondOption.tap()
            
            // First should be deselected, second selected
            XCTAssertFalse(answerOption.isSelected)
            XCTAssertTrue(secondOption.isSelected)
            
            takeScreenshot(name: "Single_Choice_Answer_Selected")
        }
    }
    
    func testAnswerMultipleChoiceQuestion() throws {
        try navigateToTestPlayer()
        
        // Navigate to multiple choice question
        navigateToQuestionType("Выберите несколько вариантов")
        
        if app.staticTexts["Выберите несколько вариантов"].exists {
            // Select multiple options
            let answerOptions = app.buttons.matching(identifier: AccessibilityIdentifiers.Tests.answerOption)
            let firstOption = answerOptions.element(boundBy: 0)
            let secondOption = answerOptions.element(boundBy: 1)
            
            firstOption.tap()
            secondOption.tap()
            
            // Both should be selected
            XCTAssertTrue(firstOption.isSelected)
            XCTAssertTrue(secondOption.isSelected)
            
            // Deselect one
            firstOption.tap()
            XCTAssertFalse(firstOption.isSelected)
            XCTAssertTrue(secondOption.isSelected)
            
            takeScreenshot(name: "Multiple_Choice_Answers_Selected")
        }
    }
    
    func testAnswerTextInputQuestion() throws {
        try navigateToTestPlayer()
        
        // Navigate to text input question
        navigateToQuestionType("Введите ответ")
        
        if app.textFields.firstMatch.exists {
            let textField = app.textFields.firstMatch
            textField.tap()
            textField.typeText("Sample answer text")
            
            dismissKeyboard()
            
            // Verify text was entered
            XCTAssertEqual(textField.value as? String, "Sample answer text")
            
            takeScreenshot(name: "Text_Input_Answer_Entered")
        }
    }
    
    // MARK: - Navigation
    
    func testNavigateBetweenQuestions() throws {
        try navigateToTestPlayer()
        
        // Answer first question
        let answerOptions = app.buttons.matching(identifier: AccessibilityIdentifiers.Tests.answerOption)
        if answerOptions.count > 0 {
            answerOptions.element(boundBy: 0).tap()
        }
        
        // Go to next question
        let nextButton = app.buttons[AccessibilityIdentifiers.Tests.nextQuestionButton]
        waitForElement(nextButton)
        nextButton.tap()
        
        // Verify on question 2
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Вопрос 2'")).firstMatch.exists)
        
        // Go back to previous
        let previousButton = app.buttons[AccessibilityIdentifiers.Tests.previousQuestionButton]
        waitForElement(previousButton)
        previousButton.tap()
        
        // Verify back on question 1
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Вопрос 1'")).firstMatch.exists)
        
        // Verify answer is still selected
        let firstAnswer = app.buttons.matching(identifier: AccessibilityIdentifiers.Tests.answerOption).element(boundBy: 0)
        XCTAssertTrue(firstAnswer.isSelected)
    }
    
    func testBookmarkQuestion() throws {
        try navigateToTestPlayer()
        
        // Bookmark current question
        let bookmarkButton = app.buttons[AccessibilityIdentifiers.Tests.bookmarkButton]
        waitForElement(bookmarkButton)
        
        // Check initial state
        let isBookmarked = bookmarkButton.isSelected
        
        // Toggle bookmark
        bookmarkButton.tap()
        
        // Verify state changed
        XCTAssertNotEqual(bookmarkButton.isSelected, isBookmarked)
        
        takeScreenshot(name: "Question_Bookmarked")
        
        // Navigate away and back
        app.buttons[AccessibilityIdentifiers.Tests.nextQuestionButton].tap()
        app.buttons[AccessibilityIdentifiers.Tests.previousQuestionButton].tap()
        
        // Bookmark state should persist
        XCTAssertNotEqual(bookmarkButton.isSelected, isBookmarked)
    }
    
    // MARK: - Time Management
    
    func testTimeLimit() throws {
        // Find a timed test
        let testsList = app.collectionViews[AccessibilityIdentifiers.Tests.testsList]
        
        // Look for test with time limit
        let timedTest = testsList.cells.containing(.staticText, identifier: "минут").firstMatch
        
        if timedTest.exists {
            timedTest.tap()
            
            // Start test
            app.buttons[AccessibilityIdentifiers.Tests.startTestButton].tap()
            
            // Check timer is displayed
            let timerLabel = app.staticTexts.matching(NSPredicate(format: "label MATCHES '\\d+:\\d+'")).firstMatch
            waitForElement(timerLabel)
            
            // Record initial time
            let initialTime = timerLabel.label
            
            // Wait a few seconds
            Thread.sleep(forTimeInterval: 3)
            
            // Timer should have decreased
            XCTAssertNotEqual(timerLabel.label, initialTime)
            
            takeScreenshot(name: "Test_Timer_Running")
        }
    }
    
    // MARK: - Submit Test
    
    func testSubmitTest() throws {
        try navigateToTestPlayer()
        
        // Answer all questions quickly
        answerAllQuestions()
        
        // Navigate to last question
        while app.buttons[AccessibilityIdentifiers.Tests.nextQuestionButton].isEnabled {
            app.buttons[AccessibilityIdentifiers.Tests.nextQuestionButton].tap()
        }
        
        // Submit button should be visible
        let submitButton = app.buttons[AccessibilityIdentifiers.Tests.submitTestButton]
        waitForElement(submitButton)
        
        takeScreenshot(name: "Test_Ready_To_Submit")
        
        // Submit test
        submitButton.tap()
        
        // Confirm submission
        app.alerts.buttons["Завершить"].tap()
        
        // Wait for results
        let resultsView = app.otherElements[AccessibilityIdentifiers.Tests.testResultView]
        waitForElement(resultsView)
        
        // Check results are displayed
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS '%'")).firstMatch.exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'баллов'")).firstMatch.exists)
        
        takeScreenshot(name: "Test_Results_Displayed")
    }
    
    func testSubmitWithUnansweredQuestions() throws {
        try navigateToTestPlayer()
        
        // Answer only first question
        let answerOptions = app.buttons.matching(identifier: AccessibilityIdentifiers.Tests.answerOption)
        if answerOptions.count > 0 {
            answerOptions.element(boundBy: 0).tap()
        }
        
        // Try to submit
        while app.buttons[AccessibilityIdentifiers.Tests.nextQuestionButton].isEnabled {
            app.buttons[AccessibilityIdentifiers.Tests.nextQuestionButton].tap()
        }
        
        let submitButton = app.buttons[AccessibilityIdentifiers.Tests.submitTestButton]
        submitButton.tap()
        
        // Should show warning
        let alert = app.alerts.firstMatch
        waitForElement(alert)
        XCTAssertTrue(alert.label.contains("не ответили") || alert.staticTexts.matching(NSPredicate(format: "label CONTAINS 'вопрос'")).count > 0)
        
        takeScreenshot(name: "Unanswered_Questions_Warning")
        
        // Can choose to continue or go back
        if alert.buttons["Продолжить"].exists {
            alert.buttons["Продолжить"].tap()
            
            // Should submit anyway
            let resultsView = app.otherElements[AccessibilityIdentifiers.Tests.testResultView]
            waitForElement(resultsView)
        } else {
            alert.buttons["Вернуться"].tap()
        }
    }
    
    // MARK: - Pause/Resume
    
    func testPauseResume() throws {
        try navigateToTestPlayer()
        
        // Answer a question
        let answerOptions = app.buttons.matching(identifier: AccessibilityIdentifiers.Tests.answerOption)
        if answerOptions.count > 0 {
            answerOptions.element(boundBy: 0).tap()
        }
        
        // Go to next question
        app.buttons[AccessibilityIdentifiers.Tests.nextQuestionButton].tap()
        
        // Pause test (usually via back button or menu)
        app.navigationBars.buttons.firstMatch.tap()
        
        // Confirm pause
        if app.alerts.firstMatch.exists {
            app.alerts.buttons["Приостановить"].tap()
        }
        
        // Should be back at test details
        let startButton = app.buttons["Продолжить тест"]
        waitForElement(startButton)
        
        takeScreenshot(name: "Test_Paused")
        
        // Resume test
        startButton.tap()
        
        // Should be on same question (question 2)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Вопрос 2'")).firstMatch.exists)
        
        // Go back to check first answer is still saved
        app.buttons[AccessibilityIdentifiers.Tests.previousQuestionButton].tap()
        let firstAnswer = app.buttons.matching(identifier: AccessibilityIdentifiers.Tests.answerOption).element(boundBy: 0)
        XCTAssertTrue(firstAnswer.isSelected)
    }
    
    // MARK: - Helper Methods
    
    private func navigateToTestPlayer() throws {
        let testsList = app.collectionViews[AccessibilityIdentifiers.Tests.testsList]
        waitForElement(testsList)
        
        testsList.cells.element(boundBy: 0).tap()
        app.buttons[AccessibilityIdentifiers.Tests.startTestButton].tap()
        
        let questionView = app.otherElements["questionView"]
        waitForElement(questionView)
    }
    
    private func navigateToQuestionType(_ type: String) {
        var attempts = 0
        while !app.staticTexts[type].exists && attempts < 10 {
            if app.buttons[AccessibilityIdentifiers.Tests.nextQuestionButton].isEnabled {
                app.buttons[AccessibilityIdentifiers.Tests.nextQuestionButton].tap()
                attempts += 1
            } else {
                break
            }
        }
    }
    
    private func answerAllQuestions() {
        repeat {
            // Answer current question
            let answerOptions = app.buttons.matching(identifier: AccessibilityIdentifiers.Tests.answerOption)
            if answerOptions.count > 0 {
                let firstAnswer = answerOptions.element(boundBy: 0)
                if !firstAnswer.isSelected {
                    firstAnswer.tap()
                }
            } else if app.textFields.firstMatch.exists {
                let textField = app.textFields.firstMatch
                textField.tap()
                textField.typeText("Answer")
                dismissKeyboard()
            }
            
            // Try to go to next question
            let nextButton = app.buttons[AccessibilityIdentifiers.Tests.nextQuestionButton]
            if nextButton.exists && nextButton.isEnabled {
                nextButton.tap()
            } else {
                break
            }
        } while true
    }
} 