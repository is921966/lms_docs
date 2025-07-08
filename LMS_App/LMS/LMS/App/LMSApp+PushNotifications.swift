//
//  LMSApp+PushNotifications.swift
//  LMS
//
//  Created on Sprint 41 Day 4 - Push Notifications Configuration
//

import SwiftUI
import UserNotifications

extension LMSApp {
    
    /// Configure push notifications
    func configurePushNotifications() {
        // Register notification categories
        APNsPushNotificationService.shared.registerCategories()
        
        // Request authorization on first launch
        Task {
            let hasRequestedBefore = UserDefaults.standard.bool(forKey: "hasRequestedPushPermission")
            
            if !hasRequestedBefore {
                _ = try? await APNsPushNotificationService.shared.requestAuthorization()
                UserDefaults.standard.set(true, forKey: "hasRequestedPushPermission")
            }
        }
    }
}

// MARK: - Push Notification Scene Modifier

struct PushNotificationModifier: ViewModifier {
    @UIApplicationDelegateAdaptor(PushNotificationDelegate.self) var pushDelegate
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                // Configure on app launch
                APNsPushNotificationService.shared.registerCategories()
            }
    }
}

// MARK: - Push Notification Delegate

class PushNotificationDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configure push notifications
        APNsPushNotificationService.shared.registerCategories()
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task {
            do {
                try await APNsPushNotificationService.shared.registerDeviceToken(deviceToken)
            } catch {
                print("Failed to register device token: \(error)")
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        APNsPushNotificationService.shared.handleRegistrationError(error)
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        APNsPushNotificationService.shared.handleRemoteNotification(
            userInfo,
            completionHandler: completionHandler
        )
    }
}

// MARK: - View Extension

extension View {
    /// Enable push notifications for the app
    func withPushNotifications() -> some View {
        self.modifier(PushNotificationModifier())
    }
} 