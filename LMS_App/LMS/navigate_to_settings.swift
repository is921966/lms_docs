import XCTest

// Переход в настройки
let app = XCUIApplication(bundleIdentifier: "com.tsum.lms.corporate.university")
app.activate()

// Ждем загрузки
Thread.sleep(forTimeInterval: 2)

// Нажимаем на вкладку "Ещё"
if app.tabBars.buttons["Ещё"].exists {
    app.tabBars.buttons["Ещё"].tap()
} else if app.tabBars.buttons["More"].exists {
    app.tabBars.buttons["More"].tap()
}

Thread.sleep(forTimeInterval: 1)

// Нажимаем на "Настройки"
if app.buttons["Настройки"].exists {
    app.buttons["Настройки"].tap()
} else if app.buttons["Settings"].exists {
    app.buttons["Settings"].tap()
}

Thread.sleep(forTimeInterval: 1)

// Делаем скриншот
let screenshot = app.screenshot()
let attachment = XCTAttachment(screenshot: screenshot)
attachment.name = "Settings Screen"
attachment.lifetime = .keepAlways
print("Screenshot taken")
