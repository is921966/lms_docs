import SwiftUI

struct CompetencyListView: View {
    @StateObject private var viewModel = CompetencyViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingFilters = false
    @State private var selectedCompetency: Competency?

    var isAdmin: Bool {
        authViewModel.currentUser?.role == .admin ||
        authViewModel.currentUser?.role == .superAdmin
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Загрузка компетенций...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityIdentifier("loadingIndicator")
                } else {
                    competencyList
                }
            }
            .navigationTitle("Компетенции")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Поиск компетенций")
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $viewModel.showingCreateSheet) {
                NavigationStack {
                    CompetencyEditView(competency: nil) { newCompetency in
                        viewModel.createCompetency(newCompetency)
                    }
                }
                .accessibilityIdentifier("createCompetencySheet")
            }
            .sheet(isPresented: $viewModel.showingEditSheet) {
                if let competency = viewModel.selectedCompetency {
                    NavigationStack {
                        CompetencyEditView(competency: competency) { updatedCompetency in
                            viewModel.updateCompetency(updatedCompetency)
                        }
                    }
                    .accessibilityIdentifier("editCompetencySheet")
                }
            }
            .sheet(isPresented: $showingFilters) {
                filterSheet
                    .accessibilityIdentifier("filtersSheet")
            }
            .navigationDestination(for: Competency.self) { competency in
                CompetencyDetailView(competency: competency)
            }
        }
        .accessibilityIdentifier("competencyListView")
    }

    // MARK: - Components

    private var competencyList: some View {
        Group {
            if viewModel.filteredCompetencies.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Statistics card
                        if viewModel.searchText.isEmpty && viewModel.selectedCategory == nil {
                            statisticsCard
                                .accessibilityIdentifier("statisticsCard")
                        }

                        // Competency cards
                        ForEach(viewModel.filteredCompetencies) { competency in
                            CompetencyCard(competency: competency)
                                .accessibilityIdentifier("competencyCard_\(competency.id)")
                                .onTapGesture {
                                    selectedCompetency = competency
                                }
                                .contextMenu {
                                    competencyContextMenu(competency)
                                }
                        }
                    }
                    .padding()
                }
                .refreshable {
                    viewModel.loadCompetencies()
                }
                .accessibilityIdentifier("competencyListScrollView")
            }
        }
    }

    private var statisticsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Статистика")
                .font(.headline)
                .accessibilityIdentifier("statisticsTitle")

            HStack(spacing: 20) {
                StatItem(
                    title: "Всего",
                    value: "\(viewModel.statistics.total)",
                    icon: "list.bullet",
                    color: .blue
                )
                .accessibilityIdentifier("totalStatItem")

                StatItem(
                    title: "Активных",
                    value: "\(viewModel.statistics.active)",
                    icon: "checkmark.circle",
                    color: .green
                )
                .accessibilityIdentifier("activeStatItem")

                StatItem(
                    title: "Неактивных",
                    value: "\(viewModel.statistics.inactive)",
                    icon: "xmark.circle",
                    color: .gray
                )
                .accessibilityIdentifier("inactiveStatItem")
            }

            // Category breakdown
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(CompetencyCategory.allCases, id: \.self) { category in
                        CompetencyCategoryChip(
                            category: category,
                            count: viewModel.statistics.count(for: category),
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.selectedCategory = category
                        }
                        .accessibilityIdentifier("categoryChip_\(category.rawValue)")
                    }
                }
            }
            .accessibilityIdentifier("categoryChipsScrollView")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .accessibilityIdentifier("emptyStateIcon")

            Text("Компетенции не найдены")
                .font(.headline)
                .accessibilityIdentifier("emptyStateTitle")

            Text("Попробуйте изменить параметры поиска или фильтры")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("emptyStateMessage")

            if isAdmin {
                Button(action: { viewModel.showingCreateSheet = true }) {
                    Label("Создать компетенцию", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("createCompetencyButton")
            }
        }
        .padding()
        .accessibilityIdentifier("emptyStateView")
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: { showingFilters = true }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .symbolVariant(hasActiveFilters ? .fill : .none)
            }
            .accessibilityIdentifier("filtersButton")

            if isAdmin {
                Button(action: { viewModel.showingCreateSheet = true }) {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("addCompetencyButton")
            }
        }
    }

    private var filterSheet: some View {
        NavigationStack {
            Form {
                Section("Категория") {
                    Picker("Категория", selection: $viewModel.selectedCategory) {
                        Text("Все категории").tag(nil as CompetencyCategory?)
                        ForEach(CompetencyCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category as CompetencyCategory?)
                        }
                    }
                    .accessibilityIdentifier("categoryPicker")
                }

                Section("Статус") {
                    Toggle("Показывать неактивные", isOn: $viewModel.showInactiveCompetencies)
                        .accessibilityIdentifier("showInactiveToggle")
                }

                Section {
                    Button("Сбросить фильтры") {
                        viewModel.clearFilters()
                        showingFilters = false
                    }
                    .foregroundColor(.red)
                    .accessibilityIdentifier("clearFiltersButton")
                }
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        showingFilters = false
                    }
                    .accessibilityIdentifier("filtersDoneButton")
                }
            }
        }
    }

    @ViewBuilder
    private func competencyContextMenu(_ competency: Competency) -> some View {
        if isAdmin {
            Button(action: { viewModel.selectCompetencyForEdit(competency) }) {
                Label("Редактировать", systemImage: "pencil")
            }

            Button(action: { viewModel.toggleCompetencyStatus(competency) }) {
                Label(
                    competency.isActive ? "Деактивировать" : "Активировать",
                    systemImage: competency.isActive ? "xmark.circle" : "checkmark.circle"
                )
            }

            Divider()

            Button(role: .destructive, action: { viewModel.deleteCompetency(competency) }) {
                Label("Удалить", systemImage: "trash")
            }
        }
    }

    private var hasActiveFilters: Bool {
        viewModel.selectedCategory != nil || viewModel.showInactiveCompetencies
    }
}

// MARK: - Supporting Views

struct CompetencyCard: View {
    let competency: Competency

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Color indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(competency.swiftUIColor)
                    .frame(width: 6)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(competency.name)
                            .font(.headline)

                        Spacer()

                        if !competency.isActive {
                            Text("Неактивна")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(competency.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack {
                        Label(competency.category.rawValue, systemImage: competency.category.icon)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(competency.levels.count) уровней")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CompetencyCategoryChip: View {
    let category: CompetencyCategory
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.caption)

                Text(category.rawValue)
                    .font(.caption)

                Text("(\(count))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Preview
struct CompetencyListView_Previews: PreviewProvider {
    static var previews: some View {
        CompetencyListView()
            .environmentObject(AuthViewModel())
    }
}
