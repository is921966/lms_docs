# План Sprint 5: Сервис управления обучением

## Информация о спринте
- **Номер спринта:** 5
- **Модуль:** Learning Management Service
- **Планируемая длительность:** 7-8 дней
- **Начало:** День 33
- **Цель спринта:** Реализовать сервис управления курсами и учебными материалами

## 🎯 Цели спринта

### Основные цели
1. Создать систему управления курсами
2. Реализовать учебные траектории (Learning Paths)
3. Внедрить отслеживание прогресса обучения
4. Интегрировать с системой оценок
5. Обеспечить 100% прохождение всех тестов

### Технические цели
- Применить все уроки из предыдущих спринтов
- Использовать валидные UUID с самого начала
- Создать фабрики тестовых данных
- Достичь >90% покрытия тестами

## 📋 User Stories

### 1. Управление курсами
**Как** администратор обучения  
**Я хочу** создавать и управлять курсами  
**Чтобы** предоставлять структурированные учебные материалы сотрудникам

**Acceptance Criteria:**
- Создание курса с метаданными (название, описание, длительность)
- Добавление модулей и уроков в курс
- Управление статусом курса (черновик, опубликован, архивирован)
- Назначение компетенций курсу

### 2. Учебные траектории
**Как** HR-специалист  
**Я хочу** создавать последовательности курсов  
**Чтобы** формировать программы развития для должностей

**Acceptance Criteria:**
- Создание learning path из последовательности курсов
- Установка обязательных и опциональных курсов
- Определение порядка прохождения
- Привязка к должностям и компетенциям

### 3. Отслеживание прогресса
**Как** сотрудник  
**Я хочу** видеть свой прогресс обучения  
**Чтобы** понимать, что уже изучено и что осталось

**Acceptance Criteria:**
- Регистрация начала/завершения курса
- Отслеживание прогресса по модулям
- Расчет процента завершения
- История обучения

### 4. Система оценок
**Как** преподаватель  
**Я хочу** оценивать результаты обучения  
**Чтобы** подтверждать освоение материала

**Acceptance Criteria:**
- Создание оценок за курсы/модули
- Интеграция с тестами
- Расчет финальной оценки
- Выдача сертификатов

## 🏗️ Техническая архитектура

### Domain Layer
```
Course (Aggregate Root)
├── CourseModule (Entity)
├── Lesson (Entity)
├── CourseCompetency (Value Object)
└── Events: CourseCreated, CoursePublished, CourseArchived

LearningPath (Aggregate Root)
├── PathCourse (Entity)
├── PathRequirement (Value Object)
└── Events: PathCreated, PathUpdated

LearningProgress (Aggregate Root)
├── CourseProgress (Entity)
├── ModuleProgress (Entity)
└── Events: CourseStarted, ProgressUpdated, CourseCompleted

Assessment (Entity)
├── Grade (Value Object)
├── Certificate (Entity)
└── Events: AssessmentCreated, GradeAssigned
```

### Сервисы
- CourseManagementService
- LearningPathService
- ProgressTrackingService
- AssessmentService

### API Endpoints
```
# Courses
POST   /api/v1/courses
GET    /api/v1/courses
GET    /api/v1/courses/{id}
PUT    /api/v1/courses/{id}
DELETE /api/v1/courses/{id}
POST   /api/v1/courses/{id}/publish
POST   /api/v1/courses/{id}/modules

# Learning Paths
POST   /api/v1/learning-paths
GET    /api/v1/learning-paths
GET    /api/v1/learning-paths/{id}
PUT    /api/v1/learning-paths/{id}
POST   /api/v1/learning-paths/{id}/courses

# Progress
POST   /api/v1/progress/start-course
POST   /api/v1/progress/update
GET    /api/v1/progress/user/{userId}
GET    /api/v1/progress/course/{courseId}

# Assessments
POST   /api/v1/assessments
POST   /api/v1/assessments/{id}/grade
GET    /api/v1/assessments/user/{userId}
```

## 📅 План по дням

### День 1 (День 33) - Исправления и Domain основа
- [ ] Исправить интеграционные тесты Position (2 часа)
- [ ] Создать Course aggregate
- [ ] Реализовать Value Objects
- [ ] Написать тесты для Course

### День 2 (День 34) - Domain расширение
- [ ] Создать LearningPath aggregate
- [ ] Создать LearningProgress aggregate
- [ ] Реализовать domain events
- [ ] Написать тесты

