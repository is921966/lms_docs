# 🚀 UI Testing Quick Start Guide

## Быстрый запуск за 2 минуты

### 1️⃣ Первый запуск
```bash
cd LMS_App/LMS
./setup-ui-testing.sh  # Только первый раз
```

### 2️⃣ Запуск тестов

#### Быстрый тест (рекомендуется)
```bash
# Один конкретный тест (3-5 секунд)
./test-quick-ui.sh SimpleSmokeTest/testAppLaunches

# Или любой другой тест
./test-quick-ui.sh AdaptedUITests/test001_AppLaunchesSuccessfully
```

#### Полный прогон
```bash
# Все тесты (~2 минуты)
./test-ui.sh
```

### 3️⃣ Написание нового теста

1. Создайте файл в `LMSUITests/`:
```swift
import XCTest

final class MyNewTest: XCTestCase {
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Ваш тест
        XCTAssertTrue(app.buttons["Обучение"].exists)
    }
}
```

2. Запустите его:
```bash
./test-quick-ui.sh MyNewTest/testExample
```

## 📋 Основные команды

| Команда | Описание | Время |
|---------|----------|-------|
| `./test-quick-ui.sh TestName/testMethod` | Один тест | 3-5 сек |
| `./test-ui.sh` | Все тесты | ~2 мин |
| `./test-ui.sh -v` | С подробным выводом | ~2 мин |
| `./run-ui-tests.sh --device "iPhone 15"` | На конкретном устройстве | Варьируется |

## ✅ Текущие рабочие тесты

### SimpleSmokeTest
- ✅ `testAppLaunches` - Приложение запускается

### AdaptedUITests  
- ✅ `test001_AppLaunchesSuccessfully` - Запуск приложения
- ✅ `test005_LearningTabContent` - Вкладка обучения
- ✅ `test007_ProfileTab` - Вкладка профиля
- ✅ `test008_MoreTab` - Вкладка "Ещё"

### QuickStateTest
- ✅ `testQuickCheck` - Быстрая проверка состояния

## 🔧 Решение проблем

### Тесты не запускаются
```bash
# Перезапустите симулятор
xcrun simctl shutdown all
xcrun simctl boot "iPhone 16"
```

### Тесты проваливаются
1. Проверьте, что приложение в режиме разработки
2. Убедитесь, что используете mock данные
3. Добавьте `sleep(2)` после навигации

### Не находит UI элементы
```swift
// Добавьте accessibility identifier
button.accessibilityIdentifier = "myButton"

// В тесте
app.buttons["myButton"].tap()
```

## 📝 Best Practices

1. **Всегда запускайте тест сразу после написания**
   ```bash
   ./test-quick-ui.sh YourTest/yourMethod
   ```

2. **Используйте waitForExistence для динамических элементов**
   ```swift
   let button = app.buttons["Login"]
   XCTAssertTrue(button.waitForExistence(timeout: 5))
   ```

3. **Делайте скриншоты для отладки**
   ```swift
   let screenshot = app.screenshot()
   add(XCTAttachment(screenshot: screenshot))
   ```

4. **Группируйте тесты по функциональности**
   - AuthTests - для аутентификации
   - LearningTests - для обучения
   - ProfileTests - для профиля

## 🎯 Цель: 95% проходящих тестов

Текущий статус: **56%** ➡️ Цель: **95%**

Помогите достичь цели:
1. Исправляйте красные тесты
2. Добавляйте новые тесты для новых функций
3. Улучшайте стабильность существующих тестов

---

**Вопросы?** Смотрите полную документацию в `UI_TESTING_GUIDE.md` 