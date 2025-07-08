# Sprint 40-42: Cmi5 Support Module - Детальный план

**Модуль**: Полная поддержка стандарта Cmi5  
**Продолжительность**: 15 дней (3 спринта)  
**Результат**: Production-ready Cmi5 функциональность  
**TestFlight**: v2.0.0-cmi5

## 🎯 Бизнес-цели модуля

1. **Поддержка современных стандартов** - Cmi5 является передовым стандартом e-learning
2. **Расширенная аналитика** - детальное отслеживание всех учебных активностей
3. **Офлайн обучение** - возможность проходить курсы без интернета
4. **Мобильная поддержка** - полноценное обучение на iOS устройствах
5. **Конкурентное преимущество** - немногие LMS поддерживают Cmi5

## 📋 User Stories с детальными сценариями

### Epic 1: Импорт и управление Cmi5 пакетами

#### Story 1.1: Импорт Cmi5 пакета
**Как** администратор курсов  
**Я хочу** импортировать Cmi5 пакеты  
**Чтобы** предоставить современный контент пользователям

**Детальные требования**:
```gherkin
Feature: Cmi5 Package Import

Scenario: Successful package upload
  Given I am on the course management page
  When I click "Import Cmi5 Package"
  And I select a valid .zip file
  Then I see upload progress indicator
  And package is validated in real-time
  And I see package metadata preview
  And I can map package to existing course
  And import completes with success message

Scenario: Invalid package handling
  Given I try to upload invalid Cmi5 package
  Then I see specific validation errors
  And suggestions for fixing issues
  And no partial data is saved

Scenario: Large package optimization
  Given I upload package > 100MB
  Then upload uses chunked transfer
  And I can pause/resume upload
  And progress is saved in case of interruption
```

**UI детали**:
- Drag & drop зона для загрузки
- Прогресс-бар с процентами и скоростью
- Превью структуры пакета в виде дерева
- Валидация манифеста в реальном времени
- Автоматическое извлечение метаданных

#### Story 1.2: Управление Cmi5 контентом
**Как** администратор  
**Я хочу** управлять импортированными пакетами  
**Чтобы** организовать учебный контент

**Детальные требования**:
- Список всех Cmi5 пакетов с фильтрами
- Детальный просмотр структуры активностей
- Редактирование метаданных пакета
- Управление версиями пакетов
- Архивирование/удаление пакетов

### Epic 2: Запуск и прохождение Cmi5 контента

#### Story 2.1: Cmi5 Player
**Как** учащийся  
**Я хочу** проходить Cmi5 курсы  
**Чтобы** получить современный опыт обучения

**Детальные требования**:
```gherkin
Feature: Cmi5 Content Player

Scenario: Launch Cmi5 activity
  Given I enrolled in course with Cmi5 content
  When I click "Start Learning"
  Then Cmi5 player opens in optimized view
  And my session is registered in LRS
  And I see native iOS controls
  And content adapts to device orientation

Scenario: Progress tracking
  Given I am in Cmi5 activity
  When I complete interactions
  Then xAPI statements are sent in real-time
  And progress bar updates immediately
  And my score is calculated correctly
  And completion status is synchronized

Scenario: Offline mode
  Given I download Cmi5 content for offline
  When I lose internet connection
  Then I can continue learning
  And xAPI statements are queued locally
  And sync happens when connection restored
```

**Player функции**:
- Встроенный WebView с оптимизациями
- Нативные контролы (play, pause, navigation)
- Picture-in-picture поддержка
- Жесты для навигации
- Автосохранение прогресса каждые 30 секунд

### Epic 3: xAPI/LRS функциональность

#### Story 3.1: Learning Record Store
**Как** система  
**Я хочу** хранить все xAPI statements  
**Чтобы** обеспечить детальную аналитику

