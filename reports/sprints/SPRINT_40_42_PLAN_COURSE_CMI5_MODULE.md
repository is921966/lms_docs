# Sprint 40-42: Course Management + Cmi5 Support Module

**Модуль**: Расширение Course Management полной поддержкой Cmi5  
**Продолжительность**: 15 дней (3 спринта по 5 дней)  
**Результат**: Production-ready управление курсами с Cmi5/xAPI  
**TestFlight**: v2.0.0-cmi5  
**Начало**: Sprint 40 (после завершения Sprint 39)

## 🎯 Бизнес-обоснование выбора

### Почему Course Management + Cmi5:
1. **Логичное расширение** - у нас уже есть базовое управление курсами
2. **Современные стандарты** - Cmi5 заменяет устаревший SCORM
3. **Конкурентное преимущество** - мало кто поддерживает Cmi5
4. **Готовая база** - можем сразу применить к существующим курсам
5. **Высокий спрос** - enterprise клиенты требуют Cmi5

### Что уже есть (Course Management):
- ✅ Создание и редактирование курсов
- ✅ Структура модулей и уроков
- ✅ Enrollment и прогресс
- ✅ Базовые материалы (PDF, видео)
- ✅ Простое тестирование

### Что добавит Cmi5:
- 🆕 Импорт профессионального контента
- 🆕 Детальное отслеживание активностей (xAPI)
- 🆕 Офлайн обучение с синхронизацией
- 🆕 Расширенная аналитика обучения
- 🆕 Совместимость с authoring tools

## 📋 User Stories - Интеграция с Course Management

### Epic 1: Расширение Course Builder

#### Story 1.1: Добавление Cmi5 в создание курса
**Как** администратор курсов  
**Я хочу** добавлять Cmi5 контент в курсы  
**Чтобы** использовать профессиональный контент

**Детальные требования**:
```gherkin
Feature: Cmi5 in Course Builder

Scenario: Add Cmi5 package to existing course
  Given I am editing course "iOS Development"
  When I click "Add Content" in module
  Then I see options: "Video", "Document", "Quiz", "Cmi5 Package"
  When I select "Cmi5 Package"
  Then I can upload .zip file
  And package is validated
  And activities are added as lessons

Scenario: Create course from Cmi5 package
  Given I have Cmi5 package "Complete Swift Course"
  When I click "Create Course from Package"
  Then course structure is auto-generated
  And all activities become lessons
  And I can customize before saving
```

**UI изменения в CourseDetailView**:
```swift
// Добавляем в существующий CourseDetailView
struct CourseDetailView: View {
    // ... existing code ...
    
    var contentSection: some View {
        Section("Course Content") {
            ForEach(course.modules) { module in
                ModuleRow(module: module)
            }
            
            // NEW: Cmi5 import button
            Button(action: { showCmi5Import = true }) {
                Label("Import Cmi5 Package", systemImage: "square.and.arrow.down")
            }
            .sheet(isPresented: $showCmi5Import) {
                Cmi5ImportView(course: course)
            }
        }
    }
}
```

### Epic 2: Улучшенный Learning Experience

#### Story 2.1: Unified Course Player
**Как** учащийся  
**Я хочу** проходить все типы контента в одном интерфейсе  
**Чтобы** иметь единообразный опыт обучения

**Интеграция в существующий CoursePlayerView**:
```swift
// Расширяем существующий player
enum ContentType {
    case video(URL)
    case document(URL)
    case quiz(TestID)
    case cmi5(Cmi5Activity) // NEW
}

struct CoursePlayerView: View {
    func contentView(for lesson: Lesson) -> some View {
        switch lesson.contentType {
        case .video(let url):
            VideoPlayer(url: url)
        case .document(let url):
            PDFViewer(url: url)
        case .quiz(let testID):
            TestPlayerView(testID: testID)
        case .cmi5(let activity): // NEW
            Cmi5PlayerView(activity: activity,
                          onStatement: handleXAPIStatement)
        }
    }
}
```

### Epic 3: Расширенная аналитика курсов

#### Story 3.1: xAPI Analytics Dashboard
**Как** руководитель обучения  
**Я хочу** видеть детальную аналитику по всем курсам  
**Чтобы** понимать эффективность обучения

