//
//  NotificationCenterView.swift
//  LMS
//
//  Created on Sprint 41 Day 2 - Notification Center UI
//

import SwiftUI

/// Главный экран центра уведомлений
struct NotificationCenterView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = NotificationCenterViewModel()
    @State private var showingSettings = false
    @State private var selectedNotification: Notification?
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    LoadingView()
                } else if viewModel.notifications.isEmpty {
                    emptyStateView
                } else {
                    notificationsList
                }
            }
            .navigationTitle("Уведомления")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    closeButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    settingsButton
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $showingSettings) {
                NotificationSettingsView()
            }
            .sheet(item: $selectedNotification) { notification in
                NotificationDetailView(notification: notification)
            }
            .onAppear {
                viewModel.loadNotifications()
            }
        }
    }
    
    // MARK: - Views
    
    private var closeButton: some View {
        Button("Закрыть") {
            dismiss()
        }
    }
    
    private var settingsButton: some View {
        Button {
            showingSettings = true
        } label: {
            Image(systemName: "gearshape")
        }
    }
    
    private var notificationsList: some View {
        VStack(spacing: 0) {
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(NotificationFilterOption.allCases, id: \.self) { option in
                        NotificationCenterFilterChip(
                            option: option,
                            isSelected: viewModel.currentFilter == option,
                            action: {
                                viewModel.applyFilter(option)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            if viewModel.unreadCount > 0 {
                markAllAsReadButton
            }
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.notifications) { notification in
                        NotificationRowView(
                            notification: notification,
                            onTap: {
                                handleNotificationTap(notification)
                            },
                            onMarkAsRead: {
                                viewModel.markAsRead(notification)
                            },
                            onDelete: {
                                viewModel.delete(notification)
                            }
                        )
                        .id(notification.id)
                        
                        if notification != viewModel.notifications.last {
                            Divider()
                                .padding(.leading, 72)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }
    
    private var markAllAsReadButton: some View {
        Button {
            viewModel.markAllAsRead()
        } label: {
            HStack {
                Image(systemName: "checkmark.circle")
                Text("Отметить все как прочитанные")
                    .font(.subheadline)
            }
            .foregroundColor(.blue)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGroupedBackground))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("Нет уведомлений")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Когда появятся новые уведомления,\nони будут отображаться здесь")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Methods
    
    private func handleNotificationTap(_ notification: Notification) {
        // Mark as read if not already
        if !notification.isRead {
            viewModel.markAsRead(notification)
        }
        
        // Handle navigation based on notification type
        if let actionUrl = notification.metadata?.actionUrl {
            handleDeepLink(actionUrl)
        } else {
            // Show detail view
            selectedNotification = notification
        }
    }
    
    private func handleDeepLink(_ url: String) {
        // This would be handled by the app's deep link handler
        print("Handle deep link: \(url)")
    }
}

// MARK: - Filter Options

enum NotificationFilterOption: String, CaseIterable {
    case all = "all"
    case unread = "unread"
    case important = "important"
    case recent = "recent"
    
    var displayName: String {
        switch self {
        case .all: return "Все"
        case .unread: return "Непрочитанные"
        case .important: return "Важные"
        case .recent: return "Недавние"
        }
    }
    
    var icon: String? {
        switch self {
        case .all: return nil
        case .unread: return "circle"
        case .important: return "exclamationmark.circle"
        case .recent: return "clock"
        }
    }
    
    var filter: NotificationFilter {
        switch self {
        case .all:
            return NotificationFilter()
        case .unread:
            return NotificationFilter(showRead: false)
        case .important:
            return NotificationFilter(priorities: [.high])
        case .recent:
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            return NotificationFilter(dateFrom: yesterday)
        }
    }
}

// MARK: - Filter Chip

struct NotificationCenterFilterChip: View {
    let option: NotificationFilterOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = option.icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(option.displayName)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color(.systemGray5))
            )
        }
    }
}

// MARK: - Notification Row

struct NotificationRowView: View {
    let notification: Notification
    let onTap: () -> Void
    let onMarkAsRead: () -> Void
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Background actions
            HStack(spacing: 0) {
                // Mark as read button
                if !notification.isRead {
                    Button(action: onMarkAsRead) {
                        VStack {
                            Image(systemName: "checkmark.circle")
                                .font(.title2)
                            Text("Прочитано")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                    }
                    .background(Color.blue)
                }
                
                // Delete button
                Button(action: onDelete) {
                    VStack {
                        Image(systemName: "trash")
                            .font(.title2)
                        Text("Удалить")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                }
                .background(Color.red)
            }
            
            // Main content
            Button(action: onTap) {
                HStack(alignment: .top, spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(iconBackgroundColor)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: notification.type.icon)
                            .font(.title3)
                            .foregroundColor(iconColor)
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(notification.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            priorityBadge
                        }
                        
                        Text(notification.body)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        HStack {
                            Text(notification.createdAt.timeAgo)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                    
                    // Unread indicator
                    if !notification.isRead {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
            }
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -160)
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring()) {
                            if value.translation.width < -80 {
                                offset = -160
                                isSwiped = true
                            } else {
                                offset = 0
                                isSwiped = false
                            }
                        }
                    }
            )
        }
    }
    
    private var iconBackgroundColor: Color {
        switch notification.priority {
        case .urgent:
            return Color.red.opacity(0.15)
        case .high:
            return Color.orange.opacity(0.15)
        case .medium:
            return Color.blue.opacity(0.15)
        case .low:
            return Color.gray.opacity(0.15)
        }
    }
    
    private var iconColor: Color {
        switch notification.priority {
        case .urgent:
            return .red
        case .high:
            return .orange
        case .medium:
            return .blue
        case .low:
            return .gray
        }
    }
    
    @ViewBuilder
    private var priorityBadge: some View {
        switch notification.priority {
        case .urgent:
            HStack(spacing: 2) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.caption2)
                Text("Критично")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.red)
            .cornerRadius(4)
        case .high:
            HStack(spacing: 2) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption2)
                Text("Важно")
                    .font(.caption2)
            }
            .foregroundColor(.orange)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.orange.opacity(0.15))
            .cornerRadius(4)
        case .medium, .low:
            EmptyView()
        }
    }
}

// MARK: - Date Extension

extension Date {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - Preview

struct NotificationCenterView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationCenterView()
    }
} 