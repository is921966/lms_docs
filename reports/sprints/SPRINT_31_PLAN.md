# Sprint 31 - Sprint Plan

**Sprint**: 31 - "100% Test Coverage и TestFlight"  
**Период**: 5-11 июля 2025  
**Продолжительность**: 5 дней  
**Цель**: Достичь 100% прохождения unit тестов и подготовить TestFlight

## 🎯 Цели спринта

### Priority 1: Завершить все тесты (КРИТИЧНО)
- [ ] Исправить оставшиеся 13 провалившихся тестов
- [ ] Достичь 100% прохождения unit тестов
- [ ] Увеличить покрытие кода до минимум 30%

### Priority 2: TestFlight
- [ ] Подготовить production сборку
- [ ] Настроить автоматический деплой
- [ ] Провести smoke тестирование
- [ ] Загрузить первую версию в TestFlight

### Priority 3: Документация
- [ ] Обновить README с инструкциями по запуску
- [ ] Создать CONTRIBUTING.md
- [ ] Документировать CI/CD процесс
- [ ] Обновить архитектурную документацию

## 📋 Детальный план по дням

### День 1 (5 июля) - Mock/Stub проблемы
- APIClientTests (5 тестов)
- RepositoryIntegrationTests (1 тест)
- Рефакторинг mock архитектуры

### День 2 (8 июля) - Value Objects
- ContactInfoTests (2 теста)
- LearningValuesTests (1 тест)
- UserResponseTests (1 тест)

### День 3 (9 июля) - Архитектурные проблемы
- AuthServiceDTOTests (1 тест)
- UserListViewModelTests (1 тест)
- EmailValidatorTests (1 тест)
- Финальный прогон всех тестов

### День 4 (10 июля) - TestFlight подготовка
- Production конфигурация
- Signing и provisioning
- Сборка и тестирование
- Загрузка в App Store Connect

### День 5 (11 июля) - Документация и релиз
- Обновление всей документации
- Release notes
- Распространение TestFlight ссылок
- Планирование следующего спринта

## 🚫 НЕ ДЕЛАТЬ

- ❌ НЕ начинать новые фичи
- ❌ НЕ игнорировать провалившиеся тесты
- ❌ НЕ использовать заглушки вместо правильных исправлений
- ❌ НЕ откладывать TestFlight "на потом"

## 📊 Критерии успеха

1. **100% unit тестов проходят** (223/223)
2. **Покрытие кода ≥ 30%**
3. **TestFlight build загружен**
4. **Вся документация обновлена**

## 🐛 Список тестов для исправления

1. **APIClientTests**:
   - testAPIRequestWith401Unauthorized
   - testAPIRequestWithNetworkError
   - testConcurrentRequests
   - testRequestCancellation
   - testSuccessfulAPIRequest

2. **Value Object тесты**:
   - ContactInfoTests.testEmailValidation
   - ContactInfoTests.testPhoneNumberEquality
   - LearningValuesTests.testCourseProgressCreation
   - UserResponseTests.testWhitespaceInNameHandling

3. **Архитектурные тесты**:
   - AuthServiceDTOTests.testInitialAuthenticationState
   - RepositoryIntegrationTests.testCachingBehavior
   - UserListViewModelTests.testCreateUser_ValidationError
   - EmailValidatorTests.testEmailValidation

## 📝 Примечания

- Это критически важный спринт для качества проекта
- После достижения 100% тестов можно будет уверенно добавлять новые фичи
- TestFlight позволит получить раннюю обратную связь от пользователей 