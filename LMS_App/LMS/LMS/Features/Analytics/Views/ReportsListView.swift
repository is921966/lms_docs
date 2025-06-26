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
                ReportFilterSection(filterType: $filterType)
                
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
    
    // MARK: - Filtered Reports
    private var filteredReports: [Report] {
        let userReports = service.getReports(for: currentUserId)
        
        if let filterType = filterType {
            return userReports.filter { $0.type == filterType }
        }
        return userReports
    }
}

// MARK: - Preview
struct ReportsListView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsListView()
    }
}
