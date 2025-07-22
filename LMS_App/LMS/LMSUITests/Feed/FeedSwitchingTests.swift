import XCTest

class FeedSwitchingTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Сброс UserDefaults перед тестом
        app.launchArguments.append("-resetUserDefaults")
        
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // Тест: проверка что по умолчанию показывается классическая лента
    func testDefaultShowsClassicFeed() throws {
        // Given: запуск приложения с дефолтными настройками
        
        // When: переходим на вкладку Лента
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        let feedTab = tabBar.buttons["Лента"]
        XCTAssertTrue(feedTab.exists)
        feedTab.tap()
        
        // Then: должна отображаться классическая лента
        let classicFeedTitle = app.staticTexts["Классическая лента новостей"]
        XCTAssertTrue(classicFeedTitle.waitForExistence(timeout: 3), "Классическая лента должна отображаться по умолчанию")
        
        let switchButton = app.buttons["Попробовать новую ленту"]
        XCTAssertTrue(switchButton.exists, "Кнопка переключения должна быть видна")
    }
    
    // Тест: переключение на новую ленту через кнопку
    func testSwitchToNewFeedViaButton() throws {
        // Given: открыта классическая лента
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        let feedTab = tabBar.buttons["Лента"]
        feedTab.tap()
        
        let classicFeedTitle = app.staticTexts["Классическая лента новостей"]
        XCTAssertTrue(classicFeedTitle.waitForExistence(timeout: 3))
        
        // When: нажимаем кнопку переключения
        let switchButton = app.buttons["Попробовать новую ленту"]
        XCTAssertTrue(switchButton.exists)
        switchButton.tap()
        
        // Then: должна отображаться новая лента
        let telegramFeedExists = app.navigationBars["Лента"].waitForExistence(timeout: 3)
        XCTAssertTrue(telegramFeedExists, "Новая лента должна отображаться после переключения")
        
        // Проверяем наличие элементов новой ленты
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.exists, "Поле поиска должно быть в новой ленте")
        
        // Проверяем что классическая лента исчезла
        XCTAssertFalse(classicFeedTitle.exists, "Классическая лента не должна отображаться")
    }
    
    // Тест: переключение обратно на классическую ленту
    func testSwitchBackToClassicFeed() throws {
        // Given: сначала переключаемся на новую ленту
        app.launchArguments.append("-useNewFeedDesign")
        app.launch()
        
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // Проверяем что отображается новая лента
        let telegramFeedNav = app.navigationBars["Лента"]
        XCTAssertTrue(telegramFeedNav.waitForExistence(timeout: 3))
        
        // When: нажимаем кнопку переключения на классическую
        let classicButton = app.navigationBars.buttons["Классическая лента"]
        XCTAssertTrue(classicButton.waitForExistence(timeout: 3), "Кнопка классической ленты должна быть видна")
        classicButton.tap()
        
        // Then: должна отображаться классическая лента
        let classicFeedTitle = app.staticTexts["Классическая лента новостей"]
        XCTAssertTrue(classicFeedTitle.waitForExistence(timeout: 3), "Классическая лента должна отображаться")
        
        // Проверяем что новая лента исчезла
        XCTAssertFalse(app.searchFields.firstMatch.exists, "Элементы новой ленты не должны отображаться")
    }
    
    // Тест: состояние сохраняется после перезапуска
    func testFeedPreferencePersists() throws {
        // Given: переключаемся на новую ленту
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        let feedTab = tabBar.buttons["Лента"]
        feedTab.tap()
        
        let switchButton = app.buttons["Попробовать новую ленту"]
        if switchButton.waitForExistence(timeout: 3) {
            switchButton.tap()
        }
        
        // Проверяем что новая лента отображается
        let telegramFeedNav = app.navigationBars["Лента"]
        XCTAssertTrue(telegramFeedNav.waitForExistence(timeout: 3))
        
        // When: перезапускаем приложение
        app.terminate()
        app.launch()
        
        // Возвращаемся на вкладку ленты
        let newTabBar = app.tabBars.firstMatch
        XCTAssertTrue(newTabBar.waitForExistence(timeout: 5))
        newTabBar.buttons["Лента"].tap()
        
        // Then: новая лента должна остаться выбранной
        XCTAssertTrue(app.navigationBars["Лента"].waitForExistence(timeout: 3), "Выбор ленты должен сохраняться")
        XCTAssertTrue(app.searchFields.firstMatch.exists, "Новая лента должна отображаться после перезапуска")
    }
} 