//
//  FeedCoordinator.swift
//  LMS
//
//  Sprint 50 - Координатор для Telegram-style Feed
//

import UIKit
import SwiftUI

/// Координатор для управления навигацией в модуле Feed
class FeedCoordinator: NSObject, Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    @MainActor
    func start() {
        let viewModel = TelegramFeedViewModel()
        let feedView = TelegramFeedView()
            .environmentObject(viewModel)
        let hostingController = UIHostingController(rootView: feedView)
        hostingController.title = "Новости"
        
        // Set self as navigation delegate
        navigationController.delegate = self
        navigationController.pushViewController(hostingController, animated: false)
    }
    
    @MainActor
    func showChannelDetail(_ channel: FeedChannel) {
        // Use the existing FeedDetailView from Views folder
        let detailView = FeedDetailView(channel: channel) { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        let hostingController = UIHostingController(rootView: detailView)
        hostingController.navigationItem.hidesBackButton = true
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    @MainActor
    func showFeedSettings() {
        let settingsView = TelegramFeedSettingsView() { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.title = "Настройки уведомлений"
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate

extension FeedCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Handle navigation events if needed
    }
}

// Coordinator protocol is now imported from a common location 