# Sprint 3: Competency Service

## Цель спринта
Реализация сервиса управления компетенциями с системой оценки, матрицами компетенций для должностей, интеграцией с User Service и полным тестовым покрытием.

## Продолжительность
5 дней (День 18-22)

## План по дням

### День 18: Domain модели

**Domain сущности:**
- [ ] `src/Competency/Domain/Competency.php` - модель компетенции
- [ ] `src/Competency/Domain/CompetencyLevel.php` - уровень владения
- [ ] `src/Competency/Domain/CompetencyCategory.php` - категория компетенций
- [ ] `src/Competency/Domain/CompetencyMatrix.php` - матрица компетенций для должности
- [ ] `src/Competency/Domain/UserCompetency.php` - компетенция пользователя
- [ ] `src/Competency/Domain/CompetencyAssessment.php` - оценка компетенции

**Value Objects:**
- [ ] `src/Competency/Domain/ValueObjects/CompetencyId.php`
- [ ] `src/Competency/Domain/ValueObjects/AssessmentScore.php`
- [ ] `src/Competency/Domain/ValueObjects/CompetencyCode.php`

**Domain Events:**
- [ ] `src/Competency/Domain/Events/CompetencyAssessed.php`
- [ ] `src/Competency/Domain/Events/CompetencyMatrixUpdated.php`
- [ ] `src/Competency/Domain/Events/UserCompetencyAchieved.php`

### День 19: Репозитории и интерфейсы

**Интерфейсы репозиториев:**
- [ ] `src/Competency/Domain/Repository/CompetencyRepositoryInterface.php`
- [ ] `src/Competency/Domain/Repository/CompetencyMatrixRepositoryInterface.php`
- [ ] `src/Competency/Domain/Repository/UserCompetencyRepositoryInterface.php`
- [ ] `src/Competency/Domain/Repository/AssessmentRepositoryInterface.php`

**Реализации репозиториев:**
- [ ] `src/Competency/Infrastructure/Repository/CompetencyRepository.php`
- [ ] `src/Competency/Infrastructure/Repository/CompetencyMatrixRepository.php`
- [ ] `src/Competency/Infrastructure/Repository/UserCompetencyRepository.php`
- [ ] `src/Competency/Infrastructure/Repository/AssessmentRepository.php`

### День 20: Сервисы

**Интерфейсы сервисов:**
- [ ] `src/Competency/Domain/Service/CompetencyServiceInterface.php`
- [ ] `src/Competency/Domain/Service/AssessmentServiceInterface.php`
- [ ] `src/Competency/Domain/Service/CompetencyGapAnalysisInterface.php`

**Реализации сервисов:**
- [ ] `src/Competency/Application/Service/CompetencyService.php`
- [ ] `src/Competency/Application/Service/AssessmentService.php`
- [ ] `src/Competency/Application/Service/CompetencyGapAnalysisService.php`
- [ ] `src/Competency/Application/Service/CompetencyReportService.php`

### День 21: HTTP контроллеры и API

**Контроллеры:**
- [ ] `src/Competency/Infrastructure/Http/CompetencyController.php`
- [ ] `src/Competency/Infrastructure/Http/AssessmentController.php`
- [ ] `src/Competency/Infrastructure/Http/CompetencyMatrixController.php`
- [ ] `src/Competency/Infrastructure/Http/UserCompetencyController.php`

**Маршруты и документация:**
- [ ] `src/Competency/Http/Routes/competency_routes.php`
- [ ] Обновление `docs/api/openapi.yaml`

### День 22: Тесты

**Unit тесты:**
- [ ] `tests/Unit/Competency/Domain/CompetencyTest.php`
- [ ] `tests/Unit/Competency/Domain/CompetencyMatrixTest.php`
- [ ] `tests/Unit/Competency/Domain/UserCompetencyTest.php`
- [ ] `tests/Unit/Competency/Domain/ValueObjects/*Test.php`
- [ ] `tests/Unit/Competency/Application/Service/*Test.php`

**Integration тесты:**
- [ ] `tests/Integration/Competency/*RepositoryTest.php`

**Feature тесты:**
- [ ] `tests/Feature/Competency/CompetencyManagementTest.php`
- [ ] `tests/Feature/Competency/AssessmentTest.php`

**Database seeders:**
- [ ] `database/seeders/CompetencySeeder.php`
- [ ] `database/seeders/CompetencyMatrixSeeder.php`

## Ключевые функции

### Управление компетенциями
- CRUD операции для компетенций
- Категоризация и группировка
- Уровни владения (1-5 или custom)
- Версионирование компетенций
- Импорт/экспорт компетенций

### Матрицы компетенций
- Привязка к должностям
- Требуемые уровни владения
- Весовые коэффициенты
- Критичные компетенции
- Наследование от родительских должностей

### Оценка компетенций
- Самооценка сотрудников
- Оценка руководителем
- 360-градусная оценка
- История оценок
- Валидация оценок

### Аналитика и отчеты
- Gap-анализ (разрыв между требуемым и текущим)
- Матрица компетенций команды
- Динамика развития
- Рекомендации по обучению
- Экспорт отчетов

### Интеграция с User Service
- Получение данных о пользователях
- Синхронизация с должностями
- События для уведомлений
- Проверка прав доступа

## Технические решения

### Архитектура
- Domain Driven Design
- Event-driven communication
- CQRS для отчетов
- Cache для матриц

### Паттерны
- Strategy pattern для типов оценки
- Observer pattern для событий
- Factory pattern для создания оценок
- Specification pattern для валидации

### База данных
- Оптимизированные индексы
- Материализованные представления для отчетов
- Партиционирование таблицы оценок
- Архивирование старых данных

## Метрики успеха
- 100% покрытие API endpoint'ов
- 80%+ покрытие тестами
- Время ответа API < 200ms
- Поддержка 1000+ компетенций
- Поддержка 10000+ оценок в месяц 