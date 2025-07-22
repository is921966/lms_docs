# Sprint 49: UI Components Examples

## 1. EmployeeListView - Единый список сотрудников

```swift
struct EmployeeListView: View {
    @StateObject private var viewModel = EmployeeListViewModel()
    @State private var selectedEmployees = Set<String>()
    @State private var showingFilters = false
    @State private var showingBulkActions = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and filter bar
                HStack {
                    SearchBar(text: $viewModel.searchText)
                    
                    Button(action: { showingFilters.toggle() }) {
                        Label("Фильтры", systemImage: "line.3.horizontal.decrease.circle")
                            .labelStyle(.iconOnly)
                    }
                    .overlay(alignment: .topTrailing) {
                        if viewModel.hasActiveFilters {
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 2, y: -2)
                        }
                    }
                }
                .padding()
                
                // Employee list
                List(selection: $selectedEmployees) {
                    ForEach(viewModel.groupedEmployees) { section in
                        Section(section.title) {
                            ForEach(section.employees) { employee in
                                EmployeeRowView(
                                    employee: employee,
                                    showAccountStatus: true,
                                    onTap: {
                                        navigateToDetail(employee)
                                    }
                                )
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await viewModel.refresh()
                }
                
                // Bulk actions toolbar
                if !selectedEmployees.isEmpty {
                    BulkActionsToolbar(
                        selectedCount: selectedEmployees.count,
                        actions: [
                            .createAccounts,
                            .assignRole,
                            .changeManager,
                            .export
                        ],
                        onAction: { action in
                            handleBulkAction(action)
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .navigationTitle("Сотрудники")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { showingImport = true }) {
                            Label("Импорт из Excel", systemImage: "square.and.arrow.down")
                        }
                        
                        Button(action: { showingADSync = true }) {
                            Label("Синхронизация с AD", systemImage: "arrow.triangle.2.circlepath")
                        }
                        
                        Divider()
                        
                        Button(action: { showingCreateEmployee = true }) {
                            Label("Добавить сотрудника", systemImage: "person.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                EmployeeFiltersView(filters: $viewModel.filters)
            }
        }
    }
}
```

## 2. EmployeeDetailView - Детальная карточка сотрудника

```swift
struct EmployeeDetailView: View {
    let employee: Employee
    @StateObject private var viewModel: EmployeeDetailViewModel
    @State private var selectedTab = 0
    
    init(employee: Employee) {
        self.employee = employee
        self._viewModel = StateObject(wrappedValue: EmployeeDetailViewModel(employee: employee))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with photo and basic info
                EmployeeHeaderView(employee: employee)
                    .padding()
                
                // Tab selector
                Picker("", selection: $selectedTab) {
                    Text("Основное").tag(0)
                    Text("Учетная запись").tag(1)
                    Text("Структура").tag(2)
                    Text("Доступы").tag(3)
                    Text("История").tag(4)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Tab content
                Group {
                    switch selectedTab {
                    case 0:
                        PersonalInfoTab(employee: employee)
                    case 1:
                        AccountManagementTab(
                            employee: employee,
                            account: viewModel.userAccount,
                            onCreateAccount: viewModel.createAccount,
                            onResetPassword: viewModel.resetPassword,
                            onBlockAccount: viewModel.toggleAccountBlock
                        )
                    case 2:
                        OrganizationTab(
                            employee: employee,
                            manager: viewModel.manager,
                            subordinates: viewModel.subordinates,
                            colleagues: viewModel.colleagues
                        )
                    case 3:
                        AccessRightsTab(
                            account: viewModel.userAccount,
                            onUpdateRoles: viewModel.updateRoles,
                            onUpdatePermissions: viewModel.updatePermissions
                        )
                    case 4:
                        HistoryTab(changes: viewModel.changeHistory)
                    default:
                        EmptyView()
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { showingEdit = true }) {
                        Label("Редактировать", systemImage: "pencil")
                    }
                    
                    if viewModel.canManageEmployee {
                        Divider()
                        
                        Button(action: viewModel.changeManager) {
                            Label("Изменить руководителя", systemImage: "person.2")
                        }
                        
                        Button(action: viewModel.transferDepartment) {
                            Label("Перевести в другое подразделение", systemImage: "building.2")
                        }
                    }
                    
                    Divider()
                    
                    Button(action: viewModel.exportVCard) {
                        Label("Экспорт vCard", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}
```

## 3. SmartImportView - Интеллектуальный импорт

