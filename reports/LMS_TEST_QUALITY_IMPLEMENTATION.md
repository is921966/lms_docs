# План внедрения методик качества тестов в LMS

**Дата**: 3 июля 2025  
**Sprint**: 28-29  
**Цель**: Повысить качество тестов с текущих 25% (iOS) и 85% (Backend) до оптимального уровня

## 🎯 Быстрые победы для Sprint 28 (оставшиеся 1.5 дня)

### 1. Внедрить Test Data Builders (2 часа)

#### iOS - UserBuilder
```swift
// LMS_App/LMS/LMSTests/Helpers/Builders/UserBuilder.swift
class UserBuilder {
    private var id = UUID().uuidString
    private var email = "test@lms.com"
    private var name = "Test User"
    private var role = "student"
    private var department: String? = nil
    private var isActive = true
    
    func withId(_ id: String) -> UserBuilder {
        self.id = id
        return self
    }
    
    func withEmail(_ email: String) -> UserBuilder {
        self.email = email
        return self
    }
    
    func asAdmin() -> UserBuilder {
        self.role = "admin"
        self.department = "IT"
        return self
    }
    
    func asStudent() -> UserBuilder {
        self.role = "student"
        return self
    }
    
    func asInstructor() -> UserBuilder {
        self.role = "instructor"
        self.department = "Education"
        return self
    }
    
    func inactive() -> UserBuilder {
        self.isActive = false
        return self
    }
    
    func build() -> UserResponse {
        return UserResponse(
            id: id,
            email: email,
            name: name,
            role: role,
            department: department,
            isActive: isActive,
            avatar: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// Использование в тестах
func testAdminCanManageUsers() {
    // Given
    let admin = UserBuilder().asAdmin().build()
    let student = UserBuilder().asStudent().build()
    
    // When
    let canManage = authService.canManageUser(admin, target: student)
    
    // Then
    XCTAssertTrue(canManage)
}
```

#### Backend - CourseBuilder
```php
// tests/Builders/CourseBuilder.php
class CourseBuilder
{
    private string $id;
    private string $title = 'Test Course';
    private string $description = 'Test Description';
    private int $duration = 30;
    private string $instructorId;
    private int $maxStudents = 30;
    private array $competencies = [];
    
    public function __construct()
    {
        $this->id = 'COURSE_' . uniqid();
        $this->instructorId = 'USER_' . uniqid();
    }
    
    public function withTitle(string $title): self
    {
        $this->title = $title;
        return $this;
    }
    
    public function withInstructor(User $instructor): self
    {
        $this->instructorId = $instructor->getId();
        return $this;
    }
    
    public function withCompetencies(array $competencies): self
    {
        $this->competencies = $competencies;
        return $this;
    }
    
    public function full(): self
    {
        $this->maxStudents = 0;
        return $this;
    }
    
    public function build(): Course
    {
        return new Course(
            CourseId::fromString($this->id),
            $this->title,
            $this->description,
            $this->duration,
            UserId::fromString($this->instructorId),
            $this->maxStudents,
            $this->competencies
        );
    }
}
```

### 2. Параметризованные тесты для критических функций (3 часа)

#### iOS - Email валидация
```swift
// LMSTests/Validators/EmailValidatorTests.swift
class EmailValidatorTests: XCTestCase {
    
    func testEmailValidation() {
        let testCases: [(email: String, isValid: Bool, description: String)] = [
            // Valid emails
            ("user@lms.com", true, "Simple valid email"),
            ("test.user@lms.com", true, "Email with dot"),
            ("user+tag@lms.com", true, "Email with plus"),
            ("user@sub.lms.com", true, "Subdomain"),
            
            // Invalid emails
            ("", false, "Empty string"),
            ("user", false, "No domain"),
            ("@lms.com", false, "No username"),
            ("user@", false, "No domain after @"),
            ("user @lms.com", false, "Space in email"),
            ("user@lms", false, "No TLD"),
            ("user@@lms.com", false, "Double @"),
            
            // Edge cases
            ("a@b.c", true, "Minimal valid email"),
            ("user@lms.co.uk", true, "Multiple TLD"),
            ("user@123.456.789.012", true, "IP address domain"),
            ("очень@длинный.email", true, "Unicode characters")
        ]
        
        for testCase in testCases {
            XCTAssertEqual(
                EmailValidator.isValid(testCase.email),
                testCase.isValid,
                "Failed for: \(testCase.description) - '\(testCase.email)'"
            )
        }
    }
}
```

