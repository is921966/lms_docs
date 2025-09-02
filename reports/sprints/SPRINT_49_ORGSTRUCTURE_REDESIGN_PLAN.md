# Sprint 49: Переработка модулей "Оргструктура" и "Управление пользователями"

**Sprint**: 49  
**Даты**: 21-27 июля 2025  
**Цель**: Создать единую интегрированную систему управления организационной структурой и пользователями с синхронизацией Active Directory

## 🎯 Проблемы текущей реализации

### 1. Разрозненность данных
- Сотрудники оргструктуры (OrgEmployee) не связаны с пользователями системы (User)
- Дублирование информации в разных таблицах
- Отсутствие синхронизации между модулями

### 2. Ограничения функциональности
- Нет привязки пользователей к должностям
- Отсутствует иерархия подчинения
- Нет автоматической синхронизации с AD/LDAP
- Импорт работает только для структуры, но не для пользователей

### 3. Архитектурные проблемы
- Модули не интегрированы между собой
- Отсутствует единая модель данных
- Нет событийной модели для синхронизации

## 🏗️ Новая архитектура

### Концепция: Единая модель "Сотрудник-Пользователь"

```
Organization (Компания)
    ├── Departments (Подразделения)
    │   └── Positions (Должности)
    │       └── Employees (Сотрудники)
    │           └── UserAccounts (Учетные записи)
```

### Ключевые изменения:

1. **Employee** становится центральной сущностью
2. **User** - это учетная запись сотрудника
3. **Position** привязана к подразделению
4. Полная интеграция с AD/LDAP

## 📋 Детальный план переработки

### День 1: Новая модель данных

#### Backend (Domain Layer):
```php
// Employee - центральная сущность
class Employee {
    - id: UUID
    - tabNumber: string (уникальный)
    - personalInfo: PersonalInfo
    - position: Position
    - department: Department
    - manager: Employee?
    - userAccount: User?
    - contacts: ContactInfo
    - employmentInfo: EmploymentInfo
    - competencies: CompetencyProfile
    - status: EmployeeStatus
}

// User - учетная запись
class User {
    - id: UUID
    - employee: Employee
    - email: string
    - adUsername: string?
    - roles: Role[]
    - permissions: Permission[]
    - authInfo: AuthenticationInfo
    - lastActivity: ActivityInfo
}

// Position - должность в структуре
class Position {
    - id: UUID
    - title: string
    - code: string
    - department: Department
    - level: PositionLevel
    - requirements: PositionRequirements
    - subordinatePositions: Position[]
}
```

#### iOS Models:
```swift
struct Employee: Identifiable {
    let id: String
    let tabNumber: String
    let fullName: String
    let position: Position
    let department: Department
    let manager: Employee?
    let userAccount: UserAccount?
    let contacts: ContactInfo
    let photoURL: URL?
    let isActive: Bool
}

struct UserAccount: Identifiable {
    let id: String
    let email: String
    let roles: [Role]
    let permissions: Set<Permission>
    let lastLogin: Date?
    let isBlocked: Bool
}
```

### День 2: Синхронизация с AD/LDAP

#### Сервис синхронизации:
```swift
class ADSyncService {
    // Полная синхронизация
    func fullSync() async throws -> SyncResult
    
    // Инкрементальная синхронизация
    func incrementalSync(since: Date) async throws -> SyncResult
    
    // Синхронизация конкретного сотрудника
    func syncEmployee(adUsername: String) async throws -> Employee
    
    // Маппинг AD атрибутов
    func mapADAttributes(_ adUser: ADUser) -> Employee
}
```

#### Автоматизация:
- Ежедневная полная синхронизация в 3:00
- Инкрементальная синхронизация каждые 4 часа
- Webhook для real-time обновлений
- Обработка конфликтов и merge стратегии

### День 3: Unified Employee Management View

#### Новый интерфейс управления:
```swift
struct EmployeeManagementView: View {
    // Единый список всех сотрудников
    // Фильтры: подразделение, должность, статус, роль
    // Быстрые действия: создать учетку, заблокировать, назначить роль
    // Bulk операции: импорт, экспорт, массовое обновление
}

struct EmployeeDetailView: View {
    // Вкладки:
    // - Основная информация
    // - Учетная запись и доступы
    // - Организационная структура
    // - Компетенции и развитие
    // - История изменений
}
```

