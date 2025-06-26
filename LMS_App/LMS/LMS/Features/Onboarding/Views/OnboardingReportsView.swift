//
//  OnboardingReportsView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI
import Charts

struct OnboardingReportsView: View {
    @StateObject private var onboardingService = OnboardingMockService.shared
    @State private var selectedPeriod: ReportPeriod = .thisMonth
    
    var filteredPrograms: [OnboardingProgram] {
        switch selectedPeriod {
        case .thisWeek:
            return onboardingService.programs.filter { isInCurrentWeek($0.startDate) }
        case .thisMonth:
            return onboardingService.programs.filter { isInCurrentMonth($0.startDate) }
        case .allTime:
            return onboardingService.programs
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Period selector
                Picker("Период", selection: $selectedPeriod) {
                    ForEach(ReportPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Key metrics
                MetricsSection(programs: filteredPrograms)
                
                // Progress distribution chart
                ProgressDistributionChart(programs: filteredPrograms)
                
                // Department statistics
                DepartmentStatisticsView(programs: filteredPrograms)
                
                // Overdue programs
                OverdueProgramsSection(programs: filteredPrograms)
                
                // Stage completion times
                StageCompletionChart(programs: filteredPrograms)
            }
            .padding(.vertical)
        }
        .navigationTitle("Отчеты по онбордингу")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func isInCurrentWeek(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInThisWeek(date)
    }
    
    private func isInCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, equalTo: Date(), toGranularity: .month)
    }
}

// MARK: - Report Period
enum ReportPeriod: String, CaseIterable {
    case thisWeek = "Эта неделя"
    case thisMonth = "Этот месяц"
    case allTime = "Все время"
}

// MARK: - Metrics Section
struct MetricsSection: View {
    let programs: [OnboardingProgram]
    
    var activePrograms: Int {
        programs.filter { $0.status == .inProgress }.count
    }
    
    var completedPrograms: Int {
        programs.filter { $0.status == .completed }.count
    }
    
    var overduePrograms: Int {
        programs.filter { $0.isOverdue }.count
    }
    
    var averageCompletion: Double {
        guard !programs.isEmpty else { return 0 }
        let totalProgress = programs.reduce(0) { $0 + $1.overallProgress }
        return totalProgress / Double(programs.count)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                MetricCard(
                    title: "Активные",
                    value: "\(activePrograms)",
                    icon: "person.badge.clock",
                    color: .blue
                )
                
                MetricCard(
                    title: "Завершенные",
                    value: "\(completedPrograms)",
                    icon: "checkmark.seal.fill",
                    color: .green
                )
            }
            
            HStack(spacing: 16) {
                MetricCard(
                    title: "Просроченные",
                    value: "\(overduePrograms)",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                )
                
                MetricCard(
                    title: "Средний прогресс",
                    value: "\(Int(averageCompletion * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Progress Distribution Chart
struct ProgressDistributionChart: View {
    let programs: [OnboardingProgram]
    
    var progressRanges: [(range: String, count: Int)] {
        let ranges = [
            ("0-25%", programs.filter { $0.overallProgress <= 0.25 }.count),
            ("26-50%", programs.filter { $0.overallProgress > 0.25 && $0.overallProgress <= 0.5 }.count),
            ("51-75%", programs.filter { $0.overallProgress > 0.5 && $0.overallProgress <= 0.75 }.count),
            ("76-100%", programs.filter { $0.overallProgress > 0.75 }.count)
        ]
        return ranges
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Распределение по прогрессу")
                .font(.headline)
                .padding(.horizontal)
            
            Chart(progressRanges, id: \.range) { item in
                BarMark(
                    x: .value("Диапазон", item.range),
                    y: .value("Количество", item.count)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Department Statistics
struct DepartmentStatisticsView: View {
    let programs: [OnboardingProgram]
    
    var departmentStats: [(department: String, count: Int, progress: Double)] {
        let grouped = Dictionary(grouping: programs, by: { $0.employeeDepartment })
        return grouped.map { department, progs in
            let avgProgress = progs.reduce(0) { $0 + $1.overallProgress } / Double(progs.count)
            return (department, progs.count, avgProgress)
        }.sorted { $0.count > $1.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Статистика по отделам")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(departmentStats, id: \.department) { stat in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stat.department)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("\(stat.count) программ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(stat.progress * 100))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Text("средний прогресс")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Overdue Programs Section
struct OverdueProgramsSection: View {
    let programs: [OnboardingProgram]
    
    var overduePrograms: [OnboardingProgram] {
        programs.filter { $0.isOverdue }.sorted { $0.daysRemaining < $1.daysRemaining }
    }
    
    var body: some View {
        if !overduePrograms.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Просроченные программы")
                        .font(.headline)
                    
                    Spacer()
                    
                    Label("\(overduePrograms.count)", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.horizontal)
                
                ForEach(overduePrograms.prefix(5)) { program in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(program.employeeName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(program.title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Просрочено на")
                                .font(.caption2)
                                .foregroundColor(.red)
                            
                            Text("\(abs(program.daysRemaining)) дн.")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                if overduePrograms.count > 5 {
                    Text("И еще \(overduePrograms.count - 5) программ...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Stage Completion Chart
struct StageCompletionChart: View {
    let programs: [OnboardingProgram]
    
    var averageStageCompletionDays: [(stage: String, days: Double)] {
        var stageData: [String: [Int]] = [:]
        
        for program in programs {
            for stage in program.stages where stage.status == .completed {
                let duration = stage.duration
                if stageData[stage.title] == nil {
                    stageData[stage.title] = []
                }
                stageData[stage.title]?.append(duration)
            }
        }
        
        return stageData.map { title, durations in
            let avg = Double(durations.reduce(0, +)) / Double(durations.count)
            return (title, avg)
        }.sorted { $0.days < $1.days }
    }
    
    var body: some View {
        if !averageStageCompletionDays.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("Среднее время прохождения этапов")
                    .font(.headline)
                    .padding(.horizontal)
                
                Chart(averageStageCompletionDays, id: \.stage) { item in
                    BarMark(
                        x: .value("Дни", item.days),
                        y: .value("Этап", item.stage)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
                .frame(height: Double(averageStageCompletionDays.count) * 50)
                .padding(.horizontal)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}

// MARK: - Calendar Extension
extension Calendar {
    func isDateInThisWeek(_ date: Date) -> Bool {
        isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
}

#Preview {
    NavigationView {
        OnboardingReportsView()
    }
} 