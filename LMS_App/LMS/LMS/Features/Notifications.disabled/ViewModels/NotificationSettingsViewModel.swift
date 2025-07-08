//
//  NotificationSettingsViewModel.swift
//  LMS
//
//  Created on Sprint 41 Day 2 - Notification Settings ViewModel
//

import SwiftUI
import UIKit
import UserNotifications

/// ViewModel для настроек уведомлений
@MainActor
final class NotificationSettingsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var preferences = NotificationPreferences(userId: UUID())
    @Published var pushNotificationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    @Published var error: Error?
    @Published var saveSuccess = false
    
    // MARK: - Private Properties
    
    private let repository: NotificationRepositoryProtocol
    private let pushService: PushNotificationServiceProtocol?
    private var currentUserId: UUID? {
        // TODO: Get from auth service
        return UUID() // Mock for now
    }
    
    // MARK: - Initialization
    
    init(
        repository: NotificationRepositoryProtocol,
        pushService: PushNotificationServiceProtocol? = nil
    ) {
        self.repository = repository
        self.pushService = pushService
    }
    
    // MARK: - Public Methods
    
    func loadPreferences() {
        Task {
            do {
                isLoading = true
                guard let userId = currentUserId else { return }
                if let loadedPreferences = try await repository.getPreferences(for: userId) {
                    preferences = loadedPreferences
                } else {
                    // Create default preferences if none exist
                    preferences = NotificationPreferences(userId: userId)
                }
                await checkNotificationPermissions()
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
    
    func savePreferences() async {
        isLoading = true
        error = nil
        
        do {
            preferences = try await repository.updatePreferences(preferences)
        } catch {
            self.error = error
            print("Failed to save preferences: \(error)")
        }
        
        isLoading = false
    }
    
    func requestPushPermission() {
        Task {
            do {
                let center = UNUserNotificationCenter.current()
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                
                if granted {
                    await UIApplication.shared.registerForRemoteNotifications()
                }
                
                await checkPushNotificationStatus()
            } catch {
                print("Failed to request push permission: \(error)")
            }
        }
    }
    
    func checkPushNotificationStatus() {
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            pushNotificationStatus = settings.authorizationStatus
        }
    }
    
    // MARK: - Helper Methods
    
    func toggleChannel(_ channel: NotificationChannel, for type: NotificationType) {
        var channels = preferences.channelPreferences[type] ?? []
        
        if channels.contains(channel) {
            channels.remove(channel)
        } else {
            channels.insert(channel)
        }
        
        preferences.channelPreferences[type] = channels
    }
    
    func updateFrequencyLimit(for type: NotificationType, limit: FrequencyLimit) {
        preferences.frequencyLimits[type] = limit
    }
    
    // MARK: - Private Methods
    
    private func checkNotificationPermissions() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        pushNotificationStatus = settings.authorizationStatus
    }
} 