### День 3 (День 35) - Domain сервисы
- [ ] CourseManagementService
- [ ] ProgressCalculationService
- [ ] Написать тесты сервисов
- [ ] Начать Application layer

### День 4 (День 36) - Application Layer
- [ ] CourseService
- [ ] LearningPathService
- [ ] Создать DTO классы
- [ ] Написать тесты

### День 5 (День 37) - Application завершение
- [ ] ProgressTrackingService
- [ ] AssessmentService
- [ ] Завершить все DTO
- [ ] Тесты application layer

### День 6 (День 38) - Infrastructure Layer
- [ ] Реализовать репозитории
- [ ] Создать HTTP контроллеры
- [ ] Настроить маршруты
- [ ] Написать unit тесты

### День 7 (День 39) - Интеграция и документация
- [ ] Интеграционные тесты
- [ ] OpenAPI спецификация
- [ ] Примеры использования API
- [ ] README модуля

### День 8 (День 40) - Резерв и завершение
- [ ] Исправление найденных проблем
- [ ] Оптимизация производительности
- [ ] Финальное тестирование
- [ ] Отчет о завершении спринта

## 🛠️ Технические улучшения

### Из уроков предыдущих спринтов
1. **UUID генерация для тестов**
   ```php
   class TestDataFactory {
       public static function validUuid(): string {
           return Uuid::uuid4()->toString();
       }
   }
   ```

2. **Улучшенная обработка ошибок**
   ```php
   try {
       $id = new CourseId($value);
   } catch (InvalidArgumentException $e) {
       throw new ValidationException("Invalid course ID format");
   }
   ```

3. **DTO с toArray() из коробки**
   ```php
   abstract class BaseDTO {
       abstract public function toArray(): array;
   }
   ```

## 📊 Метрики успеха

### Количественные метрики
- Минимум 20 API endpoints
- >150 тестов (100% passing)
- >90% покрытие кода тестами
- <10 секунд на прогон всех тестов

### Качественные метрики
- Чистая архитектура DDD
- Отсутствие технического долга
- Полная документация API
- Готовность к production

## ⚠️ Риски и митигация

### Риски
1. **Сложность бизнес-логики прогресса** - множество edge cases
2. **Интеграция с существующими сервисами** - зависимости от User и Competency
3. **Производительность расчетов** - прогресс для больших learning paths

### Митигация
1. Тщательное проектирование с учетом всех сценариев
2. Использование интерфейсов для слабой связанности
3. Кэширование результатов расчетов

## 🎯 Definition of Done

### Story Level
- [ ] Все acceptance criteria выполнены
- [ ] Unit тесты написаны и проходят
- [ ] Интеграционные тесты проходят
- [ ] Код review пройден
- [ ] Документация обновлена

### Sprint Level
- [ ] Все user stories завершены
- [ ] >90% покрытие тестами
- [ ] OpenAPI документация готова
- [ ] Нет критических багов
- [ ] Производительность соответствует требованиям

---

**Дата создания плана:** День 32  
**Автор:** AI Development Team  
**Статус:** Готов к исполнению 

# Sprint 5: Learning Management Service - План разработки

**Длительность**: 7-8 дней (Дни 33-40)  
**Цель**: Реализовать сервис управления обучением с курсами, модулями, прогрессом и сертификатами

## День 33: Domain Layer - Основные сущности

### 1. Course (Курс)
```php
namespace App\Learning\Domain;

class Course {
    private CourseId $id;
    private CourseCode $code;
    private string $title;
    private string $description;
    private CourseType $type;
    private int $durationHours;
    private ?string $imageUrl;
    private CourseStatus $status;
    private array $modules = [];
    private array $prerequisites = [];
    private array $tags = [];
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
}
```

### 2. Module (Модуль курса)
```php
class Module {
    private ModuleId $id;
    private CourseId $courseId;
    private string $title;
    private string $description;
    private int $orderIndex;
    private int $durationMinutes;
    private array $lessons = [];
    private bool $isRequired;
}
```

### 3. Lesson (Урок)
```php
class Lesson {
    private LessonId $id;
    private ModuleId $moduleId;
    private string $title;
    private LessonType $type;
    private string $content;
    private int $orderIndex;
    private int $durationMinutes;
    private array $resources = [];
}
```

