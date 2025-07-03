# Sprint 28 - Technical Debt & Stabilization Checklist

**Sprint Duration**: День 134-138 (4-8 июля 2025)

## 📋 Pre-Sprint Checklist
- [ ] Все изменения из Sprint 27 закоммичены
- [ ] Создан branch `feature/sprint-28-stabilization`
- [ ] Обновлены все зависимости проекта
- [ ] Backup текущего состояния создан

## 🔧 День 134 - Восстановление компиляции

### Утро (2-3 часа)
- [ ] Запустить `xcodebuild` и зафиксировать все ошибки
- [ ] Создать список всех compilation errors
- [ ] Приоритизировать ошибки по критичности
- [ ] Начать с исправления import statements

### День (3-4 часа)
- [ ] Устранить все дубликаты типов:
  - [ ] TokenManager дубликаты
  - [ ] UserResponse дубликаты
  - [ ] ErrorResponse дубликаты
  - [ ] HTTPMethod дубликаты
- [ ] Проверить все target memberships
- [ ] Обновить build settings если нужно

### Вечер (1-2 часа)
- [ ] Запустить полную компиляцию
- [ ] Проверить сборку для симулятора
- [ ] Проверить сборку для устройства
- [ ] Запустить приложение и проверить launch
- [ ] Документировать все исправления

## 🔄 День 135 - Миграция сервисов

### LearningService Migration
- [ ] Создать LearningEndpoint.swift
- [ ] Создать LearningModels.swift
- [ ] Мигрировать LearningService на APIClient
- [ ] Создать MockLearningService
- [ ] Написать unit тесты для LearningService
- [ ] Обновить LearningViewModel

### ProgramService Migration
- [ ] Создать ProgramEndpoint.swift
- [ ] Создать ProgramModels.swift
- [ ] Мигрировать ProgramService на APIClient
- [ ] Создать MockProgramService
- [ ] Написать unit тесты для ProgramService
- [ ] Обновить ProgramViewModel

### NotificationService Migration
- [ ] Создать NotificationEndpoint.swift
- [ ] Создать NotificationModels.swift
- [ ] Мигрировать NotificationService на APIClient
- [ ] Создать MockNotificationService
- [ ] Написать unit тесты для NotificationService
- [ ] Обновить NotificationViewModel

### Cleanup
- [ ] Удалить старый NetworkService
- [ ] Удалить все Combine-based сервисы
- [ ] Проверить, что все ViewModels используют новые сервисы
- [ ] Запустить все тесты

## 📊 День 136 - Унификация моделей

### Model Audit
- [ ] Создать список всех моделей в проекте
- [ ] Идентифицировать дубликаты и конфликты
- [ ] Определить canonical версии моделей

### UserResponse Unification
- [ ] Решить конфликт name vs firstName/lastName:
  - [ ] Создать единую модель UserResponse
  - [ ] Добавить computed properties для совместимости
  - [ ] Создать migration helper
- [ ] Обновить все Views:
  - [ ] ProfileHeaderView
  - [ ] UserListView
  - [ ] AdminEditView
  - [ ] Другие затронутые Views

### Model Mappers
- [ ] Создать UserMapper для преобразований
- [ ] Создать CompetencyMapper
- [ ] Создать LearningMapper
- [ ] Покрыть mappers unit тестами

### Cleanup
- [ ] Удалить все устаревшие модели
- [ ] Обновить все импорты
- [ ] Проверить компиляцию
- [ ] Запустить приложение

## 🧪 День 137 - Интеграционные тесты

### Auth Integration Tests
- [ ] Test login flow с реальным API
- [ ] Test token refresh
- [ ] Test logout
- [ ] Test unauthorized access handling
- [ ] Test token persistence

### User Service Integration Tests
- [ ] Test user CRUD operations
- [ ] Test pagination
- [ ] Test filtering
- [ ] Test error handling
- [ ] Test offline mode

### Competency Integration Tests
- [ ] Test competency CRUD
- [ ] Test category management
- [ ] Test level management
- [ ] Test user assignments
- [ ] Test bulk operations

### UI Tests for Critical Flows
- [ ] Login → Dashboard flow
- [ ] User creation flow
- [ ] Competency assignment flow
- [ ] Profile update flow
- [ ] Logout flow

### CI Setup
- [ ] Создать test scheme для всех тестов
- [ ] Настроить GitHub Actions для тестов
- [ ] Добавить test coverage reporting
- [ ] Настроить автоматический запуск на PR

## 🚀 День 138 - Финальное тестирование

### End-to-End Testing
- [ ] Полный user journey от login до logout
- [ ] Все CRUD операции для каждого модуля
- [ ] Проверка всех edge cases
- [ ] Performance testing основных экранов
- [ ] Memory leak detection

### TestFlight Preparation
- [ ] Increment build number
- [ ] Update release notes
- [ ] Create archive
- [ ] Upload to App Store Connect
- [ ] Submit for TestFlight review

### Documentation Updates
- [ ] API Integration Guide
- [ ] Model Migration Guide
- [ ] Service Architecture Documentation
- [ ] Testing Guide
- [ ] Troubleshooting Guide

### Release Notes
- [ ] List all fixes from Sprint 28
- [ ] Highlight architecture improvements
- [ ] Note any breaking changes
- [ ] Add migration instructions
- [ ] Include known issues if any

### Final Checks
- [ ] All tests passing (100%)
- [ ] No compiler warnings
- [ ] No SwiftLint violations
- [ ] Documentation complete
- [ ] Code review completed

## 📊 Success Metrics
- [ ] Compilation: ✅ Successful
- [ ] Unit Tests: ✅ 100% passing
- [ ] Integration Tests: ✅ 20+ passing
- [ ] UI Tests: ✅ 10+ passing
- [ ] Code Coverage: ✅ >80%
- [ ] TestFlight Build: ✅ Uploaded
- [ ] Technical Debt: ✅ Resolved

## 🚨 Contingency Plans

### If compilation still fails by end of Day 134:
1. Focus on most critical errors only
2. Create workarounds for complex issues
3. Document remaining issues for next sprint

### If service migration takes longer:
1. Prioritize most used services
2. Keep hybrid approach temporarily
3. Complete migration in Sprint 29

### If tests reveal major issues:
1. Fix blockers only
2. Document non-critical issues
3. Plan fixes for Sprint 29

## ✅ Definition of Done
- [ ] iOS app compiles without errors
- [ ] All services use APIClient
- [ ] Models are unified across the app
- [ ] Integration tests created and passing
- [ ] TestFlight build available
- [ ] Zero critical bugs
- [ ] Documentation updated
- [ ] Sprint retrospective completed

## 📝 Notes
- Focus on stability over new features
- Document everything for future reference
- Communicate progress daily
- Ask for help if blocked
- Quality is the #1 priority 