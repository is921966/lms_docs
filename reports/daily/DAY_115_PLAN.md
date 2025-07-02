# День 115 - Sprint 24, День 1/5 - Program Management Module

**Дата**: 2 июля 2025  
**Цель дня**: Создать Domain Layer для Program Management Module

## 📋 План на день

### 1. Domain Models (4 часа)
- [ ] Program entity - программа обучения
- [ ] Track entity - трек внутри программы  
- [ ] ProgramEnrollment entity - запись на программу
- [ ] TrackProgress entity - прогресс по треку

### 2. Value Objects (2 часа)
- [ ] ProgramId - идентификатор программы
- [ ] ProgramCode - код программы (PROG-001)
- [ ] ProgramStatus - статус программы
- [ ] TrackId - идентификатор трека
- [ ] TrackOrder - порядок трека в программе
- [ ] CompletionCriteria - критерии завершения

### 3. Domain Events (1 час)
- [ ] ProgramCreated
- [ ] TrackAdded
- [ ] ProgramPublished
- [ ] UserEnrolledInProgram

### 4. Business Rules (1 час)
- [ ] Программа должна иметь хотя бы один трек
- [ ] Трек должен иметь хотя бы один курс
- [ ] Порядок треков важен
- [ ] Статусы и переходы между ними

## 🎯 Acceptance Criteria

```gherkin
Given новая программа обучения
When создается программа
Then она имеет уникальный ID и код

Given программа с треками
When добавляется новый трек
Then он сохраняется в правильном порядке

Given трек с курсами
When проверяется готовность
Then учитываются все обязательные курсы
```

## 📁 Структура файлов

```
src/Program/
├── Domain/
│   ├── Program.php
│   ├── Track.php
│   ├── ProgramEnrollment.php
│   ├── TrackProgress.php
│   ├── ValueObjects/
│   │   ├── ProgramId.php
│   │   ├── ProgramCode.php
│   │   ├── ProgramStatus.php
│   │   ├── TrackId.php
│   │   ├── TrackOrder.php
│   │   └── CompletionCriteria.php
│   └── Events/
│       ├── ProgramCreated.php
│       ├── TrackAdded.php
│       ├── ProgramPublished.php
│       └── UserEnrolledInProgram.php
```

## ⚠️ Важные моменты

1. **Namespace**: использовать `Program\Domain`, НЕ `App\Program`
2. **TDD**: сначала тест, потом код
3. **Связь с Learning**: Track содержит CourseId из Learning модуля
4. **Immutability**: Value Objects должны быть immutable

## 🏁 Цели дня

- ✅ Создать все Domain сущности с тестами
- ✅ 100% покрытие тестами
- ✅ Все тесты проходят
- ✅ Готовность к Application Layer (День 116) 