### 4. Value Objects
- CourseId, ModuleId, LessonId
- CourseCode (формат: "CRS-001")
- CourseType (ONLINE, OFFLINE, BLENDED)
- CourseStatus (DRAFT, PUBLISHED, ARCHIVED)
- LessonType (VIDEO, TEXT, QUIZ, ASSIGNMENT)

### Тесты для Domain Layer
- CourseTest (15 тестов)
- ModuleTest (10 тестов)
- LessonTest (8 тестов)
- Value Objects тесты (20 тестов)

## День 34: Domain Layer - Прогресс и enrollment

### 1. Enrollment (Запись на курс)
```php
class Enrollment {
    private EnrollmentId $id;
    private CourseId $courseId;
    private UserId $userId;
    private EnrollmentStatus $status;
    private \DateTimeImmutable $enrolledAt;
    private ?\DateTimeImmutable $startedAt;
    private ?\DateTimeImmutable $completedAt;
    private ?\DateTimeImmutable $expiresAt;
}
```

### 2. Progress (Прогресс обучения)
```php
class Progress {
    private ProgressId $id;
    private EnrollmentId $enrollmentId;
    private ModuleId $moduleId;
    private LessonId $lessonId;
    private ProgressStatus $status;
    private int $percentComplete;
    private ?\DateTimeImmutable $startedAt;
    private ?\DateTimeImmutable $completedAt;
    private array $attempts = [];
}
```

### 3. Certificate (Сертификат)
```php
class Certificate {
    private CertificateId $id;
    private CertificateNumber $number;
    private EnrollmentId $enrollmentId;
    private string $recipientName;
    private \DateTimeImmutable $issuedAt;
    private ?\DateTimeImmutable $expiresAt;
    private string $verificationUrl;
}
```

### Тесты
- EnrollmentTest (12 тестов)
- ProgressTest (15 тестов)
- CertificateTest (8 тестов)

## День 35: Application Services

### 1. CourseService
- createCourse()
- updateCourse()
- publishCourse()
- archiveCourse()
- addModule()
- reorderModules()
- addPrerequisite()

### 2. EnrollmentService
- enrollUser()
- cancelEnrollment()
- completeEnrollment()
- getActiveEnrollments()
- checkPrerequisites()

### 3. ProgressService
- startLesson()
- completeLesson()
- updateProgress()
- getModuleProgress()
- getCourseProgress()
- resetProgress()

### 4. CertificateService
- issueCertificate()
- verifyCertificate()
- revokeCertificate()
- generateCertificatePDF()

## День 36: Infrastructure - Repositories

### Repositories
1. CourseRepository
2. ModuleRepository
3. LessonRepository
4. EnrollmentRepository
5. ProgressRepository
6. CertificateRepository

### Особенности реализации
- InMemory версии для тестов
- Поддержка сложных запросов
- Оптимизация загрузки связанных данных

## День 37: Infrastructure - HTTP Controllers

### Controllers
1. CourseController
   - CRUD операции
   - Управление модулями
   - Публикация курсов

2. EnrollmentController
   - Запись на курсы
   - Управление подписками
   - История обучения

3. ProgressController
   - Отслеживание прогресса
   - Отметки о завершении
   - Статистика

4. CertificateController
   - Выдача сертификатов
   - Верификация
   - Скачивание PDF

## День 38: Integration Tests

### Тестовые сценарии
1. Полный цикл создания курса
2. Процесс записи и обучения
3. Отслеживание прогресса
4. Выдача сертификатов
5. Управление prerequisites

## День 39-40: Дополнительные features

### Возможные расширения
1. Quiz система
2. Assignments (задания)
3. Discussions (обсуждения)
4. Ratings и reviews
5. Рекомендации курсов

## Метрики успеха
- 150+ unit тестов
- 30+ integration тестов
- 100% покрытие domain layer
- 85%+ общее покрытие
- Все тесты проходят

## Технические решения
- Event-driven уведомления о прогрессе
- Кеширование популярных курсов
- Оптимистичная блокировка для progress
- Версионирование контента курсов

## Риски и митигация
1. **Сложность модели Progress** - начать с простой версии
2. **Производительность при большом количестве enrollments** - пагинация и индексы
3. **Версионирование курсов** - пока игнорируем, добавим в v2

Готовы начать реализацию Day 33! 🚀 