# 🎯 Рекомендации перед началом Sprint 28

**Дата**: 3 июля 2025  
**До начала Sprint 28**: < 12 часов

## ⚠️ Критическое состояние проекта

### Текущие проблемы:
1. **iOS приложение НЕ компилируется** - 10+ ошибок
2. **28 файлов не закоммичены** - нестабильное состояние git
3. **Модели несовместимы** - name vs firstName/lastName
4. **Сервисы частично мигрированы** - 3 из 7

## 🚨 ВАЖНЫЕ действия перед Sprint 28

### 1. Git состояние (СРОЧНО!)
```bash
# Вариант 1: Сохранить текущее состояние в отдельной ветке
git stash
git checkout -b backup/pre-sprint-28-state
git stash pop
git add .
git commit -m "Backup: состояние перед Sprint 28 - компиляция не работает"

# Вариант 2: Откатиться к стабильному состоянию
git reset --hard 9dc80a2  # Sprint 27 День 2
git checkout -b feature/sprint-28-stabilization
```

### 2. Подготовка окружения
- [ ] Очистить DerivedData в Xcode
- [ ] Удалить папку build
- [ ] Перезапустить Xcode
- [ ] Обновить CocoaPods если используются

### 3. Анализ проблем
Создайте файл `compilation_errors.txt`:
```bash
cd LMS_App/LMS
xcodebuild -scheme LMS clean build 2>&1 | grep "error:" > compilation_errors.txt
```

## 📋 Приоритеты День 1 (4 июля)

### Порядок исправлений:
1. **Дубликаты типов** (30 минут)
   - Удалить `LMS/Services/Network/Core/TokenManager.swift`
   - Проверить другие дубликаты

2. **Import statements** (30 минут)
   - Исправить все missing imports
   - Удалить неиспользуемые imports

3. **Model compatibility** (1 час)
   - Добавить extension для UserResponse
   - Создать migration helpers

4. **Service fixes** (2 часа)
   - Исправить hasValidTokens → hasValidTokens()
   - Обновить error handling

## 🔧 Quick Fixes для старта

### UserResponse compatibility:
```swift
// В файле UserResponse.swift добавить:
extension UserResponse {
    var firstName: String {
        name.components(separatedBy: " ").first ?? ""
    }
    
    var lastName: String {
        let components = name.components(separatedBy: " ")
        return components.count > 1 ? components.dropFirst().joined(separator: " ") : ""
    }
}
```

### TokenManager fix:
```swift
// В AuthService.swift изменить:
// Было: if tokenManager.hasValidTokens
// Стало: if tokenManager.hasValidTokens()
```

## 📊 Success Metrics для День 1

**Минимальный успех**:
- [ ] Проект компилируется (даже с warnings)
- [ ] Можно запустить на симуляторе
- [ ] Login экран открывается

**Хороший результат**:
- [ ] 0 ошибок компиляции
- [ ] < 10 warnings
- [ ] Основные экраны работают
- [ ] Можно залогиниться

**Отличный результат**:
- [ ] Все вышеперечисленное
- [ ] Unit тесты запускаются
- [ ] Создан план на День 2-5

## ⚡ Emergency План

Если к 12:00 компиляция не восстановлена:
1. **Откатиться к последней рабочей версии**
2. **Делать изменения меньшими шагами**
3. **Фокус только на критических ошибках**
4. **Отложить миграцию сервисов**

## 💡 Советы для успеха

1. **Коммитить часто** - после каждого исправления
2. **Тестировать инкрементально** - компилировать после каждого изменения
3. **Документировать решения** - для будущих спринтов
4. **Не добавлять новый функционал** - только исправления

## 📝 Чеклист готовности к Sprint 28

- [ ] Прочитаны все документы Sprint 28
- [ ] Git состояние стабилизировано
- [ ] Окружение подготовлено
- [ ] Список ошибок составлен
- [ ] Quick fixes понятны
- [ ] Emergency план готов

## 🚀 Мотивация

**Помните**: Sprint 28 - это не "починка сломанного", это **построение фундамента** для успешного релиза. После этой недели у вас будет:
- Стабильное приложение
- Чистая архитектура
- Работающие тесты
- Уверенность в качестве

**Удачи! Sprint 28 начинается завтра в 09:00!** 🎯

---

*Документ создан: 3 июля 2025, 20:00* 