# Методики повышения качества тестов

**Дата**: 3 июля 2025  
**Автор**: AI Development Team  
**Sprint**: 28 (Technical Debt & Stabilization)

## 🎯 Что такое качественный тест?

Качественный тест должен быть:
- **F**ast (Быстрый)
- **I**ndependent (Независимый)
- **R**epeatable (Повторяемый)
- **S**elf-validating (Самопроверяющийся)
- **T**imely (Своевременный)

## 📊 Основные методики повышения качества

### 1. Test-Driven Development (TDD)

```swift
// ❌ Плохо: Тест после кода
func calculateDiscount(price: Double, discount: Double) -> Double {
    return price * (1 - discount)
}

// Тест написан после - может пропустить edge cases
func testDiscount() {
    XCTAssertEqual(calculateDiscount(100, 0.1), 90)
}

// ✅ Хорошо: TDD подход
// 1. Сначала пишем тест
func testDiscountHandlesNegativePrice() {
    XCTAssertThrows(calculateDiscount(-100, 0.1))
}

// 2. Тест падает (RED)
// 3. Пишем минимальный код для прохождения (GREEN)
// 4. Рефакторим (REFACTOR)
```

**Преимущества TDD:**
- Гарантирует тестируемость кода
- Выявляет проблемы дизайна рано
- Документирует поведение
- Предотвращает over-engineering

### 2. Behavior-Driven Development (BDD)

```gherkin
# ✅ BDD сценарий - понятен всем
Feature: User Authentication
  As a user
  I want to log in to the system
  So that I can access my personal content

  Scenario: Successful login with valid credentials
    Given I am on the login page
    When I enter "user@example.com" as email
    And I enter "validPassword123" as password
    And I click the login button
    Then I should be redirected to dashboard
    And I should see "Welcome back!" message
```

```swift
// Реализация BDD теста
func testSuccessfulLogin() {
    // Given
    let loginPage = LoginPage()
    
    // When
    loginPage.enterEmail("user@example.com")
    loginPage.enterPassword("validPassword123")
    loginPage.clickLogin()
    
    // Then
    XCTAssertEqual(app.currentPage, .dashboard)
    XCTAssertTrue(app.contains(text: "Welcome back!"))
}
```

### 3. Mutation Testing

```swift
// Исходный код
func isAdult(age: Int) -> Bool {
    return age >= 18  // Мутация: изменить на age > 18
}

// Обычный тест может пропустить граничный случай
func testIsAdult() {
    XCTAssertTrue(isAdult(20))   // Проходит с обеими версиями
    XCTAssertFalse(isAdult(16))  // Проходит с обеими версиями
}

// Mutation testing выявит пропущенный тест
func testIsAdultBoundary() {
    XCTAssertTrue(isAdult(18))   // Fail если age > 18
}
```

