//
//  OnboardingReportsView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI
import Charts

struct OnboardingReportsView: View {
    @ObservedObject var service = OnboardingMockService.shared
    @State private var selectedPeriod = "Неделя"

    let periods = ["Неделя", "Месяц", "Квартал", "Год"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Period selector
                Picker("Период", selection: $selectedPeriod) {
                    ForEach(periods, id: \.self) { period in
                        Text(period).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Summary cards
                summaryCards

                // Charts
                programStatusChart
                averageCompletionTimeChart
                templateUsageChart
                departmentBreakdownChart
            }
            .padding(.vertical)
        }
        .navigationTitle("Отчеты по адаптации")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ReportCard(
                    title: "Всего программ",
                    value: "\(service.programs.count)",
                    change: "+12%",
                    isPositive: true,
                    icon: "person.3.fill",
                    color: .blue
                )

                ReportCard(
                    title: "Завершено",
                    value: "\(service.programs.filter { $0.status == .completed }.count)",
                    change: "+8%",
                    isPositive: true,
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }

            HStack(spacing: 16) {
                ReportCard(
                    title: "Ср. время",
                    value: "21 день",
                    change: "-3 дня",
                    isPositive: true,
                    icon: "clock.fill",
                    color: .orange
                )

                ReportCard(
                    title: "Успешность",
                    value: "87%",
                    change: "+5%",
                    isPositive: true,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Charts

    private var programStatusChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статус программ")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(statusData, id: \.status) { item in
                    BarMark(
                        x: .value("Статус", item.status),
                        y: .value("Количество", item.count)
                    )
                    .foregroundStyle(item.color)
                    .cornerRadius(8)
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var averageCompletionTimeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Среднее время завершения по месяцам")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(completionTimeData, id: \.month) { item in
                    LineMark(
                        x: .value("Месяц", item.month),
                        y: .value("Дни", item.days)
                    )
                    .foregroundStyle(.blue)
                    .symbol(Circle())

                    AreaMark(
                        x: .value("Месяц", item.month),
                        y: .value("Дни", item.days)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var templateUsageChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Использование шаблонов")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(templateUsageData, id: \.template) { item in
                    SectorMark(
                        angle: .value("Использований", item.usage),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(item.color)
                    .cornerRadius(4)
                }
            }
            .frame(height: 200)
            .padding(.horizontal)

            // Legend
            HStack(spacing: 20) {
                ForEach(templateUsageData, id: \.template) { item in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 8, height: 8)
                        Text(item.template)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var departmentBreakdownChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Распределение по отделам")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(departmentData, id: \.department) { item in
                    BarMark(
                        x: .value("Количество", item.count),
                        y: .value("Отдел", item.department)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
                }
            }
            .frame(height: 250)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Data

    private var statusData: [(status: String, count: Int, color: Color)] {
        let stats = service.getProgramStatistics()
        return [
            ("В процессе", stats.active, .blue),
            ("Завершено", stats.completed, .green),
            ("Не начато", stats.total - stats.active - stats.completed - stats.overdue, .gray),
            ("Просрочено", stats.overdue, .red)
        ]
    }

    private var completionTimeData: [(month: String, days: Int)] {
        [
            ("Янв", 24),
            ("Фев", 22),
            ("Мар", 23),
            ("Апр", 21),
            ("Май", 20),
            ("Июн", 21)
        ]
    }

    private var templateUsageData: [(template: String, usage: Int, color: Color)] {
        [
            ("Продавец", 35, .blue),
            ("Кассир", 25, .green),
            ("Мерчандайзер", 20, .orange),
            ("Руководитель", 20, .purple)
        ]
    }

    private var departmentData: [(department: String, count: Int)] {
        [
            ("Продажи", 45),
            ("Маркетинг", 23),
            ("IT", 18),
            ("HR", 12),
            ("Финансы", 8)
        ]
    }
}

// MARK: - Report Card
struct ReportCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption)
                    Text(change)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(isPositive ? .green : .red)
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview
struct OnboardingReportsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingReportsView()
        }
    }
}
