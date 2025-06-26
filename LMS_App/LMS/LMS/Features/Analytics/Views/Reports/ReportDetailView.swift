import SwiftUI

struct ReportDetailView: View {
    let report: Report
    @Environment(\.dismiss) private var dismiss
    @State private var isGenerating = false
    @State private var showExportOptions = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                ReportDetailHeader(report: report)
                
                // Description
                if !report.description.isEmpty {
                    ReportDescriptionSection(description: report.description)
                }
                
                // Info
                ReportInfoGrid(report: report)
                
                // Sections
                if !report.sections.isEmpty {
                    ReportSectionsView(sections: report.sections)
                }
                
                // Actions
                ReportActionsSection(
                    report: report,
                    isGenerating: $isGenerating,
                    showExportOptions: $showExportOptions,
                    onGenerate: generateReport,
                    onExport: { showExportOptions = true }
                )
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
    
    private func generateReport() {
        isGenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isGenerating = false
        }
    }
    
    private func exportReport(in format: ReportFormat) {
        print("Exporting report in \(format.rawValue) format")
    }
}

struct ReportDetailHeader: View {
    let report: Report
    
    var body: some View {
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
}

struct ReportDescriptionSection: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Описание")
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct ReportInfoGrid: View {
    let report: Report
    
    var body: some View {
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
}

struct ReportSectionsView: View {
    let sections: [ReportSection]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Разделы отчета")
                .font(.headline)
            
            ForEach(sections.sorted(by: { $0.order < $1.order })) { section in
                ReportSectionView(section: section)
            }
        }
    }
}

struct ReportActionsSection: View {
    let report: Report
    @Binding var isGenerating: Bool
    @Binding var showExportOptions: Bool
    let onGenerate: () -> Void
    let onExport: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            if report.status == .draft {
                Button(action: onGenerate) {
                    Label("Сгенерировать отчет", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGenerating)
            }
            
            if report.status == .ready {
                Button(action: onExport) {
                    Label("Экспортировать", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.top)
    }
}

// Date Formatter
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    NavigationView {
        ReportDetailView(
            report: Report(
                title: "Отчет по обучению",
                description: "Детальный анализ прогресса обучения",
                type: .learningProgress,
                status: .ready,
                period: .month,
                createdBy: "admin",
                format: .pdf,
                sections: []
            )
        )
    }
}
