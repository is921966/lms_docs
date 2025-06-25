# UI Testing Guide для LMS iOS App

## 📱 Обзор

Приложение LMS использует XCUITest для автоматического тестирования пользовательского интерфейса. Все критические пользовательские сценарии покрыты автоматическими тестами.

## 🧪 Структура тестов

### Основные тестовые файлы:
- `LMSUITests.swift` - основные тесты навигации и функциональности
- `LessonUITests.swift` - тесты для уроков и обучения

### Покрытие тестами:
- ✅ Авторизация (студент/администратор)
- ✅ Навигация по приложению
- ✅ Список курсов и поиск
- ✅ Детали курса и модули
- ✅ Прохождение уроков
- ✅ Профиль пользователя
- ✅ Админ-панель

## 🚀 Запуск тестов

### Локально через Xcode:
```bash
# Открыть проект
open LMS.xcodeproj

# Запустить все UI тесты: Cmd+U
# Или выбрать схему LMSUITests и нажать Play
```

### Через командную строку:
```bash
# Запустить все UI тесты
./run-ui-tests.sh

# Запустить конкретный тест
xcodebuild test \
  -scheme LMS \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:LMSUITests/LMSUITests/testMockLogin_AsStudent_ShouldSucceed
```

## 🔄 Автоматический запуск

### Pre-commit hook:
Тесты автоматически запускаются перед каждым коммитом. Если тесты не проходят, коммит будет отменен.

### GitHub Actions:
При каждом push в master или создании PR автоматически запускаются UI тесты в CI/CD.

## 📝 Написание новых тестов

### Базовая структура теста:
```swift
func testFeatureName_WhenCondition_ShouldExpectedBehavior() throws {
    // Given - подготовка
    let element = app.buttons["ButtonIdentifier"]
    
    // When - действие
    element.tap()
    
    // Then - проверка
    XCTAssertTrue(app.staticTexts["Expected Text"].exists)
}
```

### Лучшие практики:
1. **Используйте Accessibility Identifiers** для надежного поиска элементов
2. **Добавляйте ожидания** для асинхронных операций:
   ```swift
   XCTAssertTrue(element.waitForExistence(timeout: 5))
   ```
3. **Изолируйте тесты** - каждый тест должен быть независимым
4. **Используйте helper методы** для повторяющихся действий

## 🏷️ Accessibility Identifiers

### Установка в коде:
```swift
Button("Login") {
    // action
}
.accessibilityIdentifier("loginButton")
```

### Существующие идентификаторы:
- `loginAsStudent` - кнопка входа как студент
- `loginAsAdmin` - кнопка входа как администратор
- Остальные элементы находятся по тексту

## 🐛 Отладка тестов

### Просмотр иерархии элементов:
```swift
// В тесте добавить:
print(app.debugDescription)
```

### Скриншоты при ошибках:
```swift
// Автоматически создаются при провале теста
// Находятся в Test Report
```

### Запись UI теста:
1. Поставить курсор в тестовый метод
2. Нажать красную кнопку записи в Xcode
3. Выполнить действия в симуляторе
4. Отредактировать записанный код

## 📊 Метрики

### Время выполнения:
- Полный набор тестов: ~2-3 минуты
- Отдельный тест: 10-30 секунд

### Покрытие:
- Основные user flows: 100%
- Edge cases: ~70%

## 🔧 Troubleshooting

### Тест не находит элемент:
1. Проверить, что элемент действительно на экране
2. Добавить waitForExistence
3. Проверить accessibility identifier

### Тесты проходят локально, но не в CI:
1. Проверить версию Xcode
2. Проверить версию симулятора
3. Добавить больше времени ожидания

### Симулятор не запускается:
```bash
# Сбросить симулятор
xcrun simctl erase all

# Пересоздать симулятор
xcrun simctl create "iPhone 16" "iPhone 16" iOS18.2
```

## 📚 Полезные ссылки

- [Apple UI Testing Guide](https://developer.apple.com/documentation/xctest/user_interface_tests)
- [XCUITest Cheat Sheet](https://www.hackingwithswift.com/articles/148/xcode-ui-testing-cheat-sheet)
- [Best Practices](https://developer.apple.com/videos/play/wwdc2023/10037/) 