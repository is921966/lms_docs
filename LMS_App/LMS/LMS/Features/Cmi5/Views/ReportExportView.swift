//
//  ReportExportView.swift
//  LMS
//

import SwiftUI

struct ReportExportView: View {
    @State private var selectedReportType = 0
    @State private var selectedFormat = 0
    @State private var isGenerating = false
    @State private var showShareSheet = false
    @State private var generatedFileURL: URL?
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let reportTypes = ["Progress", "Performance", "Engagement", "Comparison"]
    private let formats = ["PDF", "CSV"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Report Type") {
                    Picker("Type", selection: $selectedReportType) {
                        ForEach(0..<reportTypes.count, id: \.self) { index in
                            Text(reportTypes[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Export Format") {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(0..<formats.count, id: \.self) { index in
                            Text(formats[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button(action: generateReport) {
                        if isGenerating {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Generating...")
                            }
                        } else {
                            Label("Generate Report", systemImage: "doc.text.fill")
                        }
                    }
                    .disabled(isGenerating)
                }
            }
            .navigationTitle("Export Report")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showShareSheet) {
                if let url = generatedFileURL {
                    ReportShareSheet(url: url)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func generateReport() {
        isGenerating = true
        
        // Simulate report generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isGenerating = false
            // In real implementation, generate actual report
            showError = true
            errorMessage = "Report generation is temporarily unavailable"
        }
    }
}

struct ReportShareSheet: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
