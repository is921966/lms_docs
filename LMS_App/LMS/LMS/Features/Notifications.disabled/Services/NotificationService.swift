//
//  NotificationService.swift
//  LMS
//
//  Created on Sprint 41 Day 3 - Real Notification Service
//

import Foundation
import Combine
import UserNotifications
import UIKit

/// Real implementation of NotificationServiceProtocol
@MainActor
public final class NotificationService: ObservableObject, NotificationServiceProtocol {
    
    // MARK: - Singleton
    
    public static let shared = NotificationService(
        repository: MockNotificationRepository(),
        pushService: MockPushNotificationService(repository: MockNotificationRepository())
    )
    
    // MARK: - Properties
    
    @Published public private(set) var unreadCountValue: Int = 0
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var hasNewNotifications: Bool = false
    
    @Published private var _notifications: [Notification] = []
    @Published private var _preferences: NotificationPreferences?
    
    // Protocol conformance publishers
    public var notifications: AnyPublisher<[Notification], Never> {
        $_notifications.eraseToAnyPublisher()
    }
    
    public var unreadCount: AnyPublisher<Int, Never> {
        $unreadCountValue.eraseToAnyPublisher()
    }
    
    public var preferences: AnyPublisher<NotificationPreferences?, Never> {
        $_preferences.eraseToAnyPublisher()
    }
    
    private let repository: NotificationRepositoryProtocol
    private let pushService: PushNotificationServiceProtocol?
    private let currentUserId = UUID() // TODO: Get from AuthService
    
    private var cancellables = Set<AnyCancellable>()
    private var notificationObserver: NSObjectProtocol?
    
    // MARK: - Publishers
    
    public let notificationReceived = PassthroughSubject<Notification, Never>()
    public let notificationRead = PassthroughSubject<Notification, Never>()
    public let notificationDeleted = PassthroughSubject<Notification, Never>()
    
    // MARK: - Initialization
    
    public init(
        repository: NotificationRepositoryProtocol,
        pushService: PushNotificationServiceProtocol? = nil
    ) {
        self.repository = repository
        self.pushService = pushService
        
        setupObservers()
        Task {
            await refreshUnreadCount()
        }
    }
    
    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // Listen for push notifications
        notificationObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("PushNotificationReceived"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo,
                  let notificationData = userInfo["notification"] as? [String: Any] else { return }
            
            Task {
                await self.handlePushNotification(notificationData)
            }
        }
        
        // Subscribe to notification events
        notificationReceived
            .sink { [weak self] _ in
                Task {
                    await self?.refreshUnreadCount()
                }
            }
            .store(in: &cancellables)
        
        notificationRead
            .sink { [weak self] _ in
                Task {
                    await self?.refreshUnreadCount()
                }
            }
            .store(in: &cancellables)
        
