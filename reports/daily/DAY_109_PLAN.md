# День 109 - Sprint 23 Day 2 - Learning Management Application Layer

**Дата**: 1 июля 2025  
**Sprint**: 23 (Learning Management Module)  
**Цель дня**: Создать Application Layer с CQRS паттерном  

## 📋 План на день

### 1. Commands (15 тестов)
- [ ] CreateCourseCommand - создание курса
- [ ] UpdateCourseCommand - обновление деталей
- [ ] PublishCourseCommand - публикация курса
- [ ] ArchiveCourseCommand - архивирование
- [ ] EnrollUserCommand - запись на курс
- [ ] CompleteLessonCommand - завершение урока

### 2. Command Handlers (15 тестов)
- [ ] CreateCourseHandler с валидацией и событиями
- [ ] UpdateCourseHandler с проверкой прав
- [ ] PublishCourseHandler с бизнес-правилами
- [ ] EnrollmentHandler с проверкой prerequisites
- [ ] LessonCompletionHandler с прогрессом

### 3. Queries (10 тестов)
- [ ] GetCourseByIdQuery
- [ ] ListCoursesQuery с фильтрацией
- [ ] GetUserProgressQuery
- [ ] GetCourseStatisticsQuery
- [ ] SearchCoursesQuery

### 4. Query Handlers (10 тестов)
- [ ] GetCourseByIdHandler
- [ ] ListCoursesHandler с пагинацией
- [ ] ProgressCalculationHandler
- [ ] StatisticsHandler

### 5. DTOs (5 тестов)
- [ ] CourseDTO для передачи данных
- [ ] ModuleDTO
- [ ] LessonDTO
- [ ] EnrollmentDTO
- [ ] ProgressDTO

## 🎯 Ожидаемый результат

К концу дня:
- 55+ тестов написано и проходят
- CQRS паттерн полностью реализован
- Commands и Queries разделены
- Бизнес-логика в handlers
- DTO для API готовы

## 🏗️ Архитектура

```
Learning/
├── Application/
│   ├── Commands/
│   │   ├── CreateCourseCommand.php
│   │   ├── UpdateCourseCommand.php
│   │   ├── PublishCourseCommand.php
│   │   ├── EnrollUserCommand.php
│   │   └── CompleteLessonCommand.php
│   ├── Handlers/
│   │   ├── CreateCourseHandler.php
│   │   ├── UpdateCourseHandler.php
│   │   ├── PublishCourseHandler.php
│   │   └── EnrollmentHandler.php
│   ├── Queries/
│   │   ├── GetCourseByIdQuery.php
│   │   ├── ListCoursesQuery.php
│   │   └── GetUserProgressQuery.php
│   └── DTO/
│       ├── CourseDTO.php
│       ├── ModuleDTO.php
│       └── LessonDTO.php
```

## 💡 Технические решения

1. **CQRS разделение** - Commands изменяют состояние, Queries читают
2. **Handler паттерн** - вся бизнес-логика в handlers
3. **Immutable Commands/Queries** - безопасность данных
4. **DTO для API** - отделение domain от presentation
5. **События после команд** - для eventual consistency

## ⚡ Быстрый старт

```bash
# Создание теста для Command
cd tests/Unit/Learning/Application/Commands
touch CreateCourseCommandTest.php

# Запуск теста
./test-quick.sh tests/Unit/Learning/Application/Commands/CreateCourseCommandTest.php

# Создание Command
cd src/Learning/Application/Commands
touch CreateCourseCommand.php
```

Начинаем с TDD! 🚀 