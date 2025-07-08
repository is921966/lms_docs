//
//  NotificationAPIService.swift
//  LMS
//
//  Created on Sprint 41 Day 4 - Notification API Service
//

import Foundation
import Combine

/// Service for notification API operations
public final class NotificationAPIService {
    
    // MARK: - Properties
    
    private let apiClient: APIClient
    private let cache: CacheService
    private let logger: Logger
    
    // MARK: - Cache Keys
    
    private enum CacheKey {
        static func notifications(userId: UUID, page: Int) -> String {
            "notifications_\(userId)_page_\(page)"
        }
        
        static func notification(id: UUID) -> String {
            "notification_\(id)"
        }
        
        static func preferences(userId: UUID) -> String {
            "notification_preferences_\(userId)"
        }
        
        static func unreadCount(userId: UUID) -> String {
            "notification_unread_count_\(userId)"
        }
    }
    
    // MARK: - Initialization
    
    public init(
        apiClient: APIClient? = nil,
        cache: CacheService? = nil,
        logger: Logger? = nil
    ) {
        self.apiClient = apiClient ?? APIClient()
        self.cache = cache ?? CacheService()
        self.logger = logger ?? Logger.shared
    }
    
    // MARK: - Notification Operations
    
    /// Fetch notifications with pagination
    public func fetchNotifications(
        page: Int = 1,
        limit: Int = 20,
        forceRefresh: Bool = false
    ) async throws -> PaginatedResponse<Notification> {
        let userId = try await getCurrentUserId()
        let cacheKey = CacheKey.notifications(userId: userId, page: page)
        
        // Check cache if not forcing refresh
        if !forceRefresh,
           let cached: PaginatedResponse<Notification> = try? cache.get(key: cacheKey),
           !cache.isExpired(key: cacheKey) {
            logger.debug("Returning cached notifications for page \(page)")
            return cached
        }
        
        // Fetch from API
        let endpoint = NotificationEndpoint.getNotifications(page: page, limit: limit)
        let response: PaginatedResponse<Notification> = try await apiClient.request(endpoint)
        
        // Cache the response
        try? cache.set(response, for: cacheKey)
        
        return response
    }
    
    // Renamed to avoid conflicts
    public func getNotificationById(id: UUID) async throws -> Notification? {
        let cacheKey = CacheKey.notification(id: id)
        
        // Check cache
        if let cached: Notification = try? cache.get(key: cacheKey) {
            return cached
        }
        
        // Fetch from API
        let endpoint = NotificationEndpoint.getNotification(id: id)
        let notification: Notification = try await apiClient.request(endpoint)
        
        // Cache the response
        try? cache.set(notification, for: cacheKey)
        
        return notification
    }
    
    /// Create a new notification
    public func createNotification(_ request: CreateNotificationRequest) async throws -> Notification {
        let endpoint = NotificationEndpoint.createNotification(request: request)
        let notification: Notification = try await apiClient.request(endpoint)
        
        // Invalidate related caches
        invalidateNotificationCaches()
        
        return notification
    }
    
    /// Mark notification as read
    public func markAsRead(notificationId: UUID) async throws -> Notification {
        let endpoint = NotificationEndpoint.markAsRead(id: notificationId)
        let notification: Notification = try await apiClient.request(endpoint)
        
        // Update cache
        let cacheKey = CacheKey.notification(id: notificationId)
        try? cache.set(notification, for: cacheKey)
        
        // Invalidate unread count
        if let userId = try? await getCurrentUserId() {
            cache.remove(key: CacheKey.unreadCount(userId: userId))
        }
        
        return notification
    }
    
    // Renamed to avoid conflicts
    public func removeNotification(id: UUID) async throws {
        let endpoint = NotificationEndpoint.deleteNotification(id: id)
        try await apiClient.request(endpoint)
        
        // Remove from cache
        cache.remove(key: CacheKey.notification(id: id))
        
        // Invalidate related caches
        invalidateNotificationCaches()
    }
    