**Интеграция в AnalyticsDashboard**:
- Добавить вкладку "xAPI Insights"
- Показывать learning paths
- Heatmap активностей
- Сравнение обычных и Cmi5 курсов

## 🏗️ Техническая архитектура - Интеграция

### Расширение существующих сервисов:

#### CourseService Enhancement:
```swift
// Существующий CourseService
class CourseService {
    // ... existing methods ...
    
    // NEW: Cmi5 support
    func importCmi5Package(_ packageURL: URL, 
                          into courseID: UUID) async throws {
        let package = try await cmi5Parser.parse(packageURL)
        let activities = try await createLessonsFromActivities(package)
        try await addLessonsToCourse(courseID, activities)
    }
    
    func getCmi5Metadata(for lessonID: UUID) async -> Cmi5Metadata? {
        // Retrieve Cmi5-specific data
    }
}
```

#### Новые сервисы для Cmi5:
```swift
// NEW: Cmi5-specific services
class Cmi5Service: ObservableObject {
    func launchActivity(_ activity: Cmi5Activity, 
                       for learner: User) async -> LaunchData
    func processStatement(_ statement: XAPIStatement) async
    func getProgress(for activityID: UUID, 
                    learnerID: UUID) async -> Progress
}

class XAPIService: ObservableObject {
    func sendStatement(_ statement: XAPIStatement) async
    func queryStatements(filters: XAPIFilters) async -> [XAPIStatement]
    func generateAnalytics(for courseID: UUID) async -> XAPIAnalytics
}
```

### База данных - Расширение схемы:

К существующим таблицам courses и lessons добавляем:
```sql
-- Связь курсов с Cmi5
ALTER TABLE lessons ADD COLUMN cmi5_activity_id UUID;
ALTER TABLE lessons ADD COLUMN content_type VARCHAR(20);

-- Новые таблицы для Cmi5 (см. migration 017)
CREATE TABLE cmi5_packages ...
CREATE TABLE cmi5_activities ...
CREATE TABLE xapi_statements ...
```

## 📅 Детальный план по дням

### Sprint 40 (Дни 1-5): Foundation + Course Integration

#### День 1: Архитектура и планирование
- [ ] Детальный technical design document
- [ ] Расширение схемы БД для courses/lessons
- [ ] Создание Cmi5 domain models
- [ ] Написание миграций
- [ ] TDD: модели и value objects

#### День 2: Cmi5 Parser и импорт
- [ ] Cmi5PackageParser implementation
- [ ] Manifest validator
- [ ] Activity extractor
- [ ] Integration с CourseService
- [ ] TDD: parser и validator

#### День 3: UI для импорта в Course Builder
- [ ] Cmi5ImportView создание
- [ ] Интеграция в CourseDetailView
- [ ] Drag & drop для пакетов
- [ ] Preview импортируемого контента
- [ ] Mapping activities на lessons

#### День 4: Backend API расширение
- [ ] Расширить course API для Cmi5
- [ ] Endpoints для импорта пакетов
- [ ] xAPI endpoints (statements)
- [ ] Авторизация для LRS
- [ ] Integration тесты

#### День 5: Базовая интеграция и тесты
- [ ] E2E тест: создание курса с Cmi5
- [ ] Проверка импорта реальных пакетов
- [ ] UI тесты импорта
- [ ] Документация процесса
- [ ] TestFlight build 2.0.0-alpha1

### Sprint 41 (Дни 6-10): Player и Learning Experience

#### День 6: Cmi5 Player интеграция
- [ ] Cmi5PlayerView компонент
- [ ] WebView с launch parameters
- [ ] Интеграция в CoursePlayerView
- [ ] Session management
- [ ] Navigation controls

#### День 7: xAPI Statement tracking
- [ ] Real-time statement capture
- [ ] Интеграция с прогрессом курса
- [ ] Обновление CourseProgress
- [ ] Statement validation
- [ ] Queue для офлайн

#### День 8: Офлайн поддержка
- [ ] Download Cmi5 content
- [ ] Local content serving
- [ ] Offline statement queue
- [ ] Синхронизация при подключении
- [ ] Conflict resolution

#### День 9: Расширение аналитики
- [ ] xAPI tab в AnalyticsDashboard
- [ ] Learning path visualization
- [ ] Интеграция с course analytics
- [ ] Сравнительные отчеты
- [ ] Export функциональность

