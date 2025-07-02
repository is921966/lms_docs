# День 108 - Sprint 23 Day 1 - Learning Management Domain Layer

**Дата**: 1 июля 2025  
**Sprint**: 23 (Learning Management Module)  
**Цель дня**: Создать Domain Layer для управления обучением  

## 📋 План на день

### 1. Course Aggregate (15 тестов)
- [ ] Course entity с полями и методами
- [ ] CourseId, CourseCode value objects
- [ ] CourseCreated, CourseUpdated events
- [ ] Методы активации/деактивации курса
- [ ] Управление модулями курса

### 2. Module & Lesson Entities (10 тестов)
- [ ] Module entity для группировки уроков
- [ ] Lesson entity с различными типами контента
- [ ] Сортировка и управление порядком
- [ ] Обязательные/опциональные уроки

### 3. Value Objects (10 тестов)
- [ ] Duration (продолжительность)
- [ ] ContentType (video, text, quiz)
- [ ] CourseStatus (draft, published, archived)
- [ ] Difficulty (beginner, intermediate, advanced)

### 4. Domain Events (5 тестов)
- [ ] CourseCreated
- [ ] LessonCompleted
- [ ] ModuleCompleted
- [ ] CourseCompleted

## 🎯 Ожидаемый результат

К концу дня:
- 40 тестов написано и проходят
- Domain layer полностью готов
- События домена определены
- Готовы к Application layer

## 🏗️ Архитектура

```
Learning/
├── Domain/
│   ├── Course.php              # Aggregate root
│   ├── Module.php              # Модули курса
│   ├── Lesson.php              # Уроки
│   ├── ValueObjects/
│   │   ├── CourseId.php
│   │   ├── CourseCode.php
│   │   ├── Duration.php
│   │   ├── ContentType.php
│   │   └── CourseStatus.php
│   └── Events/
│       ├── CourseCreated.php
│       ├── LessonCompleted.php
│       └── ModuleCompleted.php
```

## 💡 Технические решения

1. **Course как Aggregate Root** - управляет модулями и уроками
2. **Event Sourcing Ready** - все изменения через события
3. **Immutable Value Objects** - для безопасности данных
4. **Rich Domain Model** - бизнес-логика в entities

Начинаем с TDD подхода! 🚀 