import XCTest

class TestTelegramFeed: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testTelegramFeedIsDisplayed() {
        let app = XCUIApplication()
        app.launch()
        
        // Ждем загрузки приложения
        sleep(3)
        
        // Проверяем наличие заголовка "Новости"
        let newsTitle = app.navigationBars["Новости"]
        if newsTitle.exists {
            print("✅ Найден заголовок 'Новости' - TelegramFeedView отображается!")
        } else {
            print("❌ Заголовок 'Новости' не найден")
        }
        
        // Проверяем наличие кнопки настроек (gear icon)
        let settingsButton = app.buttons["gearshape"]
        if settingsButton.exists {
            print("✅ Найдена кнопка настроек - это TelegramFeedView!")
        } else {
            print("❌ Кнопка настроек не найдена")
        }
        
        // Проверяем наличие классической ленты
        let classicFeedText = app.staticTexts["Классическая лента новостей"]
        if classicFeedText.exists {
            print("⚠️ Отображается классическая лента вместо Telegram!")
        }
        
        // Делаем скриншот
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Current_Feed_View"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

// Запускаем тест
let test = TestTelegramFeed()
test.setUp()
test.testTelegramFeedIsDisplayed() 