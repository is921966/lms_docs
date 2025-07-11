import Combine
import Foundation
import SwiftUI
import UIKit

class FeedbackManager: ObservableObject {
    static let shared = FeedbackManager()

    @Published var showFeedback = false
    @Published var feedbackButtonVisible = true
    @Published var isShowingFeedback = false
    @Published var isShakeEnabled = true
    @Published var feedbackType: FeedbackType = .bug
    @Published var feedbackText = ""
    @Published var screenshot: UIImage?
    @Published var isSubmitting = false
    @Published var submitSuccess = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let feedbackService = GitHubFeedbackService()
    private let serverFeedbackService = ServerFeedbackService.shared

    private init() {
        setupShakeDetection()
    }

    private func setupShakeDetection() {
        NotificationCenter.default.publisher(for: NSNotification.Name("deviceDidShake"))
            .sink { _ in
                // Захватываем скриншот перед показом формы
                self.captureScreenBeforeFeedback()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        self.showFeedback = true
                        self.isShowingFeedback = true
                    }
                }
            }
            .store(in: &cancellables)
    }

    /// Захватывает скриншот текущего экрана перед показом формы обратной связи
    func captureScreenBeforeFeedback() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let image = renderer.image { context in
            window.layer.render(in: context.cgContext)
        }

        self.screenshot = image
    }

    func presentFeedback() {
        // Захватываем скриншот перед показом формы
        captureScreenBeforeFeedback()

        // Показываем форму с небольшой задержкой, чтобы скриншот успел сохраниться
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isShowingFeedback = true
        }
    }

    func showFeedback(type: FeedbackType = .bug, screenshot: UIImage? = nil) {
        self.feedbackType = type

        // Если передан скриншот, используем его, иначе делаем новый
        if let providedScreenshot = screenshot {
            self.screenshot = providedScreenshot
        } else {
            captureScreenBeforeFeedback()
        }

        self.feedbackText = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isShowingFeedback = true
        }
    }

    func submitFeedback() {
        guard !feedbackText.isEmpty else {
            errorMessage = "Пожалуйста, введите описание"
            return
        }

        isSubmitting = true
        errorMessage = nil

        Task {
            do {
                // Сначала отправляем на сервер
                let serverSuccess = await sendToServer()

                if serverSuccess {
                    // Если успешно отправлено на сервер, создаем issue в GitHub
                    let issueNumber = try await feedbackService.submitFeedback(
                        type: feedbackType.rawValue,
                        title: generateTitle(),
                        body: feedbackText,
                        screenshot: screenshot
                    )

                    await MainActor.run {
                        self.submitSuccess = true
                        self.isSubmitting = false
                        self.feedbackText = ""
                        self.screenshot = nil

                        // Закрываем форму через 2 секунды
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.isShowingFeedback = false
                            self.submitSuccess = false
                        }
                    }
                } else {
                    throw FeedbackError.serverError
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isSubmitting = false
                }
            }
        }
    }

    private func sendToServer() async -> Bool {
        let feedback = FeedbackModel(
            type: feedbackType.rawValue,
            text: feedbackText,
            screenshot: screenshot?.base64String,
            deviceInfo: DeviceInfo(
                model: UIDevice.current.model,
                osVersion: UIDevice.current.systemVersion,
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
                locale: Locale.current.identifier,
                screenSize: "\(Int(UIScreen.main.bounds.width))x\(Int(UIScreen.main.bounds.height))"
            ),
            userId: await MockAuthService.shared.currentUser?.id,
            userEmail: await MockAuthService.shared.currentUser?.email,
            appContext: AppContext.current()
        )

        return await withCheckedContinuation { continuation in
            serverFeedbackService.submitFeedback(feedback) { result in
                switch result {
                case .success:
                    continuation.resume(returning: true)
                case .failure:
                    continuation.resume(returning: false)
                }
            }
        }
    }

    private func generateTitle() -> String {
        let prefix = feedbackType.emoji + " " + feedbackType.title
        let preview = String(feedbackText.prefix(50))
        return "\(prefix): \(preview)\(feedbackText.count > 50 ? "..." : "")"
    }

    func resetFeedback() {
        feedbackText = ""
        screenshot = nil
        errorMessage = nil
        submitSuccess = false
    }
}

// Error types
enum FeedbackError: LocalizedError {
    case invalidData
    case networkError
    case serverError
    case githubError(String)

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Неверные данные"
        case .networkError:
            return "Ошибка сети. Проверьте подключение к интернету."
        case .serverError:
            return "Ошибка сервера. Попробуйте позже."
        case .githubError(let message):
            return "GitHub ошибка: \(message)"
        }
    }
}

