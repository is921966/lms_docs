# День 169: План работы - CourseService Domain & Application

**Дата**: 16 июля 2025  
**Sprint**: 52 (День 1/5)  
**Цель дня**: Создать Domain и Application слои для CourseService микросервиса

## 🎯 Задачи на день

### 1. CourseService структура (15 минут)
- [ ] Создать директорию microservices/course-service
- [ ] Настроить composer.json с Symfony 7.0
- [ ] Базовая структура: Domain, Application, Infrastructure
- [ ] .gitignore и README.md

### 2. Domain Entities (45 минут)
- [ ] Course entity:
  - Properties: id, code, title, description, duration, price
  - Methods: publish(), archive(), updateContent()
  - Business rules validation
- [ ] Module entity:
  - Properties: id, courseId, title, order, content
  - Methods: reorder(), activate()
- [ ] Lesson entity:
  - Properties: id, moduleId, title, type, contentUrl
  - Support for CMI5 lessons
- [ ] Enrollment entity:
  - Properties: userId, courseId, startDate, status, progress
  - Methods: start(), complete(), suspend()

### 3. Value Objects (30 минут)
- [ ] CourseId - UUID value object
- [ ] CourseCode - уникальный код курса (REGEX validation)
- [ ] Duration - продолжительность курса
- [ ] Price - стоимость с валютой
- [ ] Progress - прогресс прохождения (0-100%)
- [ ] EnrollmentStatus - enum (active, completed, suspended)

### 4. Domain Events (20 минут)
- [ ] CourseCreatedEvent
- [ ] CoursePublishedEvent
- [ ] CourseArchivedEvent
- [ ] EnrollmentStartedEvent
- [ ] ModuleCompletedEvent
- [ ] CourseCompletedEvent

### 5. Repository Interfaces (15 минут)
- [ ] CourseRepositoryInterface
- [ ] ModuleRepositoryInterface
- [ ] LessonRepositoryInterface
- [ ] EnrollmentRepositoryInterface

### 6. Application Services (45 минут)
- [ ] CourseService:
  - createCourse()
  - updateCourse()
  - publishCourse()
  - archiveCourse()
  - getCourseWithModules()
- [ ] EnrollmentService:
  - enrollUser()
  - updateProgress()
  - completeModule()
  - getCourseProgress()
  - getEnrollmentHistory()

### 7. DTOs (30 минут)
- [ ] CreateCourseRequest DTO
- [ ] UpdateCourseRequest DTO
- [ ] CourseResponse DTO
- [ ] ModuleResponse DTO
- [ ] EnrollmentRequest DTO
- [ ] ProgressResponse DTO

### 8. Unit Tests (60 минут)
- [ ] Course entity tests (10 tests)
- [ ] Value objects tests (15 tests)
- [ ] CourseService tests (10 tests)
- [ ] EnrollmentService tests (10 tests)
- [ ] Event tests (5 tests)

## 📋 Ожидаемые результаты

К концу дня должно быть:
- ✅ Полностью готовый Domain layer
- ✅ Application layer с сервисами
- ✅ 50+ unit тестов
- ✅ 100% test coverage
- ✅ Документация в README

## 🔧 Технические детали

### Структура проекта
```
microservices/course-service/
├── composer.json
├── src/
│   ├── Domain/
│   │   ├── Entity/
│   │   ├── ValueObject/
│   │   ├── Event/
│   │   └── Repository/
│   ├── Application/
│   │   ├── Service/
│   │   └── DTO/
│   └── Infrastructure/
└── tests/
    ├── Unit/
    └── Integration/
```

### Пример Course entity
```php
class Course extends AggregateRoot
{
    private CourseId $id;
    private CourseCode $code;
    private string $title;
    private CourseStatus $status;
    private Price $price;
    private Duration $duration;
    private array $modules = [];
    
    public function publish(): void
    {
        if ($this->modules->isEmpty()) {
            throw new DomainException('Cannot publish course without modules');
        }
        
        $this->status = CourseStatus::published();
        $this->recordEvent(new CoursePublishedEvent($this->id));
    }
}
```

## ⏱️ Расписание

- **08:00-08:15** - Создание структуры проекта
- **08:15-09:00** - Domain Entities
- **09:00-09:30** - Value Objects
- **09:30-09:50** - Domain Events & Repositories
- **09:50-10:35** - Application Services
- **10:35-11:05** - DTOs
- **11:05-12:05** - Unit Tests
- **12:05-12:30** - Review & документация

## 🚀 Начнем работу!

Первый день Sprint 52 - закладываем фундамент для CourseService! 