#### День 10: Polish и интеграция
- [ ] Полный user flow testing
- [ ] Performance optimization
- [ ] UI improvements
- [ ] Bug fixes
- [ ] TestFlight build 2.0.0-beta1

### Sprint 42 (Дни 11-15): Production Polish

#### День 11: Продвинутые функции
- [ ] Bulk import для курсов
- [ ] Версионирование пакетов
- [ ] A/B testing для контента
- [ ] Advanced completion rules
- [ ] Adaptive learning hints

#### День 12: Оптимизация и масштабирование
- [ ] Оптимизация больших пакетов
- [ ] CDN интеграция
- [ ] Caching стратегия
- [ ] Background processing
- [ ] Load testing

#### День 13: Безопасность и compliance
- [ ] Security audit Cmi5/xAPI
- [ ] Data privacy compliance
- [ ] Encryption для statements
- [ ] Access control testing
- [ ] GDPR compliance

#### День 14: Документация и обучение
- [ ] Admin guide для Cmi5
- [ ] Видео туториалы
- [ ] Best practices guide
- [ ] Troubleshooting guide
- [ ] API documentation

#### День 15: Production Release
- [ ] Final regression testing
- [ ] Performance benchmarks
- [ ] TestFlight 2.0.0 release
- [ ] Release notes
- [ ] Stakeholder demo

## 🧪 Тестирование - Комплексный подход

### Расширение существующих тестов:
- CourseServiceTests + Cmi5 scenarios (20 тестов)
- CourseDetailViewTests + import UI (15 тестов)
- CoursePlayerViewTests + Cmi5 player (20 тестов)

### Новые тесты для Cmi5:
- Cmi5PackageParserTests (30 тестов)
- XAPIServiceTests (40 тестов)
- Cmi5PlayerViewTests (25 тестов)
- LRS integration tests (20 тестов)

### E2E сценарии:

#### 1. Полное ручное создание курса
**Сценарий**: Администратор создает курс с нуля со всеми типами контента
```gherkin
Feature: Complete Course Creation

Background:
  Given I am logged in as course administrator
  And I am on courses management page

Scenario: Create comprehensive course manually
  # Создание курса
  When I click "Create New Course"
  And I fill course details:
    | Field | Value |
    | Title | Комплексный курс iOS разработки |
    | Description | Полный курс от основ до продвинутых тем |
    | Category | Программирование |
    | Duration | 40 часов |
    | Level | Beginner to Advanced |
  And I upload course cover image
  And I set enrollment rules:
    | Auto-enroll positions | iOS Developer, Mobile Developer |
    | Prerequisites | Basic Programming Knowledge |
    | Max students | 50 |
  And I click "Save Course"
  Then course is created successfully
  
  # Добавление модулей
  When I click "Add Module"
  And I create module "Основы Swift":
    | Order | 1 |
    | Description | Базовый синтаксис языка Swift |
    | Duration | 8 часов |
  
  # Добавление разных типов контента
  When I add lesson "Introduction to Swift":
    | Type | Video |
    | File | intro_swift.mp4 |
    | Duration | 45 min |
    | Allow download | Yes |
  
  When I add lesson "Swift Playground":
    | Type | Document |
    | File | swift_basics.pdf |
    | Pages | 25 |
    | Required reading time | 30 min |
  
  When I add lesson "Variables and Constants":
    | Type | SCORM package |
    | File | variables_interactive.zip |
    | Passing score | 80% |
    | Attempts allowed | 3 |
  
  When I add lesson "Swift Basics Test":
    | Type | Quiz |
    | Questions | 20 |
    | Time limit | 30 min |
    | Passing score | 70% |
    | Show correct answers | After submission |
  
  # НОВОЕ: Добавление Cmi5 контента
  When I add lesson "Advanced Swift Concepts":
    | Type | Cmi5 Package |
    | File | advanced_swift_cmi5.zip |
    | Launch mode | Normal |
    | Mastery score | 85% |
  
  # Настройка последовательности
  When I set lesson sequence:
    | Lesson 1 must be completed before Lesson 2 |
    | Lesson 2 must be completed before Lesson 3 |
    | Quiz unlocks after all lessons |
  
  # Добавление ресурсов
  When I add course resources:
    | Swift Language Guide.pdf |
    | Code Examples.zip |
    | Useful Links.docx |
  
  # Настройка сертификата
  When I configure completion certificate:
    | Template | Professional Certificate |
    | Completion criteria | All modules 100% |
    | Include score | Yes |
    | Validity | 2 years |
  
  Then course structure is saved
  And course is published
  And enrolled students can access it
```

