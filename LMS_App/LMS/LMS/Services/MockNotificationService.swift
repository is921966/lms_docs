//
//  MockNotificationService.swift
//  LMS
//

import Foundation
import Combine

public class NotificationService: ObservableObject {
    public static let shared = NotificationService()
    
    @Published public var unreadCount = 0
    @Published public var notifications: [String] = []
    
    private init() {}
    
    public func markAsRead(_ id: String) {
        // Mock implementation
    }
    
    public func requestPermissions() {
        // Mock implementation
    }
}