    /// Get unread notification count
    public func getUnreadCount() async throws -> Int {
        let userId = try await getCurrentUserId()
        let cacheKey = CacheKey.unreadCount(userId: userId)
        
        // Check cache
        if let cached: UnreadCountResponse = try? cache.get(key: cacheKey),
           !cache.isExpired(key: cacheKey) {
            return cached.count
        }
        
        // Fetch from API
        let endpoint = NotificationEndpoint.getUnreadCount
        let response: UnreadCountResponse = try await apiClient.request(endpoint)
        
        // Cache for short time
        try? cache.set(response, for: cacheKey)
        
        return response.count
    }
    
    // MARK: - Preferences Operations
    
    /// Get notification preferences
    public func getPreferences() async throws -> NotificationPreferences {
        let userId = try await getCurrentUserId()
        let cacheKey = CacheKey.preferences(userId: userId)
        
        // Check cache
        if let cached: NotificationPreferences = try? cache.get(key: cacheKey) {
            return cached
        }
        
        // Fetch from API
        let endpoint = NotificationEndpoint.getPreferences
        let preferences: NotificationPreferences = try await apiClient.request(endpoint)
        
        // Cache the response
        try? cache.set(preferences, for: cacheKey)
        
        return preferences
    }
    
    /// Update notification preferences
    public func updatePreferences(_ preferences: NotificationPreferences) async throws -> NotificationPreferences {
        let endpoint = NotificationEndpoint.updatePreferences(preferences)
        let updated: NotificationPreferences = try await apiClient.request(endpoint)
        
        // Update cache
        if let userId = try? await getCurrentUserId() {
            let cacheKey = CacheKey.preferences(userId: userId)
            try? cache.set(updated, for: cacheKey)
        }
        
        return updated
    }
    
    // MARK: - Push Token Operations
    
    /// Register a push token
    public func registerPushToken(_ request: RegisterPushTokenRequest) async throws -> PushToken {
        let endpoint = NotificationEndpoint.registerPushToken(request)
        let token: PushToken = try await apiClient.request(endpoint)
        
        logger.info("Push token registered successfully")
        
        return token
    }
    
    // MARK: - Analytics Operations
    
    /// Get notification statistics
    public func getNotificationStats(from startDate: Date, to endDate: Date) async throws -> NotificationAnalytics {
        let endpoint = NotificationEndpoint.getNotificationStats(from: startDate, to: endDate)
        let analytics: NotificationAnalytics = try await apiClient.request(endpoint)
        
        return analytics
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func getCurrentUserId() async throws -> UUID {
        // In real app, get from auth service
        // For now, use mock
        guard let user = MockAuthService.shared.currentUser else {
            throw APIError.unauthorized
        }
        return user.id
    }
    
    private func invalidateNotificationCaches() {
        // Invalidate all notification-related caches
        // Since removeAll is not available, we'll need to track keys manually
        // For now, just clear specific keys
        if let userId = try? UserDefaults.standard.string(forKey: "currentUserId"),
           let uuid = UUID(uuidString: userId) {
            for page in 1...10 {
                cache.remove(key: CacheKey.notifications(userId: uuid, page: page))
            }
            cache.remove(key: CacheKey.unreadCount(userId: uuid))
        }
    }
}

// MARK: - NotificationAPIService + NotificationRepositoryProtocol

extension NotificationAPIService: NotificationRepositoryProtocol {
    
    public func fetchNotifications(
        for userId: UUID,
        limit: Int? = nil,
        offset: Int? = nil,
        includeRead: Bool = true
    ) async throws -> [Notification] {
        let actualLimit = limit ?? 20
        let actualOffset = offset ?? 0
        let page = (actualOffset / actualLimit) + 1
        let response = try await fetchNotifications(page: page, limit: actualLimit)
        
        // Filter if needed
        if !includeRead {
            return response.items.filter { !$0.isRead }
        }
        
        return response.items
    }
    
    public func getNotification(id: UUID) async throws -> Notification? {
        return try await getNotificationById(id: id)
    }
    
