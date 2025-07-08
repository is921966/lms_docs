//
//  NotificationDetailView.swift
//  LMS
//
//  Created on Sprint 41 Day 2 - Notification Detail View
//

import SwiftUI

/// Экран детальной информации об уведомлении
struct NotificationDetailView: View {
    
    // MARK: - Properties
    
    let notification: Notification
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection
                    
                    // Content
                    contentSection
                    
                    // Metadata
                    if notification.data != nil || notification.metadata != nil {
                        metadataSection
                    }
                    
                    // Actions
                    if notification.metadata?.actionUrl != nil {
                        actionSection
                    }
                }
                .padding()
            }
            .navigationTitle("Уведомление")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Icon and Type
            HStack(spacing: 12) {
                Image(systemName: notification.type.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(Color.blue.opacity(0.15))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.type.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(notification.createdAt.formatted())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Priority badge
                if notification.priority >= .high {
                    priorityBadge
                }
            }
            
            // Title
            Text(notification.title)
                .font(.title2)
                .fontWeight(.bold)
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Сообщение")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(notification.body)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Дополнительная информация")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                // Data fields
                if let data = notification.data {
                    ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text(formatKey(key))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(value)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                // Channels
                HStack {
                    Text("Каналы")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(Array(notification.channels), id: \.self) { channel in
                            channelBadge(for: channel)
                        }
                    }
                }
                
                // Status
                HStack {
                    Text("Статус")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Label(
                        notification.isRead ? "Прочитано" : "Не прочитано",
                        systemImage: notification.isRead ? "checkmark.circle.fill" : "circle"
                    )
                    .font(.subheadline)
                    .foregroundColor(notification.isRead ? .green : .orange)
                }
                
                // Read time
                if let readAt = notification.readAt {
                    HStack {
                        Text("Прочитано")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(readAt.formatted())
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: 12) {
            if let actionTitle = notification.metadata?.actionTitle {
                Button {
                    handleAction()
                } label: {
                    Label(actionTitle, systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            } else {
                Button {
                    handleAction()
                } label: {
                    Label("Открыть", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private var priorityBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.caption)
            
            Text(priorityText)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(priorityColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(priorityColor.opacity(0.15))
        )
    }
    
    private func channelBadge(for channel: NotificationChannel) -> some View {
        Text(channel.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.blue)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.15))
            )
    }
    
    // MARK: - Helper Methods
    
    private var priorityText: String {
        switch notification.priority {
        case .urgent: return "Срочно"
        case .high: return "Важно"
        case .medium: return "Средний"
        case .low: return "Низкий"
        }
    }
    
    private var priorityColor: Color {
        switch notification.priority {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .blue
        case .low: return .gray
        }
    }
    
    private func formatKey(_ key: String) -> String {
        // Convert camelCase to readable format
        let result = key.replacingOccurrences(of: "Id", with: " ID")
        return result
            .split(separator: Character(" "))
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    private func handleAction() {
        if let actionUrl = notification.metadata?.actionUrl {
            // Handle deep link
            print("Handle action URL: \(actionUrl)")
            dismiss()
        }
    }
}

// MARK: - Preview

struct NotificationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationDetailView(
            notification: Notification(
                userId: UUID(),
                type: .courseAssigned,
                title: "Новый курс назначен",
                body: "Вам назначен курс 'iOS Development Basics'. Пожалуйста, начните обучение в течение 7 дней.",
                data: ["courseId": "course123", "deadline": "7 дней"],
                channels: [.inApp, .push, .email],
                priority: .high,
                metadata: NotificationMetadata(
                    actionUrl: "course://123",
                    actionTitle: "Перейти к курсу"
                )
            )
        )
    }
} 