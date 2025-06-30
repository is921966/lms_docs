# 📋 SPRINT 15 PLAN - Phase 2: Architecture Refactoring

**Sprint:** 15  
**Dates:** 2025-07-01 → 2025-07-03 (3 дня)  
**Goal:** Применить Clean Architecture паттерны согласно новым Cursor Rules  
**Phase:** 2 из 4 (Methodology v1.8.0 Implementation)

## 🎯 Sprint Goals

1. **Реализовать Clean Architecture в критических модулях**
2. **Создать Value Objects для domain моделей**
3. **Настроить Repository pattern и Dependency Injection**
4. **Исправить критические SwiftLint warnings**

## 📝 User Stories

### Story 1: Clean Architecture для Course Module
**As a** developer  
**I want** четкое разделение слоев в модуле курсов  
**So that** модуль легко тестировать и расширять

**Acceptance Criteria:**
```gherkin
Given модуль Course в текущей архитектуре
When я применяю Clean Architecture
Then создаются слои Presentation, Domain, Data
And зависимости идут только внутрь
And domain слой не зависит от фреймворков
```

**Tasks:**
- [ ] Создать Domain entities (Course, Lesson, Module)
- [ ] Создать Use Cases (EnrollCourse, GetProgress, CompleteCourse)
- [ ] Создать Repository interfaces
- [ ] Реализовать Data layer с Repository implementations
- [ ] Обновить Presentation layer (ViewModels)

### Story 2: Value Objects Implementation
**As a** architect  
**I want** использовать Value Objects для бизнес-логики  
**So that** домен модель защищена от невалидных состояний

**Acceptance Criteria:**
```gherkin
Given примитивные типы в domain models
When я создаю Value Objects
Then каждый VO валидирует свои данные
And невозможно создать невалидный объект
And VO immutable
```

**Tasks:**
- [ ] CourseId, LessonId value objects
- [ ] Progress value object (0-100%)
- [ ] Duration value object с форматированием
- [ ] Email, PhoneNumber для User domain
- [ ] CompetencyLevel enum с методами

### Story 3: Repository Pattern & DI
**As a** developer  
**I want** абстракцию над data layer  
**So that** могу легко менять источники данных

**Acceptance Criteria:**
```gherkin
Given прямые вызовы к API/Database
When реализован Repository pattern
Then domain использует только interfaces
And конкретные реализации инжектируются
And легко создавать mock для тестов
```

**Tasks:**
- [ ] Создать Repository protocols в Domain
- [ ] Реализовать Network repositories
- [ ] Реализовать Cache repositories
- [ ] Настроить DI Container (Resolver/Swinject)
- [ ] Обновить все зависимости через DI

### Story 4: Fix Critical SwiftLint Issues
**As a** team lead  
**I want** исправить критические проблемы кода  
**So that** код соответствует стандартам качества

**Acceptance Criteria:**
```gherkin
Given 53 серьезных SwiftLint errors
When я исправляю критические проблемы
Then остается 0 errors
And warnings снижены на 50%+
```

**Tasks:**
- [ ] Fix all force unwrapping (24 errors)
- [ ] Replace .count == 0 with .isEmpty (43 errors)
- [ ] Refactor large tuples (2 errors)
- [ ] Split large functions (3 errors)
- [ ] Add file headers template

## 📊 Technical Architecture Changes

### Before (Current):
```
LMS/
├── Features/
│   └── Courses/
│       ├── CourseListView.swift
│       ├── CourseViewModel.swift
│       └── CourseMockService.swift
```

### After (Clean Architecture):
```
LMS/
├── Features/
│   └── Courses/
│       ├── Presentation/
│       │   ├── Views/
│       │   │   └── CourseListView.swift
│       │   └── ViewModels/
│       │       └── CourseListViewModel.swift
│       ├── Domain/
│       │   ├── Entities/
│       │   │   └── Course.swift
│       │   ├── UseCases/
│       │   │   └── EnrollCourseUseCase.swift
│       │   └── Repositories/
│       │       └── CourseRepositoryProtocol.swift
│       └── Data/
│           ├── Repositories/
│           │   └── CourseRepository.swift
│           └── DataSources/
│               ├── CourseRemoteDataSource.swift
│               └── CourseLocalDataSource.swift
```

## 🔧 Value Objects Examples

```swift
// Before
struct Course {
    let id: String
    let duration: Int // minutes
    let progress: Double // 0.0 - 100.0
}

// After
struct Course {
    let id: CourseId
    let duration: CourseDuration
    let progress: CourseProgress
}

struct CourseId: ValueObject {
    let value: String
    
    init?(value: String) {
        guard !value.isEmpty,
              value.count == 36 else { return nil }
        self.value = value
    }
}

struct CourseProgress: ValueObject {
    let value: Double
    
    init?(percentage: Double) {
        guard (0...100).contains(percentage) else { return nil }
        self.value = percentage
    }
    
    var isCompleted: Bool { value >= 100 }
    var formatted: String { "\(Int(value))%" }
}
```

## 🏗️ Definition of Done

### Story Level:
- [ ] Все тесты написаны и проходят
- [ ] Архитектурные слои четко разделены
- [ ] Value Objects покрыты тестами на 100%
- [ ] SwiftLint errors = 0
- [ ] Документация обновлена

### Sprint Level:
- [ ] Clean Architecture применена минимум к 2 модулям
- [ ] Созданы минимум 10 Value Objects
- [ ] DI Container настроен и используется
- [ ] SwiftLint warnings снижены на 50%+

## 📈 Success Metrics

- Testability: Unit tests без mocking UI
- Compilation time: Не увеличилось более чем на 10%
- Code coverage: Domain layer 95%+
- SwiftLint: 0 errors, <400 warnings

## 🚀 Expected Outcomes

1. **Улучшенная тестируемость**: Domain logic тестируется изолированно
2. **Гибкость**: Легко менять UI или data sources
3. **Безопасность**: Value Objects предотвращают невалидные состояния
4. **Поддерживаемость**: Четкие границы ответственности

---

**Sprint Status:** 🟡 Ready to Start  
**Estimated Effort:** 12-15 hours  
**Risk Level:** Medium (архитектурные изменения) 