# Sprint 30 - План

**Период**: 4-8 июля 2025  
**Цель**: Завершить исправление всех тестов и настроить CI/CD pipeline

## 🎯 Основные задачи

### Priority 1: Завершить исправление тестов (Must Have)

1. **Создать недостающие мапперы**:
   - [ ] UserMapper
   - [ ] UserProfileMapper  
   - [ ] CreateUserMapper
   - [ ] UpdateUserMapper

2. **Исправить оставшиеся тесты**:
   - [ ] UserDTOTests
   - [ ] TestBuildersExampleTests
   - [ ] EmailValidatorTests
   - [ ] DTOProtocolTests
   - [ ] UserListViewModelTests
   - [ ] APIClientIntegrationTests
   - [ ] OnboardingTests
   - [ ] AdminEditTests

### Priority 2: CI/CD Pipeline (Should Have)

1. **GitHub Actions для iOS**:
   - [ ] Workflow для build проверки
   - [ ] Автоматический запуск тестов
   - [ ] Отчеты о покрытии кода
   - [ ] Badge в README

2. **Pre-commit hooks**:
   - [ ] SwiftLint проверка
   - [ ] Запуск быстрых тестов
   - [ ] Проверка компиляции

### Priority 3: Качество кода (Nice to Have)

1. **Mutation Testing**:
   - [ ] Запустить muter на критических модулях
   - [ ] Анализ результатов
   - [ ] Улучшение тестов

2. **Performance Testing**:
   - [ ] Базовые performance тесты
   - [ ] Метрики производительности

## 📅 План по дням

### День 1 (4 июля) - Мапперы
- Создать все недостающие мапперы
- Написать тесты для мапперов
- Обновить UserDTOTests

### День 2 (5 июля) - Тесты часть 1
- EmailValidatorTests (параметризованные)
- TestBuildersExampleTests
- DTOProtocolTests

### День 3 (6 июля) - Тесты часть 2
- UserListViewModelTests
- APIClientIntegrationTests
- OnboardingTests
- AdminEditTests

### День 4 (7 июля) - CI/CD
- Настроить GitHub Actions
- Создать workflows
- Настроить badges

### День 5 (8 июля) - Финализация
- Полный прогон всех тестов
- Исправление найденных проблем
- Документация обновлений
- Mutation testing (если время позволит)

## 📊 Критерии успеха

1. **100% тестов компилируются и проходят**
2. **CI/CD pipeline работает автоматически**
3. **Code coverage > 80%**
4. **Документация обновлена**
5. **Нет критических TODO в коде**

## ⚠️ Риски

1. **Архитектурные изменения** - могут потребовать дополнительного рефакторинга
2. **Сложность CI/CD** - настройка может занять больше времени
3. **Неизвестные зависимости** - могут всплыть при исправлении тестов

## 📈 Ожидаемые результаты

- **Полностью рабочие тесты** - основа для дальнейшей разработки
- **Автоматизация проверок** - снижение риска регрессий
- **Готовность к production** - уверенность в качестве кода
- **Ускорение разработки** - быстрая обратная связь от CI/CD

## 🔄 Definition of Done

- [ ] Все unit тесты проходят локально
- [ ] CI/CD pipeline зеленый
- [ ] Code coverage > 80%
- [ ] Нет compiler warnings
- [ ] Документация обновлена
- [ ] Sprint review проведен 