#### Backend - Расчет прогресса компетенций
```php
// tests/Unit/Competency/Domain/CompetencyProgressCalculatorTest.php
class CompetencyProgressCalculatorTest extends TestCase
{
    /**
     * @dataProvider progressCalculationProvider
     */
    public function testProgressCalculation(
        int $currentLevel,
        int $targetLevel,
        array $completedCourses,
        array $requiredCourses,
        float $expectedProgress,
        string $description
    ): void {
        // Given
        $calculator = new CompetencyProgressCalculator();
        
        // When
        $progress = $calculator->calculate(
            $currentLevel,
            $targetLevel,
            $completedCourses,
            $requiredCourses
        );
        
        // Then
        $this->assertEquals(
            $expectedProgress,
            $progress,
            "Failed for: $description"
        );
    }
    
    public function progressCalculationProvider(): array
    {
        return [
            'no progress' => [1, 5, [], ['C1', 'C2', 'C3'], 0.0, 'No courses completed'],
            'half progress' => [1, 3, ['C1'], ['C1', 'C2'], 50.0, 'Half courses completed'],
            'full progress' => [1, 2, ['C1', 'C2'], ['C1', 'C2'], 100.0, 'All courses completed'],
            'over progress' => [3, 5, ['C1', 'C2', 'C3'], ['C1', 'C2'], 100.0, 'Extra courses completed'],
            'already achieved' => [5, 5, [], [], 100.0, 'Target already reached'],
            'invalid target' => [5, 3, [], [], 100.0, 'Current higher than target'],
        ];
    }
}
```

### 3. Mutation Testing Setup (2 часа)

#### iOS - Установка Muter
```bash
# 1. Установка
brew install muter-mutation-testing/formulae/muter

# 2. Конфигурация muter.conf.yml
cat > muter.conf.yml << 'EOF'
testCommandExecutable: xcodebuild
testCommandArguments:
  - -scheme
  - LMS
  - -destination
  - 'platform=iOS Simulator,name=iPhone 16 Pro'
  - test
mutationOperators:
  - RelationalOperatorReplacement
  - ConditionalBoundaryMutator
  - RemoveSideEffects
excludeList:
  - '**/*View.swift'
  - '**/*ViewController.swift'
  - '**/Assets.xcassets/**'
EOF

# 3. Запуск для критических компонентов
muter run --files-to-mutate "**/AuthService.swift" "**/APIClient.swift"
```

#### Backend - Infection для PHP
```bash
# 1. Установка
composer require --dev infection/infection

# 2. Конфигурация infection.json
cat > infection.json << 'EOF'
{
    "source": {
        "directories": [
            "src/User/Domain",
            "src/Competency/Domain",
            "src/Learning/Domain"
        ]
    },
    "logs": {
        "text": "infection.log",
        "html": "reports/infection.html"
    },
    "mutators": {
        "@default": true
    },
    "minMsi": 80,
    "minCoveredMsi": 90
}
EOF

# 3. Запуск
./vendor/bin/infection --threads=4
```

## 📋 План для Sprint 29 (5 дней)

### День 1: BDD для критических flows

#### Установка Cucumber для iOS
```bash
# 1. Добавить в Podfile
pod 'Cucumberish'

# 2. Создать Features/Authentication.feature
Feature: User Authentication
  As a user
  I want to log in to the LMS
  So that I can access my courses

  Background:
    Given the app is launched
    And I am on the login screen

  Scenario: Successful login as student
    When I enter "student@lms.com" as email
    And I enter "password123" as password
    And I tap the login button
    Then I should see the student dashboard
    And I should see "Welcome back!" message

  Scenario: Login with invalid credentials
    When I enter "invalid@lms.com" as email
    And I enter "wrongpassword" as password
    And I tap the login button
    Then I should see an error "Invalid credentials"
    And I should remain on the login screen

  Scenario: Login as admin shows admin panel
    When I enter "admin@lms.com" as email
    And I enter "adminpass" as password
    And I tap the login button
    Then I should see the admin dashboard
    And I should see the "Manage Users" option
```

### День 2: Snapshot Testing для UI

```swift
// 1. Установка
// Package.swift
dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.11.0")
]

// 2. Создание snapshot тестов
import SnapshotTesting
import XCTest
@testable import LMS

class CourseCardSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Записывать новые snapshots только при необходимости
        // isRecording = true
    }
    
    func testCourseCardStates() {
        let configurations: [(name: String, card: CourseCard)] = [
            ("default", CourseCard(
                course: CourseBuilder()
                    .withTitle("iOS Development")
                    .build()
            )),
            ("enrolled", CourseCard(
                course: CourseBuilder()
                    .withTitle("Swift Advanced")
                    .build(),
                isEnrolled: true
            )),
            ("completed", CourseCard(
                course: CourseBuilder()
                    .withTitle("UIKit Basics")
                    .build(),
                progress: 1.0
            )),
            ("in_progress", CourseCard(
                course: CourseBuilder()
                    .withTitle("SwiftUI")
                    .build(),
                progress: 0.65
            ))
        ]
        
        for config in configurations {
            assertSnapshot(
                matching: config.card,
                as: .image(on: .iPhone13Pro),
                named: config.name
            )
        }
    }
}
```

