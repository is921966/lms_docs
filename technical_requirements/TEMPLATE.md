# Техническое задание: [Название версии/функции]

**Версия документа:** 1.0.0  
**Дата создания:** [YYYY-MM-DD]  
**Автор:** [Имя]  
**Статус:** Draft | Review | Approved | Implemented

---

## 1. Product Context

**Epic:** [Название epic с указанием core job]

**Core Job:** Когда [ситуация], я хочу [мотивация], чтобы [желаемый результат]

**Business Value:** 
- [Конкретная бизнес-ценность с метриками]
- [Дополнительные преимущества]

**Success Metrics:**
- [Метрика 1]: current [X] → target [Y]
- [Метрика 2]: current [X] → target [Y]

**Strategic Alignment:** [Связь с product roadmap и company OKRs]

**Assumptions & Constraints:**
- [Ключевые предположения]
- [Технические или бизнес ограничения]

---

## 2. User Stories & Acceptance Criteria

### User Story 1: [Название]
**As a** [конкретная user persona с контекстом]  
**I need** [capability с техническими ограничениями]  
**So that** [measurable business outcome]

**Story Points:** [Fibonacci: 1, 2, 3, 5, 8, 13, 21]  
**Priority:** High | Medium | Low  
**Dependencies:** [Другие stories или внешние факторы]

#### BDD Acceptance Criteria:
```gherkin
Feature: [Feature Name]

Background:
  Given [общий контекст для всех сценариев]
  And [дополнительные предусловия]

Scenario: [Primary happy path]
  Given [специфический контекст]
  When [пользовательское действие]
  Then [ожидаемый результат]
  And [дополнительные проверки]

Scenario Outline: [Параметризованные тесты]
  Given [контекст с параметрами]
  When [действие с <параметром>]
  Then [результат с <ожидаемое_значение>]
  
Examples:
  | параметр | ожидаемое_значение |
  | value1   | result1            |
  | value2   | result2            |

Scenario: [Error handling]
  Given [error условие]
  When [trigger action]
  Then [appropriate error response]
  And [system remains stable]
```

### User Story 2: [Название]
[Повторить структуру]

---

## 3. Technical Architecture

### Микросервисная декомпозиция:

- **Service:** [Название сервиса]
  - **Bounded Context:** [DDD контекст]
  - **Core Responsibility:** [Основная ответственность]
  - **Data Ownership:** [Какими данными владеет]
  - **Dependencies:** [От каких сервисов зависит]

### API Contracts (OpenAPI):
```yaml
openapi: 3.0.0
info:
  title: [Service Name] API
  version: 1.0.0
paths:
  /api/v1/resource:
    post:
      summary: [Описание операции]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ResourceRequest'
      responses:
        '201':
          description: Resource created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Resource'
        '400':
          description: Invalid request data
        '409':
          description: Conflict - resource already exists

components:
  schemas:
    ResourceRequest:
      type: object
      required: [field1, field2]
      properties:
        field1:
          type: string
        field2:
          type: integer
```

### Database Schema Changes:
- **Migration:** [Название и описание]
- **Rollback Plan:** [План отката изменений]
- **Data Migration:** [Стратегия миграции данных]
- **Performance Impact:** [Влияние на производительность]

### Integration Points:
- **Synchronous:** 
  - [REST/GraphQL интеграции]
- **Asynchronous:** 
  - [Event-driven коммуникация]
- **External Services:**
  - [Third-party зависимости]

### Non-Functional Requirements:
- **Performance:** [Response time, throughput требования]
- **Scalability:** [Ожидаемая нагрузка и рост]
- **Security:** [Требования безопасности]
- **Monitoring:** [Метрики и алерты]

---

## 4. Definition of Done

### Story Level DoD:
- [ ] Все acceptance criteria выполнены и automated tests проходят
- [ ] **ВСЕ ТЕСТЫ ЗАПУЩЕНЫ ЛОКАЛЬНО И ПРОХОДЯТ** ✅
- [ ] Code coverage >= 80% для новой функциональности
- [ ] **Скриншот/лог успешного прохождения тестов приложен**
- [ ] Security scan passed (SAST/DAST)
- [ ] Performance requirements достигнуты
- [ ] API documentation обновлена
- [ ] Database migrations тестированы

### Integration DoD:
- [ ] Contract tests созданы для всех интеграций
- [ ] End-to-end tests покрывают критические user journeys
- [ ] Monitoring и alerting настроены
- [ ] Feature flags реализованы
- [ ] Rollback plan документирован и протестирован

### Business DoD:
- [ ] Success metrics baseline установлен
- [ ] A/B test plan создан (если применимо)
- [ ] Stakeholder acceptance получен
- [ ] User documentation обновлена
- [ ] Training materials подготовлены

---

## 5. Implementation Plan

### Phases:
1. **Phase 1:** [Описание и timeline]
2. **Phase 2:** [Описание и timeline]
3. **Phase 3:** [Описание и timeline]

### Resource Requirements:
- **Team:** [Необходимые роли и количество]
- **Timeline:** [Общая оценка времени]
- **Budget:** [Если применимо]

### Risks & Mitigation:
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| [Risk 1] | High/Med/Low | High/Med/Low | [План митигации] |
| [Risk 2] | High/Med/Low | High/Med/Low | [План митигации] |

---

## 6. Appendix

### Glossary:
- **[Термин]:** [Определение]

### References:
- [Ссылки на связанные документы]
- [Внешние источники]

### Change Log:
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | YYYY-MM-DD | [Name] | Initial version | 