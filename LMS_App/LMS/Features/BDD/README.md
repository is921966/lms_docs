# 🥒 BDD (Behavior-Driven Development) в проекте LMS

## Что такое BDD?

BDD - это методология разработки, где поведение системы описывается на языке, понятном всем участникам процесса: разработчикам, тестировщикам, аналитикам и бизнесу.

## Структура BDD сценариев

### Feature файлы
Находятся в папке `Features/BDD/` и имеют расширение `.feature`

### Язык Gherkin
Используем **русский язык** для лучшего понимания бизнес-требований:

```gherkin
# language: ru
Функция: Название функциональности
  Как [роль]
  Я хочу [действие]
  Чтобы [бизнес-ценность]

  Сценарий: Конкретный кейс использования
    Дано [начальное состояние]
    Когда [действие пользователя]
    Тогда [ожидаемый результат]
```

## Созданные сценарии

### 1. CourseEnrollment.feature
**Покрывает**: Запись на курсы, отслеживание прогресса, получение сертификатов
**Сценарии**: 5
**Критичность**: Высокая

### 2. TestTaking.feature
**Покрывает**: Прохождение тестов, просмотр результатов, повторные попытки
**Сценарии**: 5
**Критичность**: Высокая

### 3. OnboardingProgram.feature
**Покрывает**: Автоматическое назначение, выполнение задач, отслеживание прогресса
**Сценарии**: 5
**Критичность**: Высокая

## Интеграция с существующими UI тестами

### Маппинг BDD шагов на UI тесты

```swift
// BDD Step Definition
func stepDefinition() {
    Given("я авторизован в системе как {string}") { userName in
        // Используем существующий LoginUITests
        loginHelper.performLogin(as: userName)
    }
    
    When("я нажимаю на курс {string}") { courseName in
        // Используем CourseEnrollmentUITests
        courseListPage.selectCourse(named: courseName)
    }
    
    Then("я вижу сообщение {string}") { message in
        XCTAssertTrue(app.alerts[message].exists)
    }
}
```

### Структура Page Objects для BDD

```swift
class CourseListPage {
    let app: XCUIApplication
    
    func selectCourse(named: String) {
        app.tables.cells.staticTexts[named].tap()
    }
    
    func getCourseStatus(for course: String) -> String {
        return app.tables.cells
            .containing(.staticText, identifier: course)
            .staticTexts
            .matching(identifier: "courseStatus")
            .firstMatch.label
    }
}
```

## Теги для организации тестов

- `@smoke` - Критические пути, запускаются при каждом билде
- `@critical` - Критичные для бизнеса сценарии
- `@nightly` - Полный набор тестов для ночных прогонов
- `@wip` - Work in progress, пропускаются в CI

## Запуск BDD тестов

### Локально
```bash
# Запуск всех BDD тестов
xcodebuild test -scheme LMS -testPlan BDDTests

# Запуск по тегу
xcodebuild test -scheme LMS -testPlan BDDTests -only-testing:LMSUITests/BDD/@smoke
```

### В CI/CD
```yaml
- name: Run BDD Tests
  run: |
    xcodebuild test \
      -scheme LMS \
      -destination 'platform=iOS Simulator,name=iPhone 15' \
      -testPlan BDDTests \
      -resultBundlePath TestResults/BDD.xcresult
```

## Отчеты

### Cucumber Reports
Генерируются автоматически после прогона:
- HTML отчет с графиками
- JSON для интеграции с другими инструментами
- Screenshots при падении тестов

### Живая документация
Feature файлы служат актуальной документацией системы и всегда синхронизированы с тестами.

## Best Practices

1. **Один сценарий = один бизнес-кейс**
2. **Используйте таблицы для данных**
3. **Избегайте технических деталей в сценариях**
4. **Переиспользуйте шаги между сценариями**
5. **Держите сценарии короткими (3-10 шагов)**

## Следующие шаги

1. Установить Cucumberish через SPM
2. Создать StepDefinitions.swift
3. Связать с существующими Page Objects
4. Настроить генерацию отчетов
5. Интегрировать в CI/CD pipeline 