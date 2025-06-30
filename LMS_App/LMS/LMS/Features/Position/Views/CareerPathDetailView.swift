import SwiftUI

struct CareerPathDetailView: View {
    let path: CareerPath
    let currentPosition: Position
    @State private var completedRequirements: Set<UUID> = []
    @State private var showingProgress = false

    var completionPercentage: Double {
        guard !path.requirements.isEmpty else { return 0 }
        return Double(completedRequirements.count) / Double(path.requirements.count) * 100
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection

                // Progress overview
                progressSection

                // Requirements checklist
                requirementsSection

                // Success factors
                successFactorsSection

                // Timeline
                timelineSection
            }
            .padding()
        }
        .navigationTitle("Карьерный путь")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Прогресс") {
                    showingProgress = true
                }
            }
        }
        .sheet(isPresented: $showingProgress) {
            NavigationStack {
                ProgressTrackerView(
                    path: path,
                    completedRequirements: completedRequirements
                )
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // From -> To visualization
            HStack(spacing: 16) {
                PositionBadge(
                    name: path.fromPositionName,
                    level: currentPosition.level,
                    isCurrent: true
                )

                Image(systemName: "arrow.right")
                    .font(.title3)
                    .foregroundColor(.secondary)

                PositionBadge(
                    name: path.toPositionName,
                    level: getNextLevel(currentPosition.level),
                    isCurrent: false
                )
            }

            // Description
            if !path.description.isEmpty {
                Text(path.description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            // Key metrics
            HStack(spacing: 16) {
                MetricBadge(
                    icon: "clock",
                    text: path.estimatedDuration.rawValue,
                    color: .blue
                )

                MetricBadge(
                    icon: path.difficulty.icon,
                    text: path.difficulty.rawValue,
                    color: path.difficulty.color
                )

                MetricBadge(
                    icon: "percent",
                    text: "\(Int(path.successRate * 100))%",
                    color: getSuccessRateColor(path.successRate)
                )
            }
        }
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ваш прогресс")
                    .font(.headline)

                Spacer()

                Text("\(Int(completionPercentage))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(completionPercentage > 50 ? .green : .orange)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * (completionPercentage / 100),
                            height: 20
                        )
                }
            }
            .frame(height: 20)

            Text("\(completedRequirements.count) из \(path.requirements.count) требований выполнено")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Требования")
                .font(.headline)

            ForEach(path.requirements) { requirement in
                RequirementRow(
                    requirement: requirement,
                    isCompleted: completedRequirements.contains(requirement.id)
                ) {
                    toggleRequirement(requirement.id)
                }
            }
        }
    }

    private var successFactorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Факторы успеха")
                .font(.headline)

            VStack(spacing: 12) {
                SuccessFactorRow(
                    icon: "lightbulb",
                    title: "Активное обучение",
                    description: "Постоянное развитие навыков через курсы и практику"
                )

                SuccessFactorRow(
                    icon: "person.2",
                    title: "Менторинг",
                    description: "Поддержка опытного наставника ускорит развитие"
                )

                SuccessFactorRow(
                    icon: "target",
                    title: "Четкие цели",
                    description: "Постановка измеримых целей на каждый квартал"
                )
            }
        }
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Примерный план")
                .font(.headline)

            TimelineView(duration: path.estimatedDuration, requirements: path.requirements)
                .frame(height: 200)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }

    // MARK: - Helper Methods

    private func toggleRequirement(_ id: UUID) {
        if completedRequirements.contains(id) {
            completedRequirements.remove(id)
        } else {
            completedRequirements.insert(id)
        }
    }

    private func getNextLevel(_ current: PositionLevel) -> PositionLevel {
        let allLevels = PositionLevel.allCases
        guard let currentIndex = allLevels.firstIndex(of: current),
              currentIndex < allLevels.count - 1 else {
            return current
        }
        return allLevels[currentIndex + 1]
    }

    private func getSuccessRateColor(_ rate: Double) -> Color {
        switch rate {
        case 0.8...1.0: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
    }
}

// MARK: - Supporting Views

struct PositionBadge: View {
    let name: String
    let level: PositionLevel
    let isCurrent: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: level.icon)
                .font(.title2)
                .foregroundColor(isCurrent ? .white : level.color)

            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundColor(isCurrent ? .white : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isCurrent ? level.color : level.color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct MetricBadge: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(20)
    }
}

struct RequirementRow: View {
    let requirement: CareerPathRequirement
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isCompleted ? .green : .gray)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: requirement.type.icon)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(requirement.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .strikethrough(isCompleted)
                }

                if !requirement.description.isEmpty {
                    Text(requirement.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(isCompleted ? Color.green.opacity(0.05) : Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SuccessFactorRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TimelineView: View {
    let duration: CareerPathDuration
    let requirements: [CareerPathRequirement]

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 20) {
                Text("0 мес")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Timeline bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    // Milestones
                    HStack(spacing: 0) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 16, height: 16)
                                .offset(x: CGFloat(index) * (geometry.size.width / 2) - 8)
                        }
                    }
                }

                HStack {
                    Spacer()
                    Text("\(duration.months) мес")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Phases
                HStack(spacing: 8) {
                    PhaseCard(title: "Подготовка", icon: "book", color: .blue)
                    PhaseCard(title: "Развитие", icon: "chart.line.uptrend.xyaxis", color: .orange)
                    PhaseCard(title: "Переход", icon: "star", color: .green)
                }
            }
            .padding()
        }
    }
}

struct PhaseCard: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
                .font(.caption2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(8)
    }
}

struct ProgressTrackerView: View {
    let path: CareerPath
    let completedRequirements: Set<UUID>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Отслеживание прогресса")
                .font(.title2)
                .fontWeight(.bold)

            Text("Здесь будет функционал для детального отслеживания прогресса")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()

            Button("Закрыть") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Прогресс")
        .navigationBarTitleDisplayMode(.inline)
    }
}
