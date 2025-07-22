# Sprint 49: Спецификация импорта данных из CSV

## 📊 Анализ исходных данных

### 1. OrgChart.csv - Организационная структура
- **Объем**: 226 записей
- **Структура**: Иерархическая с глубиной до 7 уровней
- **Ключевые поля**:
  - `Код подразделения` - уникальный идентификатор (например: АП.2.9.12)
  - `Название подразделения` - полное название
  - `Код родителя` - ссылка на родительское подразделение

### 2. Names.csv - Персонал
- **Объем**: ~1,900 сотрудников
- **Ключевые поля**:
  - `Таб. номер` - уникальный табельный номер (например: АР21000026)
  - `Сотрудник` - ФИО полностью
  - `Должность` - название должности
  - `Код подразделения` - привязка к OrgChart

## 🔄 Алгоритм импорта

### Этап 1: Валидация и подготовка данных

```swift
struct ImportValidator {
    // Проверка структуры CSV
    func validateCSVStructure(_ file: URL) -> ValidationResult {
        - Проверка обязательных колонок
        - Валидация форматов данных
        - Проверка кодировки (UTF-8)
        - Обнаружение дубликатов
    }
    
    // Анализ иерархии
    func analyzeHierarchy(_ orgData: [OrgChartRow]) -> HierarchyAnalysis {
        - Построение дерева подразделений
        - Проверка циклических ссылок
        - Выявление орфанов (подразделений без родителя)
        - Расчет глубины иерархии
    }
}
```

### Этап 2: Импорт организационной структуры

```swift
// 1. Создание корневых подразделений
let rootDepartments = orgData.filter { $0.parentCode == nil || $0.parentCode.isEmpty }

// 2. Рекурсивное создание дочерних подразделений
func importDepartment(_ row: OrgChartRow, level: Int) {
    let department = Department(
        id: generateUUID(),
        code: row.code,           // АП.2.9.12
        name: row.name,           // Операционный директор
        level: level,
        parentCode: row.parentCode,
        path: buildPath(row),     // АП.2/АП.2.9/АП.2.9.12
        metadata: DepartmentMetadata(
            originalCode: row.code,
            importDate: Date(),
            source: "OrgChart.csv"
        )
    )
}

// 3. Построение связей
func linkDepartments() {
    - Установка parent-child связей
    - Расчет полного пути в иерархии
    - Подсчет сотрудников на каждом уровне
}
```

### Этап 3: Импорт персонала и создание пользователей

```swift
// 1. Парсинг ФИО
func parseEmployeeName(_ fullName: String) -> PersonalInfo {
    // "Глебова Дарья Александровна" → 
    let components = fullName.split(separator: " ")
    return PersonalInfo(
        lastName: String(components[0]),     // Глебова
        firstName: String(components[1]),    // Дарья
        middleName: components.count > 2 ? String(components[2]) : nil  // Александровна
    )
}

// 2. Создание сотрудника
func createEmployee(_ row: NameRow) -> Employee {
    let personalInfo = parseEmployeeName(row.employeeName)
    
    return Employee(
        id: generateUUID(),
        tabNumber: row.tabNumber,     // АР21000026
        personalInfo: personalInfo,
        employmentInfo: EmploymentInfo(
            position: findOrCreatePosition(row.position),
            department: findDepartmentByCode(row.departmentCode),
            hireDate: nil  // Будет заполнено из AD
        ),
        userAccount: createUserAccount(personalInfo, row.tabNumber)
    )
}

// 3. Генерация учетных данных
func createUserAccount(_ info: PersonalInfo, _ tabNumber: String) -> UserAccount {
    // Варианты генерации email:
    // 1. firstName.lastName@tsum.ru (darya.glebova@tsum.ru)
    // 2. tabNumber@tsum.ru (ar21000026@tsum.ru)
    // 3. Транслитерация: d.glebova@tsum.ru
    
    let email = generateEmail(info, tabNumber)
    
    return UserAccount(
        email: email,
        username: email.split(separator: "@")[0],
        isActive: true,
        roles: determineRoles(position),
        permissions: []  // Будут назначены позже
    )
}
```

### Этап 4: Обогащение данных из AD

```swift
struct ADEnrichmentService {
    func enrichEmployee(_ employee: Employee) async -> Employee {
        // Поиск в AD по табельному номеру или ФИО
        guard let adUser = await findInAD(employee) else { 
            return employee 
        }
        
        // Обновление данных из AD
        var enriched = employee
        enriched.personalInfo.personalEmail = adUser.personalEmail
        enriched.personalInfo.personalPhone = adUser.mobilePhone
        enriched.personalInfo.photoURL = adUser.thumbnailPhoto
        enriched.employmentInfo.hireDate = adUser.whenCreated
        enriched.userAccount?.lastLoginDate = adUser.lastLogon
        
        return enriched
    }
}
```

