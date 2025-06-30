//
//  AnalyticsDashboard.swift
//  LMS
//
//  Created on 26/01/2025.
//

import Charts
import SwiftUI

struct AnalyticsDashboard: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var showReports = false
    @State private var showExport = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Period selector
                    periodSelector

                    // Key metrics
                    keyMetricsSection

                    // Charts
                    chartsSection

                    // Top performers
                    topPerformersSection

                    // Course statistics
                    courseStatisticsSection

                    // Competency progress
                    competencyProgressSection
                }
                .padding()
            }
            .navigationTitle("Аналитика")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showReports = true }) {
                            Image(systemName: "doc.text.fill")
                        }

                        Button(action: { showExport = true }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showReports) {
            ReportsListView()
        }
        .confirmationDialog("Экспорт", isPresented: $showExport) {
            Button("Экспорт в HTML") {
                if let url = viewModel.exportDashboard() {
                    // Show share sheet or save confirmation
                    print("Dashboard exported to: \(url)")
                }
            }
            Button("Отмена", role: .cancel) {}
        }
    }

    // MARK: - Period Selector
    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                    PeriodButton(
                        period: period,
                        isSelected: viewModel.selectedPeriod == period
                    ) {
                        viewModel.changePeriod(period)
                    }
                }
            }
        }
    }

    // MARK: - Key Metrics Section
    private var keyMetricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ключевые показатели")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                AnalyticsMetricCard(
                    icon: "person.3.fill",
                    title: "Активные",
                    value: "\(viewModel.analyticsSummary?.activeUsers ?? 0)",
                    change: 12.5,
                    color: .blue
                )

                AnalyticsMetricCard(
                    icon: "checkmark.seal.fill",
                    title: "Завершено",
                    value: "\(viewModel.analyticsSummary?.completedCourses ?? 0)",
                    change: 8.3,
                    color: .green
                )

                AnalyticsMetricCard(
                    icon: "star.fill",
                    title: "Средний балл",
                    value: viewModel.averageScore,
                    change: 2.1,
                    color: .orange
                )

                AnalyticsMetricCard(
                    icon: "clock.fill",
                    title: "Часы",
                    value: viewModel.totalLearningHours,
                    change: 15.7,
                    color: .purple
                )
            }
        }
    }

    // MARK: - Charts Section
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Графики")
                .font(.headline)

            // Learning Progress Chart
            ChartCard(
                title: "Прогресс обучения",
                icon: "chart.line.uptrend.xyaxis",
                color: .blue
            ) {
                Chart(viewModel.learningProgressChartData) { point in
                    LineMark(
                        x: .value("Период", point.label),
                        y: .value("Курсы", point.value)
                    )
                    .foregroundStyle(.blue)

                    AreaMark(
                        x: .value("Период", point.label),
                        y: .value("Курсы", point.value)
                    )
                    .foregroundStyle(.blue.opacity(0.1))
                }
                .frame(height: 200)
            }

            // Test Scores Chart
            ChartCard(
                title: "Результаты тестов",
                icon: "checkmark.seal",
                color: .green
            ) {
                Chart(viewModel.testScoresChartData) { point in
                    BarMark(
                        x: .value("Период", point.label),
                        y: .value("Балл", point.value)
                    )
                    .foregroundStyle(.green.gradient)
                }
                .frame(height: 200)
            }

            // Competency Growth Chart
            ChartCard(
                title: "Рост компетенций",
                icon: "star.circle",
                color: .purple
            ) {
                Chart(viewModel.competencyGrowthChartData) { point in
                    BarMark(
                        x: .value("Компетенция", point.label),
                        y: .value("Прогресс", point.value)
                    )
                    .foregroundStyle(.purple.gradient)
                    .annotation(position: .top) {
                        Text("\(Int(point.value))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 200)
            }
        }
    }

    // MARK: - Top Performers Section
    private var topPerformersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Топ исполнители")
                    .font(.headline)

                Spacer()

                NavigationLink(destination: LeaderboardView()) {
                    Text("Все")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            VStack(spacing: 8) {
                ForEach(viewModel.topPerformers.prefix(3)) { performer in
                    PerformerRow(performer: performer)
                }
            }
        }
    }

    // MARK: - Course Statistics Section
    private var courseStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статистика курсов")
                .font(.headline)

            ForEach(viewModel.popularCourses.prefix(3)) { course in
                CourseStatRow(course: course)
            }
        }
    }

    // MARK: - Competency Progress Section
    private var competencyProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Прогресс компетенций")
                .font(.headline)

            ForEach(viewModel.competencyProgress) { competency in
                CompetencyProgressRow(competency: competency)
            }
        }
    }
}

// MARK: - Helper Views

struct PeriodButton: View {
    let period: AnalyticsPeriod
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(period.rawValue)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(20)
        }
    }
}

struct AnalyticsMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let change: Double?
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()

                if let change = change {
                    HStack(spacing: 2) {
                        Image(systemName: change > 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                        Text("\(String(format: "%.1f", abs(change)))%")
                            .font(.caption)
                    }
                    .foregroundColor(change > 0 ? .green : .red)
                }
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            content()
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct PerformerRow: View {
    let performer: UserPerformance

    var body: some View {
        HStack(spacing: 12) {
            // Rank badge
            Text("#\(performer.rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(rankColor)
                .clipShape(Circle())

            // Avatar
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundColor(.gray)

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(performer.userName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    Label("\(performer.totalScore)", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.orange)

                    Label("\(performer.completedCourses)", systemImage: "book.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            // Trend
            Image(systemName: performer.trend.icon)
                .foregroundColor(Color(performer.trend.color))
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private var rankColor: Color {
        switch performer.rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
}

struct CourseStatRow: View {
    let course: CourseStatistics

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(course.courseName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", course.satisfactionRating))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * course.averageProgress, height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(course.enrolledCount) записано")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(course.completedCount) завершили")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct CompetencyProgressRow: View {
    let competency: CompetencyProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(competency.competencyName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(Int(competency.progressPercentage))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(progressColor)
            }

            // Level indicator
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Double(level) <= competency.averageLevel ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }

            HStack {
                Text("Текущий: \(String(format: "%.1f", competency.averageLevel))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("Цель: \(String(format: "%.1f", competency.targetLevel))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private var progressColor: Color {
        if competency.progressPercentage >= 90 {
            return .green
        } else if competency.progressPercentage >= 70 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Placeholder Views

struct LeaderboardView: View {
    var body: some View {
        Text("Таблица лидеров")
            .navigationTitle("Лидеры")
    }
}

// MARK: - Preview

struct AnalyticsDashboard_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsDashboard()
    }
}
