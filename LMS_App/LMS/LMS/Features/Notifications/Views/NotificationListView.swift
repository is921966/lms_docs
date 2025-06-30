import SwiftUI

struct NotificationListView: View {
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var authService = MockAuthService.shared
    @State private var selectedFilter: NotificationType?
    @State private var showingDeleteConfirmation = false
    @State private var notificationToDelete: Notification?

    var filteredNotifications: [Notification] {
        let allNotifications = notificationService.notifications

        if let filter = selectedFilter {
            return allNotifications.filter { $0.type == filter }
        }
        return allNotifications
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        NotificationFilterChip(
                            title: "Все",
                            isSelected: selectedFilter == nil,
                            action: { selectedFilter = nil }
                        )

                        ForEach(NotificationType.allCases, id: \.self) { type in
                            NotificationFilterChip(
                                title: type.displayName,
                                isSelected: selectedFilter == type,
                                action: { selectedFilter = type }
                            )
                        }
                    }
                    .padding()
                }

                if filteredNotifications.isEmpty {
                    EmptyNotificationsView()
                } else {
                    List {
                        ForEach(filteredNotifications) { notification in
                            NotificationRow(notification: notification)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        notificationToDelete = notification
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    if !notification.isRead {
                                        Button {
                                            notificationService.markAsRead(notification)
                                        } label: {
                                            Label("Прочитано", systemImage: "checkmark")
                                        }
                                        .tint(.blue)
                                    }
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Уведомления")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if notificationService.unreadCount > 0 {
                        Button("Прочитать все") {
                            notificationService.markAllAsRead()
                        }
                    }
                }
            }
        }
        .alert("Удалить уведомление?", isPresented: $showingDeleteConfirmation) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                if let notification = notificationToDelete {
                    notificationService.deleteNotification(notification)
                }
            }
        }
    }
}

// MARK: - Filter Chip
struct NotificationFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Notification Row
struct NotificationRow: View {
    let notification: Notification
    @StateObject private var notificationService = NotificationService.shared
    @State private var navigateToAction = false

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(notification.color.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: notification.icon)
                    .font(.system(size: 24))
                    .foregroundColor(notification.color)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundColor(notification.isRead ? .secondary : .primary)

                    Spacer()

                    Text(timeAgo(from: notification.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                if notification.priority == .high && !notification.isRead {
                    Label("Важное", systemImage: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            // Unread indicator
            if !notification.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            if !notification.isRead {
                notificationService.markAsRead(notification)
            }
            handleNotificationAction()
        }
        .background(
            NavigationLink(
                destination: destinationView(),
                isActive: $navigateToAction,
                label: { EmptyView() }
            )
        )
    }

    private func handleNotificationAction() {
        // Check if notification has an actionUrl
        if notification.actionUrl != nil {
            navigateToAction = true
        }
    }

    @ViewBuilder
    private func destinationView() -> some View {
        // Route based on notification type
        switch notification.type {
        case .courseAssigned:
            LearningListView()
        case .testReminder:
            TestListView()
        case .certificateEarned:
            CertificateListView()
        case .onboardingTask:
            MyOnboardingProgramsView()
        case .feedActivity, .feedMention:
            // In real app would navigate to specific feed post
            NavigationStack {
                FeedView()
            }
        default:
            EmptyView()
        }
    }

    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Empty State
struct EmptyNotificationsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Нет уведомлений")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Здесь будут появляться важные уведомления о курсах, тестах и задачах")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NotificationListView()
}
