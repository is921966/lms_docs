//
//  ReportsListView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct ReportsListView: View {
    @StateObject private var service = AnalyticsService()
    @State private var showCreateReport = false
    @State private var selectedReport: Report?
    @State private var filterType: ReportType?
    
    private let currentUserId = "user-1"
    
    var body: some View {
        NavigationView {
            List {
                // Filter section
                filterSection
                
                // Reports list
                ForEach(filteredReports) { report in
                    ReportRow(report: report) {
                        selectedReport = report
                    }
                }
            }
            .navigationTitle("Отчеты")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateReport = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateReport) {
                CreateReportView()
            }
            .sheet(item: $selectedReport) { report in
                NavigationView {
                    ReportDetailView(report: report)
                }
            }
        }
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ReportFilterChip(
                    title: "Все",
                    isSelected: filterType == nil,
                    action: { filterType = nil }
                )
                
                ForEach(ReportType.allCases, id: \.self) { type in
                    ReportFilterChip(
                        title: type.rawValue,
                        isSelected: filterType == type,
                        action: { filterType = type }
                    )
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Filtered Reports
    private var filteredReports: [Report] {
        let userReports = service.getReports(for: currentUserId)
        
        if let filterType = filterType {
            return userReports.filter { $0.type == filterType }
        }
        return userReports
    }
}

// MARK: - Report Row

struct ReportRow: View {
    let report: Report
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Type icon
                Image(systemName: report.type.icon)
                    .font(.title2)
                    .foregroundColor(report.type.color)
                    .frame(width: 40, height: 40)
                    .background(report.type.color.opacity(0.1))
                    .cornerRadius(10)
                
                // Report info
                VStack(alignment: .leading, spacing: 4) {
                    Text(report.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Label(report.period.rawValue, systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label(report.format.rawValue, systemImage: report.format.icon)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: report.status.icon)
                            .font(.caption)
                        Text(report.status.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(report.status.color)
                }
                
                Spacer()
                
                // Schedule indicator
                if report.schedule != nil {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.blue)
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Report Detail View

struct ReportDetailView: View {
    let report: Report
    @Environment(\.dismiss) private var dismiss
    @State private var isGenerating = false
    @State private var showExportOptions = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection
                
                // Description
                if !report.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Описание")
                            .font(.headline)
                        Text(report.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Info
                infoSection
                
                // Sections
                if !report.sections.isEmpty {
                    sectionsView
                }
                
                // Actions
                actionsSection
            }
            .padding()
        }
        .navigationTitle(report.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Готово") {
                    dismiss()
                }
            }
        }
        .confirmationDialog("Экспорт отчета", isPresented: $showExportOptions) {
            ForEach(ReportFormat.allCases, id: \.self) { format in
                Button(format.rawValue) {
                    exportReport(in: format)
                }
            }
            Button("Отмена", role: .cancel) {}
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: report.type.icon)
                        .foregroundColor(report.type.color)
                    Text(report.type.rawValue)
                        .foregroundColor(report.type.color)
                }
                .font(.subheadline)
                
                HStack {
                    Image(systemName: report.status.icon)
                    Text(report.status.rawValue)
                }
                .font(.caption)
                .foregroundColor(report.status.color)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Создан")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(report.createdAt, formatter: dateFormatter)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ReportInfoCard(
                icon: "calendar",
                title: "Период",
                value: report.period.rawValue
            )
            
            ReportInfoCard(
                icon: "doc.text",
                title: "Формат",
                value: report.format.rawValue
            )
            
            if let schedule = report.schedule {
                ReportInfoCard(
                    icon: "clock.arrow.circlepath",
                    title: "Расписание",
                    value: schedule.frequency.rawValue
                )
            }
            
            ReportInfoCard(
                icon: "person.2",
                title: "Получатели",
                value: "\(report.recipients.count)"
            )
        }
    }
    
    // MARK: - Sections View
    private var sectionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Разделы отчета")
                .font(.headline)
            
            ForEach(report.sections.sorted(by: { $0.order < $1.order })) { section in
                ReportSectionView(section: section)
            }
        }
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            if report.status == .draft {
                Button(action: generateReport) {
                    Label("Сгенерировать отчет", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGenerating)
            }
            
            if report.status == .ready {
                Button(action: { showExportOptions = true }) {
                    Label("Экспортировать", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.top)
    }
    
    // MARK: - Actions
    private func generateReport() {
        isGenerating = true
        // In real app would generate report
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isGenerating = false
        }
    }
    
    private func exportReport(in format: ReportFormat) {
        // In real app would export report
        print("Exporting report in \(format.rawValue) format")
    }
}

