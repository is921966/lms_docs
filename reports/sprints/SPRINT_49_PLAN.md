# Sprint 49: План реализации модуля управления организационной структурой

**Дата начала**: 16 июля 2025  
**Продолжительность**: 5 дней  
**Статус**: 🚀 В процессе

## 🎯 Цель спринта

Реализация полноценной системы управления организационной структурой с автоматическим импортом из CSV файлов и интеграцией с Active Directory.

## 📋 Основные задачи

### День 1 (16 июля) - Backend: Парсинг и валидация
- [ ] Создание CSVParser с поддержкой различных кодировок
- [ ] Реализация EmployeeModel и OrgStructureModel  
- [ ] Валидация иерархии организационной структуры
- [ ] Unit тесты для парсера и моделей

### День 2 (17 июля) - Backend: Orchestrator и API
- [ ] ImportOrchestrator для управления процессом импорта
- [ ] ADSyncService для интеграции с Active Directory (mock)
- [ ] REST API endpoints для импорта
- [ ] Integration тесты для всего backend

### День 3 (18 июля) - iOS: Import Wizard UI
- [ ] ImportWizardView с пошаговым процессом (6 шагов)
- [ ] Drag & drop поддержка для загрузки файлов
- [ ] Визуализация маппинга колонок
- [ ] Progress индикаторы и статистика

### День 4 (19 июля) - iOS: Визуализация и управление  
- [ ] OrgChartView для визуализации структуры (дерево)
- [ ] EmployeeListView с фильтрацией и поиском
- [ ] ConflictResolutionView для обработки дубликатов
- [ ] UI тесты критических путей

### День 5 (20 июля) - Интеграция и TestFlight
- [ ] E2E тесты полного цикла импорта
- [ ] Оптимизация производительности (< 3 мин для 1901 записи)
- [ ] Обработка edge cases
- [ ] Сборка и деплой в TestFlight

## 🏗️ Архитектура решения

### Backend структура:
```
src/
├── OrgStructure/
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── Employee.php
│   │   │   ├── Department.php
│   │   │   └── Position.php
│   │   └── Services/
│   │       └── HierarchyValidator.php
│   ├── Application/
│   │   ├── Services/
│   │   │   ├── CSVParser.php
│   │   │   ├── ImportOrchestrator.php
│   │   │   └── ADSyncService.php
│   │   └── DTOs/
│   │       └── ImportResult.php
│   └── Infrastructure/
│       └── Persistence/
│           └── EmployeeRepository.php
```

### iOS структура:
```
LMS/Features/OrgStructure/
├── Views/
│   ├── ImportWizard/
│   │   ├── ImportWizardView.swift
│   │   ├── FileUploadStep.swift
│   │   ├── ValidationStep.swift
│   │   ├── MappingStep.swift
│   │   ├── PreviewStep.swift
│   │   ├── ImportProgressStep.swift
│   │   └── ResultsStep.swift
│   ├── Visualization/
│   │   ├── OrgChartView.swift
│   │   └── EmployeeNodeView.swift
│   └── Management/
│       ├── EmployeeListView.swift
│       └── ConflictResolutionView.swift
├── ViewModels/
│   ├── ImportWizardViewModel.swift
│   └── OrgStructureViewModel.swift
└── Models/
    └── Employee.swift
```

## 📊 Ожидаемые метрики

- **Производительность**: Импорт 1,901 записей < 3 минут
- **Качество**: 95%+ покрытие тестами
- **Надежность**: 0 потерь данных при импорте
- **UX**: Интуитивный 6-шаговый процесс импорта

## ⚠️ Риски и митигация

1. **Большой объем данных** → Batch обработка с progress индикаторами
2. **Разные форматы CSV** → Умный парсер с автоопределением
3. **Конфликты данных** → UI для разрешения конфликтов
4. **Производительность UI** → Виртуализация для больших списков

## ✅ Критерии успеха

- [ ] Успешный импорт тестового набора данных (1,901 сотрудник)
- [ ] Корректное построение иерархии (226 подразделений)
- [ ] Визуальное отображение оргструктуры
- [ ] Все тесты проходят
- [ ] TestFlight build готов к тестированию 