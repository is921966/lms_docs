import XCTest

final class FixedUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "MOCK_MODE"]
        app.launchEnvironment = ["UI_TESTING": "1"]
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Login Tests
    
    func testMockLogin_AsStudent() throws {
        // Запускаем приложение
        app.launch()
        
        // Ждем появления UI
        let loginButton = app.buttons["Войти для разработки"]
        let exists = loginButton.waitForExistence(timeout: 10)
        
        if exists {
            // Нашли кнопку мок-логина
            loginButton.tap()
            
            // Выбираем студента
            let studentButton = app.buttons["Войти как студент"]
            XCTAssertTrue(studentButton.waitForExistence(timeout: 5))
            studentButton.tap()
            
            // Проверяем что попали на главный экран
            let tabBar = app.tabBars.firstMatch
            XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
            XCTAssertTrue(app.tabBars.buttons["Обучение"].exists)
        } else {
            // Возможно, пользователь уже залогинен
            if app.tabBars.firstMatch.exists {
                XCTAssertTrue(app.tabBars.buttons["Обучение"].exists)
            } else {
                XCTFail("Не найден экран логина или главный экран")
            }
        }
    }
    
    func testMockLogin_AsAdmin() throws {
        app.launch()
        
        let loginButton = app.buttons["Войти для разработки"]
        if loginButton.waitForExistence(timeout: 10) {
            loginButton.tap()
            
            let adminButton = app.buttons["Войти как администратор"]
            XCTAssertTrue(adminButton.waitForExistence(timeout: 5))
            adminButton.tap()
            
            // Проверяем админские функции
            let moreTab = app.tabBars.buttons["Ещё"]
            XCTAssertTrue(moreTab.waitForExistence(timeout: 5))
            moreTab.tap()
            
            XCTAssertTrue(app.buttons["Администрирование"].waitForExistence(timeout: 5))
        }
    }
    
    // MARK: - Navigation Tests
    
    func testTabBarNavigation() throws {
        app.launch()
        ensureLoggedIn()
        
        // Проверяем все табы
        let tabs = ["Обучение", "Профиль", "Ещё"]
        
        for tabName in tabs {
            let tab = app.tabBars.buttons[tabName]
            XCTAssertTrue(tab.exists, "Таб \(tabName) должен существовать")
            tab.tap()
            
            // Небольшая задержка для анимации
            sleep(1)
            
            XCTAssertTrue(tab.isSelected, "Таб \(tabName) должен быть выбран")
        }
    }
    
    // MARK: - Course Tests
    
    func testCourseList() throws {
        app.launch()
        ensureLoggedIn()
        
        // Переходим на вкладку обучения
        let learningTab = app.tabBars.buttons["Обучение"]
        if !learningTab.isSelected {
            learningTab.tap()
        }
        
        // Ждем загрузки курсов
        sleep(2)
        
        // Проверяем наличие курсов
        let firstCourse = app.scrollViews.otherElements.buttons.firstMatch
        XCTAssertTrue(firstCourse.waitForExistence(timeout: 5), "Должен быть хотя бы один курс")
        
        // Проверяем поиск
        let searchField = app.textFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("продаж")
            
            // Проверяем результаты поиска
            sleep(1)
            let searchResults = app.scrollViews.otherElements.buttons.count
            XCTAssertGreaterThan(searchResults, 0, "Должны быть результаты поиска")
        }
    }
    
    func testCourseDetail() throws {
        app.launch()
        ensureLoggedIn()
        
        // Переходим к курсу
        let firstCourse = app.scrollViews.otherElements.buttons.firstMatch
        XCTAssertTrue(firstCourse.waitForExistence(timeout: 5))
        firstCourse.tap()
        
        // Проверяем элементы детальной страницы
        XCTAssertTrue(app.staticTexts["О курсе"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Программа курса"].exists)
        
        // Проверяем кнопку начала обучения
        let startButton = app.buttons["Начать обучение"]
        let continueButton = app.buttons["Продолжить обучение"]
        XCTAssertTrue(startButton.exists || continueButton.exists)
    }
    
    // MARK: - Profile Tests
    
    func testProfile() throws {
        app.launch()
        ensureLoggedIn()
        
        // Переходим в профиль
        let profileTab = app.tabBars.buttons["Профиль"]
        profileTab.tap()
        
        // Проверяем основные элементы профиля
        XCTAssertTrue(app.navigationBars["Профиль"].waitForExistence(timeout: 5))
        
        // Проверяем статистику
        XCTAssertTrue(app.staticTexts["Курсов"].exists)
        XCTAssertTrue(app.staticTexts["Сертификатов"].exists)
        XCTAssertTrue(app.staticTexts["Обучения"].exists)
        
        // Проверяем табы в профиле
        if app.buttons["Достижения"].exists {
            app.buttons["Достижения"].tap()
            sleep(1)
            XCTAssertTrue(app.staticTexts["Мои достижения"].exists)
        }
    }
    
    // MARK: - Helper Methods
    
    private func ensureLoggedIn() {
        // Если видим кнопку логина, логинимся
        let loginButton = app.buttons["Войти для разработки"]
        if loginButton.exists {
            loginButton.tap()
            
            let studentButton = app.buttons["Войти как студент"]
            if studentButton.waitForExistence(timeout: 3) {
                studentButton.tap()
            }
        }
        
        // Ждем появления главного экрана
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "Должен появиться tab bar")
    }
} 