import SwiftUI

struct ServerStatusView: View {
    @State private var logServerHealthy = false
    @State private var feedbackServerHealthy = false
    @State private var isChecking = true
    @State private var lastCheckTime: Date?
    @State private var logServerStats: ServerStats?
    @State private var feedbackServerStats: ServerStats?
    
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    var body: some View {
        List {
            // Header with refresh button
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Server Health Check")
                            .font(.headline)
                        if let lastCheck = lastCheckTime {
                            Text("Last checked: \(lastCheck, formatter: timeFormatter)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: checkServerHealth) {
                        if isChecking {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(isChecking)
                }
            }
            
            // Log Server Status
            Section(header: Text("📊 Log Server")) {
                ServerStatusRow(
                    title: "Status",
                    value: logServerHealthy ? "Online" : "Offline",
                    color: logServerHealthy ? .green : .red
                )
                
                ServerStatusRow(
                    title: "URL",
                    value: CloudServerManager.shared.logServerURL,
                    color: .blue
                )
                
                if let stats = logServerStats {
                    ServerStatusRow(
                        title: "Total Logs",
                        value: "\(stats.totalLogs)",
                        color: .primary
                    )
                    
                    ServerStatusRow(
                        title: "Devices",
                        value: "\(stats.deviceCount)",
                        color: .primary
                    )
                    
                    ServerStatusRow(
                        title: "Uptime",
                        value: stats.uptime,
                        color: .primary
                    )
                }
                
                NavigationLink(destination: CloudServersView()) {
                    HStack {
                        Text("Open Dashboard")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Feedback Server Status
            Section(header: Text("💬 Feedback Server")) {
                ServerStatusRow(
                    title: "Status",
                    value: feedbackServerHealthy ? "Online" : "Offline",
                    color: feedbackServerHealthy ? .green : .red
                )
                
                ServerStatusRow(
                    title: "URL",
                    value: CloudServerManager.shared.feedbackServerURL,
                    color: .blue
                )
                
                if let stats = feedbackServerStats {
                    ServerStatusRow(
                        title: "Total Feedback",
                        value: "\(stats.totalFeedback)",
                        color: .primary
                    )
                    
                    ServerStatusRow(
                        title: "GitHub Issues",
                        value: stats.githubConfigured ? "Configured" : "Not configured",
                        color: stats.githubConfigured ? .green : .orange
                    )
                }
                
                NavigationLink(destination: CloudServersView()) {
                    HStack {
                        Text("Open Dashboard")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Connection Settings
            Section(header: Text("⚙️ Connection Settings")) {
                NavigationLink(destination: CloudServerSettingsView()) {
                    Label("Configure Server URLs", systemImage: "gear")
                }
                
                Button(action: testConnections) {
                    Label("Test Connections", systemImage: "network")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Server Status")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkServerHealth()
        }
        .onReceive(timer) { _ in
            checkServerHealth()
        }
        .refreshable {
            await checkServerHealthAsync()
        }
    }
    
    private func checkServerHealth() {
        isChecking = true
        
        CloudServerManager.shared.checkServerHealth { logHealthy, feedbackHealthy in
            DispatchQueue.main.async {
                self.logServerHealthy = logHealthy
                self.feedbackServerHealthy = feedbackHealthy
                self.isChecking = false
                self.lastCheckTime = Date()
                
                // Fetch additional stats if servers are healthy
                if logHealthy {
                    fetchLogServerStats()
                }
                if feedbackHealthy {
                    fetchFeedbackServerStats()
                }
            }
        }
    }
    
    @MainActor
    private func checkServerHealthAsync() async {
        await withCheckedContinuation { continuation in
            checkServerHealth()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                continuation.resume()
            }
        }
    }
    
    private func fetchLogServerStats() {
        guard let url = URL(string: "\(CloudServerManager.shared.logServerURL)/health") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    self.logServerStats = ServerStats(
                        totalLogs: json["log_count"] as? Int ?? 0,
                        deviceCount: json["device_count"] as? Int ?? 0,
                        uptime: "Online"
                    )
                }
            }
        }.resume()
    }
    
    private func fetchFeedbackServerStats() {
        guard let url = URL(string: "\(CloudServerManager.shared.feedbackServerURL)/health") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    self.feedbackServerStats = ServerStats(
                        totalFeedback: json["feedback_count"] as? Int ?? 0,
                        githubConfigured: json["github_configured"] as? Bool ?? false
                    )
                }
            }
        }.resume()
    }
    
    private func testConnections() {
        // Test log upload
        ComprehensiveLogger.shared.log(.system, .info, "Server connection test", details: [
            "source": "ServerStatusView",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
        
        // Force upload
        LogUploader.shared.uploadLogsImmediately()
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }
}

// MARK: - Supporting Views
struct ServerStatusRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(color)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Models
struct ServerStats {
    var totalLogs: Int = 0
    var deviceCount: Int = 0
    var uptime: String = ""
    var totalFeedback: Int = 0
    var githubConfigured: Bool = false
}

// MARK: - Preview
struct ServerStatusView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ServerStatusView()
        }
    }
} 