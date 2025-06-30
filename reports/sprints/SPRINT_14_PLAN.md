# 📋 SPRINT 14 PLAN - Phase 1: Cursor Rules & BDD Foundation

**Sprint:** 14  
**Dates:** 2025-06-30 → 2025-07-02 (3 дня)  
**Goal:** Создание полной системы Cursor Rules и внедрение первых BDD сценариев  
**Phase:** 1 из 4 (Methodology v1.8.0 Implementation)

## 🎯 Sprint Goals

1. **Создать полное содержимое всех 7 файлов Cursor Rules**
2. **Настроить SwiftLint в проекте LMS**
3. **Написать первые BDD сценарии для критических функций**
4. **Обновить локальный проект с новой методологией**

## 📝 User Stories

### Story 1: Полная реализация Cursor Rules
**As a** разработчик  
**I want** иметь полный набор правил для Cursor IDE  
**So that** AI-ассистент генерирует качественный код с первой попытки

**Acceptance Criteria:**
```gherkin
Given файлы правил в .cursor/rules/
When я открываю проект в Cursor
Then AI использует все 7 файлов правил
And генерирует код согласно архитектурным принципам
```

**Tasks:**
- [ ] Создать полное содержимое architecture.mdc
- [ ] Создать полное содержимое ui-guidelines.mdc
- [ ] Создать полное содержимое testing.mdc
- [ ] Создать полное содержимое naming-and-structure.mdc
- [ ] Создать полное содержимое client-server-integration.mdc
- [ ] Создать полное содержимое ci-cd-review.mdc
- [ ] Создать полное содержимое ai-interaction.mdc

### Story 2: SwiftLint Configuration
**As a** team lead  
**I want** автоматическую проверку стиля кода  
**So that** код соответствует единым стандартам

**Acceptance Criteria:**
```gherkin
Given SwiftLint установлен в проекте
When я запускаю build
Then SwiftLint проверяет все Swift файлы
And выдает ошибки при нарушении правил
```

**Tasks:**
- [ ] Создать .swiftlint.yml с правилами
- [ ] Добавить SwiftLint в build phase
- [ ] Настроить custom rules для проекта
- [ ] Исправить существующие warnings

### Story 3: BDD Scenarios Implementation
**As a** QA engineer  
**I want** BDD сценарии для критических функций  
**So that** требования становятся исполняемой документацией

**Acceptance Criteria:**
```gherkin
Given Quick/Nimble фреймворк установлен
When я запускаю BDD тесты
Then сценарии выполняются и проходят
And генерируется readable отчет
```

**Tasks:**
- [ ] Установить Quick/Nimble через SPM
- [ ] Создать features/Authentication.feature
- [ ] Создать features/CourseEnrollment.feature
- [ ] Создать features/CompetencyProgress.feature
- [ ] Написать step definitions
- [ ] Интегрировать с существующими UI тестами

### Story 4: Methodology Integration
**As a** developer  
**I want** обновленную методологию в проекте  
**So that** могу использовать все новые возможности

**Acceptance Criteria:**
```gherkin
Given методология v1.8.0 синхронизирована
When я работаю в Cursor IDE
Then используются новые правила
And AI генерирует код по новым стандартам
```

**Tasks:**
- [ ] Обновить .cursorrules из центрального репозитория
- [ ] Скопировать все файлы правил
- [ ] Обновить README с новыми инструкциями
- [ ] Провести тестирование с AI

## 📊 Definition of Done

### Story Level:
- [ ] Все файлы правил содержат полную реализацию
- [ ] SwiftLint проходит без критических ошибок
- [ ] BDD сценарии запускаются и проходят
- [ ] Документация обновлена
- [ ] Code review пройден

### Sprint Level:
- [ ] Все 7 файлов правил готовы к использованию
- [ ] SwiftLint интегрирован в CI/CD
- [ ] Минимум 10 BDD сценариев реализовано
- [ ] Методология протестирована с AI
- [ ] Команда обучена новым практикам

## 🏗️ Technical Tasks

### Day 1: Cursor Rules Implementation
1. architecture.mdc - Clean Architecture, SOLID, DDD
2. ui-guidelines.mdc - SwiftUI, HIG, Accessibility
3. testing.mdc - TDD/BDD с Gherkin

### Day 2: Cursor Rules & SwiftLint
1. naming-and-structure.mdc - Swift conventions
2. client-server-integration.mdc - API, DTO, network
3. ci-cd-review.mdc - CI/CD, code review
4. ai-interaction.mdc - AI security
5. SwiftLint setup и configuration

### Day 3: BDD Implementation
1. Quick/Nimble installation
2. Feature files creation
3. Step definitions
4. Integration с UI tests
5. Final testing и documentation

## 🚀 Expected Outcomes

1. **Качество кода**: AI генерирует код согласно архитектуре с первой попытки в 75%+ случаев
2. **Стиль кода**: 0 SwiftLint warnings в новом коде
3. **Живая документация**: BDD сценарии служат исполняемой спецификацией
4. **Скорость разработки**: Снижение времени на code review на 30%

## 🔄 Dependencies

- Центральный репозиторий методологии обновлен ✅
- Cursor IDE установлен у всех разработчиков
- Доступ к GitHub для CI/CD настройки
- TestFlight для тестирования

## 📈 Success Metrics

- Все 7 файлов правил реализованы: 100%
- SwiftLint coverage: 100% файлов
- BDD scenarios written: 10+
- AI code generation success rate: 75%+

---

**Sprint Status:** 🟡 Planning
**Start Date:** 2025-06-30
**Team Velocity:** 40 story points 