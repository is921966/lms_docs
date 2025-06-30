import XCTest

final class SimpleSmokeTest: XCTestCase {
    func testAppLaunches() throws {
        // Простейший тест - проверяем что приложение запускается
        let app = XCUIApplication()
        app.launch()

        // Ждем немного чтобы приложение загрузилось
        sleep(2)

        // Проверяем что приложение запустилось
        XCTAssertTrue(app.state == .runningForeground, "Приложение должно быть запущено")

        // Делаем скриншот для визуальной проверки
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testBasicUIElements() throws {
        let app = XCUIApplication()
        app.launch()

        // Ждем загрузки
        sleep(3)

        // Проверяем наличие любых элементов UI
        let elementExists = !app.buttons.isEmpty ||
                           !app.staticTexts.isEmpty ||
                           !app.images.isEmpty

        XCTAssertTrue(elementExists, "Должны быть видны UI элементы")

        // Выводим информацию о найденных элементах
        print("Найдено кнопок: \(app.buttons.count)")
        print("Найдено текстов: \(app.staticTexts.count)")
        print("Найдено изображений: \(app.images.count)")
    }
}