**Инструменты:**
- Swift: [Muter](https://github.com/muter-mutation-testing/muter)
- PHP: [Infection](https://infection.github.io/)

### 4. Property-Based Testing

```swift
// ❌ Традиционный подход - тестируем конкретные случаи
func testSortArray() {
    XCTAssertEqual(sort([3,1,2]), [1,2,3])
    XCTAssertEqual(sort([]), [])
    XCTAssertEqual(sort([1]), [1])
}

// ✅ Property-based - тестируем свойства
func testSortProperties() {
    // Свойство 1: Длина не меняется
    property("sorted array has same length") <- forAll { (array: [Int]) in
        return sort(array).count == array.count
    }
    
    // Свойство 2: Каждый элемент <= следующего
    property("elements are ordered") <- forAll { (array: [Int]) in
        let sorted = sort(array)
        return sorted.indices.dropLast().allSatisfy { i in
            sorted[i] <= sorted[i + 1]
        }
    }
    
    // Свойство 3: Идемпотентность
    property("sorting twice gives same result") <- forAll { (array: [Int]) in
        return sort(sort(array)) == sort(array)
    }
}
```

### 5. Contract Testing

```yaml
# API Contract (OpenAPI)
paths:
  /users/{id}:
    get:
      responses:
        200:
          content:
            application/json:
              schema:
                type: object
                required: [id, email, name]
                properties:
                  id: 
                    type: string
                  email: 
                    type: string
                    format: email
                  name: 
                    type: string
```

```swift
// Contract test
func testUserAPIContract() {
    // Provider test
    let response = api.getUser(id: "123")
    
    // Verify contract
    XCTAssertNotNil(response.id)
    XCTAssertTrue(response.email.isValidEmail())
    XCTAssertNotNil(response.name)
    
    // Consumer test
    let mockUser = User(id: "123", email: "test@test.com", name: "Test")
    XCTAssertNoThrow(try validator.validate(mockUser, against: contract))
}
```

### 6. Snapshot/Golden Testing

```swift
// UI Snapshot testing
func testLoginScreenLayout() {
    let loginView = LoginView()
    
    // Capture snapshot
    assertSnapshot(matching: loginView, as: .image(on: .iPhone13Pro))
    
    // Автоматически сравнивает с сохраненным эталоном
    // Fail если UI изменился
}

// JSON Response snapshot
func testAPIResponseFormat() {
    let response = api.fetchUserProfile()
    
    assertSnapshot(matching: response, as: .json)
}
```

### 7. Test Data Builders (Object Mother Pattern)

```swift
// ❌ Плохо: Дублирование setup кода
func testUserPermissions1() {
    let user = User(
        id: "123",
        email: "test@test.com",
        name: "Test User",
        role: "admin",
        department: "IT",
        isActive: true,
        createdAt: Date(),
        updatedAt: Date()
    )
    // ... test logic
}

// ✅ Хорошо: Test Data Builder
class UserBuilder {
    private var id = "test-id"
    private var email = "test@test.com"
    private var name = "Test User"
    private var role = "user"
    
    func withRole(_ role: String) -> UserBuilder {
        self.role = role
        return self
    }
    
    func withEmail(_ email: String) -> UserBuilder {
        self.email = email
        return self
    }
    
    func build() -> User {
        return User(id: id, email: email, name: name, role: role)
    }
}

// Использование
func testAdminPermissions() {
    let admin = UserBuilder()
        .withRole("admin")
        .build()
    
    XCTAssertTrue(admin.canManageUsers)
}
```

### 8. Test Pyramid vs Test Trophy

```
Traditional Test Pyramid:          Modern Test Trophy:
                                  
         /\                              ____
        /  \                            /    \
       / E2E\                          | E2E  |
      /______\                         |______|
     /        \                        /      \
    /   Integ  \                      |  Integ |
   /____________\                     |________|
  /              \                    /        \
 /      Unit      \                  |   Unit   |
/_________________\                  |__________|

Many unit tests                    Balanced approach
Few E2E tests                      More integration tests
```

### 9. Parameterized/Data-Driven Tests

```swift
// ❌ Плохо: Повторяющиеся тесты
func testEmailValidation1() {
    XCTAssertTrue(isValidEmail("user@example.com"))
}

func testEmailValidation2() {
    XCTAssertFalse(isValidEmail("invalid.email"))
}

func testEmailValidation3() {
    XCTAssertFalse(isValidEmail("@example.com"))
}

// ✅ Хорошо: Параметризованный тест
func testEmailValidation() {
    let testCases: [(email: String, isValid: Bool)] = [
        ("user@example.com", true),
        ("test.user@company.co.uk", true),
        ("invalid.email", false),
        ("@example.com", false),
        ("user@", false),
        ("", false)
    ]
    
    for testCase in testCases {
        XCTAssertEqual(
            isValidEmail(testCase.email),
            testCase.isValid,
            "Email '\(testCase.email)' validation failed"
        )
    }
}
```

### 10. Test Coverage Analysis

```bash
# Не просто процент, а качественный анализ

# 1. Line Coverage - базовый
xcrun xccov view --report coverage.xcresult

# 2. Branch Coverage - важнее
# Проверяет все условные переходы

# 3. Path Coverage - самый строгий
# Проверяет все возможные пути выполнения

# 4. Mutation Coverage - качество тестов
muter --output-xcode
```

## 🎯 Практические рекомендации для LMS

### 1. Начните с TDD для новых фич
```swift
// Sprint 29: Новая фича - уведомления
// 1. Пишем тест первым
func testNotificationSentOnCourseCompletion() {
    // Given
    let course = CourseBuilder().build()
    let student = UserBuilder().withRole("student").build()
    
    // When
    courseService.markAsCompleted(course, by: student)
    
    // Then
    XCTAssertEqual(notificationService.sentNotifications.count, 1)
    XCTAssertEqual(notificationService.lastNotification?.type, .courseCompleted)
}
```

### 2. Используйте BDD для критических user flows
```gherkin
Feature: Course Enrollment
  Scenario: Student enrolls in available course
    Given a course "iOS Development" with 5 available seats
    And I am logged in as a student
    When I click "Enroll" on the course page
    Then I should be enrolled in the course
    And available seats should decrease to 4
    And I should receive confirmation email
```

### 3. Snapshot testing для UI стабильности
```swift
func testCourseCardAppearance() {
    let card = CourseCard(
        title: "Test Course",
        instructor: "John Doe",
        duration: "4 weeks",
        enrolled: 25
    )
    
    assertSnapshot(matching: card, as: .image)
}
```

### 4. Contract testing для API
```swift
// Убедитесь что iOS и Backend синхронизированы
func testUserResponseContract() {
    let contract = try! OpenAPIContract(from: "user-api.yaml")
    let response = mockAPI.getUser()
    
    XCTAssertNoThrow(try contract.validate(response))
}
```

## 📈 Метрики качества тестов

### Хорошие метрики:
1. **Mutation Score** > 80% - тесты находят баги
2. **Test Execution Time** < 10 сек для unit тестов
3. **Flakiness Rate** < 1% - стабильные тесты
4. **Code Coverage** с фокусом на критический код

### Плохие метрики:
1. Только % покрытия без контекста
2. Количество тестов без учета качества
3. Покрытие UI кода unit тестами

## 🚀 План внедрения для Sprint 29

### Неделя 1: Основы
- [ ] Внедрить TDD для всех новых фич
- [ ] Настроить mutation testing
- [ ] Создать test data builders

### Неделя 2: Продвинутые техники
- [ ] Добавить BDD тесты для критических flows
- [ ] Внедрить snapshot testing для UI
- [ ] Настроить contract testing

### Неделя 3: Автоматизация
- [ ] CI/CD с quality gates
- [ ] Автоматические performance benchmarks
- [ ] Dashboard с метриками качества

## 📚 Рекомендуемые инструменты

### iOS:
- **Quick/Nimble** - BDD framework
- **SnapshotTesting** - Snapshot tests
- **SwiftCheck** - Property-based testing
- **Muter** - Mutation testing

### Backend (PHP):
- **PHPSpec** - BDD для PHP
- **Behat** - Cucumber для PHP
- **Infection** - Mutation testing
- **Pest** - Современный test runner

## 🎯 Ключевые выводы

1. **Качество > Количество** - 100 хороших тестов лучше 1000 плохих
2. **Тестируйте поведение, не реализацию**
3. **Используйте правильный тип теста для задачи**
4. **Автоматизируйте все что можно**
5. **Измеряйте и улучшайте постоянно**

**Помните**: Цель тестов - находить баги и давать уверенность в коде, а не достигать метрик! 