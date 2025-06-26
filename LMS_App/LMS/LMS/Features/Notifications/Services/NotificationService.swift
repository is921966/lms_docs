import Foundation
import SwiftUI
import Combine

// MARK: - Notification Service
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var notifications: [Notification] = []
    @Published var unreadCount: Int = 0
    @Published var pendingApprovals: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadNotifications()
        setupObservers()
    }
    
    // MARK: - Public Methods
    
    func loadNotifications() {
        // In production, this would fetch from API
        notifications = Notification.mockNotifications
        updateUnreadCount()
    }
    
    func markAsRead(_ notification: Notification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].readAt = Date()
            updateUnreadCount()
            saveNotifications()
        }
    }
    
    func markAllAsRead() {
        for index in notifications.indices {
            if notifications[index].readAt == nil {
                notifications[index].readAt = Date()
            }
        }
        updateUnreadCount()
        saveNotifications()
    }
    
    func deleteNotification(_ notification: Notification) {
        notifications.removeAll { $0.id == notification.id }
        updateUnreadCount()
        saveNotifications()
    }
    
    func sendNotification(
        to recipientId: UUID,
        title: String,
        message: String,
        type: NotificationType,
        priority: NotificationPriority = .medium,
        actionType: NotificationAction? = nil,
        actionData: [String: String]? = nil
    ) {
        let notification = Notification(
            title: title,
            message: message,
            type: type,
            priority: priority,
            actionType: actionType,
            actionData: actionData,
            recipientId: recipientId
        )
        
        notifications.insert(notification, at: 0)
        updateUnreadCount()
        saveNotifications()
        
        // In production, also send push notification
        if priority == .high {
            scheduleLocalNotification(notification)
        }
    }
    
    // MARK: - Course Notifications
    
    func notifyCourseAssigned(courseId: String, courseName: String, recipientId: UUID, deadline: Date?) {
        let deadlineText = deadline != nil ? " Срок: \(formatDate(deadline!))" : ""
        sendNotification(
            to: recipientId,
            title: "Назначен новый курс",
            message: "Вам назначен курс '\(courseName)'.\(deadlineText)",
            type: .courseAssigned,
            priority: .high,
            actionType: .openCourse,
            actionData: ["courseId": courseId]
        )
    }
    
    func notifyTestReminder(testId: String, testName: String, recipientId: UUID, daysLeft: Int) {
        let priority: NotificationPriority = daysLeft <= 1 ? .high : .medium
        sendNotification(
            to: recipientId,
            title: "Напоминание о тесте",
            message: "Осталось \(daysLeft) дней для прохождения теста '\(testName)'",
            type: .testReminder,
            priority: priority,
            actionType: .openTest,
            actionData: ["testId": testId]
        )
    }
    
    func notifyCertificateEarned(certificateId: String, courseName: String, recipientId: UUID) {
        sendNotification(
            to: recipientId,
            title: "Поздравляем!",
            message: "Вы получили сертификат за успешное прохождение курса '\(courseName)'",
            type: .certificateEarned,
            priority: .low,
            actionType: .viewCertificate,
            actionData: ["certificateId": certificateId]
        )
    }
    
    // MARK: - Onboarding Notifications
    
    func notifyOnboardingTask(taskId: String, taskName: String, recipientId: UUID, isOverdue: Bool = false) {
        let priority: NotificationPriority = isOverdue ? .high : .medium
        let title = isOverdue ? "Просроченная задача" : "Новая задача онбординга"
        
        sendNotification(
            to: recipientId,
            title: title,
            message: taskName,
            type: .onboardingTask,
            priority: priority,
            actionType: .openOnboardingTask,
            actionData: ["taskId": taskId]
        )
    }
    
    func notifyOnboardingProgress(programId: String, progress: Int, recipientId: UUID) {
        sendNotification(
            to: recipientId,
            title: "Прогресс онбординга",
            message: "Вы завершили \(progress)% программы адаптации. Продолжайте в том же духе!",
            type: .achievement,
            priority: .low,
            actionType: .openOnboardingTask,
            actionData: ["programId": programId]
        )
    }
    
    // MARK: - Private Methods
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
    
    private func setupObservers() {
        // Listen for app becoming active to refresh notifications
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.loadNotifications()
            }
            .store(in: &cancellables)
    }
    
    private func saveNotifications() {
        // In production, sync with backend
        // For now, save to UserDefaults
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: "notifications")
        }
    }
    
    private func scheduleLocalNotification(_ notification: Notification) {
        // Local notification scheduling would go here
        // This is a placeholder for the actual implementation
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    // MARK: - Filtering
    
    func getNotifications(for userId: UUID) -> [Notification] {
        notifications.filter { $0.recipientId == userId }
    }
    
    func getUnreadNotifications(for userId: UUID) -> [Notification] {
        notifications.filter { $0.recipientId == userId && !$0.isRead }
    }
    
    func getNotificationsByType(_ type: NotificationType, for userId: UUID) -> [Notification] {
        notifications.filter { $0.recipientId == userId && $0.type == type }
    }
}
