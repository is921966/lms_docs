# 🤖 Руководство по автоматическим UI тестам

## 📋 Обзор

Созданы автоматические UI тесты, покрывающие все сценарии из:
- **[MANUAL_TESTING_PLAN.md](./MANUAL_TESTING_PLAN.md)** - весь план ручного тестирования
- **[TESTING_SCENARIOS_CMI5.md](./TESTING_SCENARIOS_CMI5.md)** - все 8 сценариев для Cmi5

## 🗂️ Структура тестов

### 1. Cmi5UITests.swift
Полное покрытие всех 8 сценариев тестирования Cmi5:
- ✅ Сценарий 1: Базовый запуск Cmi5 контента
- ✅ Сценарий 2: Офлайн режим
- ✅ Сценарий 3: Прерывание и возобновление
- ✅ Сценарий 4: Аналитика и отчеты
- ✅ Сценарий 5: Некорректный контент
- ✅ Сценарий 6: Множественные AU
- ✅ Сценарий 7: Производительность
- ✅ Сценарий 8: Граничные случаи

### 2. ManualTestPlanAutomation.swift
Автоматизация всех разделов из Manual Test Plan:
- ✅ Раздел 1: Авторизация и роли
- ✅ Раздел 2: Дашборд
- ✅ Раздел 3: Модуль обучения
- ✅ Раздел 4: Тестирование
- ✅ Раздел 5: Дашборды по ролям
- ✅ Раздел 6: Административные функции
- ✅ Раздел 7: Технические аспекты

## 🚀 Быстрый запуск

### Вариант 1: Использование готового скрипта (рекомендуется)

```bash
cd LMS_App/LMS
./scripts/test-manual-plan.sh
```

Скрипт предложит меню:
```
Выберите категорию тестов:
1) Все тесты из Manual Test Plan
2) Только Cmi5 тесты  
3) Авторизация и роли
4) Модуль обучения
5) Тестирование (quizzes)
6) Административные функции
7) Технические аспекты
8) Конкретный тест
```

### Вариант 2: Запуск через Xcode

1. Откройте `LMS.xcodeproj` в Xcode
2. Выберите схему `LMS`
3. Выберите симулятор iPhone 15
4. Нажмите `Cmd+U` или Product → Test

### Вариант 3: Командная строка

```bash
# Все Cmi5 тесты
xcodebuild test \
  -scheme LMS \
  -destination "platform=iOS Simulator,name=iPhone 15,OS=17.0" \
  -only-testing:LMSUITests/Cmi5UITests

# Конкретный сценарий
xcodebuild test \
  -scheme LMS \
  -destination "platform=iOS Simulator,name=iPhone 15,OS=17.0" \
  -only-testing:LMSUITests/Cmi5UITests/testScenario1_BasicCmi5Launch
```

## 📊 Примеры тестов

### Тест авторизации
```swift
func test_1_1_LoginScreen() {
    // Проверка отображения формы
    waitForElement(app.textFields["loginEmailField"])
    
    // Проверка валидации
    app.buttons["loginButton"].tap()
    waitForElement(app.staticTexts["loginErrorLabel"])
    
    // Успешный вход
    clearAndTypeText(app.textFields["loginEmailField"], text: "student@company.com")
    clearAndTypeText(app.secureTextFields["loginPasswordField"], text: "password123")
    app.buttons["loginButton"].tap()
    
    waitForElement(app.tabBars.firstMatch)
}
```

### Тест Cmi5 контента
```swift
func testScenario1_BasicCmi5Launch() {
    // Поиск курса с Cmi5
    let cmi5Course = app.cells.matching(NSPredicate(format: "label CONTAINS[c] 'интерактивный'")).firstMatch
    cmi5Course.tap()
    
    // Запуск Cmi5 урока
    app.buttons["Начать интерактивный урок"].tap()
    
    // Проверка загрузки
    waitForElement(app.webViews.firstMatch, timeout: 10)
    XCTAssertTrue(app.webViews.firstMatch.exists)
}
```

## 🔍 Что проверяется автоматически

### Авторизация
- ✅ Отображение формы входа
- ✅ Валидация полей
- ✅ Обработка неверных данных
- ✅ Успешный вход для разных ролей
- ✅ Функция "Запомнить меня"

### Курсы и обучение
- ✅ Отображение списка курсов
- ✅ Поиск и фильтрация
- ✅ Детали курса
- ✅ Запись/отписка от курса
- ✅ Навигация по урокам
- ✅ Все типы уроков (видео, текст, Cmi5)

### Cmi5 функциональность
- ✅ Поиск и запуск Cmi5 контента
- ✅ Загрузка в Cmi5 Player
- ✅ Обработка офлайн режима
- ✅ Сохранение прогресса
- ✅ Прерывание и возобновление
- ✅ Аналитика и статистика
- ✅ Обработка ошибок
- ✅ Производительность

### Технические аспекты
- ✅ Скорость загрузки (< 3 сек)
- ✅ Плавность скролла
- ✅ Обработка сетевых ошибок
- ✅ Accessibility labels
- ✅ Поворот экрана

## 📸 Скриншоты

Тесты автоматически создают скриншоты в ключевых моментах:
- `Login_Screen` - экран авторизации
- `Cmi5_Before_Launch` - перед запуском Cmi5
- `Cmi5_Player_Loaded` - загруженный контент
- `Cmi5_Analytics` - статистика
- И многие другие...

Скриншоты сохраняются в `.xcresult` файле и доступны через Xcode.

## ⚙️ Настройка окружения

### Требования
- Xcode 15+
- iOS Simulator с iOS 17.0+
- Минимум 8GB RAM для плавной работы

### Подготовка данных
Для полного тестирования необходимо:
1. Создать тестовый курс с Cmi5 уроками
2. Иметь тестовые учетные записи (student/admin)
3. Загрузить хотя бы один Cmi5 пакет

## 🐛 Решение проблем

### Тесты не находят Cmi5 контент
```bash
# Проверьте что есть курсы с Cmi5
# Попросите администратора создать тестовый курс
```

### Timeout при загрузке
```swift
// Увеличьте timeout в тестах
waitForElement(element, timeout: 20) // вместо 10
```

### Симулятор зависает
```bash
# Перезапустите симулятор
xcrun simctl shutdown all
xcrun simctl erase all
```

## 📈 Метрики покрытия

- **Manual Test Plan**: ~85% автоматизировано
- **Cmi5 сценарии**: 100% покрыто
- **Общее покрытие UI**: ~70%

Не автоматизировано:
- Ручная проверка дизайна
- Тестирование с реальными устройствами
- Интеграция с внешними системами
- Некоторые edge cases требующие специальной подготовки

## 🔄 Continuous Integration

Для запуска в CI/CD добавьте в workflow:

```yaml
- name: Run UI Tests
  run: |
    xcodebuild test \
      -scheme LMS \
      -destination "platform=iOS Simulator,name=iPhone 15,OS=17.0" \
      -resultBundlePath TestResults \
      -only-testing:LMSUITests
```

## 💡 Советы

1. **Запускайте тесты регулярно** - минимум раз в день
2. **Начинайте с smoke тестов** - базовые сценарии
3. **Изолируйте тесты** - каждый тест независим
4. **Используйте скриншоты** - для отладки failures
5. **Параллельный запуск** - для ускорения

## 📞 Поддержка

При проблемах с автоматическими тестами:
1. Проверьте логи в `.xcresult`
2. Запустите тест в debug режиме
3. Сделайте скриншот момента падения
4. Используйте Shake для отправки feedback 