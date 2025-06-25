# Настройка автоматического UI тестирования для iOS LMS App

## 📱 Обзор

Проект настроен для автоматического запуска UI тестов перед каждым коммитом используя нативные iOS инструменты.

## 🛠 Используемые технологии

1. **XCUITest** - нативный фреймворк Apple для UI тестирования
2. **Git Hooks** - для автоматического запуска перед коммитом
3. **GitHub Actions** - для CI/CD пайплайна

## 📋 Структура тестов

```
LMSUITests/
├── LMSUITests.swift          # Основные тесты навигации и функциональности
├── LessonUITests.swift       # Тесты для уроков и обучения
└── LMSUITestsLaunchTests.swift # Тесты запуска приложения
```

## 🚀 Быстрый старт

### 1. Локальный запуск тестов

```bash
# Простой запуск
./test-ui.sh

# Запуск конкретного теста
xcodebuild test -scheme LMS \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:LMSUITests/LMSUITests/testMockLogin_AsStudent_ShouldSucceed
```

### 2. Настройка pre-commit hook

```bash
# Установка pre-commit (если не установлен)
brew install pre-commit

# Активация hooks
pre-commit install

# Теперь тесты будут запускаться автоматически перед коммитом
```

### 3. Ручная настройка Git Hook (альтернатива)

```bash
# Создаем hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Проверяем, есть ли изменения в iOS файлах
if git diff --cached --name-only | grep -E '\.(swift|xib|storyboard)$' > /dev/null; then
    echo "🧪 Запуск UI тестов..."
    
    cd LMS_App/LMS
    if ./test-ui.sh; then
        echo "✅ Тесты прошли!"
        exit 0
    else
        echo "❌ Тесты не прошли! Исправьте ошибки перед коммитом."
        exit 1
    fi
fi

exit 0
EOF

# Делаем исполняемым
chmod +x .git/hooks/pre-commit
```

## 📊 Покрытие тестами

### Текущее покрытие:
- ✅ Авторизация (mock login)
- ✅ Навигация по табам
- ✅ Список курсов и поиск
- ✅ Детали курса
- ✅ Профиль пользователя
- ✅ Админ панель
- ✅ Навигация по урокам
- ✅ Прохождение тестов

### Планируется добавить:
- 🔲 Офлайн режим
- 🔲 Синхронизация данных
- 🔲 Push уведомления
- 🔲 Интеграция с VK ID (когда будет настроено)

## 🐛 Решение проблем

### Тесты не запускаются

1. Убедитесь что симулятор iPhone 16 существует:
```bash
xcrun simctl list devices | grep "iPhone 16"
```

2. Если нет, создайте:
```bash
xcrun simctl create "iPhone 16" "iPhone 16" iOS18.2
```

### Тесты медленно работают

1. Закройте лишние симуляторы:
```bash
xcrun simctl shutdown all
```

2. Очистите кеш:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Элемент не найден в тесте

1. Проверьте accessibility identifier:
```swift
.accessibilityIdentifier("myButton")
```

2. Добавьте ожидание:
```swift
XCTAssertTrue(element.waitForExistence(timeout: 5))
```

## 🔧 Настройки CI/CD

GitHub Actions автоматически запускает тесты при:
- Push в master или develop
- Создании Pull Request

Файл конфигурации: `.github/workflows/ios-ui-tests.yml`

## 📈 Метрики производительности

Целевые показатели:
- Время выполнения всех тестов: < 3 минут
- Время выполнения одного теста: < 30 секунд
- Стабильность: 0% flaky тестов

## 🎯 Best Practices

1. **Изолируйте тесты** - каждый тест должен быть независимым
2. **Используйте Page Object Pattern** для сложных экранов
3. **Не используйте sleep()** - используйте waitForExistence
4. **Тестируйте только UI** - бизнес логику тестируйте unit тестами
5. **Поддерживайте тесты** - обновляйте при изменении UI

## 📚 Полезные ресурсы

- [Apple UI Testing Guide](https://developer.apple.com/documentation/xctest/user_interface_tests)
- [WWDC Testing Videos](https://developer.apple.com/videos/frameworks/testing)
- [XCUITest Cheat Sheet](https://www.hackingwithswift.com/articles/148/xcode-ui-testing-cheat-sheet)

## 🤝 Вклад в тесты

При добавлении новой функциональности:
1. Добавьте UI тест для основного сценария
2. Добавьте тест для edge cases
3. Обновите этот документ с новым покрытием
4. Убедитесь что тесты проходят локально

---

**Помните**: Автоматические тесты - это инвестиция в качество продукта. Поддерживайте их в актуальном состоянии! 