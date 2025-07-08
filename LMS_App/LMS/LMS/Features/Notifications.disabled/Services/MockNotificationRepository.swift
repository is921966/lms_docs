//
//  MockNotificationRepository.swift
//  LMS
//
//  Created on Sprint 41 Day 2 - Mock Notification Repository
//

import Foundation

/// Mock implementation of NotificationRepositoryProtocol for testing
final class MockNotificationRepository: NotificationRepositoryProtocol {
    
    // MARK: - Properties
    
    private var notifications: [Notification] = []
    private var preferences: [UUID: NotificationPreferences] = [:]
    private var pushTokens: [PushToken] = []
    private var templates: [NotificationTemplate] = []
    
    private let queue = DispatchQueue(label: "mock.notification.repository", attributes: .concurrent)
    
    // MARK: - Initialization
    
    init() {
        setupMockData()
    }
    
    // MARK: - NotificationRepositoryProtocol
    
    func fetchNotifications(
        for userId: UUID,
        filter: NotificationFilter?,
        pagination: PaginationRequest?
    ) async throws -> PaginatedResponse<Notification> {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                var filtered = self.notifications.filter { $0.userId == userId }
                
                // Apply additional filters if provided
                if let filter = filter {
                    // Filter by types
                    if let types = filter.types, !types.isEmpty {
                        filtered = filtered.filter { types.contains($0.type) }
                    }
                    
                    // Filter by channels
                    if let channels = filter.channels, !channels.isEmpty {
                        filtered = filtered.filter { notification in
                            channels.contains(where: { notification.channels.contains($0) })
                        }
                    }
                    
                    // Filter by priorities
                    if let priorities = filter.priorities, !priorities.isEmpty {
                        filtered = filtered.filter { priorities.contains($0.priority) }
                    }
                    
                    // Filter by read status
                    if !filter.showRead {
                        filtered = filtered.filter { !$0.isRead }
                    }
                    
                    // Filter by date range
                    if let dateFrom = filter.dateFrom {
                        filtered = filtered.filter { $0.createdAt >= dateFrom }
                    }
                    
                    if let dateTo = filter.dateTo {
                        filtered = filtered.filter { $0.createdAt <= dateTo }
                    }
                }
                
                // Sort by date
                filtered.sort { $0.createdAt > $1.createdAt }
                
                // Apply pagination
                let page = pagination?.page ?? 1
                let limit = pagination?.limit ?? 20
                let startIndex = (page - 1) * limit
                let endIndex = min(startIndex + limit, filtered.count)
                
                let paginatedItems = startIndex < filtered.count 
                    ? Array(filtered[startIndex..<endIndex])
                    : []
                
                let response = PaginatedResponse(
                    items: paginatedItems,
                    currentPage: page,
                    totalPages: (filtered.count + limit - 1) / limit,
                    totalItems: filtered.count
                )
                
                continuation.resume(returning: response)
            }
        }
    }
    
    func createNotification(_ notification: Notification) async throws -> Notification {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                self.notifications.append(notification)
                continuation.resume(returning: notification)
            }
        }
    }
    
    func updateNotification(_ notification: Notification) async throws -> Notification {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                if let index = self.notifications.firstIndex(where: { $0.id == notification.id }) {
                    self.notifications[index] = notification
                    continuation.resume(returning: notification)
                } else {
                    continuation.resume(throwing: NotificationError.notFound)
                }
            }
        }
    }
    
    func deleteNotification(id: UUID) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                if let index = self.notifications.firstIndex(where: { $0.id == id }) {
                    self.notifications.remove(at: index)
                    continuation.resume()
                } else {
                    continuation.resume(throwing: NotificationError.notFound)
                }
            }
        }
    }
    
    func markAsRead(notificationId: UUID) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                if let index = self.notifications.firstIndex(where: { $0.id == notificationId }) {
                    self.notifications[index].markAsRead()
                    continuation.resume()
                } else {
                    continuation.resume(throwing: NotificationError.notFound)
                }
            }
        }
    }
    
    func markAllAsRead(for userId: UUID) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                for index in self.notifications.indices {
                    if self.notifications[index].userId == userId && !self.notifications[index].isRead {
                        self.notifications[index].markAsRead()
                    }
                }
                continuation.resume()
            }
        }
    }
    
    // MARK: - Push Tokens
    
    func savePushToken(_ token: PushToken) async throws -> PushToken {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                // Deactivate existing tokens for this device
                for index in self.pushTokens.indices {
                    if self.pushTokens[index].deviceId == token.deviceId {
                        self.pushTokens[index].deactivate()
                    }
                }
                
                self.pushTokens.append(token)
                continuation.resume(returning: token)
            }
        }
    }
    
    func getPushTokens(for userId: UUID) async throws -> [PushToken] {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                let tokens = self.pushTokens.filter { $0.userId == userId && $0.isActive }
                continuation.resume(returning: tokens)
            }
        }
    }
    
    // Alias for protocol compliance
    func getUserPushTokens(userId: UUID) async throws -> [PushToken] {
        return try await getPushTokens(for: userId)
    }
    
    func updatePushToken(_ token: PushToken) async throws -> PushToken {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                if let index = self.pushTokens.firstIndex(where: { $0.id == token.id }) {
                    self.pushTokens[index] = token
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: NotificationError.notFound)
                }
            }
        }
    }
    
    func deletePushToken(id: UUID) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                if let index = self.pushTokens.firstIndex(where: { $0.id == id }) {
                    self.pushTokens.remove(at: index)
                    continuation.resume()
                } else {
                    continuation.resume(throwing: NotificationError.notFound)
                }
            }
        }
    }
    
    func getAllPushTokens() async throws -> [PushToken] {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                continuation.resume(returning: self.pushTokens)
            }
        }
    }
    
    // MARK: - Analytics
    
    private var analytics: [String: [NotificationEvent]] = [:]
    
    func trackNotificationEvent(
        notificationId: UUID,
        event: NotificationEvent
    ) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                let key = "event_\(notificationId.uuidString)"
                var events = self.analytics[key] ?? []
                events.append(event)
                self.analytics[key] = events
                
                // Update notification status based on event
                if let index = self.notifications.firstIndex(where: { $0.id == notificationId }) {
                    switch event.type {
                    case .opened:
                        self.notifications[index].markAsRead()
                    case .actionTaken:
                        self.notifications[index].markAsRead()
                    default:
                        break
                    }
                }
                
                continuation.resume()
            }
        }
    }
    
    func getNotificationAnalytics(
        userId: UUID?,
        from startDate: Date,
        to endDate: Date
    ) async throws -> NotificationAnalytics {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                var delivered = 0
                var opened = 0
                var actionTaken = 0
                var dismissed = 0
                var failed = 0
                
                for (_, events) in self.analytics {
                    for event in events {
                        if event.timestamp >= startDate && event.timestamp <= endDate {
                            switch event.type {
                            case .delivered: delivered += 1
                            case .opened: opened += 1
                            case .actionTaken: actionTaken += 1
                            case .dismissed: dismissed += 1
                            case .failed: failed += 1
                            }
                        }
                    }
                }
                
                let total = delivered
                let openRate = total > 0 ? Double(opened) / Double(total) : 0
                let ctr = total > 0 ? Double(actionTaken) / Double(total) : 0
                
                let analytics = NotificationAnalytics(
                    totalSent: delivered,
                    totalDelivered: delivered,
                    totalOpened: opened,
                    totalActioned: actionTaken,
                    openRate: openRate,
                    clickThroughRate: ctr,
                    byType: [:],
                    byChannel: [:],
                    timeline: []
                )
                
                continuation.resume(returning: analytics)
            }
        }
    }
    
    // MARK: - Preferences
    
    func getPreferences(for userId: UUID) async throws -> NotificationPreferences? {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                if let prefs = self.preferences[userId] {
                    continuation.resume(returning: prefs)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func updatePreferences(_ preferences: NotificationPreferences) async throws -> NotificationPreferences {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                self.preferences[preferences.userId] = preferences
                continuation.resume(returning: preferences)
            }
        }
    }
    
    // MARK: - Templates
    
    func getTemplates(for type: NotificationType?) async throws -> [NotificationTemplate] {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                if let type = type {
                    let filtered = self.templates.filter { $0.type == type }
                    continuation.resume(returning: filtered)
                } else {
                    continuation.resume(returning: self.templates)
                }
            }
        }
    }
    
    func createTemplate(_ template: NotificationTemplate) async throws -> NotificationTemplate {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                self.templates.append(template)
                continuation.resume(returning: template)
            }
        }
    }
    
    func updateTemplate(_ template: NotificationTemplate) async throws -> NotificationTemplate {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                if let index = self.templates.firstIndex(where: { $0.id == template.id }) {
                    self.templates[index] = template
                    continuation.resume(returning: template)
                } else {
                    continuation.resume(throwing: NotificationError.notFound)
                }
            }
        }
    }
    
    func deleteTemplate(id: UUID) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                if let index = self.templates.firstIndex(where: { $0.id == id }) {
                    self.templates.remove(at: index)
                    continuation.resume()
                } else {
                    continuation.resume(throwing: NotificationError.notFound)
                }
            }
        }
    }
    
    // MARK: - Additional Protocol Methods
    
    func fetchNotifications(
        for userId: UUID,
        limit: Int? = nil,
        offset: Int? = nil,
        includeRead: Bool = true
    ) async throws -> [Notification] {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                var filtered = self.notifications.filter { $0.userId == userId }
                
                if !includeRead {
                    filtered = filtered.filter { !$0.isRead }
                }
                
                // Sort by date
                filtered.sort { $0.createdAt > $1.createdAt }
                
                // Apply pagination
                let startIndex = offset ?? 0
                let itemLimit = limit ?? filtered.count
                let endIndex = min(startIndex + itemLimit, filtered.count)
                
                let paginatedItems = startIndex < filtered.count 
                    ? Array(filtered[startIndex..<endIndex])
                    : []
                
                continuation.resume(returning: paginatedItems)
            }
        }
    }
    
    func getNotification(id: UUID) async throws -> Notification? {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                let notification = self.notifications.first { $0.id == id }
                continuation.resume(returning: notification)
            }
        }
    }
    
    func markAsRead(notificationId: UUID, at date: Date) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                if let index = self.notifications.firstIndex(where: { $0.id == notificationId }) {
                    self.notifications[index].markAsRead()
                    self.notifications[index].readAt = date
                    continuation.resume()
                } else {
                    continuation.resume(throwing: NotificationError.notFound)
                }
            }
        }
    }
    
    func getUnreadCount(for userId: UUID) async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                let count = self.notifications.filter { $0.userId == userId && !$0.isRead }.count
                continuation.resume(returning: count)
            }
        }
    }
    
    func deleteExpiredNotifications() async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                let now = Date()
                let initialCount = self.notifications.count
                self.notifications.removeAll { notification in
                    if let expiresAt = notification.expiresAt {
                        return expiresAt < now
                    }
                    return false
                }
                let deletedCount = initialCount - self.notifications.count
                continuation.resume(returning: deletedCount)
            }
        }
    }
    
    func registerPushToken(_ token: PushToken) async throws -> PushToken {
        return try await savePushToken(token)
    }
    
    func deactivatePushToken(tokenId: UUID) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                if let index = self.pushTokens.firstIndex(where: { $0.id == tokenId }) {
                    self.pushTokens[index].deactivate()
                    continuation.resume()
                } else {
                    continuation.resume(throwing: NotificationError.notFound)
                }
            }
        }
    }
    
    func deactivateTokensForDevice(deviceId: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                for index in self.pushTokens.indices {
                    if self.pushTokens[index].deviceId == deviceId {
                        self.pushTokens[index].deactivate()
                    }
                }
                continuation.resume()
            }
        }
    }
    
    func savePreferences(_ preferences: NotificationPreferences) async throws -> NotificationPreferences {
        return try await updatePreferences(preferences)
    }
    
    func getTemplate(type: NotificationType) async throws -> NotificationTemplate? {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                let template = self.templates.first { $0.type == type }
                continuation.resume(returning: template)
            }
        }
    }
    
    func getAllTemplates() async throws -> [NotificationTemplate] {
        return try await getTemplates(for: nil)
    }
    
    func saveTemplate(_ template: NotificationTemplate) async throws -> NotificationTemplate {
        if templates.contains(where: { $0.id == template.id }) {
            return try await updateTemplate(template)
        } else {
            return try await createTemplate(template)
        }
    }
    
    func trackEvent(
        notificationId: UUID,
        channel: NotificationChannel,
        eventType: NotificationEventType,
        eventData: [String: Any]? = nil
    ) async throws {
        let event = NotificationEvent(
            notificationId: notificationId,
            type: eventType,
            metadata: eventData?.compactMapValues { "\($0)" }
        )
        try await trackNotificationEvent(notificationId: notificationId, event: event)
    }
    
    func getAnalytics(notificationId: UUID) async throws -> NotificationAnalytics {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                let key = "event_\(notificationId.uuidString)"
                let events = self.analytics[key] ?? []
                
                var delivered = 0
                var opened = 0
                var actionTaken = 0
                var dismissed = 0
                var failed = 0
                
                for event in events {
                    switch event.type {
                    case .delivered: delivered += 1
                    case .opened: opened += 1
                    case .actionTaken: actionTaken += 1
                    case .dismissed: dismissed += 1
                    case .failed: failed += 1
                    }
                }
                
                let total = max(delivered, 1) // Avoid division by zero
                let openRate = Double(opened) / Double(total)
                let ctr = Double(actionTaken) / Double(total)
                
                let analytics = NotificationAnalytics(
                    totalSent: delivered,
                    totalDelivered: delivered,
                    totalOpened: opened,
                    totalActioned: actionTaken,
                    openRate: openRate,
                    clickThroughRate: ctr,
                    byType: [:],
                    byChannel: [:],
                    timeline: []
                )
                
                continuation.resume(returning: analytics)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupMockData() {
        let userId = UUID() // Mock user
        
        // Create mock notifications
        notifications = [
            Notification(
                userId: userId,
                type: .courseAssigned,
                title: "Новый курс назначен",
                body: "Вам назначен курс 'iOS Development Basics'",
                data: ["courseId": "course123"],
                channels: [.inApp, .push],
                priority: .high,
                createdAt: Date().addingTimeInterval(-3600)
            ),
            Notification(
                userId: userId,
                type: .testDeadline,
                title: "Срок теста истекает",
                body: "Осталось 2 дня для прохождения теста по SwiftUI",
                data: ["testId": "test456"],
                channels: [.inApp, .push],
                priority: .high,
                createdAt: Date().addingTimeInterval(-7200)
            ),
            Notification(
                userId: userId,
                type: .certificateIssued,
                title: "Сертификат получен",
                body: "Поздравляем! Вы получили сертификат по курсу Swift",
                data: ["certificateId": "cert789"],
                channels: [.inApp],
                priority: .medium,
                isRead: true,
                readAt: Date().addingTimeInterval(-86400),
                createdAt: Date().addingTimeInterval(-86400)
            ),
            Notification(
                userId: userId,
                type: .feedActivity,
                title: "Новая активность",
                body: "Иван прокомментировал ваш пост",
                data: ["postId": "post123"],
                channels: [.inApp],
                priority: .low,
                createdAt: Date().addingTimeInterval(-172800)
            )
        ]
        
        // Create mock templates
        templates = [
            NotificationTemplate(
                type: .courseAssigned,
                titleTemplate: "Новый курс: {{courseName}}",
                bodyTemplate: "Вам назначен курс '{{courseName}}'. Срок прохождения: {{deadline}}",
                defaultChannels: [.inApp, .push],
                defaultPriority: .high
            ),
            NotificationTemplate(
                type: .testDeadline,
                titleTemplate: "Напоминание о тесте",
                bodyTemplate: "Осталось {{daysLeft}} дней для прохождения теста '{{testName}}'",
                defaultChannels: [.inApp, .push],
                defaultPriority: .high
            ),
            NotificationTemplate(
                type: .certificateIssued,
                titleTemplate: "Сертификат получен!",
                bodyTemplate: "Поздравляем! Вы успешно завершили курс '{{courseName}}' и получили сертификат",
                defaultChannels: [.inApp, .email],
                defaultPriority: .medium
            )
        ]
        
        // Create mock preferences
        preferences[userId] = NotificationPreferences(
            userId: userId,
            channelPreferences: [
                .courseAssigned: [.inApp, .push],
                .testDeadline: [.inApp, .push, .email],
                .certificateIssued: [.inApp, .email]
            ],
            isEnabled: true,
            quietHours: QuietHours(
                isEnabled: true,
                startTime: DateComponents(hour: 22, minute: 0),
                endTime: DateComponents(hour: 8, minute: 0),
                allowUrgent: true
            )
        )
    }
}

// MARK: - Supporting Types

enum NotificationError: LocalizedError {
    case notFound
    case invalidData
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Уведомление не найдено"
        case .invalidData:
            return "Неверные данные"
        case .unauthorized:
            return "Нет доступа"
        }
    }
} 