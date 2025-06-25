# Sprint 3: Competency Management Service

## 📅 Информация о спринте
- **Старт**: 2025-01-22
- **Длительность**: 10 дней
- **Цель**: Реализовать сервис управления компетенциями с полным TDD покрытием

## 🎯 Цели спринта

### Основные цели
1. Реализовать Domain модель компетенций
2. Создать систему оценки компетенций
3. Интегрировать компетенции с позициями
4. Обеспечить 80%+ покрытие тестами

### Метрики успеха
- [ ] 100% Domain тестов проходят
- [ ] 80%+ покрытие кода тестами
- [ ] Все API endpoints задокументированы
- [ ] 0 критических багов
- [ ] Среднее время выполнения теста < 100ms

## 📋 User Stories

### 1. Создание и управление компетенциями
**Как** HR-менеджер  
**Я хочу** создавать и редактировать компетенции  
**Чтобы** формировать требования к должностям

**Acceptance Criteria:**
- Компетенция имеет название, описание, категорию
- Компетенции могут быть сгруппированы по категориям
- Поддержка иерархии компетенций (родительские/дочерние)
- Валидация уникальности названия в категории

### 2. Уровни владения компетенцией
**Как** руководитель  
**Я хочу** определять уровни владения компетенциями  
**Чтобы** точно оценивать сотрудников

**Acceptance Criteria:**
- 5 уровней: Beginner, Elementary, Intermediate, Advanced, Expert
- Каждый уровень имеет описание критериев
- Возможность кастомизации уровней для компетенции
- Цветовая индикация уровней

### 3. Оценка компетенций сотрудников
**Как** руководитель  
**Я хочу** оценивать компетенции своих подчиненных  
**Чтобы** планировать их развитие

**Acceptance Criteria:**
- Оценка с комментарием и датой
- История изменения оценок
- Возможность самооценки
- Подтверждение оценки вышестоящим руководителем

## 🏗️ Техническая архитектура

### Domain Layer

#### Entities
```php
// Competency.php
- id: CompetencyId
- name: string
- description: string
- category: CompetencyCategory
- parentId: ?CompetencyId
- levels: CompetencyLevel[]
- isActive: bool
- metadata: array

// CompetencyAssessment.php
- id: AssessmentId
- competencyId: CompetencyId
- userId: UserId
- assessorId: UserId
- level: CompetencyLevel
- comment: ?string
- assessedAt: DateTimeImmutable
- confirmedBy: ?UserId
- confirmedAt: ?DateTimeImmutable
```

#### Value Objects
```php
// CompetencyId.php
// CompetencyCategory.php (Technical, Soft, Leadership, etc.)
// CompetencyLevel.php (Beginner...Expert)
// AssessmentId.php
```

#### Domain Services
```php
// CompetencyAssessmentService.php
- assessCompetency()
- confirmAssessment()
- getAssessmentHistory()
- calculateProgress()
```

### Application Layer

#### Services
```php
// CompetencyService.php
- createCompetency()
- updateCompetency()
- deactivateCompetency()
- assignToPosition()
- getCompetencyTree()

// AssessmentService.php
- createAssessment()
- updateAssessment()
- confirmAssessment()
- getEmployeeCompetencies()
- getGapAnalysis()
```

### Infrastructure Layer

#### Repositories
```php
// CompetencyRepository.php
- save()
- findById()
- findByCategory()
- findActive()
- search()

// AssessmentRepository.php
- save()
- findByUser()
- findByCompetency()
- getHistory()
- getStatistics()
```

## 📝 Задачи спринта

### День 1-2: Domain Models
- [ ] CompetencyId value object + тесты
- [ ] CompetencyCategory value object + тесты
- [ ] CompetencyLevel value object + тесты
- [ ] Competency entity + тесты
- [ ] CompetencyAssessment entity + тесты

### День 3-4: Repositories
- [ ] CompetencyRepositoryInterface
- [ ] CompetencyRepository + тесты
- [ ] AssessmentRepositoryInterface
- [ ] AssessmentRepository + тесты

### День 5-6: Domain Services
- [ ] CompetencyAssessmentService + тесты
- [ ] Бизнес-правила оценки
- [ ] Расчет прогресса
- [ ] События домена

### День 7-8: Application Services
- [ ] CompetencyService + тесты
- [ ] AssessmentService + тесты
- [ ] DTO и маппинг
- [ ] Валидация

### День 9-10: HTTP Layer & Integration
- [ ] CompetencyController
- [ ] AssessmentController
- [ ] API документация
- [ ] Integration тесты
- [ ] Миграции БД

## 🧪 Стратегия тестирования

### TDD Workflow
1. **Каждая фича начинается с теста**
   ```bash
   # 1. Создать тест
   vim tests/Unit/Competency/Domain/CompetencyTest.php
   
   # 2. Запустить - RED
   make test-one TEST=CompetencyTest
   
   # 3. Реализовать
   vim src/Competency/Domain/Competency.php
   
   # 4. Запустить - GREEN
   make test-one TEST=CompetencyTest
   ```

2. **Малые итерации**
   - Максимум 2 часа на фичу
   - Коммит после каждого зеленого теста
   - Рефакторинг только при зеленых тестах

3. **Тестовые данные**
   ```php
   // Фабрики для тестов
   CompetencyFactory::create()
       ->withName('PHP Development')
       ->withCategory(CompetencyCategory::TECHNICAL)
       ->withLevels(CompetencyLevel::defaults())
       ->build();
   ```

## 📊 Дневной чек-лист

- [ ] Утро: План на день (какие тесты писать)
- [ ] Каждые 30 мин: Запуск тестов
- [ ] Каждые 2 часа: Коммит
- [ ] Обед: Проверка покрытия
- [ ] Вечер: Обновление документации

## 🚀 Команды для работы

```bash
# Быстрая разработка
make test-one TEST=CompetencyTest     # Один тест
make test-class CLASS=Competency       # Все тесты класса
make test-domain                       # Проверка домена

# Проверка качества
make test-coverage                     # Покрытие
make stan                             # Статический анализ
make cs-fix                           # Code style

# Continuous testing
make test-watch                       # Автозапуск
```

## ⚠️ Риски и митигация

| Риск | Вероятность | Митигация |
|------|-------------|-----------|
| Сложная иерархия компетенций | Высокая | Начать с плоской структуры |
| Performance при большом количестве | Средняя | Индексы БД, кеширование |
| Миграция существующих данных | Низкая | Import сервис с маппингом |

## 📝 Definition of Done

- [ ] Код написан и работает
- [ ] Unit тесты написаны и проходят (>80% покрытие)
- [ ] Integration тесты для критических путей
- [ ] Документация API обновлена
- [ ] Code review пройден
- [ ] Нет критических замечаний от анализаторов
- [ ] Миграции БД протестированы

## 🎯 Итоги спринта

К концу спринта должны иметь:
1. Полностью функциональный Competency Management Service
2. 80%+ покрытие тестами
3. Документированный API
4. Готовность к интеграции с другими сервисами

---

**Помни**: Каждый день начинается с работающих тестов! 