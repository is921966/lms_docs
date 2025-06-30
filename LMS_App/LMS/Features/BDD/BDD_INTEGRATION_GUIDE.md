# BDD Integration Guide для LMS

## Обзор

Данное руководство описывает, как интегрировать BDD сценарии (Gherkin) с существующими XCUITest в проекте LMS.

## Структура BDD в проекте

```
Features/BDD/
├── Scenarios/                    # Gherkin feature файлы
│   ├── Authentication.feature    # Сценарии входа
│   ├── CourseEnrollment.feature  # Сценарии записи на курсы
│   └── TestTaking.feature        # Сценарии прохождения тестов
├── Steps/                        # Step definitions
│   ├── CommonSteps.swift         # Общие шаги
│   ├── AuthenticationSteps.swift # Шаги для входа
│   ├── CourseSteps.swift         # Шаги для курсов
│   └── TestSteps.swift           # Шаги для тестов
└── Support/                      # Вспомогательные файлы
    ├── BDDTestCase.swift         # Базовый класс
    └── StepDefinitions.swift     # Регистрация шагов
```

## Пример интеграции с XCUITest

### 1. Базовый класс для BDD тестов

```swift
// Features/BDD/Support/BDDTestCase.swift
import XCTest

class BDDTestCase: XCTestCase {
    var app: XCUIApplication!
    var stepDefinitions: StepDefinitions!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-state"]
        app.launch()
        
        stepDefinitions = StepDefinitions(app: app)
    }
    
    // Вспомогательные методы для читаемости
    func given(_ step: String, action: () throws -> Void) rethrows {
        print("Дано: \(step)")
        try action()
    }
    
    func when(_ step: String, action: () throws -> Void) rethrows {
        print("Когда: \(step)")
        try action()
    }
    
    func then(_ step: String, action: () throws -> Void) rethrows {
        print("Тогда: \(step)")
        try action()
    }
}
```

### 2. Реализация шагов для Authentication

```swift
// Features/BDD/Steps/AuthenticationSteps.swift
import XCTest

extension StepDefinitions {
    
    func registerAuthenticationSteps() {
        
        // Дано приложение LMS запущено
        steps["приложение LMS запущено"] = {
            XCTAssertTrue(self.app.state == .runningForeground)
        }
        
        // И я нахожусь на экране входа
        steps["я нахожусь на экране входа"] = {
            XCTAssertTrue(self.loginPage.isDisplayed)
        }
        
        // Когда я ввожу email "ivan.petrov@company.ru"
        steps["я ввожу email (.*)"] = { email in
            self.loginPage.enterEmail(email)
        }
        
        // И я ввожу пароль "SecurePass123!"
        steps["я ввожу пароль (.*)"] = { password in
            self.loginPage.enterPassword(password)
        }
        
        // И я нажимаю кнопку "Войти"
        steps["я нажимаю кнопку \"(.*)\""] = { buttonTitle in
            self.app.buttons[buttonTitle].tap()
        }
        
        // Тогда я должен увидеть главную панель
        steps["я должен увидеть главную панель"] = {
            XCTAssertTrue(self.dashboardPage.isDisplayed)
        }
        
        // И я должен увидеть приветственное сообщение "Добро пожаловать, Иван!"
        steps["я должен увидеть приветственное сообщение \"(.*)\""] = { message in
            let label = self.app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", message)).firstMatch
            XCTAssertTrue(label.waitForExistence(timeout: 5))
        }
    }
}
```

### 3. Тест на основе BDD сценария

