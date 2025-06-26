import SwiftUI

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
        // In real app would save to service
        dismiss()
    }
}

#Preview {
    CreateReportView()
}
