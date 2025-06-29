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

// Debug menu для разработки
struct FeedbackDebugMenu: View {
    var body: some View {
        List {
            Section("Feedback Actions") {
                Button("Show Feedback Form") {
                    FeedbackManager.shared.presentFeedback()
                }
                
                Button("Toggle Floating Button") {
                    FeedbackManager.shared.feedbackButtonVisible.toggle()
                }
                
                Button("Send Test Feedback") {
                    sendTestFeedback()
                }
                
                NavigationLink("View Feedback Feed") {
                    FeedbackFeedView()
                }
            }
        }
        .navigationTitle("Feedback Debug")
    }
    
    private func sendTestFeedback() {
        let testFeedback = FeedbackModel(
            type: "bug",
            text: "Test feedback from debug menu",
            deviceInfo: DeviceInfo(
                model: UIDevice.current.model,
                osVersion: UIDevice.current.systemVersion,
                appVersion: "1.0.0",
                buildNumber: "100"
            )
        )
        
        Task {
            let success = await FeedbackService.shared.createFeedback(testFeedback)
            await MainActor.run {
                print("Test feedback sent: \(success)")
            }
        }
    }
} 