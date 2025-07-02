# Sprint 20 Plan: Завершение User Management модуля

**Sprint**: 20
**Даты**: День 96-100 (условные), календарные дни 11-15
**Цель**: Полная реализация User Management с Domain, Application, Infrastructure и HTTP слоями

## 🎯 Цели спринта

1. **Завершить Application слой** для User модуля
2. **Реализовать Infrastructure слой** с репозиториями и маппингами
3. **Создать HTTP контроллеры** согласно OpenAPI спецификации
4. **Написать интеграционные тесты** для всех слоев
5. **Обновить документацию** API и архитектуры

## 📋 User Stories

### Story 1: Управление пользователями через API
**Как** администратор системы
**Я хочу** управлять пользователями через REST API
**Чтобы** создавать, обновлять и удалять учетные записи

#### Acceptance Criteria:
```gherkin
Feature: User Management API

Scenario: Create new user
  Given I am authenticated as admin
  When I send POST to /api/users with valid data
  Then user should be created
  And I should receive 201 status
  And response should contain user details

Scenario: Update user
  Given existing user with ID "123"
  When I send PUT to /api/users/123 with updated data
  Then user should be updated
  And I should receive 200 status

Scenario: Delete user
  Given existing user with ID "123"
  When I send DELETE to /api/users/123
  Then user should be soft deleted
  And I should receive 204 status
```

## 📅 План по дням

### День 96 (✅ Завершен)
- ✅ Исправление namespace в User Domain
- ✅ Создание UserCreateHandler в Application слое
- ✅ Создание DTO для запросов и ответов
- ✅ Unit-тесты для Application слоя

### День 97 (Сегодня)
- [ ] Создать оставшиеся handlers в Application слое:
  - [ ] UserUpdateHandler
  - [ ] UserDeleteHandler
  - [ ] UserQueryHandler
- [ ] Создать соответствующие DTO
- [ ] Написать unit-тесты для всех handlers

### День 98
- [ ] Реализовать Infrastructure слой:
  - [ ] MySQLUserRepository
  - [ ] Doctrine Entity mappings
  - [ ] Миграции базы данных
- [ ] Написать интеграционные тесты для репозитория

### День 99
- [ ] Создать HTTP контроллеры:
  - [ ] UserController с CRUD операциями
  - [ ] Middleware для аутентификации
  - [ ] Request validation
- [ ] Написать функциональные тесты для API

### День 100
- [ ] Финальная интеграция и тестирование
- [ ] Обновить OpenAPI документацию
- [ ] Провести code review
- [ ] Подготовить отчет о завершении

## 🏗️ Техническая архитектура

### Application Layer Structure:
```
src/User/Application/
├── Commands/
│   ├── CreateUser/
│   │   ├── CreateUserCommand.php
│   │   └── CreateUserHandler.php
│   ├── UpdateUser/
│   │   ├── UpdateUserCommand.php
│   │   └── UpdateUserHandler.php
│   └── DeleteUser/
│       ├── DeleteUserCommand.php
│       └── DeleteUserHandler.php
├── Queries/
│   ├── GetUser/
│   │   ├── GetUserQuery.php
│   │   └── GetUserHandler.php
│   └── ListUsers/
│       ├── ListUsersQuery.php
│       └── ListUsersHandler.php
└── DTO/
    ├── UserCreateRequest.php
    ├── UserCreateResponse.php
    ├── UserUpdateRequest.php
    └── UserListResponse.php
```

## 📊 Definition of Done

- [ ] Все unit-тесты проходят (coverage > 80%)
- [ ] Интеграционные тесты проходят
- [ ] API соответствует OpenAPI спецификации
- [ ] Код прошел статический анализ (PHPStan level 8)
- [ ] Документация обновлена
- [ ] Performance тесты показывают < 100ms response time

## 🚀 Риски и митигация

1. **Риск**: Сложность интеграции с существующей БД
   **Митигация**: Использовать миграции и тестовую БД

2. **Риск**: Конфликты с legacy кодом
   **Митигация**: Изолировать новый код через интерфейсы

3. **Риск**: Performance при большом количестве пользователей
   **Митигация**: Добавить пагинацию и кеширование

---
*План создан согласно методологии TDD и DDD* 