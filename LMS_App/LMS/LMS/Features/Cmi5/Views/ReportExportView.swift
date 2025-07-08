//
//  ReportExportView.swift
//  LMS
//
//  Created on Sprint 42 Day 3 - Report Export
//

import SwiftUI
import UniformTypeIdentifiers

struct ReportExportView: View {
    @ObservedObject var viewModel: AnalyticsDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedReportType = ReportGenerator.ReportType.progress
    @State private var selectedFormat = ExportFormat.pdf
    @State private var isGenerating = false
    @State private var showingShareSheet = false
    @State private var generatedFileURL: URL?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    enum ExportFormat: String, CaseIterable {
        case pdf = "PDF"
        case csv = "CSV"
        case excel = "Excel"
        
        var icon: String {
            switch self {
            case .pdf: return "doc.fill"
            case .csv: return "tablecells.fill"
            case .excel: return "tablecells.badge.ellipsis"
            }
        }
        
        var fileExtension: String {
            switch self {
            case .pdf: return "pdf"
            case .csv: return "csv"
            case .excel: return "xlsx"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                reportTypeSection
                formatSection
                previewSection
                exportOptionsSection
            }
            .navigationTitle("Export Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Export") {
                        generateReport()
                    }
                    .disabled(isGenerating)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = generatedFileURL {
                ShareSheet(items: [url])
            }
        }
        .alert("Export Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Sections
    
    private var reportTypeSection: some View {
        Section {
            Picker("Report Type", selection: $selectedReportType) {
                ForEach([ReportGenerator.ReportType.progress,
                         .performance,
                         .engagement,
                         .comparison], id: \.self) { type in
                    Label(type.rawValue, systemImage: reportIcon(for: type))
                        .tag(type)
                }
            }
            .pickerStyle(DefaultPickerStyle())
        } header: {
            Text("Select Report Type")
        }
    }
    
    private var formatSection: some View {
        Section {
            ForEach(ExportFormat.allCases, id: \.self) { format in
                HStack {
                    Image(systemName: format.icon)
                        .foregroundColor(.accentColor)
                        .frame(width: 24)
                    
                    Text(format.rawValue)
                    
                    Spacer()
                    
                    if selectedFormat == format {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedFormat = format
                }
            }
        } header: {
            Text("Export Format")
        }
    }
    
    private var previewSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                // Report preview
                ReportPreview(
                    type: selectedReportType,
                    metrics: ReportMetrics(
                        completion: viewModel.completionRate,
                        averageScore: viewModel.averageScore,
                        totalTime: viewModel.totalTime,
                        activities: viewModel.completedActivities
                    )
                )
            }
            .padding(.vertical, 8)
        } header: {
            Text("Preview")
        }
    }
    
    private var exportOptionsSection: some View {
        Section {
            // Date range
            DateRangeRow()
            
            // Include charts toggle
            if selectedFormat == .pdf {
                Toggle("Include Charts", isOn: .constant(true))
            }
            
            // Include detailed data
            Toggle("Include Detailed Data", isOn: .constant(true))
            
            // Email option
            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(.accentColor)
                    .frame(width: 24)
                
                Text("Email to")
                
                Spacer()
                
                Text("user@example.com")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Options")
        } footer: {
            if isGenerating {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Generating report...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Actions
    
    private func generateReport() {
        isGenerating = true
        
        Task {
            do {
                // Simulate report generation
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                
                // Create temporary file
                let fileName = "\(selectedReportType.rawValue)_\(Date().timeIntervalSince1970).\(selectedFormat.fileExtension)"
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                
                // Generate content based on format
                switch selectedFormat {
                case .pdf:
                    try generatePDFReport(to: tempURL)
                case .csv:
                    try generateCSVReport(to: tempURL)
                case .excel:
                    try generateExcelReport(to: tempURL)
                }
                
                await MainActor.run {
                    generatedFileURL = tempURL
                    isGenerating = false
                    showingShareSheet = true
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isGenerating = false
                }
            }
        }
    }
    
    private func generatePDFReport(to url: URL) throws {
        // In real implementation, would use ReportGenerator
        let pdfData = "Sample PDF content".data(using: .utf8)!
        try pdfData.write(to: url)
    }
    
    private func generateCSVReport(to url: URL) throws {
        let csvContent = """
        Report Type,\(selectedReportType.rawValue)
        Generated,\(Date())
        
        Metric,Value
        Completion Rate,\(viewModel.completionRate)
        Average Score,\(viewModel.averageScore)
        Total Time,\(viewModel.totalTime)
        Completed Activities,\(viewModel.completedActivities)
        """
        
        try csvContent.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func generateExcelReport(to url: URL) throws {
        // In real implementation, would generate actual Excel file
        // For now, create CSV that Excel can open
        try generateCSVReport(to: url)
    }
    
    private func reportIcon(for type: ReportGenerator.ReportType) -> String {
        switch type {
        case .progress: return "chart.line.uptrend.xyaxis"
        case .performance: return "star.fill"
        case .engagement: return "person.3.fill"
        case .comparison: return "person.2.fill"
        case .completion: return "rosette"
        }
    }
}

// MARK: - Supporting Views

struct ReportPreview: View {
    let type: ReportGenerator.ReportType
    let metrics: ReportMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(type.rawValue)
                .font(.headline)
            
            Text("Generated: \(Date(), formatter: dateFormatter)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Divider()
            
            // Preview content based on type
            switch type {
            case .progress:
                progressPreview
            case .performance:
                performancePreview
            case .engagement:
                engagementPreview
            case .comparison:
                comparisonPreview
            case .completion:
                completionPreview
            }
        }
    }
    
    private var progressPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            PreviewRow(label: "Completion", value: "\(Int(metrics.completion * 100))%")
            PreviewRow(label: "Activities", value: "\(metrics.activities) completed")
            PreviewRow(label: "Time Invested", value: LearningMetrics.formatLearningTime(metrics.totalTime))
        }
    }
    
    private var performancePreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            PreviewRow(label: "Average Score", value: "\(Int(metrics.averageScore * 100))%")
            PreviewRow(label: "Success Rate", value: "85%")
            PreviewRow(label: "Performance Level", value: "Good ✨")
        }
    }
    
    private var engagementPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            PreviewRow(label: "Active Days", value: "15 out of 30")
            PreviewRow(label: "Peak Time", value: "2-3 PM")
            PreviewRow(label: "Consistency", value: "High")
        }
    }
    
    private var comparisonPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            PreviewRow(label: "Your Score", value: "85%")
            PreviewRow(label: "Group Average", value: "78%")
            PreviewRow(label: "Percentile", value: "75th")
        }
    }
    
    private var completionPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            PreviewRow(label: "Course", value: "Introduction to Swift")
            PreviewRow(label: "Final Score", value: "\(Int(metrics.averageScore * 100))%")
            PreviewRow(label: "Certificate ID", value: "CERT-2025-001")
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

struct PreviewRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
        }
    }
}

struct DateRangeRow: View {
    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            Text("Date Range")
            
            Spacer()
            
            Text("Last 30 days")
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Data Models

struct ReportMetrics {
    let completion: Double
    let averageScore: Double
    let totalTime: TimeInterval
    let activities: Int
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

struct ReportExportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportExportView(viewModel: AnalyticsDashboardViewModel())
    }
} 