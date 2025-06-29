import SwiftUI

// MARK: - Feedback Setup Extension
extension LMSApp {
    func setupFeedback() {
        // Initialize feedback manager
        _ = FeedbackManager.shared
        
        // The feedback system is ready to use
        print("✅ Feedback system initialized")
    }
}

// MARK: - View Extension for Feedback
extension View {
    func feedbackEnabled() -> some View {
        self.modifier(FeedbackEnabledModifier())
    }
}

// MARK: - Feedback Modifier
struct FeedbackEnabledModifier: ViewModifier {
    @ObservedObject private var feedbackManager = FeedbackManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            // Floating feedback button
            if feedbackManager.feedbackButtonVisible {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            feedbackManager.presentFeedback()
                        }) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .sheet(isPresented: $feedbackManager.isShowingFeedback) {
            FeedbackView()
        }
    }
} 