// MARK: - Report Section View

struct ReportSectionView: View {
    let section: ReportSection
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: sectionIcon)
                        .foregroundColor(.blue)
                    
                    Text(section.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Content
            if isExpanded {
                sectionContent
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(8)
            }
        }
    }
    
    private var sectionIcon: String {
        switch section.type {
        case .summary: return "doc.text"
        case .chart: return "chart.bar"
        case .table: return "tablecells"
        case .text: return "text.alignleft"
        case .metrics: return "number"
        }
    }
    
    @ViewBuilder
    private var sectionContent: some View {
        switch section.data {
        case .summary(let data):
            SummaryView(data: data)
        case .metrics(let metrics):
            MetricsView(metrics: metrics)
        case .text(let text):
            Text(text)
                .font(.subheadline)
        case .chart(_):
            // Chart preview
            Text("График")
                .font(.caption)
                .foregroundColor(.secondary)
        case .table(let data):
            TableView(data: data)
        }
    }
}

// MARK: - Summary View

struct SummaryView: View {
    let data: SummaryData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !data.highlights.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Основные моменты")
                        .font(.caption)
                        .fontWeight(.semibold)
                    ForEach(data.highlights, id: \.self) { highlight in
                        HStack(alignment: .top) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(highlight)
                                .font(.caption)
                        }
                    }
                }
            }
            
            if !data.keyFindings.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ключевые выводы")
                        .font(.caption)
                        .fontWeight(.semibold)
                    ForEach(data.keyFindings, id: \.self) { finding in
                        HStack(alignment: .top) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text(finding)
                                .font(.caption)
                        }
                    }
                }
            }
            
            if !data.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Рекомендации")
                        .font(.caption)
                        .fontWeight(.semibold)
                    ForEach(data.recommendations, id: \.self) { recommendation in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text(recommendation)
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Metrics View

struct MetricsView: View {
    let metrics: [MetricData]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(metrics) { metric in
                MetricMiniCard(metric: metric)
            }
        }
    }
}

struct MetricMiniCard: View {
    let metric: MetricData
    
    var body: some View {
        VStack(spacing: 4) {
            if let icon = metric.icon {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            HStack(spacing: 2) {
                Text(metric.value)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                if let unit = metric.unit {
                    Text(unit)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(metric.title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

// MARK: - Table View

struct TableView: View {
    let data: TableData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Headers
            HStack {
                ForEach(data.headers, id: \.self) { header in
                    Text(header)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Divider()
            
            // Rows
            ForEach(data.rows.prefix(3), id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { cell in
                        Text(cell)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            
            if data.rows.count > 3 {
                Text("... и еще \(data.rows.count - 3)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Create Report View

struct CreateReportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedType = ReportType.learningProgress
    @State private var selectedPeriod = AnalyticsPeriod.month
    @State private var selectedFormat = ReportFormat.pdf
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Название отчета", text: $title)
                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Параметры") {
                    Picker("Тип отчета", selection: $selectedType) {
                        ForEach(ReportType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    
                    Picker("Период", selection: $selectedPeriod) {
                        ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    
                    Picker("Формат", selection: $selectedFormat) {
                        ForEach(ReportFormat.allCases, id: \.self) { format in
                            Label(format.rawValue, systemImage: format.icon)
                                .tag(format)
                        }
                    }
                }
            }
            .navigationTitle("Новый отчет")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        createReport()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func createReport() {
        // Create report logic
        dismiss()
    }
}

// MARK: - Helper Views

struct ReportFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(15)
        }
    }
}

struct ReportInfoCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

// MARK: - Date Formatter
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

// MARK: - Preview

struct ReportsListView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsListView()
    }
} 