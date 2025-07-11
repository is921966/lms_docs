# Sprint 28: Production Code Warnings

**Дата**: 3 июля 2025  
**Sprint**: 28, День 4/5  
**Статус**: Требует исправления в Sprint 29

## 📊 Общая статистика

- **Всего warnings**: 42
- **Критичность**: Низкая-Средняя
- **BUILD STATUS**: ✅ SUCCEEDED

## 🔍 Категории warnings

### 1. Immutable property decoding (8 warnings)
**Файлы**:
- Course.swift (7 warnings)
- OnboardingTemplate.swift (1)
- Certificate.swift (2)
- Report.swift (1)
- OnboardingProgram.swift (2)

**Проблема**: `immutable property will not be decoded because it is declared with an initial value`
**Решение**: Удалить default значения или сделать свойства `var`

### 2. Неиспользуемые переменные (10 warnings)
**Примеры**:
- `variable 'user' was never mutated; consider changing to 'let'`
- `value 'activeAttempt' was defined but never used`
- `initialization of immutable value 'issueNumber' was never used`

**Решение**: Заменить на `let` или удалить неиспользуемые переменные

### 3. Async/await warnings (5 warnings)
**Файлы**:
- FeedbackManager.swift (3)
- ServerFeedbackService.swift (3)
- DomainUserRepository.swift (2)

**Проблема**: `expression is 'async' but is not marked with 'await'`
**Решение**: Добавить `await` или убрать async

### 4. Deprecated API (3 warnings)
- `imageEdgeInsets` deprecated в iOS 15.0
- `onChange(of:perform:)` deprecated в iOS 17.0
- `NavigationLink(destination:isActive:label:)` deprecated в iOS 16.0

**Решение**: Использовать современные API

### 5. Nil coalescing с non-optional (3 warnings)
**Примеры**:
- `left side of nil coalescing operator '??' has non-optional type`

**Решение**: Убрать ненужный `??` оператор

## 🎯 Приоритеты исправления

### Высокий приоритет:
1. Async/await warnings - могут привести к runtime ошибкам
2. Deprecated API - подготовка к будущим версиям iOS

### Средний приоритет:
1. Неиспользуемые переменные - улучшение читаемости
2. Nil coalescing - упрощение кода

### Низкий приоритет:
1. Immutable property decoding - работает, но не оптимально

## 📝 План действий для Sprint 29

### Quick fixes (30 минут):
```swift
// Заменить var на let
var user = User() // ❌
let user = User() // ✅

// Убрать лишний ??
color ?? .blue // ❌ если color non-optional
color // ✅

// Добавить await
Task { sendFeedback() } // ❌
Task { await sendFeedback() } // ✅
```

### API updates (1 час):
```swift
// Старый onChange
.onChange(of: value) { newValue in } // ❌

// Новый onChange
.onChange(of: value) { oldValue, newValue in } // ✅

// Старый NavigationLink
NavigationLink(destination: View(), isActive: $active) // ❌

// Новый NavigationLink
NavigationLink(value: item) { View() } // ✅
```

## 💡 Автоматизация

Добавить в CI/CD:
```bash
# Проверка warnings
xcodebuild ... | grep -c "warning:" 

# Fail если warnings > threshold
if [ $WARNING_COUNT -gt 50 ]; then
  echo "Too many warnings: $WARNING_COUNT"
  exit 1
fi
```

## 📈 Метрики

| Тип warning | Количество | Время исправления |
|-------------|------------|-------------------|
| Immutable property | 13 | 15 мин |
| Unused variables | 10 | 10 мин |
| Async/await | 8 | 20 мин |
| Deprecated API | 3 | 30 мин |
| Nil coalescing | 3 | 5 мин |
| Other | 5 | 10 мин |
| **ИТОГО** | **42** | **~1.5 часа** |

---

**Рекомендация**: Выделить 2 часа в начале Sprint 29 для очистки всех warnings. 