**Технические требования**:
- REST API согласно xAPI спецификации
- Поддержка всех типов statements
- Фильтрация и поиск statements
- Экспорт данных в различных форматах
- Оптимизация для больших объемов

#### Story 3.2: Расширенная аналитика
**Как** руководитель  
**Я хочу** видеть детальную аналитику по Cmi5  
**Чтобы** принимать data-driven решения

**Аналитические дашборды**:
- Learning paths visualization
- Time spent analysis
- Interaction heatmaps
- Success/failure patterns
- Comparative analytics

## 🏗️ Техническая архитектура

### iOS приложение

#### Новые компоненты:
```swift
// Feature structure
Features/Cmi5/
├── Models/
│   ├── Cmi5Package.swift
│   ├── Cmi5Activity.swift
│   ├── XAPIStatement.swift
│   └── LearningSession.swift
├── Views/
│   ├── Cmi5ImportView.swift
│   ├── Cmi5PlayerView.swift
│   ├── Cmi5ProgressView.swift
│   └── XAPIAnalyticsView.swift
├── ViewModels/
│   ├── Cmi5ImportViewModel.swift
│   ├── Cmi5PlayerViewModel.swift
│   └── LRSViewModel.swift
├── Services/
│   ├── Cmi5PackageService.swift
│   ├── XAPIService.swift
│   ├── LRSClient.swift
│   └── OfflineSyncService.swift
└── Utils/
    ├── Cmi5Parser.swift
    ├── XAPIStatementBuilder.swift
    └── LaunchParametersGenerator.swift
```

### Backend архитектура

#### Новый микросервис - xAPI Service:
```php
src/xAPI/
├── Domain/
│   ├── Statement.php
│   ├── Actor.php
│   ├── Activity.php
│   ├── Verb.php
│   └── Result.php
├── Application/
│   ├── Commands/
│   │   ├── StoreStatementCommand.php
│   │   └── ProcessStatementBatchCommand.php
│   ├── Queries/
│   │   ├── GetStatementsQuery.php
│   │   └── GetAnalyticsQuery.php
│   └── Services/
│       ├── StatementValidator.php
│       └── AnalyticsProcessor.php
├── Infrastructure/
│   ├── Persistence/
│   │   ├── MongoStatementRepository.php
│   │   └── PostgresStatementRepository.php
│   └── External/
│       └── Cmi5Validator.php
└── Http/
    └── Controllers/
        ├── XAPIController.php
        └── Cmi5Controller.php
```

### База данных

См. `/database/migrations/017_create_cmi5_tables.php` для полной схемы.

## 📅 Детальный план по дням

### Sprint 40 (Дни 1-5): Foundation

#### День 1: Архитектура и модели
- [ ] Создать все Domain модели для Cmi5
- [ ] Написать миграции БД
- [ ] Создать базовую структуру xAPI Service
- [ ] Написать тесты для моделей (TDD)

#### День 2: Импорт функциональность (Backend)
- [ ] Cmi5 package parser
- [ ] Manifest validator
- [ ] Content extractor
- [ ] API endpoints для импорта

#### День 3: Импорт UI (iOS)
- [ ] Cmi5ImportView дизайн
- [ ] Drag & drop загрузка
- [ ] Progress индикаторы
- [ ] Интеграция с API

#### День 4: xAPI/LRS Core
- [ ] xAPI statement validator
- [ ] LRS storage implementation
- [ ] Basic statement API
- [ ] Auth mechanisms

#### День 5: Интеграция и тесты
- [ ] End-to-end импорт тест
- [ ] UI тесты для импорта
- [ ] Performance тесты
- [ ] Документация API

### Sprint 41 (Дни 6-10): Player и прогресс

#### День 6: Cmi5 Player (iOS)
- [ ] WebView интеграция
- [ ] Launch parameters
- [ ] Native controls
- [ ] Session management

#### День 7: Statement tracking
- [ ] Real-time statement capture
- [ ] Queue для офлайн
- [ ] Sync механизм
- [ ] Progress calculation

