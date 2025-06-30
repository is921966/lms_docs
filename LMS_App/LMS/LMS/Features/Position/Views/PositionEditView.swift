import SwiftUI

struct PositionEditView: View {
    let position: Position?
    let onSave: (Position) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var competencyService = CompetencyMockService.shared

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var department: String = ""
    @State private var level: PositionLevel = .junior
    @State private var isActive: Bool = true
    @State private var employeeCount: Int = 0
    @State private var competencyRequirements: [CompetencyRequirement] = []

    @State private var showingCompetencyPicker = false
    @State private var editingRequirement: CompetencyRequirement?

    init(position: Position?, onSave: @escaping (Position) -> Void) {
        self.position = position
        self.onSave = onSave
    }

    var body: some View {
        Form {
            // Basic information
            basicInfoSection

            // Level and department
            organizationSection

            // Competency requirements
            competencySection

            // Status
            statusSection
        }
        .navigationTitle(position == nil ? "Новая должность" : "Редактирование")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showingCompetencyPicker) {
            CompetencyPickerView { competency in
                addCompetencyRequirement(competency)
            }
        }
        .sheet(item: $editingRequirement) { requirement in
            RequirementEditView(
                requirement: requirement,
                onSave: { updated in
                    updateRequirement(updated)
                }
            )
        }
        .onAppear {
            loadPositionData()
        }
    }

    // MARK: - Sections

    private var basicInfoSection: some View {
        Section("Основная информация") {
            TextField("Название должности", text: $name)

            TextField("Описание", text: $description, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    private var organizationSection: some View {
        Section("Организация") {
            TextField("Отдел", text: $department)

            Picker("Уровень", selection: $level) {
                ForEach(PositionLevel.allCases, id: \.self) { level in
                    HStack {
                        Image(systemName: level.icon)
                            .foregroundColor(level.color)
                        Text(level.rawValue)
                    }
                    .tag(level)
                }
            }

            Stepper("Сотрудников: \(employeeCount)", value: $employeeCount, in: 0...999)
        }
    }

    private var competencySection: some View {
        Section {
            if competencyRequirements.isEmpty {
                emptyCompetencyState
            } else {
                ForEach(competencyRequirements) { requirement in
                    CompetencyRequirementEditRow(requirement: requirement) {
                        editingRequirement = requirement
                    } onDelete: {
                        removeRequirement(requirement)
                    }
                }
            }

            Button(action: { showingCompetencyPicker = true }) {
                Label("Добавить компетенцию", systemImage: "plus.circle.fill")
            }
        } header: {
            HStack {
                Text("Требуемые компетенции")
                Spacer()
                Text("\(competencyRequirements.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var statusSection: some View {
        Section("Статус") {
            Toggle("Активная должность", isOn: $isActive)
        }
    }

    private var emptyCompetencyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "star.slash")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Компетенции не добавлены")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Отмена") {
                dismiss()
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Сохранить") {
                savePosition()
            }
            .fontWeight(.semibold)
            .disabled(!isValid)
        }
    }

    // MARK: - Methods

    private func loadPositionData() {
        guard let position = position else { return }

        name = position.name
        description = position.description
        department = position.department
        level = position.level
        isActive = position.isActive
        employeeCount = position.employeeCount
        competencyRequirements = position.competencyRequirements
    }

    private func savePosition() {
        let updatedPosition = Position(
            id: position?.id ?? UUID(),
            name: name,
            description: description,
            department: department,
            level: level,
            competencyRequirements: competencyRequirements,
            careerPaths: position?.careerPaths ?? [],
            isActive: isActive,
            employeeCount: employeeCount,
            createdAt: position?.createdAt ?? Date(),
            updatedAt: Date()
        )

        onSave(updatedPosition)
        dismiss()
    }

    private func addCompetencyRequirement(_ competency: Competency) {
        let requirement = CompetencyRequirement(
            competencyId: competency.id,
            competencyName: competency.name,
            requiredLevel: 3,
            isCritical: false
        )
        competencyRequirements.append(requirement)
    }

    private func updateRequirement(_ updated: CompetencyRequirement) {
        if let index = competencyRequirements.firstIndex(where: { $0.id == updated.id }) {
            competencyRequirements[index] = updated
        }
    }

    private func removeRequirement(_ requirement: CompetencyRequirement) {
        competencyRequirements.removeAll { $0.id == requirement.id }
    }

    private var isValid: Bool {
        !name.isEmpty && !department.isEmpty
    }
}

// MARK: - Competency Picker

struct CompetencyPickerView: View {
    let onSelect: (Competency) -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var service = CompetencyMockService.shared
    @State private var searchText = ""

    var filteredCompetencies: [Competency] {
        if searchText.isEmpty {
            return service.competencies
        }
        return service.searchCompetencies(query: searchText)
    }

    var body: some View {
        NavigationStack {
            List(filteredCompetencies) { competency in
                CompetencySelectionRow(competency: competency) {
                    onSelect(competency)
                    dismiss()
                }
            }
            .searchable(text: $searchText, prompt: "Поиск компетенций")
            .navigationTitle("Выбор компетенции")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CompetencySelectionRow: View {
    let competency: Competency
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Circle()
                    .fill(Color(hex: competency.color.rawValue))
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(competency.name)
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    Text(competency.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Requirement Edit View

struct RequirementEditView: View {
    let requirement: CompetencyRequirement
    let onSave: (CompetencyRequirement) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var requiredLevel: Int
    @State private var isCritical: Bool

    init(requirement: CompetencyRequirement, onSave: @escaping (CompetencyRequirement) -> Void) {
        self.requirement = requirement
        self.onSave = onSave
        _requiredLevel = State(initialValue: requirement.requiredLevel)
        _isCritical = State(initialValue: requirement.isCritical)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Компетенция") {
                    HStack {
                        Text(requirement.competencyName)
                            .font(.headline)
                        Spacer()
                    }
                }

                Section("Требуемый уровень") {
                    Picker("Уровень", selection: $requiredLevel) {
                        ForEach(1...5, id: \.self) { level in
                            HStack {
                                Text("Уровень \(level)")
                                Spacer()
                                LevelIndicator(level: level)
                            }
                            .tag(level)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section("Важность") {
                    Toggle("Критичная компетенция", isOn: $isCritical)

                    Text(isCritical ?
                        "Обязательная для выполнения должностных обязанностей" :
                        "Желательная, но не обязательная компетенция"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Редактирование требования")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveRequirement()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveRequirement() {
        var updated = requirement
        updated.requiredLevel = requiredLevel
        updated.isCritical = isCritical
        onSave(updated)
        dismiss()
    }
}

// MARK: - Supporting Views

struct CompetencyRequirementEditRow: View {
    let requirement: CompetencyRequirement
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(requirement.competencyName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if requirement.isCritical {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }

                Menu {
                    Button(action: onEdit) {
                        Label("Изменить", systemImage: "pencil")
                    }

                    Button(role: .destructive, action: onDelete) {
                        Label("Удалить", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }

            HStack {
                Text("Уровень \(requirement.requiredLevel)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                LevelIndicator(level: requirement.requiredLevel)
            }
        }
        .padding(.vertical, 4)
    }
}