        notificationDeleted
            .sink { [weak self] _ in
                Task {
                    await self?.refreshUnreadCount()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Protocol Methods
    
    public func loadNotifications(limit: Int? = nil, offset: Int? = nil) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let notifications = try await repository.fetchNotifications(
            for: currentUserId,
            limit: limit ?? 50,
            offset: offset ?? 0,
            includeRead: true
        )
        
        _notifications = notifications
    }
    
    public func refreshNotifications() async throws {
        try await loadNotifications()
    }
    
    public func sendNotification(
        to recipientIds: [UUID],
        type: NotificationType,
        title: String,
        body: String,
        data: [String: Any]? = nil,
        channels: [NotificationChannel]? = nil,
        priority: NotificationPriority? = nil,
        metadata: NotificationMetadata? = nil
    ) async throws {
        for recipientId in recipientIds {
            let notification = Notification(
                userId: recipientId,
                type: type,
                title: title,
                body: body,
                data: data?.compactMapValues { $0 as? String },
                channels: Set(channels ?? [.inApp]),
                priority: priority ?? type.defaultPriority,
                metadata: metadata
            )
            
            let created = try await repository.createNotification(notification)
            
            // Send push if enabled
            if channels?.contains(.push) == true, let pushService = pushService {
                // Push notifications are sent via backend when notification is created
                // Local service only handles scheduling and display
                _ = try? await pushService.scheduleLocalNotification(
                    created,
                    triggerDate: nil
                )
            }
            
            if recipientId == currentUserId {
                notificationReceived.send(created)
                hasNewNotifications = true
                try await loadNotifications()
            }
        }
    }
    
    public func sendTemplatedNotification(
        to recipientIds: [UUID],
        type: NotificationType,
        parameters: [String: String],
        data: [String: Any]? = nil
    ) async throws {
        // Get template for type
        let template = NotificationTemplate(
            type: type,
            titleTemplate: "{{title}}",
            bodyTemplate: "{{body}}"
        )
        
        let rendered = template.render(with: parameters)
        
        try await sendNotification(
            to: recipientIds,
            type: type,
            title: rendered.title,
            body: rendered.body,
            data: data
        )
    }
    
    public func markAsRead(_ notificationId: UUID) async throws {
        if let notification = try await repository.getNotification(id: notificationId) {
            var updatedNotification = notification
            updatedNotification.markAsRead()
            
            _ = try await repository.updateNotification(updatedNotification)
            notificationRead.send(updatedNotification)
            
            // Update local list
            if let index = _notifications.firstIndex(where: { $0.id == notificationId }) {
                _notifications[index] = updatedNotification
            }
            
            // Track analytics
            try? await repository.trackNotificationEvent(
                notificationId: notification.id,
                event: NotificationEvent(
                    notificationId: notification.id,
                    type: .opened
                )
            )
        }
    }
    
    public func deleteNotification(_ notificationId: UUID) async throws {
        try await repository.deleteNotification(id: notificationId)
        
        if let notification = _notifications.first(where: { $0.id == notificationId }) {
            notificationDeleted.send(notification)
            _notifications.removeAll { $0.id == notificationId }
        }
    }
    
    public func markAllAsRead() async throws {
        try await repository.markAllAsRead(for: currentUserId)
        await refreshUnreadCount()
        try await loadNotifications()
    }
    
    public func deleteAllNotifications() async throws {
        _notifications.removeAll { $0.userId == currentUserId }
        await refreshUnreadCount()
    }
    
    public func loadPreferences() async throws {
        if let prefs = try await repository.getPreferences(for: currentUserId) {
            _preferences = prefs
        } else {
            // Create default preferences
            let defaultPrefs = NotificationPreferences(userId: currentUserId)
            _preferences = try await repository.savePreferences(defaultPrefs)
        }
    }
    
    public func updateChannelPreference(
        type: NotificationType,
        channels: [NotificationChannel]
    ) async throws {
        guard var prefs = _preferences else {
            try await loadPreferences()
            return
        }
        
        prefs.channelPreferences[type] = Set(channels)
        prefs.updatedAt = Date()
        
        _preferences = try await repository.savePreferences(prefs)
    }
    
    public func updateQuietHours(_ quietHours: QuietHours?) async throws {
        guard var prefs = _preferences else {
            try await loadPreferences()
            return
        }
        
        prefs.quietHours = quietHours
        prefs.updatedAt = Date()
        
        _preferences = try await repository.savePreferences(prefs)
    }
    
    public func updateFrequencyLimit(
        type: NotificationType,
        limit: FrequencyLimit?
    ) async throws {
        guard var prefs = _preferences else {
            try await loadPreferences()
            return
        }
        
        if let limit = limit {
            prefs.frequencyLimits[type] = limit
        } else {
            prefs.frequencyLimits.removeValue(forKey: type)
        }
        prefs.updatedAt = Date()
        
        _preferences = try await repository.savePreferences(prefs)
    }
    
    public func registerPushToken(_ tokenData: Data) async throws {
        guard let pushService = pushService else { return }
        
        let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        
        let pushToken = PushToken(
            userId: currentUserId,
            token: token,
            deviceId: deviceId
        )
        
        _ = try await repository.savePushToken(pushToken)
        try await pushService.registerDeviceToken(tokenData)
    }
    
    public func unregisterDevice() async throws {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let tokens = try await repository.getUserPushTokens(userId: currentUserId)
        
        for token in tokens where token.deviceId == deviceId {
            try await repository.deletePushToken(id: token.id)
        }
    }
    
    public func isPushEnabled() async -> Bool {
        guard let pushService = pushService else { return false }
        return await pushService.getAuthorizationStatus() == .authorized
    }
    
    public func trackNotificationOpened(_ notificationId: UUID) async throws {
        try await repository.trackNotificationEvent(
            notificationId: notificationId,
            event: NotificationEvent(
                notificationId: notificationId,
                type: .opened
            )
        )
    }
    
    public func trackNotificationAction(
        _ notificationId: UUID,
        action: String
    ) async throws {
        try await repository.trackNotificationEvent(
            notificationId: notificationId,
            event: NotificationEvent(
                notificationId: notificationId,
                type: .actionTaken,
                metadata: ["action": action]
            )
        )
    }
    
    public func getNotificationStats(
        from startDate: Date,
        to endDate: Date
    ) async throws -> NotificationStats {
        let analytics = try await repository.getNotificationAnalytics(
            userId: currentUserId,
            from: startDate,
            to: endDate
        )
        
        return NotificationStats(
            totalSent: analytics.totalSent,
            totalOpened: analytics.totalOpened,
            totalClicked: analytics.totalActioned,  // Изменено с totalClicked
            openRate: analytics.openRate,
            clickRate: analytics.clickThroughRate,  // Изменено с clickRate
            byType: [:],  // TODO: преобразовать из analytics.byType
            byChannel: [:]  // TODO: преобразовать из analytics.byChannel
        )
    }
    
    // MARK: - Convenience Methods
    
    public func notifyCourseAssigned(
        courseId: String,
        courseName: String,
        recipientIds: [UUID],
        deadline: Date? = nil
    ) async throws {
        let body = deadline != nil ? 
            "Вам назначен курс '\(courseName)'. Срок: \(deadline!.formatted())" :
            "Вам назначен курс '\(courseName)'"
        
        try await sendNotification(
            to: recipientIds,
            type: .courseAssigned,
            title: "Новый курс назначен",
            body: body,
            data: ["courseId": courseId],
            channels: [.inApp, .push],
            priority: .high
        )
    }
    
    public func notifyTestReminder(
        testId: String,
        testName: String,
        recipientIds: [UUID],
        daysLeft: Int
    ) async throws {
        let priority: NotificationPriority = daysLeft <= 1 ? .high : .medium
        
        try await sendNotification(
            to: recipientIds,
            type: .testDeadline,
            title: "Напоминание о тесте",
            body: "Осталось \(daysLeft) дней для прохождения теста '\(testName)'",
            data: ["testId": testId],
            channels: [.inApp, .push],
            priority: priority
        )
    }
    
    public func notifyCertificateEarned(
        certificateId: String,
        courseName: String,
        recipientId: UUID
    ) async throws {
        try await sendNotification(
            to: [recipientId],
            type: .achievementUnlocked,
            title: "Поздравляем!",
            body: "Вы получили сертификат за успешное прохождение курса '\(courseName)'",
            data: ["certificateId": certificateId],
            channels: [.inApp],
            priority: .low
        )
    }
    
    public func notifyAchievementUnlocked(
        achievementName: String,
        description: String,
        recipientId: UUID
    ) async throws {
        try await sendNotification(
            to: [recipientId],
            type: .achievementUnlocked,
            title: "Новое достижение!",
            body: "\(achievementName): \(description)",
            channels: [.inApp, .push],
            priority: .medium
        )
    }
    
    public func notifyOnboardingTask(
        taskId: String,
        taskName: String,
        recipientId: UUID,
        isOverdue: Bool = false
    ) async throws {
        let priority: NotificationPriority = isOverdue ? .high : .medium
        let title = isOverdue ? "Просроченная задача" : "Новая задача онбординга"
        
        try await sendNotification(
            to: [recipientId],
            type: .taskAssigned,
            title: title,
            body: taskName,
            data: ["taskId": taskId],
            channels: [.inApp, .push],
            priority: priority
        )
    }
    
    // MARK: - Public Methods (Additional)
    
    public func fetchNotifications(
        page: Int = 1,
        limit: Int = 20,
        filter: NotificationFilter? = nil
    ) async throws -> PaginatedResponse<Notification> {
        isLoading = true
        defer { isLoading = false }
        
        let notifications = try await repository.fetchNotifications(
            for: currentUserId,
            limit: limit,
            offset: (page - 1) * limit,
            includeRead: filter?.showRead ?? true
        )
        
        // Apply additional filters if needed
        var filtered = notifications
        if let filter = filter {
            filtered = applyFilter(notifications: filtered, filter: filter)
        }
        
        let totalCount = filtered.count
        
        return PaginatedResponse(
            items: filtered,
            currentPage: page,
            totalPages: Int(ceil(Double(totalCount) / Double(limit))),
            totalItems: totalCount
        )
    }
    
    public func getNotification(id: UUID) async throws -> Notification? {
        return try await repository.getNotification(id: id)
    }
    
    public func markAsRead(_ notification: Notification) async throws {
        try await markAsRead(notification.id)
    }
    
    public func deleteNotification(_ notification: Notification) async throws {
        try await deleteNotification(notification.id)
    }
    
    public func getPreferences() async throws -> NotificationPreferences {
        if _preferences == nil {
            try await loadPreferences()
        }
        return _preferences ?? NotificationPreferences(userId: currentUserId)
    }
    
    public func updatePreferences(_ preferences: NotificationPreferences) async throws {
        _preferences = try await repository.savePreferences(preferences)
    }
    
    public func refreshUnreadCount() async {
        do {
            unreadCountValue = try await repository.getUnreadCount(for: currentUserId)
        } catch {
            print("Failed to refresh unread count: \(error)")
        }
    }
    
    public func sendTestNotification(type: NotificationType) async throws {
        let notification = createTestNotification(type: type)
        let created = try await repository.createNotification(notification)
        
        // Send push if enabled
        if let pushService = pushService {
            // Push notifications are sent via backend when notification is created
            // Local service only handles scheduling and display
            _ = try? await pushService.scheduleLocalNotification(
                created,
                triggerDate: nil
            )
        }
        
        notificationReceived.send(created)
        hasNewNotifications = true
        try await loadNotifications()
    }
    
    public func clearNewNotificationFlag() {
        hasNewNotifications = false
    }
    
    // MARK: - Compatibility methods for old NotificationService
    
    public func add(_ notification: Notification) async {
        _ = try? await repository.createNotification(notification)
        notificationReceived.send(notification)
        hasNewNotifications = true
        try? await loadNotifications()
    }
    
    // MARK: - Private Methods
    
    private func handlePushNotification(_ data: [String: Any]) async {
        // Parse notification from push data
        guard let typeString = data["type"] as? String,
              let type = NotificationType(rawValue: typeString),
              let title = data["title"] as? String,
              let body = data["body"] as? String else {
            return
        }
        
        let notification = Notification(
            userId: currentUserId,
            type: type,
            title: title,
            body: body,
            data: data.compactMapValues { $0 as? String },
            channels: [.push]
        )
        
        do {
            let created = try await repository.createNotification(notification)
            notificationReceived.send(created)
            hasNewNotifications = true
            await refreshUnreadCount()
            try await loadNotifications()
        } catch {
            print("Failed to save push notification: \(error)")
        }
    }
    
    private func applyFilter(notifications: [Notification], filter: NotificationFilter) -> [Notification] {
        var result = notifications
        
        // Filter by types
        if let types = filter.types, !types.isEmpty {
            result = result.filter { types.contains($0.type) }
        }
        
        // Filter by channels
        if let channels = filter.channels, !channels.isEmpty {
            result = result.filter { notification in
                channels.contains(where: { notification.channels.contains($0) })
            }
        }
        
        // Filter by priorities
        if let priorities = filter.priorities, !priorities.isEmpty {
            result = result.filter { priorities.contains($0.priority) }
        }
        
        // Filter by date range
        if let dateFrom = filter.dateFrom {
            result = result.filter { $0.createdAt >= dateFrom }
        }
        
        if let dateTo = filter.dateTo {
            result = result.filter { $0.createdAt <= dateTo }
        }
        
        return result
    }
    
    private func createTestNotification(type: NotificationType) -> Notification {
        let templates: (String, String) = {
            switch type {
            case .courseAssigned:
                return ("Новый курс назначен", "Вам назначен курс 'iOS Development'. Начните обучение прямо сейчас!")
            case .courseCompleted:
                return ("Курс завершен", "Поздравляем! Вы успешно завершили курс 'iOS Development'")
            case .testAvailable:
                return ("Доступен новый тест", "Тест 'Swift Basics' готов к прохождению")
            case .testDeadline:
                return ("Приближается дедлайн", "Осталось 2 дня до окончания теста 'Swift Basics'")
            case .testCompleted:
                return ("Тест завершен", "Вы прошли тест с результатом 85%")
            case .taskAssigned:
                return ("Новое задание", "Вам назначено задание 'Implement Login Screen'")
            case .achievementUnlocked:
                return ("Новое достижение", "Поздравляем! Вы разблокировали достижение 'Swift Master'")
            case .certificateIssued:
                return ("Сертификат выдан", "Ваш сертификат об окончании курса готов")
            case .systemMessage:
                return ("Системное сообщение", "Важное обновление системы обучения")
            case .adminMessage:
                return ("Сообщение администратора", "У вас новое сообщение от администратора")
            case .reminderDaily:
                return ("Ежедневное напоминание", "Время для обучения! Продолжите ваш курс")
            case .reminderWeekly:
                return ("Еженедельное напоминание", "Проверьте ваш прогресс за неделю")
            case .feedActivity:
                return ("Активность в ленте", "Новые комментарии к вашему посту")
            case .feedMention:
                return ("Вас упомянули", "@user упомянул вас в комментарии")
            case .onboardingTask:
                return ("Задача онбординга", "Завершите настройку профиля")
            case .deadline:
                return ("Приближается дедлайн", "До окончания задания осталось 24 часа")
            case .achievement:
                return ("Достижение", "Вы достигли нового уровня!")
            case .testReminder:
                return ("Напоминание о тесте", "Не забудьте пройти тест до конца недели")
            case .certificateEarned:
                return ("Сертификат получен", "Поздравляем с получением сертификата!")
            }
        }()
        
        return Notification(
            userId: currentUserId,
            type: type,
            title: templates.0,
            body: templates.1,
            data: ["test": "true"],
            channels: [.inApp, .push],
            priority: type.defaultPriority
        )
    }
}

