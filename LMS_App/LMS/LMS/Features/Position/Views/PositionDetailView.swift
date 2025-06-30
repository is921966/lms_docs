import SwiftUI

struct PositionDetailView: View {
    let position: Position
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = PositionViewModel()
    @State private var showingEditSheet = false
    @State private var showingCareerPaths = false
    @State private var selectedCompetencyRequirement: CompetencyRequirement?

    var isAdmin: Bool {
        authViewModel.currentUser?.role == .admin ||
        authViewModel.currentUser?.role == .superAdmin
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                if !position.description.isEmpty { descriptionSection }
                metricsSection
                competencyMatrixSection
                careerPathsSection
                metadataSection
            }
            .padding()
        }
        .navigationTitle(position.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isAdmin {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Редактировать") { showingEditSheet = true }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                PositionEditView(position: position) { updatedPosition in
                    viewModel.updatePosition(updatedPosition)
                }
            }
        }
        .sheet(isPresented: $showingCareerPaths) {
            NavigationStack {
                CareerPathView(position: position)
            }
        }
        .sheet(item: $selectedCompetencyRequirement) { requirement in
            competencyRequirementDetail(requirement)
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        HStack(spacing: 16) {
            // Level badge
            HStack(spacing: 6) {
                Image(systemName: position.level.icon)
                Text(position.level.rawValue)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(position.level.color.opacity(0.2))
            .foregroundColor(position.level.color)
            .cornerRadius(20)

            // Department badge
            HStack(spacing: 6) {
                Image(systemName: "building.2")
                Text(position.department)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray5))
            .cornerRadius(20)

            Spacer()

            if !position.isActive {
                Text("Неактивна")
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Описание")
                .font(.headline)
            Text(position.description)
                .font(.body)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var metricsSection: some View {
        HStack(spacing: 16) {
            PositionDetailMetricCard(
                title: "Сотрудников",
                value: "\(position.employeeCount)",
                icon: "person.3.fill",
                color: .blue
            )
            PositionDetailMetricCard(
                title: "Компетенций",
                value: "\(position.requiredCompetenciesCount)",
                icon: "star.fill",
                color: .orange
            )
            PositionDetailMetricCard(
                title: "Ср. уровень",
                value: String(format: "%.1f", position.averageRequiredLevel),
                icon: "chart.bar.fill",
                color: .green
            )
        }
    }

    private var competencyMatrixSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Матрица компетенций")
                    .font(.headline)
                Spacer()
                Text("\(position.competencyRequirements.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }

            if position.competencyRequirements.isEmpty {
                emptyCompetencyState
            } else {
                let matrix = viewModel.getCompetencyMatrix(for: position)

                if !matrix.criticalRequirements.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Критичные компетенции", systemImage: "exclamationmark.triangle.fill")
                            .font(.subheadline)
                            .foregroundColor(.red)

                        ForEach(matrix.criticalRequirements) { requirement in
                            CompetencyRequirementRow(requirement: requirement, isCritical: true)
                                .onTapGesture { selectedCompetencyRequirement = requirement }
                        }
                    }
                }

                if !matrix.optionalRequirements.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Желательные компетенции", systemImage: "star.circle")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        ForEach(matrix.optionalRequirements) { requirement in
                            CompetencyRequirementRow(requirement: requirement, isCritical: false)
                                .onTapGesture { selectedCompetencyRequirement = requirement }
                        }
                    }
                }
            }
        }
    }

    private var emptyCompetencyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.slash")
                .font(.title)
                .foregroundColor(.gray)
            Text("Компетенции не определены")
                .font(.subheadline)
                .foregroundColor(.secondary)
            if isAdmin {
                Button("Добавить компетенции") { showingEditSheet = true }
                    .font(.caption)
                    .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var careerPathsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Карьерные пути")
                    .font(.headline)
                Spacer()
                Button(action: { showingCareerPaths = true }) {
                    Text("Все пути")
                        .font(.caption)
                }
            }

            let outgoingPaths = viewModel.getCareerPaths(for: position)
            let incomingPaths = viewModel.getIncomingCareerPaths(for: position)

            if outgoingPaths.isEmpty && incomingPaths.isEmpty {
                Text("Карьерные пути не определены")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                VStack(spacing: 16) {
                    if !incomingPaths.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Откуда приходят", systemImage: "arrow.down.circle")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            ForEach(incomingPaths.prefix(2)) { path in
                                MiniCareerPathCard(path: path, isIncoming: true)
                            }
                        }
                    }

                    if !outgoingPaths.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Куда развиваться", systemImage: "arrow.up.circle")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            ForEach(outgoingPaths.prefix(2)) { path in
                                MiniCareerPathCard(path: path, isIncoming: false)
                            }
                        }
                    }
                }
            }
        }
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Информация")
                .font(.headline)
            VStack(spacing: 8) {
                HStack {
                    Text("Создана:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(position.createdAt.formatted(date: .abbreviated, time: .omitted))
                }
                Divider()
                HStack {
                    Text("Обновлена:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(position.updatedAt.formatted(date: .abbreviated, time: .omitted))
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func competencyRequirementDetail(_ requirement: CompetencyRequirement) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(requirement.competencyName)
                        .font(.title2)
                        .fontWeight(.bold)
                    HStack {
                        Label(
                            requirement.isCritical ? "Критичная" : "Желательная",
                            systemImage: requirement.isCritical ? "exclamationmark.triangle.fill" : "star.circle"
                        )
                        .font(.subheadline)
                        .foregroundColor(requirement.isCritical ? .red : .secondary)
                        Spacer()
                        Text("Уровень \(requirement.requiredLevel)")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
                .padding()

                LevelVisualization(currentLevel: requirement.requiredLevel, maxLevel: 5)
                    .padding()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Описание требования")
                        .font(.headline)
                    Text("Для данной должности требуется \(requirement.requiredLevel) уровень компетенции '\(requirement.competencyName)'.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Требование к компетенции")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { selectedCompetencyRequirement = nil }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct CompetencyRequirementRow: View {
    let requirement: CompetencyRequirement
    let isCritical: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(requirement.competencyName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack(spacing: 4) {
                    if isCritical {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                    Text("Уровень \(requirement.requiredLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            LevelIndicator(level: requirement.requiredLevel)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LevelIndicator: View {
    let level: Int
    let maxLevel: Int = 5

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxLevel, id: \.self) { i in
                Circle()
                    .fill(i <= level ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

struct MiniCareerPathCard: View {
    let path: CareerPath
    let isIncoming: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(isIncoming ? path.fromPositionName : path.toPositionName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(path.estimatedDuration.rawValue)
                        .font(.caption)
                    Circle()
                        .fill(path.difficulty.color)
                        .frame(width: 6, height: 6)
                    Text(path.difficulty.rawValue)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: isIncoming ? "arrow.down" : "arrow.up")
                .font(.caption)
                .foregroundColor(isIncoming ? .blue : .green)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LevelVisualization: View {
    let currentLevel: Int
    let maxLevel: Int

    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 24)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                        .frame(
                            width: geometry.size.width * (Double(currentLevel) / Double(maxLevel)),
                            height: 24
                        )
                }
            }
            .frame(height: 24)

            HStack {
                ForEach(1...maxLevel, id: \.self) { level in
                    VStack(spacing: 4) {
                        Text("\(level)")
                            .font(.caption)
                            .fontWeight(level == currentLevel ? .bold : .regular)
                            .foregroundColor(level <= currentLevel ? .blue : .gray)
                        if level == currentLevel {
                            Image(systemName: "arrowtriangle.up.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                    if level < maxLevel { Spacer() }
                }
            }
        }
    }
}

// MARK: - Position Detail Metric Card

struct PositionDetailMetricCard: View {
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
                .font(.title3)
                .fontWeight(.semibold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct PositionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PositionDetailView(
                position: Position(
                    name: "iOS Developer Middle",
                    description: "Разработка iOS приложений",
                    department: "Engineering",
                    level: .middle,
                    competencyRequirements: [
                        CompetencyRequirement(
                            competencyId: UUID(),
                            competencyName: "iOS разработка",
                            requiredLevel: 3,
                            isCritical: true
                        )
                    ],
                    employeeCount: 8
                )
            )
            .environmentObject(AuthViewModel())
        }
    }
}
