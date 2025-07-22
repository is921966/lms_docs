import SwiftUI

struct FeedView: View {
    @AppStorage("useNewFeedDesign") private var useNewFeedDesign = false
    
    init() {
        print("📜 Classic FeedView init")
        ComprehensiveLogger.shared.log(.ui, .info, "Classic FeedView initialized")
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Классическая лента новостей")
                .font(.largeTitle)
                .padding()
            
            Text("Переключите на новый дизайн в настройках")
                .foregroundColor(.secondary)
            
            // Кнопка быстрого переключения
            Button(action: {
                print("🔘 Quick switch button pressed")
                ComprehensiveLogger.shared.log(.ui, .info, "Try new feed button tapped", details: [
                    "currentDesign": "classic",
                    "action": "switch_to_new"
                ])
                
                // Напрямую меняем UserDefaults
                withAnimation {
                    useNewFeedDesign = true
                    
                    // Также обновляем FeedDesignManager для синхронизации
                    FeedDesignManager.shared.setDesign(true)
                }
            }) {
                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                    Text("Попробовать новую ленту")
                        .font(.headline)
                    Text("Современный дизайн в стиле Telegram")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Лента")
        .trackScreen("FeedView", metadata: [
            "type": "classic",
            "design": "old",
            "hasButton": true
        ])
        .onAppear {
            print("📜 Classic FeedView body rendered")
            print("   - useNewFeedDesign: \(useNewFeedDesign)")
            
            ComprehensiveLogger.shared.log(.ui, .info, "Classic FeedView appeared", details: [
                "useNewFeedDesign": useNewFeedDesign,
                "reason": "User is viewing classic feed design"
            ])
        }
    }
} 