import SwiftUI

struct FeedDetailView: View {
    let channel: FeedChannel
    let onDismiss: () -> Void
    
    @State private var messages: [FeedMessage] = []
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                FeedDetailNavigationBar(
                    channel: channel,
                    onBack: onDismiss
                )
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .onAppear {
                        loadMessages()
                        // Scroll to bottom
                        if let lastMessage = messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.width > 50 && !isDragging {
                        isDragging = true
                    }
                    offset = value.translation.width
                }
                .onEnded { value in
                    if value.translation.width > 100 {
                        onDismiss()
                    }
                    offset = 0
                    isDragging = false
                }
        )
        .offset(x: offset > 0 ? offset : 0)
        .animation(.interactiveSpring(), value: offset)
    }
    
    private func loadMessages() {
        // Mock messages for now
        messages = [
            FeedMessage(
                id: UUID(),
                text: "Добро пожаловать в **\(channel.name)**!",
                timestamp: Date().addingTimeInterval(-3600),
                author: "System",
                isRead: true
            ),
            channel.lastMessage,
            FeedMessage(
                id: UUID(),
                text: "Здесь будут отображаться **важные новости** и *объявления*.",
                timestamp: Date().addingTimeInterval(-300),
                author: "System",
                isRead: true
            ),
            FeedMessage(
                id: UUID(),
                text: "Вы можете настроить уведомления для этого канала в [настройках](settings://notifications).",
                timestamp: Date().addingTimeInterval(-60),
                author: "System",
                isRead: true
            )
        ]
    }
}

// MARK: - Navigation Bar

struct FeedDetailNavigationBar: View {
    let channel: FeedChannel
    let onBack: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Back button
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.accentColor)
            }
            
            // Channel info
            HStack(spacing: 10) {
                // Avatar
                ChannelAvatar(avatarType: channel.avatarType, size: 36)
                
                // Title and subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(channel.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(channel.category.displayName) • \(channel.priority.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // More button
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            Color(UIColor.systemBackground)
                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
    }
}

// MARK: - Preview

struct FeedDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FeedDetailView(
            channel: FeedChannel(
                id: UUID(),
                name: "ЦУМ Новости",
                avatarType: .text("ЦН", .blue),
                lastMessage: FeedMessage(
                    id: UUID(),
                    text: "Важное объявление о работе магазина",
                    timestamp: Date(),
                    author: "Admin",
                    isRead: false
                ),
                unreadCount: 0,
                category: .announcement,
                priority: .high
            ),
            onDismiss: {}
        )
    }
} 