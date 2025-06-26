import SwiftUI

struct CompetencyEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    let competency: Competency?
    let onSave: (Competency) -> Void
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: CompetencyCategory = .technical
    @State private var selectedColor: CompetencyColor = .blue
    @State private var levels: [CompetencyLevel] = CompetencyLevel.defaultLevels()
    @State private var isActive: Bool = true
    @State private var relatedPositions: [String] = []
    @State private var newPosition: String = ""
    
    @State private var showingLevelEditor = false
    @State private var editingLevel: CompetencyLevel?
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    var isEditing: Bool {
        competency != nil
    }
    
    init(competency: Competency?, onSave: @escaping (Competency) -> Void) {
        self.competency = competency
        self.onSave = onSave
    }
    
    var body: some View {
        Form {
            // Basic info
            basicInfoSection
            
            // Category and color
            appearanceSection
            
            // Levels
            levelsSection
            
            // Related positions
            positionsSection
            
            // Status
            if isEditing {
                statusSection
            }
        }
        .navigationTitle(isEditing ? "Редактировать" : "Новая компетенция")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Отмена") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Сохранить") {
                    saveCompetency()
                }
                .fontWeight(.semibold)
                .disabled(name.isEmpty)
            }
        }
        .onAppear {
            if let competency = competency {
                loadCompetencyData(competency)
            }
        }
        .alert("Ошибка", isPresented: $showingValidationAlert) {
            Button("OK") { }
        } message: {
            Text(validationMessage)
        }
        .sheet(item: $editingLevel) { level in
            NavigationStack {
                LevelEditView(level: level) { updatedLevel in
                    updateLevel(updatedLevel)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var basicInfoSection: some View {
        Section("Основная информация") {
            TextField("Название компетенции", text: $name)
            
            VStack(alignment: .leading) {
                Text("Описание")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $description)
                    .frame(minHeight: 100)
            }
        }
    }
    
    private var appearanceSection: some View {
        Section("Категория и визуализация") {
            Picker("Категория", selection: $selectedCategory) {
                ForEach(CompetencyCategory.allCases, id: \.self) { category in
                    Label(category.rawValue, systemImage: category.icon)
                        .tag(category)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Цвет")
                    .font(.subheadline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(CompetencyColor.allCases, id: \.self) { color in
                        ColorOption(
                            color: color,
                            isSelected: selectedColor == color
                        ) {
                            selectedColor = color
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var levelsSection: some View {
        Section("Уровни компетенции") {
            ForEach(levels) { level in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Уровень \(level.level): \(level.name)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(level.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button(action: { editingLevel = level }) {
                        Image(systemName: "pencil.circle")
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.vertical, 4)
            }
            
            Button(action: { addLevel() }) {
                Label("Добавить уровень", systemImage: "plus.circle")
            }
        }
    }
    
    private var positionsSection: some View {
        Section("Связанные должности") {
            ForEach(relatedPositions, id: \.self) { position in
                HStack {
                    Text(position)
                    Spacer()
                    Button(action: { removePosition(position) }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack {
                TextField("Добавить должность", text: $newPosition)
                    .textFieldStyle(.plain)
                
                Button(action: addPosition) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                }
                .disabled(newPosition.isEmpty)
            }
        }
    }
    
    private var statusSection: some View {
        Section("Статус") {
            Toggle("Активна", isOn: $isActive)
        }
    }
    
    // MARK: - Actions
    
    private func loadCompetencyData(_ competency: Competency) {
        name = competency.name
        description = competency.description
        selectedCategory = competency.category
        selectedColor = competency.color
        levels = competency.levels
        isActive = competency.isActive
        relatedPositions = competency.relatedPositions
    }
    
    private func saveCompetency() {
        guard validateCompetency() else { return }
        
        let newCompetency = Competency(
            id: competency?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            color: selectedColor,
            levels: levels,
            isActive: isActive,
            relatedPositions: relatedPositions,
            createdAt: competency?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        onSave(newCompetency)
        dismiss()
    }
    
    private func validateCompetency() -> Bool {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Название компетенции не может быть пустым"
            showingValidationAlert = true
            return false
        }
        
        if levels.isEmpty {
            validationMessage = "Компетенция должна иметь хотя бы один уровень"
            showingValidationAlert = true
            return false
        }
        
        return true
    }
    
    private func addLevel() {
        let newLevel = CompetencyLevel(
            level: levels.count + 1,
            name: "Новый уровень",
            description: "Описание уровня"
        )
        levels.append(newLevel)
    }
    
    private func updateLevel(_ updatedLevel: CompetencyLevel) {
        if let index = levels.firstIndex(where: { $0.id == updatedLevel.id }) {
            levels[index] = updatedLevel
        }
    }
    
    private func addPosition() {
        let trimmed = newPosition.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !relatedPositions.contains(trimmed) {
            relatedPositions.append(trimmed)
            newPosition = ""
        }
    }
    
    private func removePosition(_ position: String) {
        relatedPositions.removeAll { $0 == position }
    }
}

// MARK: - Supporting Views

struct ColorOption: View {
    let color: CompetencyColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.swiftUIColor)
                    .frame(height: 40)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
        }
    }
}

// MARK: - Level Edit View

struct LevelEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    let level: CompetencyLevel
    let onSave: (CompetencyLevel) -> Void
    
    @State private var name: String
    @State private var description: String
    @State private var behaviors: [String]
    @State private var newBehavior: String = ""
    
    init(level: CompetencyLevel, onSave: @escaping (CompetencyLevel) -> Void) {
        self.level = level
        self.onSave = onSave
        self._name = State(initialValue: level.name)
        self._description = State(initialValue: level.description)
        self._behaviors = State(initialValue: level.behaviors)
    }
    
    var body: some View {
        Form {
            Section("Основная информация") {
                TextField("Название уровня", text: $name)
                
                VStack(alignment: .leading) {
                    Text("Описание")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
            }
            
            Section("Ключевые индикаторы") {
                ForEach(behaviors, id: \.self) { behavior in
                    HStack {
                        Text(behavior)
                        Spacer()
                        Button(action: { removeBehavior(behavior) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                HStack {
                    TextField("Добавить индикатор", text: $newBehavior)
                        .textFieldStyle(.plain)
                    
                    Button(action: addBehavior) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                    .disabled(newBehavior.isEmpty)
                }
            }
        }
        .navigationTitle("Уровень \(level.level)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Отмена") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Сохранить") {
                    saveLevel()
                }
                .fontWeight(.semibold)
            }
        }
    }
    
    private func saveLevel() {
        let updatedLevel = CompetencyLevel(
            id: level.id,
            level: level.level,
            name: name,
            description: description,
            behaviors: behaviors
        )
        onSave(updatedLevel)
        dismiss()
    }
    
    private func addBehavior() {
        let trimmed = newBehavior.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !behaviors.contains(trimmed) {
            behaviors.append(trimmed)
            newBehavior = ""
        }
    }
    
    private func removeBehavior(_ behavior: String) {
        behaviors.removeAll { $0 == behavior }
    }
}

// MARK: - Preview
struct CompetencyEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CompetencyEditView(competency: nil) { _ in }
        }
    }
} 