```swift
// LMSUITests/BDD/AuthenticationBDDTests.swift
class AuthenticationBDDTests: BDDTestCase {
    
    func testSuccessfulLoginWithValidCredentials() {
        // Сценарий: Успешный вход с валидными учетными данными
        
        given("приложение LMS запущено") {
            // Автоматически выполнено в setUp
        }
        
        given("я нахожусь на экране входа") {
            XCTAssertTrue(LoginPage(app: app).isDisplayed)
        }
        
        given("у меня есть корпоративный аккаунт") {
            // Mock аккаунт уже настроен в тестовом окружении
        }
        
        when("я ввожу email \"ivan.petrov@company.ru\"") {
            LoginPage(app: app).enterEmail("ivan.petrov@company.ru")
        }
        
        when("я ввожу пароль \"SecurePass123!\"") {
            LoginPage(app: app).enterPassword("SecurePass123!")
        }
        
        when("я нажимаю кнопку \"Войти\"") {
            LoginPage(app: app).tapLoginButton()
        }
        
        then("я должен увидеть главную панель") {
            XCTAssertTrue(DashboardPage(app: app).waitForDisplay())
        }
        
        then("я должен увидеть приветственное сообщение \"Добро пожаловать, Иван!\"") {
            let welcomeLabel = app.staticTexts["welcomeLabel"]
            XCTAssertTrue(welcomeLabel.waitForExistence(timeout: 5))
            XCTAssertTrue(welcomeLabel.label.contains("Добро пожаловать, Иван!"))
        }
    }
    
    func testFailedLoginWithInvalidPassword() {
        // Сценарий: Неудачный вход с неверным паролем
        
        given("у меня есть корпоративный аккаунт") {
            // Настроено в тестовом окружении
        }
        
        when("я ввожу email \"ivan.petrov@company.ru\"") {
            LoginPage(app: app).enterEmail("ivan.petrov@company.ru")
        }
        
        when("я ввожу пароль \"НеверныйПароль\"") {
            LoginPage(app: app).enterPassword("НеверныйПароль")
        }
        
        when("я нажимаю кнопку \"Войти\"") {
            LoginPage(app: app).tapLoginButton()
        }
        
        then("я должен увидеть сообщение об ошибке \"Неверный email или пароль\"") {
            let errorLabel = app.staticTexts["errorLabel"]
            XCTAssertTrue(errorLabel.waitForExistence(timeout: 5))
            XCTAssertEqual(errorLabel.label, "Неверный email или пароль")
        }
        
        then("поле пароля должно быть очищено") {
            let passwordField = app.secureTextFields["passwordField"]
            XCTAssertEqual(passwordField.value as? String, "")
        }
    }
}
```

### 4. Page Objects для улучшения читаемости

```swift
// LMSUITests/Pages/LoginPage.swift
struct LoginPage {
    let app: XCUIApplication
    
    var isDisplayed: Bool {
        app.navigationBars["Вход в систему"].exists
    }
    
    func enterEmail(_ email: String) {
        let emailField = app.textFields["emailField"]
        emailField.tap()
        emailField.typeText(email)
    }
    
    func enterPassword(_ password: String) {
        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText(password)
    }
    
    func tapLoginButton() {
        app.buttons["Войти"].tap()
    }
}
```

## Автоматизация с Cucumberish (опционально)

Для полной автоматизации BDD можно использовать Cucumberish:

### 1. Установка через CocoaPods

```ruby
target 'LMSUITests' do
  pod 'Cucumberish'
end
```

### 2. Настройка Cucumberish

```swift
// LMSUITests/CucumberishInitializer.swift
import Foundation
import Cucumberish

@objc public class CucumberishInitializer: NSObject {
    
    @objc public class func setupCucumberish() {
        
        before { _ in
            // Настройка перед каждым сценарием
        }
        
        Given("^приложение LMS запущено$") { args, userInfo in
            // Реализация шага
        }
        
        When("^я ввожу email \"(.*)\"$") { args, userInfo in
            let email = args![0] as! String
            // Реализация шага
        }
        
        // Загружаем feature файлы
        let bundle = Bundle(for: CucumberishInitializer.self)
        Cucumberish.executeFeatures(
            inDirectory: "Features/BDD/Scenarios",
            from: bundle,
            includeTags: nil,
            excludeTags: nil
        )
    }
}
```

## Рекомендации по внедрению

### 1. Начните с критических сценариев
- Фокусируйтесь на @smoke и @critical тегах
- Покройте happy path для основных функций

### 2. Используйте data-driven подход
- Применяйте "Структура сценария" для похожих тестов
- Переиспользуйте шаги между сценариями

### 3. Поддерживайте синхронизацию
- Обновляйте feature файлы при изменении требований
- Держите step definitions актуальными

### 4. Интеграция в CI/CD
```yaml
- name: Run BDD Tests
  run: |
    xcodebuild test \
      -scheme LMSUITests \
      -testPlan BDDTests \
      -destination 'platform=iOS Simulator,name=iPhone 15' \
      -resultBundlePath BDDTestResults.xcresult
```

## Метрики и отчеты

### Генерация отчетов в Cucumber формате
```swift
// Добавьте в схему тестирования
-reporter cucumber:report.json
```

### Визуализация результатов
- Используйте Allure или другие инструменты
- Интегрируйте с системой отчетности компании

## Заключение

BDD подход позволяет:
- ✅ Улучшить коммуникацию между командами
- ✅ Создать живую документацию
- ✅ Повысить понимание требований
- ✅ Упростить регрессионное тестирование 