#### День 8: Офлайн поддержка
- [ ] Content download
- [ ] Local storage
- [ ] Offline queue
- [ ] Conflict resolution

#### День 9: Analytics foundation
- [ ] Statement aggregation
- [ ] Basic analytics API
- [ ] Dashboard widgets
- [ ] Export функции

#### День 10: Интеграция
- [ ] Full flow testing
- [ ] Performance optimization
- [ ] UI polish
- [ ] Beta feedback

### Sprint 42 (Дни 11-15): Polish и release

#### День 11: Расширенная аналитика
- [ ] Learning paths viz
- [ ] Heatmaps
- [ ] Comparative reports
- [ ] ML insights prep

#### День 12: Оптимизация
- [ ] Performance tuning
- [ ] Memory optimization
- [ ] Battery usage
- [ ] Network efficiency

#### День 13: Безопасность
- [ ] Security audit
- [ ] Penetration testing
- [ ] Data encryption
- [ ] Privacy compliance

#### День 14: Документация
- [ ] User guides
- [ ] Admin documentation
- [ ] API documentation
- [ ] Video tutorials

#### День 15: Release
- [ ] Final testing
- [ ] TestFlight build
- [ ] Release notes
- [ ] Marketing materials

## 🧪 Тестирование (детальный план)

### Unit тесты (300+)
- Models: 50 тестов
- Services: 100 тестов
- ViewModels: 80 тестов
- Utilities: 70 тестов

### Integration тесты (50+)
- Import flow: 10 тестов
- Player flow: 15 тестов
- Sync flow: 15 тестов
- Analytics: 10 тестов

### UI тесты (30+)
- Import scenarios: 10 тестов
- Player interactions: 10 тестов
- Offline scenarios: 5 тестов
- Analytics views: 5 тестов

### Performance тесты
- Import 100MB package < 30s
- Statement processing < 50ms
- UI response < 100ms
- Memory usage < 200MB

## 📊 Метрики успеха

### Технические метрики
- Code coverage > 90%
- 0 критических багов
- Performance SLA 100%
- Security scan passed

### Бизнес метрики
- 50% курсов используют Cmi5 за 3 месяца
- +30% engagement для Cmi5 курсов
- 95% satisfaction rate
- 25% снижение support tickets

## 🚀 Deliverables

### Для пользователей
1. Возможность проходить современные Cmi5 курсы
2. Офлайн обучение с синхронизацией
3. Детальная аналитика прогресса
4. Мобильный Cmi5 player

### Для администраторов
1. Простой импорт Cmi5 пакетов
2. Управление версиями контента
3. Расширенная аналитика
4. xAPI data export

### Для разработчиков
1. xAPI Service с полным API
2. Документация интеграции
3. SDK для расширений
4. Примеры использования

## ⚠️ Риски и митигация

1. **Сложность стандарта**
   - Митигация: Использование проверенных библиотек
   - Тщательное тестирование с reference контентом

2. **Производительность LRS**
   - Митигация: Оптимизация с первого дня
   - Horizontal scaling ready архитектура

3. **Совместимость контента**
   - Митигация: Тестирование с популярными authoring tools
   - Graceful degradation для неподдерживаемых функций

## ✅ Definition of Done

- [ ] Все user stories реализованы и протестированы
- [ ] Code review пройден для 100% кода
- [ ] Автоматические тесты покрывают >90%
- [ ] Производительность соответствует SLA
- [ ] Безопасность проверена и подтверждена
- [ ] Документация написана и проверена
- [ ] TestFlight build выпущен и протестирован
- [ ] Обратная связь от бета-тестеров собрана
- [ ] Метрики и мониторинг настроены
- [ ] Демо для stakeholders проведено

---
*Этот план обеспечивает создание полностью готового к продакшену Cmi5 модуля с детальной проработкой всех аспектов.* 