```swift
struct SmartImportView: View {
    @StateObject private var viewModel = SmartImportViewModel()
    @State private var importStep: ImportStep = .fileUpload
    
    var body: some View {
        NavigationStack {
            VStack {
                // Progress indicator
                ImportProgressBar(currentStep: importStep)
                    .padding()
                
                // Step content
                Group {
                    switch importStep {
                    case .fileUpload:
                        FileUploadStep(
                            onFileSelected: { file in
                                viewModel.processFile(file)
                                importStep = .formatDetection
                            }
                        )
                        
                    case .formatDetection:
                        FormatDetectionStep(
                            detectedFormat: viewModel.detectedFormat,
                            onConfirm: {
                                importStep = .columnMapping
                            }
                        )
                        
                    case .columnMapping:
                        ColumnMappingStep(
                            sourceColumns: viewModel.sourceColumns,
                            mapping: $viewModel.columnMapping,
                            suggestions: viewModel.mappingSuggestions,
                            onComplete: {
                                importStep = .dataValidation
                            }
                        )
                        
                    case .dataValidation:
                        ValidationStep(
                            validationResults: viewModel.validationResults,
                            onFixIssues: viewModel.fixValidationIssues,
                            onProceed: {
                                importStep = .preview
                            }
                        )
                        
                    case .preview:
                        ImportPreviewStep(
                            preview: viewModel.importPreview,
                            onConfirm: {
                                importStep = .processing
                                Task {
                                    await viewModel.performImport()
                                    importStep = .complete
                                }
                            }
                        )
                        
                    case .processing:
                        ProcessingStep(
                            progress: viewModel.importProgress,
                            currentOperation: viewModel.currentOperation
                        )
                        
                    case .complete:
                        CompleteStep(
                            result: viewModel.importResult,
                            onViewEmployees: {
                                // Navigate to employee list
                            },
                            onClose: {
                                dismiss()
                            }
                        )
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                
                Spacer()
            }
            .navigationTitle("Импорт сотрудников")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        showCancelConfirmation = true
                    }
                }
            }
        }
    }
}
```

## 4. OrgChartView - Визуализация оргструктуры

```swift
struct OrgChartView: View {
    @StateObject private var viewModel = OrgChartViewModel()
    @State private var selectedEmployee: Employee?
    @State private var zoomLevel: CGFloat = 1.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Interactive org chart
                ScrollView([.horizontal, .vertical]) {
                    OrgChartCanvas(
                        rootEmployee: viewModel.rootEmployee,
                        selectedEmployee: $selectedEmployee,
                        showRoles: viewModel.showRoles,
                        showPhotos: viewModel.showPhotos
                    )
                    .scaleEffect(zoomLevel)
                    .onTapGesture { location in
                        handleTap(at: location)
                    }
                }
                
                // Controls overlay
                VStack {
                    HStack {
                        // View options
                        Menu {
                            Toggle("Показать роли", isOn: $viewModel.showRoles)
                            Toggle("Показать фото", isOn: $viewModel.showPhotos)
                            Toggle("Показать вакансии", isOn: $viewModel.showVacancies)
                            
                            Divider()
                            
                            Picker("Уровень детализации", selection: $viewModel.detailLevel) {
                                Text("Департаменты").tag(0)
                                Text("Отделы").tag(1)
                                Text("Все сотрудники").tag(2)
                            }
                        } label: {
                            Label("Вид", systemImage: "eye")
                                .padding(8)
                                .background(.regularMaterial)
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        // Zoom controls
                        HStack(spacing: 16) {
                            Button(action: { zoomLevel *= 0.8 }) {
                                Image(systemName: "minus.magnifyingglass")
                            }
                            
                            Text("\(Int(zoomLevel * 100))%")
                                .font(.caption)
                                .frame(width: 50)
                            
                            Button(action: { zoomLevel *= 1.2 }) {
                                Image(systemName: "plus.magnifyingglass")
                            }
                        }
                        .padding(8)
                        .background(.regularMaterial)
                        .cornerRadius(8)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Selected employee card
                    if let employee = selectedEmployee {
                        EmployeeQuickCard(
                            employee: employee,
                            onViewDetails: {
                                navigateToEmployee(employee)
                            },
                            onClose: {
                                selectedEmployee = nil
                            }
                        )
                        .padding()
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationTitle("Организационная структура")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: viewModel.exportChart) {
                        Label("Экспорт", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}
```

## 5. AccessMatrixView - Матрица доступов

```swift
struct AccessMatrixView: View {
    @StateObject private var viewModel = AccessMatrixViewModel()
    @State private var selectedDepartment: Department?
    @State private var selectedRole: Role?
    
    var body: some View {
        NavigationStack {
            HSplitView {
                // Department tree
                DepartmentTreeView(
                    departments: viewModel.departments,
                    selectedDepartment: $selectedDepartment
                )
                .frame(minWidth: 250, idealWidth: 300, maxWidth: 400)
                
                // Access matrix
                if let department = selectedDepartment {
                    VStack {
                        // Department header
                        DepartmentAccessHeader(
                            department: department,
                            stats: viewModel.getStats(for: department)
                        )
                        
                        // Role matrix
                        ScrollView {
                            LazyVGrid(
                                columns: viewModel.roleColumns,
                                spacing: 16
                            ) {
                                ForEach(viewModel.getRoles(for: department)) { role in
                                    RoleCard(
                                        role: role,
                                        employeeCount: viewModel.getEmployeeCount(for: role, in: department),
                                        isInherited: viewModel.isInherited(role, in: department),
                                        onTap: {
                                            selectedRole = role
                                        }
                                    )
                                }
                            }
                            .padding()
                        }
                        
                        // Quick actions
                        HStack {
                            Button("Добавить роль") {
                                showingAddRole = true
                            }
                            
                            Button("Массовое назначение") {
                                showingBulkAssign = true
                            }
                            
                            Spacer()
                            
                            Button("Аудит доступов") {
                                showingAudit = true
                            }
                        }
                        .padding()
                    }
                } else {
                    ContentUnavailableView(
                        "Выберите подразделение",
                        systemImage: "building.2",
                        description: Text("Выберите подразделение слева для просмотра матрицы доступов")
                    )
                }
            }
            .navigationTitle("Матрица доступов")
        }
    }
}
``` 