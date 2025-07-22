# Sprint 49: Техническое задание - Импорт CSV

## 1. Модуль CSVImportService

### 1.1 Основные компоненты

```swift
// MARK: - CSV Parser
class CSVParser {
    func parse(fileURL: URL) throws -> CSVData {
        // Автоопределение разделителя (запятая/точка с запятой)
        // Обработка кавычек и экранирования
        // Поддержка UTF-8, Windows-1251
    }
}

// MARK: - Import Orchestrator
class ImportOrchestrator {
    private let orgChartImporter: OrgChartImporter
    private let employeeImporter: EmployeeImporter
    private let adEnricher: ADEnrichmentService
    
    func executeImport(
        orgChartFile: URL,
        namesFile: URL,
        options: ImportOptions
    ) async throws -> ImportResult {
        // 1. Валидация файлов
        // 2. Импорт оргструктуры
        // 3. Импорт сотрудников
        // 4. Обогащение из AD
        // 5. Создание учетных записей
    }
}
```

### 1.2 Обработка ошибок

```swift
enum ImportError: Error {
    case invalidFileFormat
    case missingRequiredColumns([String])
    case duplicateTabNumber(String)
    case departmentNotFound(String)
    case cyclicHierarchy([String])
    case adConnectionFailed
}

struct ImportResult {
    let successCount: Int
    let failedCount: Int
    let warnings: [ImportWarning]
    let errors: [ImportError]
    let importLog: URL
}
```

## 2. UI компоненты

### 2.1 ImportWizardView

```swift
struct ImportWizardView: View {
    @StateObject private var viewModel = ImportWizardViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Прогресс бар
                ImportProgressBar(
                    steps: ImportStep.allCases,
                    currentStep: viewModel.currentStep
                )
                .padding()
                
                // Контент текущего шага
                ImportStepContent(
                    step: viewModel.currentStep,
                    viewModel: viewModel
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Кнопки навигации
                ImportNavigationBar(viewModel: viewModel)
                    .padding()
            }
        }
        .sheet(isPresented: $viewModel.showingResults) {
            ImportResultsView(result: viewModel.importResult)
        }
    }
}
```

### 2.2 Предпросмотр импорта

```swift
struct ImportPreviewView: View {
    let departments: [DepartmentPreview]
    let employees: [EmployeePreview]
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Вкладка подразделений
            DepartmentHierarchyView(departments: departments)
                .tabItem {
                    Label("Подразделения (\(departments.count))", 
                          systemImage: "building.2")
                }
                .tag(0)
            
            // Вкладка сотрудников
            EmployeeListPreview(employees: employees)
                .tabItem {
                    Label("Сотрудники (\(employees.count))", 
                          systemImage: "person.3")
                }
                .tag(1)
            
            // Вкладка проблем
            ImportIssuesView(issues: viewModel.validationIssues)
                .tabItem {
                    Label("Проблемы (\(viewModel.issueCount))", 
                          systemImage: "exclamationmark.triangle")
                }
                .tag(2)
        }
    }
}
```

## 3. Backend API

### 3.1 Endpoints

```yaml
# Загрузка CSV файлов
POST /api/v1/import/upload
  Request:
    - orgChartFile: multipart/form-data
    - namesFile: multipart/form-data
  Response:
    - uploadId: string
    - validation: ValidationResult

# Предпросмотр импорта
POST /api/v1/import/{uploadId}/preview
  Request:
    - mappingRules: ColumnMapping[]
  Response:
    - departments: DepartmentPreview[]
    - employees: EmployeePreview[]
    - issues: ImportIssue[]

# Выполнение импорта
POST /api/v1/import/{uploadId}/execute
  Request:
    - options: ImportOptions
    - confirmDuplicates: boolean
  Response:
    - importId: string
    - status: ImportStatus

# Статус импорта
GET /api/v1/import/{importId}/status
  Response:
    - progress: number (0-100)
    - currentStep: string
    - processed: number
    - total: number
    - errors: ImportError[]
```

### 3.2 Фоновые задачи

```php
// ImportJob.php
class ImportJob implements ShouldQueue
{
    public function handle(
        CSVImporter $importer,
        ADSyncService $adSync,
        NotificationService $notifier
    ) {
        // 1. Импорт подразделений
        $departments = $importer->importDepartments($this->orgChartPath);
        
        // 2. Импорт сотрудников
        $employees = $importer->importEmployees($this->namesPath);
        
        // 3. Синхронизация с AD
        foreach ($employees as $employee) {
            $adData = $adSync->findUser($employee->tabNumber);
            if ($adData) {
                $employee->enrichFromAD($adData);
            }
        }
        
        // 4. Уведомление о завершении
        $notifier->notifyImportComplete($this->userId, $result);
    }
}
```

