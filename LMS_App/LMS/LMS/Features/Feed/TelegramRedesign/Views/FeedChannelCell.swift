//
//  FeedChannelCell.swift
//  LMS
//
//  Sprint 50 - Ячейка канала новостей в стиле Telegram
//

import SwiftUI

/// Ячейка канала в списке новостей
struct FeedChannelCell: View {
    let channel: FeedChannel
    @Environment(\.colorScheme) var colorScheme
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var secondaryColor: Color {
        Color(UIColor.systemGray)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ChannelAvatar(avatarType: channel.avatarType)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Header: Name and Time
                HStack(alignment: .top) {
                    HStack(spacing: 6) {
                        if channel.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 12))
                                .foregroundColor(secondaryColor)
                        }
                        
                        Text(channel.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(textColor)
                            .lineLimit(1)
                        
                        if channel.isMuted {
                            Image(systemName: "speaker.slash.fill")
                                .font(.system(size: 12))
                                .foregroundColor(secondaryColor)
                        }
                    }
                    
                    Spacer()
                    
                    Text(timeFormatter.string(from: channel.lastMessage.timestamp))
                        .font(.system(size: 14))
                        .foregroundColor(secondaryColor)
                }
                
                // Message and Badge
                HStack(alignment: .center) {
                    Text(channel.lastMessage.text)
                        .font(.system(size: 15))
                        .foregroundColor(channel.lastMessage.isRead ? secondaryColor : textColor)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if channel.hasUnread && !channel.isMuted {
                        UnreadBadge(count: channel.unreadCount)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

// MARK: - Previews

struct FeedChannelCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            // Pinned channel with unread
            FeedChannelCell(channel: FeedChannel(
                id: UUID(),
                name: "Администрация ЦУМ",
                avatarType: .text("А", .red),
                lastMessage: FeedMessage(
                    id: UUID(),
                    text: "📢 Важное объявление о графике работы...",
                    timestamp: Date(),
                    author: "Admin",
                    isRead: false
                ),
                unreadCount: 1,
                category: .announcement,
                priority: .critical,
                isPinned: true
            ))
            
            Divider()
                .padding(.leading, 76)
            
            // Learning channel
            FeedChannelCell(channel: FeedChannel(
                id: UUID(),
                name: "Учебный центр",
                avatarType: .icon("book.fill", .blue),
                lastMessage: FeedMessage(
                    id: UUID(),
                    text: "Открыта регистрация на курс Swift",
                    timestamp: Date().addingTimeInterval(-3600),
                    author: "Learning",
                    isRead: false
                ),
                unreadCount: 518,
                category: .learning,
                priority: .normal
            ))
            
            Divider()
                .padding(.leading, 76)
            
            // Muted HR Department
            FeedChannelCell(channel: FeedChannel(
                id: UUID(),
                name: "HR Департамент",
                avatarType: .text("HR", .green),
                lastMessage: FeedMessage(
                    id: UUID(),
                    text: "Напоминание: подайте заявления на отпуск",
                    timestamp: Date().addingTimeInterval(-7200),
                    author: "HR",
                    isRead: true
                ),
                unreadCount: 5,
                category: .department,
                priority: .normal,
                isMuted: true
            ))
            
            Divider()
                .padding(.leading, 76)
            
            // IT channel with important message
            FeedChannelCell(channel: FeedChannel(
                id: UUID(),
                name: "IT Новости",
                avatarType: .icon("desktopcomputer", .purple),
                lastMessage: FeedMessage(
                    id: UUID(),
                    text: "🚀 Выпущена новая версия приложения LMS 2.0",
                    timestamp: Date().addingTimeInterval(-86400),
                    author: "IT",
                    isRead: false
                ),
                unreadCount: 1,
                category: .event,
                priority: .high
            ))
        }
        .background(Color(UIColor.systemBackground))
        .previewLayout(.sizeThatFits)
    }
} 