### День 4: Smart Import с автоматическим созданием пользователей

#### Улучшенный импорт:
```swift
class SmartImportService {
    // Парсинг Excel с авто-определением формата
    func parseExcelFile(_ file: Data) -> ImportPreview
    
    // Интеллектуальный маппинг колонок
    func autoMapColumns(_ columns: [String]) -> ColumnMapping
    
    // Валидация и обогащение данных
    func validateAndEnrich(_ data: ImportData) -> ValidationResult
    
    // Создание сотрудников и учетных записей
    func performImport(_ validated: ValidatedData) -> ImportResult
}
```

#### Функции импорта:
- Автоматическое определение формата
- Обогащение данных из AD
- Создание учетных записей с временными паролями
- Отправка приглашений на email
- Детальный отчет об импорте

### День 5: Иерархический вид с ролями и правами

#### Визуализация структуры:
```swift
struct OrgChartView: View {
    // Org Chart визуализация
    // Показ ролей и прав доступа
    // Drag & drop для изменения структуры
    // Предпросмотр изменений
}

struct AccessMatrixView: View {
    // Матрица доступов по подразделениям
    // Визуализация наследования прав
    // Быстрое назначение ролей
    // Аудит доступов
}
```

### День 6: API и интеграции

#### RESTful API v2:
```yaml
# Employees
GET    /api/v2/employees
GET    /api/v2/employees/{id}
POST   /api/v2/employees
PUT    /api/v2/employees/{id}
DELETE /api/v2/employees/{id}
POST   /api/v2/employees/bulk-import
GET    /api/v2/employees/{id}/subordinates
GET    /api/v2/employees/{id}/access-rights

# Sync
POST   /api/v2/sync/ad/full
POST   /api/v2/sync/ad/incremental
GET    /api/v2/sync/status
GET    /api/v2/sync/conflicts

# Organization
GET    /api/v2/organization/structure
GET    /api/v2/organization/chart
POST   /api/v2/organization/restructure
```

### День 7: Миграция данных и TestFlight

#### Миграция существующих данных:
1. Объединение таблиц users и org_employees
2. Создание связей между сущностями
3. Импорт недостающих данных из AD
4. Валидация целостности данных
5. Резервное копирование

## 🎨 UI/UX улучшения

### 1. Unified Employee Card:
- Фото сотрудника (из AD или загруженное)
- Полная информация в одном месте
- Quick actions: позвонить, написать, изменить доступы
- Визуальные индикаторы статуса

### 2. Smart Search:
- Поиск по всем атрибутам
- Fuzzy matching для имен
- Поиск по иерархии ("все подчиненные Иванова")
- Сохраненные фильтры

### 3. Drag & Drop Management:
- Перемещение сотрудников между подразделениями
- Изменение подчинения
- Массовое назначение ролей
- Предпросмотр изменений

## 📊 Метрики успеха

1. **Интеграция**:
   - 100% сотрудников связаны с учетными записями
   - Автоматическая синхронизация с AD работает
   - Импорт создает полноценные профили

2. **Производительность**:
   - Загрузка структуры 1000+ сотрудников < 2 сек
   - Поиск < 100мс
   - Синхронизация AD < 5 мин

3. **Удобство**:
   - Единая точка управления сотрудниками
   - Сокращение времени на администрирование на 50%
   - 0 дублирования данных

## 🔗 Интеграции

- **Active Directory**: полная двусторонняя синхронизация
- **Email сервис**: отправка приглашений и уведомлений
- **HR системы**: импорт/экспорт данных
- **Модуль компетенций**: автоматическая привязка
- **Модуль обучения**: назначение курсов по должностям

## 🚀 Результат

Единая система управления персоналом, которая:
- Автоматически синхронизируется с корпоративными системами
- Предоставляет полную картину организационной структуры
- Упрощает управление доступами и ролями
- Интегрирована со всеми модулями LMS
- Готова к масштабированию на 10000+ сотрудников 