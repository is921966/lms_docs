import SwiftUI

struct PositionListView: View {
    @StateObject private var viewModel = PositionViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingFilters = false
    @State private var selectedPosition: Position?

    var isAdmin: Bool {
        authViewModel.currentUser?.role == .admin ||
        authViewModel.currentUser?.role == .superAdmin
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Загрузка должностей...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    positionList
                }
            }
            .navigationTitle("Должности")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Поиск должностей")
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $viewModel.showingCreateSheet) {
                NavigationStack {
                    PositionEditView(position: nil) { newPosition in
                        viewModel.createPosition(newPosition)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingEditSheet) {
                if let position = viewModel.selectedPosition {
                    NavigationStack {
                        PositionEditView(position: position) { updatedPosition in
                            viewModel.updatePosition(updatedPosition)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                filterSheet
            }
            .sheet(isPresented: $viewModel.showingCareerPaths) {
                if let position = viewModel.selectedPosition {
                    NavigationStack {
                        CareerPathView(position: position)
                    }
                }
            }
            .navigationDestination(for: Position.self) { position in
                PositionDetailView(position: position)
            }
        }
    }

    // MARK: - Components

    private var positionList: some View {
        Group {
            if viewModel.filteredPositions.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Statistics card
                        if viewModel.searchText.isEmpty && viewModel.selectedLevel == nil && viewModel.selectedDepartment == nil {
                            statisticsCard
                        }

                        // Department sections
                        ForEach(groupedPositions.keys.sorted(), id: \.self) { department in
                            VStack(alignment: .leading, spacing: 12) {
                                // Department header
                                HStack {
                                    Image(systemName: "building.2")
                                    Text(department)
                                        .font(.headline)

                                    Spacer()

                                    Text("\(groupedPositions[department]?.count ?? 0)")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal)

                                // Position cards
                                ForEach(groupedPositions[department] ?? []) { position in
                                    PositionCard(position: position)
                                        .onTapGesture {
                                            selectedPosition = position
                                        }
                                        .contextMenu {
                                            positionContextMenu(position)
                                        }
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    viewModel.loadData()
                }
            }
        }
    }

    private var groupedPositions: [String: [Position]] {
        Dictionary(grouping: viewModel.filteredPositions, by: { $0.department })
    }

    private var statisticsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Статистика")
                .font(.headline)

            // Main stats
            HStack(spacing: 0) {
                StatBox(
                    title: "Всего должностей",
                    value: "\(viewModel.statistics.total)",
                    icon: "briefcase.fill",
                    color: .blue
                )

                Divider()
                    .frame(height: 50)

                StatBox(
                    title: "Сотрудников",
                    value: "\(viewModel.statistics.totalEmployees)",
                    icon: "person.3.fill",
                    color: .green
                )

                Divider()
                    .frame(height: 50)

                StatBox(
                    title: "Отделов",
                    value: "\(viewModel.statistics.departments.count)",
                    icon: "building.2.fill",
                    color: .purple
                )
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Level breakdown
            VStack(alignment: .leading, spacing: 12) {
                Text("По уровням")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(PositionLevel.allCases, id: \.self) { level in
                            LevelChip(
                                level: level,
                                count: viewModel.statistics.count(for: level),
                                isSelected: viewModel.selectedLevel == level
                            ) {
                                if viewModel.selectedLevel == level {
                                    viewModel.selectedLevel = nil
                                } else {
                                    viewModel.selectedLevel = level
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "briefcase.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Должности не найдены")
                .font(.headline)

            Text("Попробуйте изменить параметры поиска или фильтры")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if isAdmin {
                Button(action: { viewModel.showingCreateSheet = true }) {
                    Label("Создать должность", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: { showingFilters = true }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .symbolVariant(hasActiveFilters ? .fill : .none)
            }

            if isAdmin {
                Button(action: { viewModel.showingCreateSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
    }

    private var filterSheet: some View {
        NavigationStack {
            Form {
                Section("Уровень") {
                    Picker("Уровень", selection: $viewModel.selectedLevel) {
                        Text("Все уровни").tag(nil as PositionLevel?)
                        ForEach(PositionLevel.allCases, id: \.self) { level in
                            HStack {
                                Image(systemName: level.icon)
                                    .foregroundColor(level.color)
                                Text(level.rawValue)
                            }
                            .tag(level as PositionLevel?)
                        }
                    }
                }

                Section("Отдел") {
                    Picker("Отдел", selection: $viewModel.selectedDepartment) {
                        Text("Все отделы").tag(nil as String?)
                        ForEach(viewModel.statistics.departments, id: \.self) { department in
                            Text(department).tag(department as String?)
                        }
                    }
                }

                Section("Статус") {
                    Toggle("Показывать неактивные", isOn: $viewModel.showInactivePositions)
                }

                Section {
                    Button("Сбросить фильтры") {
                        viewModel.clearFilters()
                        showingFilters = false
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        showingFilters = false
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func positionContextMenu(_ position: Position) -> some View {
        Button(action: { viewModel.selectPositionForCareerPaths(position) }) {
            Label("Карьерные пути", systemImage: "arrow.up.right.circle")
        }

        if isAdmin {
            Divider()

            Button(action: { viewModel.selectPositionForEdit(position) }) {
                Label("Редактировать", systemImage: "pencil")
            }

            Button(action: { viewModel.togglePositionStatus(position) }) {
                Label(
                    position.isActive ? "Деактивировать" : "Активировать",
                    systemImage: position.isActive ? "xmark.circle" : "checkmark.circle"
                )
            }

            Divider()

            Button(role: .destructive, action: { viewModel.deletePosition(position) }) {
                Label("Удалить", systemImage: "trash")
            }
        }
    }

    private var hasActiveFilters: Bool {
        viewModel.selectedLevel != nil ||
        viewModel.selectedDepartment != nil ||
        viewModel.showInactivePositions
    }
}

// MARK: - Supporting Views

struct PositionCard: View {
    let position: Position

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with level indicator
            HStack {
                // Level badge
                HStack(spacing: 6) {
                    Image(systemName: position.level.icon)
                        .font(.caption)
                    Text(position.level.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(position.level.color.opacity(0.2))
                .foregroundColor(position.level.color)
                .cornerRadius(12)

                Spacer()

                // Employee count
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                    Text("\(position.employeeCount)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)

                if !position.isActive {
                    Text("Неактивна")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }

            // Title and description
            VStack(alignment: .leading, spacing: 4) {
                Text(position.name)
                    .font(.headline)

                Text(position.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            // Competency requirements summary
            if !position.competencyRequirements.isEmpty {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.orange)

                    Text("\(position.requiredCompetenciesCount) компетенций")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Ср. уровень: \(String(format: "%.1f", position.averageRequiredLevel))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Action indicator
            HStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

struct LevelChip: View {
    let level: PositionLevel
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: level.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : level.color)

                Text(level.rawValue)
                    .font(.caption)

                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .frame(width: 70, height: 70)
            .background(isSelected ? level.color : level.color.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview
struct PositionListView_Previews: PreviewProvider {
    static var previews: some View {
        PositionListView()
            .environmentObject(AuthViewModel())
    }
}
