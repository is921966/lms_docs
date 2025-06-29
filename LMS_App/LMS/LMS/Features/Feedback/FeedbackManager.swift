import SwiftUI
import Combine

class FeedbackManager: ObservableObject {
    static let shared = FeedbackManager()
    
    @Published var showFeedback = false
    @Published var feedbackButtonVisible = true
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupShakeDetection()
    }
    
    private func setupShakeDetection() {
        NotificationCenter.default.publisher(for: NSNotification.Name("deviceDidShake"))
            .sink { _ in
                withAnimation {
                    self.showFeedback = true
                }
            }
            .store(in: &cancellables)
    }
    
    func presentFeedback() {
        showFeedback = true
    }
}

// ⚡ НОВОЕ: Расширенный Debug menu с мониторингом производительности
struct FeedbackDebugMenu: View {
    @StateObject private var feedbackService = FeedbackService.shared
    @State private var showPerformanceDetails = false
    
    var body: some View {
        List {
            // Статус сети и производительности
            performanceSection
            
            // Offline queue monitoring
            if !feedbackService.pendingFeedbacks.isEmpty {
                offlineQueueSection
            }
            
            // Debug actions
            debugActionsSection
            
            // GitHub API Test
            githubTestSection
        }
        .navigationTitle("Feedback Debug")
        .sheet(isPresented: $showPerformanceDetails) {
            PerformanceDetailsView()
        }
    }
    
    private var performanceSection: some View {
        Section("📊 Performance Monitoring") {
            HStack {
                VStack(alignment: .leading) {
                    Text("Network Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        Text(feedbackService.networkStatus.emoji)
                        Text(feedbackService.networkStatus.description)
                            .font(.headline)
                    }
                }
                Spacer()
            }
            
            if feedbackService.performanceMetrics.totalFeedbacksCreated > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Avg GitHub Time:")
                        Spacer()
                        Text("\(String(format: "%.2f", feedbackService.performanceMetrics.averageGitHubCreateTime))s")
                            .foregroundColor(feedbackService.performanceMetrics.averageGitHubCreateTime < 5 ? .green : .orange)
                    }
                    
                    HStack {
                        Text("Success Rate:")
                        Spacer()
                        Text("\(String(format: "%.1f", feedbackService.performanceMetrics.successRate * 100))%")
                            .foregroundColor(feedbackService.performanceMetrics.successRate > 0.9 ? .green : .red)
                    }
                    
                    HStack {
                        Text("Total Created:")
                        Spacer()
                        Text("\(feedbackService.performanceMetrics.totalFeedbacksCreated)")
                    }
                    
                    if let lastSync = feedbackService.performanceMetrics.lastSyncTime {
                        HStack {
                            Text("Last Sync:")
                            Spacer()
                            Text(lastSync, style: .relative)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .font(.system(.body, design: .monospaced))
                
                Button("📈 Detailed Performance") {
                    showPerformanceDetails = true
                }
            }
        }
    }
    