## 4. Интеграция с AD

### 4.1 Стратегии поиска

```swift
struct ADSearchStrategy {
    // Поиск по табельному номеру
    func searchByTabNumber(_ tabNumber: String) -> ADSearchQuery {
        return ADSearchQuery(
            filter: "(employeeID=\(tabNumber))",
            attributes: ADUser.requiredAttributes
        )
    }
    
    // Поиск по ФИО
    func searchByFullName(_ name: PersonalInfo) -> ADSearchQuery {
        return ADSearchQuery(
            filter: "(&(sn=\(name.lastName))(givenName=\(name.firstName)))",
            attributes: ADUser.requiredAttributes
        )
    }
    
    // Массовый поиск
    func batchSearch(_ employees: [Employee]) -> ADBatchQuery {
        let filters = employees.map { emp in
            "(employeeID=\(emp.tabNumber))"
        }.joined(separator: "")
        
        return ADBatchQuery(
            filter: "(|\(filters))",
            pageSize: 100
        )
    }
}
```

### 4.2 Маппинг полей AD → Employee

```swift
extension Employee {
    mutating func enrichFromAD(_ adUser: ADUser) {
        // Персональные данные
        personalInfo.personalEmail = adUser.mail
        personalInfo.personalPhone = adUser.mobile
        personalInfo.birthDate = adUser.extensionAttribute1.toDate()
        
        // Рабочие данные
        employmentInfo.workPhone = adUser.telephoneNumber
        employmentInfo.officeLocation = adUser.physicalDeliveryOfficeName
        employmentInfo.hireDate = adUser.whenCreated
        
        // Учетная запись
        if userAccount == nil {
            userAccount = UserAccount(
                email: adUser.userPrincipalName,
                username: adUser.sAMAccountName,
                isActive: !adUser.userAccountControl.contains(.accountDisabled)
            )
        }
    }
}
```

## 5. Обработка конфликтов

### 5.1 Стратегии разрешения

```swift
enum ConflictResolution {
    case keepExisting      // Оставить существующие данные
    case updateFromCSV     // Обновить из CSV
    case updateFromAD      // Обновить из AD
    case merge            // Объединить данные
    case manual           // Ручное разрешение
}

struct ImportConflict {
    let employee: Employee
    let field: String
    let existingValue: Any?
    let csvValue: Any?
    let adValue: Any?
    var resolution: ConflictResolution = .manual
}
```

### 5.2 UI для разрешения конфликтов

```swift
struct ConflictResolutionView: View {
    @Binding var conflicts: [ImportConflict]
    
    var body: some View {
        List(conflicts.indices, id: \.self) { index in
            ConflictRow(conflict: $conflicts[index])
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu("Применить ко всем") {
                    Button("Оставить существующие") {
                        applyToAll(.keepExisting)
                    }
                    Button("Обновить из CSV") {
                        applyToAll(.updateFromCSV)
                    }
                    Button("Обновить из AD") {
                        applyToAll(.updateFromAD)
                    }
                }
            }
        }
    }
}
```

## 6. Мониторинг и логирование

```swift
struct ImportLogger {
    func logImportStart(files: [URL], user: String) {
        logger.info("Import started", metadata: [
            "user": .string(user),
            "orgChart": .string(files[0].lastPathComponent),
            "names": .string(files[1].lastPathComponent),
            "timestamp": .date(Date())
        ])
    }
    
    func logValidationError(error: ValidationError, row: Int) {
        logger.error("Validation failed", metadata: [
            "error": .string(error.localizedDescription),
            "row": .int(row),
            "field": .string(error.field)
        ])
    }
    
    func generateReport() -> ImportReport {
        return ImportReport(
            totalProcessed: processed,
            successCount: success,
            errorCount: errors.count,
            duration: Date().timeIntervalSince(startTime),
            detailedErrors: errors
        )
    }
}
```

## 7. Требования к производительности

- Импорт 2000 сотрудников: < 3 минуты
- Валидация CSV: < 5 секунд
- Синхронизация с AD: batch по 100 записей
- UI отзывчивость: обновление прогресса каждую секунду
- Память: < 200MB для импорта 10,000 записей 