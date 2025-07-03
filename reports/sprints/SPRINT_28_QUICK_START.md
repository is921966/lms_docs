# Sprint 28 - Quick Start Guide

## 🚀 День 134 (4 июля) - СТАРТ

### Первые шаги (30 минут)
```bash
# 1. Создать branch
git checkout -b feature/sprint-28-stabilization

# 2. Проверить текущее состояние компиляции
cd LMS_App/LMS
xcodebuild -scheme LMS -destination 'generic/platform=iOS' clean build 2>&1 | tee compilation_errors.log

# 3. Создать список ошибок
grep "error:" compilation_errors.log > errors_list.txt
```

### Приоритетные исправления
1. **Import errors** - исправить первыми
2. **Duplicate types** - удалить дубликаты
3. **Type mismatches** - обновить использование
4. **Missing files** - проверить пути

### Критические файлы для проверки
- `TokenManager.swift` - дубликаты
- `UserResponse.swift` - конфликт name vs firstName/lastName
- `NetworkError.swift` - изменения в enum cases
- `AuthService.swift` - hasValidTokens() метод

## 🔧 Полезные команды

### Поиск дубликатов
```bash
# Найти все файлы с TokenManager
find . -name "*.swift" -exec grep -l "class TokenManager\|struct TokenManager" {} \;

# Найти все UserResponse определения
grep -r "struct UserResponse" --include="*.swift" .
```

### Быстрая компиляция
```bash
# Только build без тестов
xcodebuild -scheme LMS -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15' build

# С verbose output для отладки
xcodebuild -scheme LMS -configuration Debug -verbose build
```

### Проверка конкретного файла
```bash
# Компилировать только один файл
swiftc -parse LMS/Services/AuthService.swift
```

## 📝 Чеклист первого дня

- [ ] Branch создан
- [ ] Ошибки компиляции собраны
- [ ] Дубликаты типов идентифицированы
- [ ] Import statements исправлены
- [ ] Базовая компиляция проходит

## 🚨 Если застряли

1. **Слишком много ошибок?**
   - Фокус на одном модуле за раз
   - Начните с AuthService

2. **Непонятные ошибки?**
   - Clean build folder: Cmd+Shift+K
   - Delete DerivedData
   - Restart Xcode

3. **Конфликты моделей?**
   - Временно закомментируйте проблемный код
   - Исправьте по одному конфликту

## 💡 Быстрые wins

1. Удалить `LMS/Services/Network/Core/TokenManager.swift` (дубликат)
2. В `AuthService.swift` изменить `hasValidTokens` на `hasValidTokens()`
3. В `UserResponse` добавить computed properties:
```swift
extension UserResponse {
    var firstName: String {
        return name.components(separatedBy: " ").first ?? ""
    }
    
    var lastName: String {
        let components = name.components(separatedBy: " ")
        return components.count > 1 ? components.dropFirst().joined(separator: " ") : ""
    }
}
```

## 📊 Цель дня 134

**К концу дня должно быть:**
- ✅ Проект компилируется
- ✅ Можно запустить на симуляторе
- ✅ Основные экраны открываются
- ✅ Список оставшихся задач составлен

---

**Помните**: Цель Sprint 28 - стабильность, а не новые фичи! 