    public func createNotification(_ notification: Notification) async throws -> Notification {
        let request = CreateNotificationRequest(
            recipientIds: [notification.userId],
            type: notification.type,
            title: notification.title,
            body: notification.body,
            data: notification.data,
            channels: Array(notification.channels),
            priority: notification.priority,
            metadata: notification.metadata
        )
        
        return try await createNotification(request)
    }
    
    public func updateNotification(_ notification: Notification) async throws -> Notification {
        // For now, only support marking as read
        if notification.isRead {
            return try await markAsRead(notificationId: notification.id)
        }
        
        // In real implementation, would have a full update endpoint
        return notification
    }
    
    public func deleteNotification(id: UUID) async throws {
        try await removeNotification(id: id)
    }
    
    public func markAllAsRead(for userId: UUID) async throws {
        // This would need a dedicated API endpoint
        // For now, fetch all and mark individually (not efficient)
        let notifications = try await fetchNotifications(for: userId, limit: 100, offset: 0, includeRead: false)
        
        for notification in notifications where !notification.isRead {
            _ = try await markAsRead(notificationId: notification.id)
        }
    }
    
    public func getUnreadCount(for userId: UUID) async throws -> Int {
        return try await getUnreadCount()
    }
    
    public func getPreferences(for userId: UUID) async throws -> NotificationPreferences? {
        return try await getPreferences()
    }
    
    public func savePreferences(_ preferences: NotificationPreferences) async throws -> NotificationPreferences {
        return try await updatePreferences(preferences)
    }
    
    public func savePushToken(_ token: PushToken) async throws -> PushToken {
        let request = RegisterPushTokenRequest(
            token: token.token,
            deviceId: token.deviceId,
            platform: token.platform,
            environment: token.environment
        )
        
        return try await registerPushToken(request)
    }
    
    public func getUserPushTokens(userId: UUID) async throws -> [PushToken] {
        // This would need a dedicated API endpoint
        return []
    }
    
    public func deletePushToken(id: UUID) async throws {
        // This would need a dedicated API endpoint
    }
    
    public func trackNotificationEvent(notificationId: UUID, event: NotificationEvent) async throws {
        // This would be sent to analytics service
        logger.info("Tracking notification event: \(event.type) for notification \(notificationId)")
    }
    
    public func getNotificationAnalytics(userId: UUID?, from startDate: Date, to endDate: Date) async throws -> NotificationAnalytics {
        return try await getNotificationStats(from: startDate, to: endDate)
    }
    
    public func getAllPushTokens() async throws -> [PushToken] {
        // Admin-only endpoint
        return []
    }
    
    public func markAsRead(notificationId: UUID, at date: Date) async throws {
        _ = try await markAsRead(notificationId: notificationId)
    }
    
    public func deleteExpiredNotifications() async throws -> Int {
        // This would need a dedicated API endpoint
        return 0
    }
    
    public func getTemplate(type: NotificationType) async throws -> NotificationTemplate? {
        // This would need a dedicated API endpoint
        return nil
    }
    
    public func getAllTemplates() async throws -> [NotificationTemplate] {
        // This would need a dedicated API endpoint
        return []
    }
    
    public func saveTemplate(_ template: NotificationTemplate) async throws -> NotificationTemplate {
        // This would need a dedicated API endpoint
        return template
    }
    
    public func updatePushToken(_ token: PushToken) async throws -> PushToken {
        // Update is done through register
        return try await savePushToken(token)
    }
    
    public func registerPushToken(_ token: PushToken) async throws -> PushToken {
        return try await savePushToken(token)
    }
    
    public func getPushTokens(for userId: UUID) async throws -> [PushToken] {
        return try await getUserPushTokens(userId: userId)
    }
    
    public func deactivatePushToken(tokenId: UUID) async throws {
        // This would need a dedicated API endpoint
        try await deletePushToken(id: tokenId)
    }
    
    public func deactivateTokensForDevice(deviceId: String) async throws {
        // This would need a dedicated API endpoint
        // For now, we'll need to fetch and delete manually
        let tokens = try await getAllPushTokens()
        for token in tokens where token.deviceId == deviceId {
            try await deletePushToken(id: token.id)
        }
    }
} 