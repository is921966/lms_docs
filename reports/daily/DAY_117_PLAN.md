# День 117 - Sprint 24, День 3/5 - Program Management Module

**Дата**: 2 июля 2025  
**Цель дня**: Завершить Application Layer и начать Infrastructure Layer

## 📋 План на день

### 1. Завершение Application Layer - DTO (1 час)
- [ ] TrackDTO - передача данных о треке
- [ ] ProgramEnrollmentDTO - передача данных о записи
- [ ] UpdateProgramRequest - запрос обновления программы
- [ ] EnrollUserRequest - запрос записи пользователя

### 2. Application Layer - Use Cases (2 часа)
- [ ] UpdateProgramUseCase - обновление программы
- [ ] PublishProgramUseCase - публикация программы
- [ ] EnrollUserUseCase - запись пользователя
- [ ] GetProgramDetailsUseCase - получение деталей программы

### 3. Infrastructure Layer (1.5 часа)
- [ ] InMemoryProgramRepository
- [ ] InMemoryTrackRepository
- [ ] InMemoryProgramEnrollmentRepository
- [ ] Базовые интеграционные тесты

## 🎯 Acceptance Criteria

```gherkin
Given программа в статусе draft
When программа имеет треки и готова
Then она может быть опубликована

Given пользователь хочет записаться
When программа активна
Then создается enrollment запись

Given программа существует
When запрашиваются детали
Then возвращается полная информация с треками
```

## 📁 Структура файлов

```
src/Program/
├── Application/
│   ├── DTO/
│   │   ├── TrackDTO.php (NEW)
│   │   └── ProgramEnrollmentDTO.php (NEW)
│   ├── Requests/
│   │   ├── UpdateProgramRequest.php (NEW)
│   │   └── EnrollUserRequest.php (NEW)
│   └── UseCases/
│       ├── UpdateProgramUseCase.php (NEW)
│       ├── PublishProgramUseCase.php (NEW)
│       ├── EnrollUserUseCase.php (NEW)
│       └── GetProgramDetailsUseCase.php (NEW)
└── Infrastructure/
    └── Persistence/
        ├── InMemoryProgramRepository.php (NEW)
        ├── InMemoryTrackRepository.php (NEW)
        └── InMemoryProgramEnrollmentRepository.php (NEW)
```

## ⚠️ Важные моменты

1. **TrackDTO**: должен включать информацию о курсах
2. **PublishProgramUseCase**: проверка наличия треков
3. **EnrollUserUseCase**: проверка дубликатов записи
4. **InMemory репозитории**: для тестирования

## 🏁 Цели дня

- ✅ Завершить Application Layer полностью
- ✅ Создать базовую Infrastructure
- ✅ 100+ тестов для модуля
- ✅ Готовность к интеграции 