### Этап 5: Обработка должностей

```swift
// Автоматическое создание справочника должностей
func processPositions(_ employees: [NameRow]) {
    let uniquePositions = Set(employees.map { $0.position })
    
    for positionName in uniquePositions {
        let position = Position(
            id: generateUUID(),
            name: positionName,
            category: categorizePosition(positionName),
            level: determineLevel(positionName),
            competencies: []  // Будут назначены позже
        )
        
        // Категоризация по ключевым словам
        if positionName.contains("Руководитель") {
            position.category = .management
            position.level = .head
        } else if positionName.contains("Старший") {
            position.level = .senior
        } else if positionName.contains("Ведущий") {
            position.level = .lead
        }
    }
}
```

## 📱 UI для импорта

### ImportWizardView - Пошаговый мастер импорта

```swift
struct ImportWizardView: View {
    @StateObject private var viewModel = ImportWizardViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Progress indicator
                ImportProgressBar(currentStep: viewModel.currentStep)
                
                // Current step content
                Group {
                    switch viewModel.currentStep {
                    case .fileSelection:
                        FileSelectionStep()
                    case .validation:
                        ValidationStep()
                    case .mapping:
                        FieldMappingStep()
                    case .preview:
                        ImportPreviewStep()
                    case .processing:
                        ImportProcessingStep()
                    case .results:
                        ImportResultsStep()
                    }
                }
                
                // Navigation buttons
                ImportNavigationBar(
                    canGoBack: viewModel.canGoBack,
                    canGoNext: viewModel.canGoNext,
                    onBack: viewModel.previousStep,
                    onNext: viewModel.nextStep
                )
            }
        }
    }
}
```

### Интеллектуальный маппинг колонок

```swift
struct SmartColumnMapper {
    // Автоматическое определение соответствий
    func suggestMapping(_ headers: [String]) -> [ColumnMapping] {
        var mappings: [ColumnMapping] = []
        
        for header in headers {
            let normalized = header.lowercased()
            
            // Определение по ключевым словам
            if normalized.contains("таб") && normalized.contains("номер") {
                mappings.append(ColumnMapping(
                    sourceColumn: header,
                    targetField: "tabNumber",
                    confidence: 0.95
                ))
            } else if normalized.contains("сотрудник") || normalized.contains("фио") {
                mappings.append(ColumnMapping(
                    sourceColumn: header,
                    targetField: "fullName",
                    confidence: 0.90
                ))
            } else if normalized.contains("должность") {
                mappings.append(ColumnMapping(
                    sourceColumn: header,
                    targetField: "position",
                    confidence: 0.95
                ))
            }
        }
        
        return mappings
    }
}
```

## 🔐 Правила безопасности при импорте

1. **Валидация табельных номеров**
   - Проверка формата (2 буквы + 8 цифр)
   - Уникальность в системе
   - Соответствие подразделению

2. **Генерация паролей**
   - Временный пароль для первого входа
   - Обязательная смена при первом входе
   - Отправка на личную почту из AD

3. **Логирование**
   - Все операции импорта логируются
   - Возможность отката изменений
   - Аудит trail для compliance

## 📊 Статистика импорта

```swift
struct ImportStatistics {
    let totalDepartments: Int = 226
    let totalEmployees: Int = 1901
    let hierarchyDepth: Int = 7
    
    // Распределение по подразделениям
    let departmentDistribution: [String: Int] = [
        "Дирекция электронной коммерции": 423,
        "Департамент операционной деятельности": 312,
        "Департамент информационных технологий": 189,
        // ...
    ]
    
    // Топ должностей
    let topPositions: [(String, Int)] = [
        ("Кладовщик", 156),
        ("Специалист", 134),
        ("Менеджер", 98),
        ("Руководитель отдела", 67),
        // ...
    ]
}
```

## 🚀 Оптимизации для больших объемов

1. **Batch processing**
   - Импорт по 100 записей за транзакцию
   - Параллельная обработка независимых данных
   - Progress reporting каждые 10%

2. **Кеширование**
   - Кеш подразделений для быстрого поиска
   - Кеш должностей для дедупликации
   - In-memory индексы по ключевым полям

3. **Отказоустойчивость**
   - Checkpoint после каждого этапа
   - Возможность продолжить с места остановки
   - Детальный лог ошибок с указанием строки 