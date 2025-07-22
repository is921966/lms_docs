//
//  TelegramFeedViewModel.swift
//  LMS
//
//  Sprint 50 - ViewModel для ленты новостей в стиле Telegram
//

import Foundation
import SwiftUI

@MainActor
class TelegramFeedViewModel: ObservableObject {
    @Published var channels: [FeedChannel] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: NewsCategory?
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    
    private let feedService: TelegramFeedServiceProtocol
    var onChannelTap: ((FeedChannel) -> Void)?
    
    var filteredChannels: [FeedChannel] {
        channels.filter { channel in
            let matchesSearch = searchText.isEmpty || 
                channel.name.localizedCaseInsensitiveContains(searchText) ||
                channel.lastMessage.text.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == nil || channel.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
    }
    
    var totalUnreadCount: Int {
        channels.reduce(0) { $0 + $1.unreadCount }
    }
    
    init(feedService: TelegramFeedServiceProtocol = MockTelegramFeedService.shared) {
        self.feedService = feedService
        Task {
            await loadChannels()
        }
    }
    
    @MainActor
    func loadChannels() async {
        isLoading = true
        do {
            channels = try await feedService.loadChannels()
        } catch {
            print("Error loading channels: \(error)")
        }
        isLoading = false
    }
    
    func refresh() async {
        isRefreshing = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        do {
            channels = try await feedService.loadChannels()
        } catch {
            print("Error refreshing channels: \(error)")
        }
        isRefreshing = false
    }
    
    func markAsRead(_ channel: FeedChannel) {
        guard let index = channels.firstIndex(where: { $0.id == channel.id }) else { return }
        
        channels[index].unreadCount = 0
        channels[index].lastMessage.isRead = true
    }
    
    func markAsUnread(_ channel: FeedChannel) {
        guard let index = channels.firstIndex(where: { $0.id == channel.id }) else { return }
        
        channels[index].unreadCount = 1
        channels[index].lastMessage.isRead = false
    }
    
    func markAllAsRead() {
        for index in channels.indices {
            channels[index].unreadCount = 0
            channels[index].lastMessage.isRead = true
        }
    }
    
    func togglePin(_ channel: FeedChannel) {
        guard let index = channels.firstIndex(where: { $0.id == channel.id }) else { return }
        
        channels[index].isPinned.toggle()
        
        // Re-sort channels to move pinned to top
        sortChannels()
    }
    
    func toggleMute(_ channel: FeedChannel) {
        guard let index = channels.firstIndex(where: { $0.id == channel.id }) else { return }
        
        channels[index].isMuted.toggle()
        
        // Save mute preference
        UserDefaults.standard.set(channels[index].isMuted, forKey: "muted_\(channel.id)")
    }
    
    func deleteChannel(_ channel: FeedChannel) {
        channels.removeAll { $0.id == channel.id }
    }
    
    private func sortChannels() {
        channels.sort { lhs, rhs in
            // First, sort by pinned status
            if lhs.isPinned != rhs.isPinned {
                return lhs.isPinned
            }
            
            // Then by priority
            if lhs.priority != rhs.priority {
                return lhs.priority.sortOrder < rhs.priority.sortOrder
            }
            
            // Finally by last message time
            return lhs.lastMessage.timestamp > rhs.lastMessage.timestamp
        }
    }
    
    func handleChannelTap(_ channel: FeedChannel) {
        markAsRead(channel)
        onChannelTap?(channel)
    }
} 