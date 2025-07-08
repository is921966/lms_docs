//
//  NotificationCenterViewModel.swift
//  LMS
//
//  Created on Sprint 41 Day 2 - Notification Center ViewModel
//

import Foundation
import Combine

/// ViewModel для центра уведомлений
@MainActor
final class NotificationCenterViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var notifications: [Notification] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var unreadCount = 0
    @Published var currentFilter: NotificationFilterOption = .all
    @Published var isLoadingMore = false
    @Published var hasMore = false
    
    // MARK: - Private Properties
    
    private let repository: NotificationRepositoryProtocol
    private let userId: UUID
    private var allNotifications: [Notification] = []
    private var cancellables = Set<AnyCancellable>()
    private var pagination: PaginationRequest?
    private var filter: NotificationFilter?
    private var currentUserId: UUID? {
        // TODO: Get from auth service
        return userId
    }
    
    // MARK: - Initialization
    
    init(repository: NotificationRepositoryProtocol? = nil) {
        self.repository = repository ?? MockNotificationRepository()
        // TODO: Get real user ID from auth service
        self.userId = UUID() // Mock user ID
        
        setupObservers()
    }
    
    // MARK: - Public Methods
    
    func loadNotifications() {
        Task {
            do {
                isLoading = true
                guard let userId = currentUserId else { return }
                let response = try await repository.fetchNotifications(
                    for: userId,
                    limit: pagination?.limit,
                    offset: pagination?.offset,
                    includeRead: filter?.showRead ?? true
                )
                
                notifications = response
                allNotifications = response
                hasMore = response.count == (pagination?.limit ?? 20)
                
                unreadCount = try await repository.getUnreadCount(for: userId)
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
    
    func loadMoreNotifications() {
        guard !isLoadingMore, hasMore else { return }
        
        Task {
            do {
                isLoadingMore = true
                guard let userId = currentUserId else { return }
                let nextPage = (pagination?.page ?? 1) + 1
                let newPagination = PaginationRequest(page: nextPage, limit: pagination?.limit ?? 20)
                
                let response = try await repository.fetchNotifications(
                    for: userId,
                    limit: newPagination.limit,
                    offset: newPagination.offset,
                    includeRead: filter?.showRead ?? true
                )
                
                notifications.append(contentsOf: response)
                allNotifications.append(contentsOf: response)
                hasMore = response.count == newPagination.limit
                pagination = newPagination
            } catch {
                self.error = error
            }
            isLoadingMore = false
        }
    }
    
    func refresh() async {
        pagination = PaginationRequest(page: 1, limit: 20)
        filter = nil
        notifications = []
        allNotifications = []
        loadNotifications()
    }
    
    func applyFilter(_ filter: NotificationFilterOption) {
        currentFilter = filter
        
        switch filter {
        case .all:
            notifications = allNotifications
        case .unread:
            notifications = allNotifications.filter { !$0.isRead }
        case .important:
            notifications = allNotifications.filter { notification in
                notification.priority == .high
            }
        case .recent:
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            notifications = allNotifications.filter { notification in
                notification.createdAt >= yesterday
            }
        }
    }
    
    func markAsRead(_ notification: Notification) {
        Task {
            do {
                guard !notification.isRead else { return }
                try await repository.markAsRead(notificationId: notification.id, at: Date())
                
                if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                    var updatedNotification = notification
                    updatedNotification.markAsRead()
                    updatedNotification.readAt = Date()
                    notifications[index] = updatedNotification
                    unreadCount = max(0, unreadCount - 1)
                }
                
                if let index = allNotifications.firstIndex(where: { $0.id == notification.id }) {
                    var updatedNotification = notification
                    updatedNotification.markAsRead()
                    updatedNotification.readAt = Date()
                    allNotifications[index] = updatedNotification
                }
                
                // Post notification for other views
                NotificationCenter.default.post(
                    name: .lmsNotificationRead,
                    object: notification
                )
            } catch {
                self.error = error
            }
        }
    }
    
    func markAllAsRead() {
        Task {
            do {
                // Mark all as read one by one
                for notification in notifications where !notification.isRead {
                    try await repository.markAsRead(notificationId: notification.id, at: Date())
                }
                
                // Update local state
                for index in notifications.indices {
                    notifications[index].markAsRead()
                    notifications[index].readAt = Date()
                }
                for index in allNotifications.indices {
                    allNotifications[index].markAsRead()
                    allNotifications[index].readAt = Date()
                }
                
                updateUnreadCount()
            } catch {
                print("Failed to mark all as read: \(error)")
            }
        }
    }
    
    func delete(_ notification: Notification) {
        Task {
            do {
                try await repository.deleteNotification(id: notification.id)
                
                // Update local state
                notifications.removeAll { $0.id == notification.id }
                allNotifications.removeAll { $0.id == notification.id }
                
                updateUnreadCount()
            } catch {
                print("Failed to delete notification: \(error)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        // Listen for notification updates
        NotificationCenter.default.publisher(for: .lmsNotificationReceived)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notif in
                if let newNotification = notif.object as? Notification {
                    self?.handleNewNotification(newNotification)
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleNewNotification(_ notification: Notification) {
        // Add to beginning of lists if it's for this user
        guard notification.userId == userId else { return }
        
        notifications.insert(notification, at: 0)
        allNotifications.insert(notification, at: 0)
        updateUnreadCount()
    }
    
    private func updateUnreadCount() {
        unreadCount = allNotifications.filter { !$0.isRead }.count
    }
}

// MARK: - Notification Names

extension Foundation.Notification.Name {
    static let lmsNotificationReceived = Foundation.Notification.Name("lmsNotificationReceived")
    static let lmsNotificationRead = Foundation.Notification.Name("lmsNotificationRead")
    static let lmsNotificationDeleted = Foundation.Notification.Name("lmsNotificationDeleted")
} 