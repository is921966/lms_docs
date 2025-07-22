//
//  MessageBubble.swift
//  LMS
//
//  Sprint 50 - Компонент пузыря сообщения в стиле Telegram
//

import SwiftUI

/// Компонент для отображения сообщения в стиле Telegram
struct MessageBubble: View {
    let message: FeedMessage
    @Environment(\.colorScheme) var colorScheme
    
    private var bubbleColor: Color {
        message.author == "You" ? Color.blue : Color(UIColor.systemGray5)
    }
    
    private var textColor: Color {
        message.author == "You" ? .white : (colorScheme == .dark ? .white : .black)
    }
    
    private var alignment: HorizontalAlignment {
        message.author == "You" ? .trailing : .leading
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack {
            if message.author == "You" { Spacer() }
            
            VStack(alignment: alignment, spacing: 4) {
                // Author name (if not from user)
                if message.author != "You" {
                    Text(message.author)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Message bubble
                VStack(alignment: .leading, spacing: 4) {
                    // Message text with markdown support
                    MarkdownContentView(text: message.text)
                        .foregroundColor(textColor)
                    
                    // Time and read status
                    HStack(spacing: 4) {
                        Text(timeFormatter.string(from: message.timestamp))
                            .font(.caption2)
                            .foregroundColor(textColor.opacity(0.7))
                        
                        if message.author == "You" && message.isRead {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(bubbleColor)
                .cornerRadius(16)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: alignment == .trailing ? .trailing : .leading)
            }
            
            if message.author != "You" { Spacer() }
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
}

// MARK: - Previews

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            // Incoming message
            MessageBubble(message: FeedMessage(
                id: UUID(),
                text: "Привет! Это обычное сообщение от системы.",
                timestamp: Date(),
                author: "System",
                isRead: true
            ))
            
            // Outgoing message
            MessageBubble(message: FeedMessage(
                id: UUID(),
                text: "Это мой ответ на сообщение",
                timestamp: Date().addingTimeInterval(-60),
                author: "You",
                isRead: true
            ))
            
            // Long message with markdown
            MessageBubble(message: FeedMessage(
                id: UUID(),
                text: "**Важное обновление!**\n\nМы рады сообщить о выпуске новой версии:\n- Улучшена производительность\n- Добавлены новые функции\n- Исправлены ошибки\n\n[Подробнее](https://example.com)",
                timestamp: Date().addingTimeInterval(-3600),
                author: "Admin",
                isRead: false
            ))
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
} 