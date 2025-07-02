# День 116 - Sprint 24, День 2/5 - Program Management Module

**Дата**: 2 июля 2025  
**Цель дня**: Завершить Domain Layer и начать Application Layer

## 📋 План на день

### 1. Завершение Domain Layer (2 часа)
- [ ] ProgramEnrollment entity - запись пользователя на программу
- [ ] TrackProgress entity - прогресс по треку
- [ ] Domain Events:
  - [ ] TrackAdded
  - [ ] ProgramPublished 
  - [ ] UserEnrolledInProgram
- [ ] Repository interfaces:
  - [ ] ProgramRepositoryInterface
  - [ ] TrackRepositoryInterface
  - [ ] ProgramEnrollmentRepositoryInterface

### 2. Application Layer - DTO (1 час)
- [ ] ProgramDTO
- [ ] TrackDTO
- [ ] ProgramEnrollmentDTO
- [ ] CreateProgramRequest
- [ ] UpdateProgramRequest
- [ ] EnrollUserRequest

### 3. Application Layer - Use Cases (2 часа)
- [ ] CreateProgramUseCase
- [ ] UpdateProgramUseCase
- [ ] PublishProgramUseCase
- [ ] EnrollUserUseCase
- [ ] GetProgramDetailsUseCase

## 🎯 Acceptance Criteria

```gherkin
Given пользователь записывается на программу
When создается ProgramEnrollment
Then отслеживается прогресс по всем трекам

Given программа готова к публикации
When программа имеет треки и курсы
Then она может быть опубликована

Given пользователь проходит трек
When завершены все обязательные курсы
Then трек считается завершенным
```

## 📁 Структура файлов

```
src/Program/
├── Domain/
│   ├── ProgramEnrollment.php (NEW)
│   ├── TrackProgress.php (NEW)
│   ├── Events/
│   │   ├── TrackAdded.php (NEW)
│   │   ├── ProgramPublished.php (NEW)
│   │   └── UserEnrolledInProgram.php (NEW)
│   └── Repository/
│       ├── ProgramRepositoryInterface.php (NEW)
│       ├── TrackRepositoryInterface.php (NEW)
│       └── ProgramEnrollmentRepositoryInterface.php (NEW)
└── Application/
    ├── DTO/
    │   ├── ProgramDTO.php (NEW)
    │   ├── TrackDTO.php (NEW)
    │   └── ProgramEnrollmentDTO.php (NEW)
    ├── Requests/
    │   ├── CreateProgramRequest.php (NEW)
    │   ├── UpdateProgramRequest.php (NEW)
    │   └── EnrollUserRequest.php (NEW)
    └── UseCases/
        ├── CreateProgramUseCase.php (NEW)
        ├── UpdateProgramUseCase.php (NEW)
        ├── PublishProgramUseCase.php (NEW)
        ├── EnrollUserUseCase.php (NEW)
        └── GetProgramDetailsUseCase.php (NEW)
```

## ⚠️ Важные моменты

1. **ProgramEnrollment**: связывает User, Program и отслеживает прогресс
2. **TrackProgress**: отслеживает прогресс по конкретному треку
3. **Use Cases**: инкапсулируют бизнес-логику операций
4. **DTO**: для передачи данных между слоями

## 🏁 Цели дня

- ✅ Завершить Domain Layer полностью
- ✅ Создать базовые DTO
- ✅ Реализовать основные Use Cases
- ✅ 100% покрытие тестами 