// Extension for UIImage to Base64
extension UIImage {
    var base64String: String? {
        guard let imageData = self.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString()
    }
}

// Helper to get device info
extension FeedbackManager {
    func getDeviceInfo() -> String {
        let device = UIDevice.current
        let bundle = Bundle.main
        let appVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = bundle.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

        return """
        Device: \(device.model)
        iOS: \(device.systemVersion)
        App Version: \(appVersion) (\(buildNumber))
        """
    }
}

// MARK: - Test Helpers
#if DEBUG
extension FeedbackManager {
    func sendTestFeedback() {
        Task {
            let testFeedback = FeedbackModel(
                type: FeedbackType.bug.rawValue,
                text: "Test feedback from iOS app",
                screenshot: nil,
                deviceInfo: DeviceInfo(
                    model: "iPhone",
                    osVersion: "iOS 18.0",
                    appVersion: "2.0.0",
                    buildNumber: "1",
                    locale: "ru-RU",
                    screenSize: "390x844"
                ),
                userId: "test-user",
                userEmail: "test@example.com",
                appContext: nil
            )

            serverFeedbackService.submitFeedback(testFeedback) { result in
                switch result {
                case .success(let issueUrl):
                    Logger.shared.success("Test feedback sent successfully: \(issueUrl)", category: .feedback)
                case .failure(let error):
                    Logger.shared.error("Failed to send test feedback: \(error)", category: .feedback)
                }
            }
        }
    }
}
#endif

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
                        Logger.shared.info("Manual queue processing triggered", category: .feedback)
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
                buildNumber: "100",
                locale: Locale.current.identifier,
                screenSize: "\(Int(UIScreen.main.bounds.width))x\(Int(UIScreen.main.bounds.height))"
            )
        )

        Task {
            let startTime = Date()
            let success = await FeedbackService.shared.createFeedback(testFeedback)
            let duration = Date().timeIntervalSince(startTime)

            await MainActor.run {
                Logger.shared.success("Test feedback completed in \(String(format: "%.2f", duration))s: \(success)", category: .feedback)
            }
        }
    }

    private func performanceTest() {
        Task {
            Logger.shared.info("Starting performance test (10 feedbacks)...", category: .feedback)
            let startTime = Date()

            for i in 1...10 {
                let testFeedback = FeedbackModel(
                    type: "question",
                    text: "Performance test feedback #\(i) at \(Date())",
                    deviceInfo: DeviceInfo(
                        model: UIDevice.current.model,
                        osVersion: UIDevice.current.systemVersion,
                        appVersion: "1.0.0",
                        buildNumber: "100",
                        locale: Locale.current.identifier,
                        screenSize: "\(Int(UIScreen.main.bounds.width))x\(Int(UIScreen.main.bounds.height))"
                    )
                )

                _ = await FeedbackService.shared.createFeedback(testFeedback)
            }

            let totalDuration = Date().timeIntervalSince(startTime)
            let avgPerFeedback = totalDuration / 10

            await MainActor.run {
                Logger.shared.info("""
                Performance test completed:
                - Total time: \(String(format: "%.2f", totalDuration))s
                - Average per feedback: \(String(format: "%.2f", avgPerFeedback))s
                - Rate: \(String(format: "%.1f", 10 / totalDuration)) feedbacks/sec
                """, category: .feedback)
            }
        }
    }

    func testGitHubConnection() {
        Task {
            let startTime = Date()

            guard let url = URL(string: "https://api.github.com/rate_limit") else { return }

            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                let duration = Date().timeIntervalSince(startTime)

                if let httpResponse = response as? HTTPURLResponse {
                    await MainActor.run {
                        Logger.shared.info("""
                        GitHub API Test:
                        - Response time: \(String(format: "%.2f", duration))s
                        - Status: \(httpResponse.statusCode)
                        - Connection: \(httpResponse.statusCode == 200 ? "Good" : "Failed")
                        """, category: .network)
                    }

                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let resources = json["resources"] as? [String: Any],
                       let core = resources["core"] as? [String: Any],
                       let remaining = core["remaining"] as? Int {
                        Logger.shared.info("- API calls remaining: \(remaining)", category: .network)
                    }
                }
            } catch {
                await MainActor.run {
                    Logger.shared.error("GitHub API test failed: \(error)", category: .network)
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
                Logger.shared.info("""
                GitHub Issue Test:
                - Success: \(success ? "Yes" : "No")
                - Duration: \(String(format: "%.2f", duration))s
                - Status: \(success ? "Issue created successfully" : "Failed to create issue")
                """, category: .network)
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