### День 3: Contract Testing

```swift
// 1. Создание контрактов
// Contracts/UserAPI.contract.swift
struct UserAPIContract {
    static let getUserResponse = """
    {
        "type": "object",
        "required": ["id", "email", "name", "role"],
        "properties": {
            "id": {"type": "string"},
            "email": {"type": "string", "format": "email"},
            "name": {"type": "string"},
            "role": {"type": "string", "enum": ["admin", "instructor", "student"]},
            "department": {"type": "string", "nullable": true},
            "isActive": {"type": "boolean"}
        }
    }
    """
}

// 2. Contract test
func testUserAPIContractCompliance() {
    // Given
    let mockResponse = mockAPI.getUser(id: "123")
    let validator = JSONSchemaValidator(schema: UserAPIContract.getUserResponse)
    
    // When/Then
    XCTAssertNoThrow(try validator.validate(mockResponse))
}
```

### День 4: Property-Based Testing

```swift
// Используем SwiftCheck
import SwiftCheck

class CompetencyLevelTests: XCTestCase {
    func testLevelProgressionProperties() {
        // Свойство 1: Прогресс всегда между 0 и 100
        property("progress is bounded") <- forAll { (current: Int, target: Int) in
            let progress = CompetencyCalculator.calculateProgress(
                current: abs(current) % 10,
                target: abs(target) % 10
            )
            return progress >= 0.0 && progress <= 100.0
        }
        
        // Свойство 2: Если current >= target, то progress = 100
        property("completion is recognized") <- forAll { (level: Int) in
            let safeLevel = abs(level) % 10
            let progress = CompetencyCalculator.calculateProgress(
                current: safeLevel,
                target: safeLevel
            )
            return progress == 100.0
        }
        
        // Свойство 3: Прогресс монотонно возрастает
        property("progress is monotonic") <- forAll { (target: Int) in
            let safeTarget = max(1, abs(target) % 10)
            var previousProgress = 0.0
            
            for current in 0...safeTarget {
                let progress = CompetencyCalculator.calculateProgress(
                    current: current,
                    target: safeTarget
                )
                if progress < previousProgress {
                    return false
                }
                previousProgress = progress
            }
            return true
        }
    }
}
```

### День 5: CI/CD Integration & Metrics

```yaml
# .github/workflows/test-quality.yml
name: Test Quality Checks

on: [push, pull_request]

jobs:
  ios-quality:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Tests with Coverage
        run: |
          xcodebuild test \
            -scheme LMS \
            -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
            -enableCodeCoverage YES \
            -resultBundlePath TestResults.xcresult
      
      - name: Generate Coverage Report
        run: |
          xcrun xccov view --report --json TestResults.xcresult > coverage.json
          
      - name: Run Mutation Testing
        run: |
          muter run --output-json
          
      - name: Check Quality Gates
        run: |
          python3 scripts/check_quality_gates.py \
            --coverage-min 70 \
            --mutation-score-min 60 \
            --test-time-max 300
            
  backend-quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Tests with Coverage
        run: |
          ./vendor/bin/phpunit --coverage-clover coverage.xml
          
      - name: Run Mutation Testing
        run: |
          ./vendor/bin/infection --min-msi=80
          
      - name: Run Static Analysis
        run: |
          ./vendor/bin/phpstan analyse --level=7
```

## 📊 Метрики успеха

### Sprint 28 (конец):
- ✅ Test builders созданы
- ✅ Параметризованные тесты для критических функций
- ✅ Mutation testing настроен
- ✅ iOS покрытие: 40-45% (рост с 25%)

### Sprint 29 (конец):
- ✅ BDD тесты для 5 критических flows
- ✅ Snapshot тесты для UI компонентов
- ✅ Contract тесты iOS <-> Backend
- ✅ Property-based тесты для алгоритмов
- ✅ CI/CD с quality gates
- ✅ iOS покрытие: 70-75%
- ✅ Mutation score: >60%

## 🎯 Ключевые выводы

1. **Начните с простого** - Test builders дают быстрый выигрыш
2. **Фокус на критическом** - Auth, Payments, Core Logic
3. **Автоматизируйте проверки** - CI/CD должен блокировать плохой код
4. **Измеряйте правильные метрики** - Mutation score > Coverage %
5. **Итеративное улучшение** - Не пытайтесь внедрить все сразу

**Результат**: За 6.5 дней можно существенно повысить качество тестов и создать фундамент для дальнейшего улучшения! 