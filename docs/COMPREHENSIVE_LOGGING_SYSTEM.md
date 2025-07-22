# Comprehensive Logging System для автоматизированного тестирования iOS

## Обзор

Система создана для решения проблемы отсутствия визуального доступа к экрану при автоматизированном тестировании. Детальное логирование компенсирует невозможность "видеть" экран, предоставляя полную информацию о состоянии приложения.

## Архитектура системы

### 1. ComprehensiveLogger
Центральный компонент системы логирования.

**Возможности:**
- Логирование по категориям (UI, Navigation, Network, Data, Performance, Error)
- Уровни логирования (Verbose, Debug, Info, Warning, Error)
- Автоматическое обогащение контекстом
- Сохранение в Core Data и файлы
- Экспорт в JSON/CSV

**Использование:**
```swift
ComprehensiveLogger.shared.log(.ui, .info, "Button tapped", details: [
    "buttonName": "Login",
    "view": "LoginView"
])
```

### 2. NavigationTracker
Отслеживает навигационный путь пользователя.

**Функции:**
- Tracking текущего экрана и модуля
- Поддержка навигационного стека
- Автоматическое логирование переходов

**Интеграция:**
```swift
YourView()
    .trackScreen("ScreenName", module: "ModuleName")
```

### 3. UIEventLogger
Специализированный логгер для UI событий.

**События:**
- Нажатия кнопок
- Ввод текста
- Выбор элементов списка
- Жесты и свайпы
- Состояния загрузки
- Ошибки

**Примеры:**
```swift
// Автоматическое логирование кнопки
Button("Login") {
    // action
}
.logButton("Login", in: "LoginView") {
    viewModel.login()
}

// Логирование текстового поля
TextField("Email", text: $email)
    .logTextField("email", in: "LoginView", text: $email)
```

### 4. Network Logging
Автоматическое логирование всех сетевых запросов.

**Информация:**
- URL, метод, заголовки
- Тело запроса и ответа
- Статус коды
- Время выполнения
- Ошибки

### 5. Automated Test Runner
Фреймворк для написания и выполнения тестов на основе логов.

**Возможности:**
- Декларативные тестовые сценарии
- Assertions на основе логов
- Timeout handling
- Детальные отчеты

**Пример теста:**
```swift
TestStep("Tap login button",
    action: {
        // Simulate button tap
        UIEventLogger.shared.logButtonTap("Login", in: "LoginView")
    },
    assertion: AutomatedTestRunner.assertButtonTapped("Login")
)
```

## Интеграция в приложение

### 1. Добавление логирования в View

```swift
struct MyView: View, LoggableView {
    var viewName: String { "MyView" }
    var moduleName: String { "MyModule" }
    
    func captureState() -> [String: Any] {
        // Return current view state
        [
            "isLoading": viewModel.isLoading,
            "itemCount": viewModel.items.count
        ]
    }
    
    var body: some View {
        VStack {
            // Your UI
        }
        .withAutoLogging() // Автоматическое логирование
    }
}
```

### 2. Логирование действий пользователя

```swift
Button("Save") {
    UIEventLogger.shared.logButtonTap("Save", in: viewName)
    viewModel.save()
}

TextField("Name", text: $name)
    .onChange(of: name) { old, new in
        UIEventLogger.shared.logTextInput("name", oldValue: old, newValue: new, in: viewName)
    }
```

### 3. Логирование навигации

```swift
NavigationLink(destination: DetailView()) {
    Text("Details")
}
.onTapGesture {
    NavigationTracker.shared.trackScreen("DetailView", module: "Details")
}
```

## Анализ логов

### Python скрипт analyze_app_logs.py

**Возможности:**
- Верификация login flow
- Анализ навигационного пути
- Извлечение метрик производительности
- Генерация отчетов

**Использование:**
```bash
# Полный анализ
python3 analyze_app_logs.py app_logs.json --test full --output report.md

# Проверка логина
python3 analyze_app_logs.py app_logs.json --test login --email test@tsum.ru

# Анализ конкретного View
python3 analyze_app_logs.py app_logs.json --view LoginView
```

## Написание автоматизированных тестов

### 1. Создание Test Suite

```swift
let suite = TestSuite()

suite.addTest("User Login Flow", steps: [
    TestStep("Navigate to Login",
        action: { NavigationTracker.shared.trackScreen("LoginView", module: "Auth") },
        assertion: AutomatedTestRunner.assertNavigatedTo("LoginView")
    ),
    
    TestStep("Enter credentials",
        action: {
            UIEventLogger.shared.logTextInput("email", oldValue: "", newValue: "test@tsum.ru", in: "LoginView")
            UIEventLogger.shared.logTextInput("password", oldValue: "", newValue: "***", in: "LoginView")
        },
        assertion: AutomatedTestRunner.assertTextEntered("email", value: "test@tsum.ru")
    ),
    
    TestStep("Submit login",
        action: {
            UIEventLogger.shared.logButtonTap("Login", in: "LoginView")
            // Simulate successful response
            MockNetworkLogger.logMockResponse("/api/login", 
                response: LoginResponse(token: "123"), 
                statusCode: 200
            )
        },
        assertion: AutomatedTestRunner.assertNetworkRequest("/api/login", statusCode: 200)
    )
])

// Run tests
Task {
    let results = await suite.runAll()
}
```

### 2. Custom Assertions

```swift
// Создание кастомной assertion
let customAssertion = TestAssertion("Custom check", timeout: 10.0) { log in
    log.category == .ui &&
    log.details["customField"] as? String == "expectedValue"
}
```

## Преимущества системы

1. **Полная видимость** - каждое действие и изменение состояния логируется
2. **Автоматизация тестов** - тесты могут выполняться без визуального доступа
3. **Отладка** - детальные логи помогают найти проблемы
4. **Метрики** - автоматический сбор performance данных
5. **Воспроизводимость** - можно воспроизвести путь пользователя

## Best Practices

1. **Логируйте ключевые действия** - все button taps, navigations, data changes
2. **Используйте контекст** - всегда указывайте view и module
3. **Структурированные данные** - используйте details dictionary
4. **Уровни логирования** - используйте правильные уровни (info для обычных событий, error для ошибок)
5. **Тестовые сценарии** - пишите тесты как user stories

## Пример полного сценария

```swift
// 1. Пользователь открывает приложение
NavigationTracker.shared.trackScreen("LoginView", module: "Auth")

// 2. Вводит email
UIEventLogger.shared.logTextInput("email", oldValue: "", newValue: "test@tsum.ru", in: "LoginView")

// 3. Вводит пароль
UIEventLogger.shared.logTextInput("password", oldValue: "", newValue: "***", in: "LoginView")

// 4. Нажимает Login
UIEventLogger.shared.logButtonTap("Login", in: "LoginView")

// 5. Отправляется запрос
ComprehensiveLogger.shared.logNetworkRequest(request, response: response, data: data, error: nil)

// 6. Переход на главный экран
NavigationTracker.shared.trackScreen("FeedView", module: "Feed")

// 7. Анализ результатов
python3 analyze_app_logs.py logs.json --test login --email test@tsum.ru
```

## Заключение

Эта система позволяет эффективно тестировать iOS приложение без визуального доступа к экрану. Детальное логирование предоставляет всю необходимую информацию для верификации корректности работы приложения. 