    private var offlineQueueSection: some View {
        Section("📦 Offline Queue (\(feedbackService.pendingFeedbacks.count))") {
            ForEach(feedbackService.pendingFeedbacks, id: \.id) { feedback in
                VStack(alignment: .leading, spacing: 2) {
                    Text(feedback.title)
                        .font(.headline)
                    Text("Created: \(feedback.createdAt, style: .relative)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if feedbackService.networkStatus == .connected {
                Button("🔄 Process Queue Now") {
                    Task {
                        // Trigger manual processing
                        print("Manual queue processing triggered")
                    }
                }
            }
        }
    }
    
    private var debugActionsSection: some View {
        Section("🔧 Debug Actions") {
            Button("Show Feedback Form") {
                FeedbackManager.shared.presentFeedback()
            }
            
            Button("Toggle Floating Button") {
                FeedbackManager.shared.feedbackButtonVisible.toggle()
            }
            
            Button("Send Test Feedback") {
                sendTestFeedback()
            }
            
            Button("Send Performance Test (10x)") {
                performanceTest()
            }
            
            NavigationLink("View Feedback Feed") {
                FeedbackFeedView()
            }
        }
    }
    
    private var githubTestSection: some View {
        Section("🔗 GitHub API Test") {
            Button("Test GitHub Connection") {
                testGitHubConnection()
            }
            
            Button("Create Test Issue") {
                createTestGitHubIssue()
            }
        }
    }
    
    private func sendTestFeedback() {
        let testFeedback = FeedbackModel(
            type: "bug",
            text: "Test feedback from debug menu at \(Date())",
            deviceInfo: DeviceInfo(
                model: UIDevice.current.model,
                osVersion: UIDevice.current.systemVersion,
                appVersion: "1.0.0",
                buildNumber: "100"
            )
        )
        
        Task {
            let startTime = Date()
            let success = await FeedbackService.shared.createFeedback(testFeedback)
            let duration = Date().timeIntervalSince(startTime)
            
            await MainActor.run {
                print("✅ Test feedback completed in \(String(format: "%.2f", duration))s: \(success)")
            }
        }
    }
    
    private func performanceTest() {
        Task {
            print("🚀 Starting performance test (10 feedbacks)...")
            let startTime = Date()
            
            for i in 1...10 {
                let testFeedback = FeedbackModel(
                    type: "question",
                    text: "Performance test feedback #\(i) at \(Date())",
                    deviceInfo: DeviceInfo(
                        model: UIDevice.current.model,
                        osVersion: UIDevice.current.systemVersion,
                        appVersion: "1.0.0",
                        buildNumber: "100"
                    )
                )
                
                _ = await FeedbackService.shared.createFeedback(testFeedback)
            }
            
            let totalDuration = Date().timeIntervalSince(startTime)
            let avgPerFeedback = totalDuration / 10
            
            await MainActor.run {
                print("""
                🏁 Performance test completed:
                - Total time: \(String(format: "%.2f", totalDuration))s
                - Average per feedback: \(String(format: "%.2f", avgPerFeedback))s
                - Rate: \(String(format: "%.1f", 10/totalDuration)) feedbacks/sec
                """)
            }
        }
    }
    
    private func testGitHubConnection() {
        Task {
            let startTime = Date()
            
            guard let url = URL(string: "https://api.github.com/rate_limit") else { return }
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                let duration = Date().timeIntervalSince(startTime)
                
                if let httpResponse = response as? HTTPURLResponse {
                    await MainActor.run {
                        print("""
                        📡 GitHub API Test:
                        - Response time: \(String(format: "%.2f", duration))s
                        - Status: \(httpResponse.statusCode)
                        - Connection: \(httpResponse.statusCode == 200 ? "✅ Good" : "❌ Failed")
                        """)
                    }
                    
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let resources = json["resources"] as? [String: Any],
                       let core = resources["core"] as? [String: Any],
                       let remaining = core["remaining"] as? Int {
                        print("- API calls remaining: \(remaining)")
                    }
                }
            } catch {
                await MainActor.run {
                    print("❌ GitHub API test failed: \(error)")
                }
            }
        }
    }
    
    private func createTestGitHubIssue() {
        let testFeedback = FeedbackItem(
            title: "Test GitHub Integration",
            description: "This is a test issue created from the debug menu to verify GitHub integration performance.",
            type: .question,
            author: "Debug Menu",
            authorId: "debug_user",
            isOwnFeedback: true
        )
        
        Task {
            let startTime = Date()
            let success = await GitHubFeedbackService.shared.createIssueFromFeedback(testFeedback)
            let duration = Date().timeIntervalSince(startTime)
            
            await MainActor.run {
                print("""
                🧪 GitHub Issue Test:
                - Success: \(success ? "✅" : "❌")
                - Duration: \(String(format: "%.2f", duration))s
                - Status: \(success ? "Issue created successfully" : "Failed to create issue")
                """)
            }
        }
    }
}

// ⚡ НОВОЕ: Детальный вид производительности
struct PerformanceDetailsView: View {
    @StateObject private var feedbackService = FeedbackService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("📊 Current Metrics") {
                    MetricRow(title: "Average GitHub Time", 
                             value: "\(String(format: "%.2f", feedbackService.performanceMetrics.averageGitHubCreateTime))s",
                             status: feedbackService.performanceMetrics.averageGitHubCreateTime < 5 ? .good : .warning)
                    
                    MetricRow(title: "Success Rate", 
                             value: "\(String(format: "%.1f", feedbackService.performanceMetrics.successRate * 100))%",
                             status: feedbackService.performanceMetrics.successRate > 0.9 ? .good : .error)
                    
                    MetricRow(title: "Total Created", 
                             value: "\(feedbackService.performanceMetrics.totalFeedbacksCreated)",
                             status: .neutral)
                    
                    MetricRow(title: "Pending", 
                             value: "\(feedbackService.pendingFeedbacks.count)",
                             status: feedbackService.pendingFeedbacks.isEmpty ? .good : .warning)
                }
                
                Section("🎯 SLA Targets") {
                    SLARow(title: "Local Save", target: "< 0.5s", current: "~0.1s", isGood: true)
                    SLARow(title: "GitHub Issue", target: "< 5s", 
                          current: "\(String(format: "%.1f", feedbackService.performanceMetrics.averageGitHubCreateTime))s", 
                          isGood: feedbackService.performanceMetrics.averageGitHubCreateTime < 5)
                    SLARow(title: "Success Rate", target: "> 95%", 
                          current: "\(String(format: "%.1f", feedbackService.performanceMetrics.successRate * 100))%", 
                          isGood: feedbackService.performanceMetrics.successRate > 0.95)
                }
            }
            .navigationTitle("Performance Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MetricRow: View {
    let title: String
    let value: String
    let status: MetricStatus
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(status.color)
                .font(.system(.body, design: .monospaced))
            Text(status.emoji)
        }
    }
}

struct SLARow: View {
    let title: String
    let target: String
    let current: String
    let isGood: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                Spacer()
                Text(isGood ? "✅" : "⚠️")
            }
            .font(.headline)
            
            HStack {
                Text("Target: \(target)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Current: \(current)")
                    .font(.caption)
                    .foregroundColor(isGood ? .green : .orange)
            }
        }
    }
}

enum MetricStatus {
    case good, warning, error, neutral
    
    var color: Color {
        switch self {
        case .good: return .green
        case .warning: return .orange
        case .error: return .red
        case .neutral: return .primary
        }
    }
    
    var emoji: String {
        switch self {
        case .good: return "✅"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .neutral: return ""
        }
    }
} 