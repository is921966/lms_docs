//
//  TelegramFeedViewModel.swift
//  LMS
//
//  ViewModel для Telegram-style feed
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TelegramFeedViewModel: ObservableObject {
    // MARK: - Properties
    
    @Published var channels: [FeedChannel] = []
    @Published var folders: [FeedFolder] = FeedFolder.defaultFolders
    @Published var isLoading = false
    @Published var selectedFolder: FeedFolder = .all
    @Published var searchText: String = ""
    @Published var channelPosts: [String: [FeedPost]] = [:] // Добавляем это свойство
    @Published var error: Error?
    
    var unreadCount: Int {
        channels.reduce(0) { $0 + $1.unreadCount }
    }
    
    private let feedService = MockFeedService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        ComprehensiveLogger.shared.log(.ui, .info, "TelegramFeedViewModel initialized")
        setupBindings()
        loadCustomFolders()
    }
    
    private func setupBindings() {
        ComprehensiveLogger.shared.log(.ui, .debug, "Setting up bindings")
        
        // Observe MockFeedService channels
        MockFeedService.shared.$channels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newChannels in
                ComprehensiveLogger.shared.log(.data, .info, "Received channels update", details: [
                    "channelsCount": newChannels.count,
                    "channels": newChannels.map { ["name": $0.name, "type": $0.type.rawValue, "unread": $0.unreadCount] }
                ])
                self?.channels = newChannels
            }
            .store(in: &cancellables)
            
        // Observe MockFeedService channelPosts
        MockFeedService.shared.$channelPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newChannelPosts in
                ComprehensiveLogger.shared.log(.data, .info, "Received channel posts update", details: [
                    "postsPerChannel": newChannelPosts.mapValues { $0.count }
                ])
                self?.channelPosts = newChannelPosts
            }
            .store(in: &cancellables)
    }
    
    func loadChannels() async {
        ComprehensiveLogger.shared.log(.ui, .info, "Starting channel load")
        
        await MainActor.run {
            isLoading = true
            error = nil
            
            ComprehensiveLogger.shared.log(.ui, .debug, "UI state updated - loading started")
        }
        
        do {
            // Refresh mock service which will trigger real data loading
            ComprehensiveLogger.shared.log(.data, .info, "Calling MockFeedService.refresh()")
            MockFeedService.shared.refresh()
            
            await MainActor.run {
                // Get current state
                let loadedChannels = MockFeedService.shared.channels
                let channelPosts = MockFeedService.shared.channelPosts
                
                ComprehensiveLogger.shared.log(.data, .info, "Channels loaded", details: [
                    "totalChannels": loadedChannels.count,
                    "channelTypes": Dictionary(grouping: loadedChannels, by: { $0.type }).mapValues { $0.count },
                    "channelNames": loadedChannels.map { $0.name },
                    "postsPerChannel": channelPosts.mapValues { $0.count }
                ])
                
                // Log details for each channel
                for channel in loadedChannels {
                    if let posts = channelPosts[channel.id] {
                        ComprehensiveLogger.shared.log(.data, .debug, "Channel '\(channel.name)' details", details: [
                            "type": channel.type.rawValue,
                            "postsCount": posts.count,
                            "unreadCount": channel.unreadCount,
                            "lastMessage": channel.lastMessage.content.prefix(50) + "..."
                        ])
                    }
                }
                
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
                
                ComprehensiveLogger.shared.log(.ui, .error, "Failed to load channels", details: [
                    "error": error.localizedDescription
                ])
            }
        }
    }
    
    func refresh() async {
        feedService.refresh()
    }
    
    func markChannelAsRead(_ channelId: String) {
        // Implement mark as read logic
        ComprehensiveLogger.shared.log(.ui, .info, "Channel marked as read", details: ["channelId": channelId])
    }
    
    func getUnreadCount(for folder: FeedFolder) -> Int {
        ComprehensiveLogger.shared.log(.data, .debug, "Getting unread count for folder", details: [
            "folder": folder.name
        ])
        
        switch folder {
        case .all:
            return channels.reduce(0) { $0 + $1.unreadCount }
        case .sprints:
            return channels.filter { $0.type == .sprints }.reduce(0) { $0 + $1.unreadCount }
        case .docs:
            return channels.filter { $0.type == .methodology }.reduce(0) { $0 + $1.unreadCount }
        case .system:
            return channels.filter { $0.type == .releases }.reduce(0) { $0 + $1.unreadCount }
        case .custom(_, _, let filter):
            return channels.filter(filter).reduce(0) { $0 + $1.unreadCount }
        }
    }
    
    // MARK: - Custom Folder Management
    
    func createCustomFolder(name: String, icon: String, channelIds: [String]) {
        ComprehensiveLogger.shared.log(.data, .info, "Creating custom folder", details: [
            "name": name,
            "icon": icon,
            "channelIds": channelIds
        ])
        
        let customFolder = FeedFolder.custom(
            name: name,
            icon: icon,
            filter: { channel in
                channelIds.contains(channel.id)
            }
        )
        
        folders.append(customFolder)
        
        // Сохраняем в UserDefaults для персистентности
        saveCustomFolders()
        
        ComprehensiveLogger.shared.log(.data, .info, "Custom folder created successfully", details: [
            "folderId": customFolder.id,
            "totalFolders": folders.count
        ])
    }
    
    func deleteCustomFolder(_ folder: FeedFolder) {
        guard case .custom = folder else { return }
        
        ComprehensiveLogger.shared.log(.data, .info, "Deleting custom folder", details: [
            "folderId": folder.id,
            "name": folder.name
        ])
        
        folders.removeAll { $0.id == folder.id }
        saveCustomFolders()
    }
    
    private func saveCustomFolders() {
        // Сохраняем только кастомные папки
        let customFolders = folders.compactMap { folder -> [String: Any]? in
            guard case let .custom(name, icon, _) = folder else { return nil }
            
            // Для фильтра сохраняем список ID каналов
            let channelIds = channels
                .filter { channel in
                    if case let .custom(_, _, filter) = folder {
                        return filter(channel)
                    }
                    return false
                }
                .map { $0.id }
            
            return [
                "name": name,
                "icon": icon,
                "channelIds": channelIds
            ]
        }
        
        UserDefaults.standard.set(customFolders, forKey: "customFeedFolders")
    }
    
    func loadCustomFolders() {
        guard let savedFolders = UserDefaults.standard.array(forKey: "customFeedFolders") as? [[String: Any]] else {
            return
        }
        
        let customFolders = savedFolders.compactMap { dict -> FeedFolder? in
            guard let name = dict["name"] as? String,
                  let icon = dict["icon"] as? String,
                  let channelIds = dict["channelIds"] as? [String] else {
                return nil
            }
            
            return .custom(
                name: name,
                icon: icon,
                filter: { channel in
                    channelIds.contains(channel.id)
                }
            )
        }
        
        // Добавляем кастомные папки к дефолтным
        folders = FeedFolder.defaultFolders + customFolders
        
        ComprehensiveLogger.shared.log(.data, .info, "Loaded custom folders", details: [
            "count": customFolders.count
        ])
    }
} 