# День 118 - Sprint 24, День 4/5 - Program Management Module

**Дата**: 2 июля 2025  
**Цель дня**: Завершить Application Layer и начать HTTP Layer

## 📋 План на день

### 1. Завершение Application Layer - Use Cases (2 часа)
- [ ] PublishProgramUseCase - публикация программы
- [ ] UpdateProgramUseCase - обновление программы
- [ ] GetProgramDetailsUseCase - получение деталей программы
- [ ] UpdateProgramRequest - валидация обновления

### 2. HTTP Layer - Controllers (1.5 часа)
- [ ] ProgramController - основной контроллер
- [ ] EnrollmentController - управление записями
- [ ] HTTP Request/Response классы

### 3. API Routes и Integration (1 час)
- [ ] Настройка маршрутов в config/routes/program.yaml
- [ ] Интеграция с DI контейнером
- [ ] Базовые интеграционные тесты

## 🎯 Acceptance Criteria

```gherkin
Feature: Program Management API

Scenario: Publish program
  Given программа в статусе draft с треками
  When POST /api/programs/{id}/publish
  Then программа переходит в статус active

Scenario: Enroll user
  Given активная программа
  When POST /api/programs/{id}/enroll
  Then создается запись о регистрации

Scenario: Get program details
  Given существующая программа
  When GET /api/programs/{id}
  Then возвращается полная информация с треками
```

## 📁 Структура файлов

```
src/Program/
├── Application/
│   ├── Requests/
│   │   └── UpdateProgramRequest.php (NEW)
│   └── UseCases/
│       ├── PublishProgramUseCase.php (NEW)
│       ├── UpdateProgramUseCase.php (NEW)
│       └── GetProgramDetailsUseCase.php (NEW)
└── Http/
    ├── Controllers/
    │   ├── ProgramController.php (NEW)
    │   └── EnrollmentController.php (NEW)
    ├── Requests/
    │   ├── CreateProgramHttpRequest.php (NEW)
    │   └── UpdateProgramHttpRequest.php (NEW)
    └── Responses/
        ├── ProgramResponse.php (NEW)
        └── EnrollmentResponse.php (NEW)
```

## ⚠️ Важные моменты

1. **PublishProgramUseCase**: проверка наличия треков обязательна
2. **UpdateProgramUseCase**: только draft программы можно обновлять
3. **HTTP валидация**: использовать Symfony Validator
4. **API версионирование**: /api/v1/programs

## 🏁 Цели дня

- ✅ Завершить все основные Use Cases
- ✅ Создать HTTP контроллеры
- ✅ Настроить API endpoints
- ✅ 150+ тестов для модуля 