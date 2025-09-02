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
        // Show posts from the channel
        if let posts = MockFeedService.shared.channelPosts[channel.id],
           let firstPost = posts.first {
            let detailView = TelegramPostDetailView(post: firstPost)
            let hostingController = UIHostingController(rootView: detailView)
            hostingController.navigationItem.hidesBackButton = false
            navigationController.pushViewController(hostingController, animated: true)
        }
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