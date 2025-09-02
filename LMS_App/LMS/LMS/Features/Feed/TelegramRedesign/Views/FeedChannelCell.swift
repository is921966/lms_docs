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
    
    private var channelColor: Color {
        switch channel.type {
        case .releases:
            return Color.blue
        case .sprints:
            return Color.green
        case .methodology:
            return Color.purple
        case .courses:
            return Color.orange
        case .admin:
            return Color.red
        case .hr:
            return Color.teal
        case .myCourses:
            return Color.indigo
        case .userPosts:
            return Color.pink
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return timeFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Вчера"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM"
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ChannelAvatar(avatar: channel.avatar, size: 60)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Name and Time
                HStack {
                    Text(channel.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(textColor)
                    
                    Spacer()
                    
                    Text(formatDate(channel.lastMessage.date))
                        .font(.system(size: 14))
                        .foregroundColor(secondaryColor)
                }
                
                // Message and Badge
                HStack(alignment: .center) {
                    Text(channel.lastMessage.content)
                        .font(.system(size: 15))
                        .foregroundColor(channel.lastMessage.isRead ? secondaryColor : textColor)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if channel.hasUnread && !channel.isMuted {
                        UnreadBadge(count: channel.unreadCount)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Previews

#if DEBUG
struct FeedChannelCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FeedChannelCell(channel: FeedChannel(
                type: .releases,
                lastMessage: FeedMessage(
                    content: "Важное объявление о работе офиса в праздничные дни",
                    author: "HR Department",
                    date: Date()
                ),
                unreadCount: 3,
                isPinned: true
            ))
            .previewLayout(.sizeThatFits)
            
            FeedChannelCell(channel: FeedChannel(
                type: .courses,
                lastMessage: FeedMessage(
                    content: "Новый курс по iOS разработке уже доступен",
                    author: "Учебный центр",
                    date: Date().addingTimeInterval(-3600)
                ),
                unreadCount: 0,
                isPinned: false,
                isMuted: true
            ))
            .previewLayout(.sizeThatFits)
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
}
#endif 