#### 2. Комплексное редактирование существующего курса
**Сценарий**: Администратор вносит изменения во все аспекты курса
```gherkin
Feature: Comprehensive Course Editing

Scenario: Edit all aspects of existing course
  Given course "iOS Development" exists with:
    | 3 modules |
    | 15 lessons |
    | 45 enrolled students |
    | Average progress 35% |
  
  # Редактирование основной информации
  When I open course for editing
  And I update course details:
    | Title | iOS Development 2025 Edition |
    | Add tags | Swift 5.9, SwiftUI, Cmi5 |
    | Update duration | 45 hours |
  
  # Реорганизация модулей
  When I reorder modules:
    | Move "Advanced Topics" before "Intermediate" |
    | Merge "UIKit Basics" into "UI Development" |
    | Split "Networking" into "REST API" and "WebSockets" |
  
  # Обновление контента
  When I edit lesson "SwiftUI Basics":
    | Replace video | swiftui_2025.mp4 |
    | Update duration | 60 min |
    | Add captions | English, Russian |
    | Add chapter markers | Introduction, Components, Layout |
  
  # Замена SCORM на Cmi5
  When I select lesson "Interactive Practice"
  And I click "Convert to Cmi5"
  And I upload "practice_cmi5.zip"
  Then old SCORM package is archived
  And student progress is preserved
  And new Cmi5 content is active
  
  # Массовое обновление
  When I select multiple lessons
  And I bulk update:
    | Add tag | Updated 2025 |
    | Enable offline mode | Yes |
    | Update completion time | +10% |
  
  # Обновление тестов
  When I edit quiz "Module 1 Test":
    | Add question bank | 50 questions |
    | Randomize questions | Pick 20 of 50 |
    | Add time pressure | -1 point per minute over limit |
    | Enable proctoring | Camera required |
  
  # Версионирование
  When I save changes as new version:
    | Version | 2.0 |
    | Changelog | Updated for 2025, added Cmi5 support |
    | Migration plan | Auto-upgrade active learners |
  
  Then all changes are saved
  And active learners see update notification
  And progress is maintained
```

#### 3. Cmi5 специфичные сценарии
**Сценарий**: Работа с Cmi5 контентом
```gherkin
Feature: Cmi5 Content Management

Scenario: Import and configure Cmi5 package
  Given I am editing course "Professional Development"
  
  When I click "Import Cmi5 Content"
  And I drag and drop "leadership_skills_cmi5.zip"
  Then I see package validation:
    | Valid manifest | ✓ |
    | Activities found | 12 |
    | Total size | 245 MB |
    | xAPI profiles | cmi5, video |
  
  When I click "Configure Import"
  Then I can map activities to course structure:
    | Activity "Introduction" → Module 1, Lesson 1 |
    | Activity "Assessment 1" → Module 1, Quiz |
    | Activity "Case Study" → Module 2, Lesson 1 |
  
  When I set Cmi5 specific settings:
    | Launch mode | Review |
    | Move on | CompletedOrPassed |
    | Mastery score | 80 |
    | Launch parameters | lang=ru&theme=dark |
  
  And I configure xAPI settings:
    | Statement forwarding | Enabled |
    | Additional endpoints | analytics.lms.com/xapi |
    | Data retention | 2 years |
    | Anonymous mode | Available for learners |
  
  Then Cmi5 content is integrated
  And xAPI statements flow correctly
```

#### 4. Смешанный контент и миграция
**Сценарий**: Курс с разными типами контента
```gherkin
Feature: Mixed Content Course

Scenario: Create course mixing all content types
  Given I create new course "Hybrid Learning Experience"
  
  # Модуль 1: Традиционный контент
  When I add Module 1 "Traditional Learning":
    | PDF documents | 5 files |
    | Videos | 3 files |
    | PowerPoint | 2 files |
  
  # Модуль 2: Интерактивный контент
  When I add Module 2 "Interactive Learning":
    | SCORM packages | 2 packages |
    | H5P content | 3 activities |
    | Embedded web apps | 1 app |
  
  # Модуль 3: Современный контент
  When I add Module 3 "Next-Gen Learning":
    | Cmi5 packages | 4 packages |
    | xAPI activities | 6 activities |
    | VR simulations | 2 simulations |
  
  # Настройка единого прохождения
  When I configure unified progression:
    | Track all content types | Yes |
    | Unified progress bar | Yes |
    | Mixed prerequisites | SCORM before Cmi5 |
    | Combined analytics | All in one dashboard |
  
  Then learners see seamless experience
  And all progress is tracked uniformly
  And analytics combine all sources
```

#### 5. Офлайн сценарии
**Сценарий**: Полный офлайн workflow
```gherkin
Feature: Offline Course Experience

Scenario: Download and complete course offline
  Given I am enrolled in "Mobile Development" course
  And course contains:
    | Videos | 10 files, 2GB |
    | Documents | 15 files, 50MB |
    | Cmi5 packages | 3 packages, 300MB |
    | Quizzes | 5 quizzes |
  
  When I click "Download for Offline"
  Then I see download progress:
    | Optimizing video quality | 720p |
    | Compressing documents | PDF |
    | Packaging Cmi5 | With dependencies |
    | Quiz questions | Encrypted cache |
  
  When I go offline
  And I complete:
    | Watch 3 videos |
    | Read 5 documents |
    | Complete 2 Cmi5 activities |
    | Take 1 quiz |
  
  Then progress is saved locally
  And xAPI statements are queued
  And completion certificates are pending
  
  When I go online
  Then sync process starts:
    | Upload queued statements | 45 statements |
    | Verify quiz answers | With server |
    | Update completion status | 40% → 65% |
    | Download new content | If available |
    | Generate certificates | If completed |
```

### Performance тесты
- Import 100MB package < 30s
- Statement processing < 50ms
- UI response < 100ms
- Memory usage < 200MB
- Bulk operations (50 items) < 5s
- Offline sync (1000 statements) < 30s

## 📊 Метрики успеха

### Технические:
- 0 regression bugs в Course Management
- < 3 сек импорт пакета до 50MB
- < 100ms обработка statement
- 99.9% успешная синхронизация
- 90%+ test coverage

### Бизнес:
- 30% курсов используют Cmi5 за 2 месяца
- +25% completion rate для Cmi5 курсов
- 50% снижение вопросов поддержки
- NPS > 60 для новой функциональности

### Пользовательские:
- Seamless integration с существующими курсами
- Единый опыт обучения
- Понятная аналитика
- Быстрая загрузка контента

## 🚀 Результаты для пользователей

### Для администраторов:
1. **Легкий импорт** профессионального контента
2. **Гибкое управление** смешанными курсами
3. **Детальная аналитика** всех активностей
4. **Версионирование** контента

### Для учащихся:
1. **Единый интерфейс** для всех типов контента
2. **Офлайн доступ** к Cmi5 курсам
3. **Детальный прогресс** по активностям
4. **Мобильная поддержка** Cmi5

### Для руководителей:
1. **ROI обучения** через xAPI analytics
2. **Learning paths** visualization
3. **Сравнительные отчеты** по типам контента
4. **Предиктивная аналитика** (foundation)

## ⚠️ Риски и митигация

1. **Сложность интеграции с существующим кодом**
   - Митигация: Тщательное планирование, incremental changes
   - Fallback: Cmi5 как отдельный тип курса

2. **Performance при больших пакетах**
   - Митигация: Chunked upload, background processing
   - Monitoring с первого дня

3. **Совместимость различных Cmi5 пакетов**
   - Митигация: Тестирование с популярными authoring tools
   - Graceful degradation для неподдерживаемых функций

## ✅ Definition of Done

- [ ] Course Management полностью поддерживает Cmi5
- [ ] Все существующие функции работают без regression
- [ ] Новые функции покрыты тестами >90%
- [ ] Performance SLA выполнены
- [ ] Документация обновлена
- [ ] TestFlight 2.0.0 выпущен
- [ ] 5+ бета-тестеров подтвердили работу
- [ ] Метрики и мониторинг настроены
- [ ] Обратная связь собрана и обработана

---
*Этот план обеспечивает органичное расширение Course Management современным стандартом Cmi5, создавая мощную систему управления обучением.* 