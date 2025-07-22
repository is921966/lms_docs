//
//  TelegramFeedView.swift
//  LMS
//
//  Sprint 50 - Основной экран новостей в стиле Telegram
//

import SwiftUI

/// Основной вид ленты новостей в стиле Telegram
struct TelegramFeedView: View {
    @StateObject private var viewModel = TelegramFeedViewModel()
    @State private var searchText = ""
    @State private var selectedChannel: FeedChannel?
    @State private var showSettings = false
    
    init() {
        print("🚀 TelegramFeedView init")
        ComprehensiveLogger.shared.log(.ui, .info, "TelegramFeedView initialized")
    }
    
    var body: some View {
        NavigationView {
            mainContent
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .trackScreen("TelegramFeedView", metadata: [
            "type": "telegram",
            "design": "new",
            "channelsCount": viewModel.channels.count
        ])
        .sheet(isPresented: $showSettings) {
            TelegramFeedSettingsView(onDismiss: {
                showSettings = false
            })
                .onAppear {
                    NavigationTracker.shared.trackScreen("TelegramFeedSettingsView", metadata: ["parent": "TelegramFeedView"])
                }
        }
        .sheet(item: $selectedChannel) { channel in
            NavigationView {
                FeedDetailView(channel: channel, onDismiss: {
                    selectedChannel = nil
                })
                    .onAppear {
                        NavigationTracker.shared.trackScreen("FeedDetailView", metadata: [
                            "parent": "TelegramFeedView",
                            "channelId": channel.id,
                            "channelName": channel.name
                        ])
                    }
            }
        }
        .onAppear {
            NavigationTracker.shared.trackScreen("TelegramFeedView", metadata: [
                "channelsCount": viewModel.channels.count,
                "totalUnread": viewModel.totalUnreadCount
            ])
            
            ComprehensiveLogger.shared.log(.ui, .info, "TelegramFeedView appeared", details: [
                "channelsCount": viewModel.channels.count,
                "isLoading": viewModel.isLoading,
                "totalUnread": viewModel.totalUnreadCount,
                "design": "telegram",
                "feedType": "new"
            ])
            
            Task {
                UIEventLogger.shared.logLoadingState(true, in: "TelegramFeedView", reason: "Loading channels")
                await viewModel.loadChannels()
                UIEventLogger.shared.logLoadingState(false, in: "TelegramFeedView", reason: "Channels loaded")
                
                ComprehensiveLogger.shared.log(.data, .info, "Channels loaded", details: [
                    "count": viewModel.channels.count,
                    "categories": Set(viewModel.channels.map { $0.category.rawValue }).joined(separator: ", ")
                ])
            }
        }
        .onChange(of: viewModel.channels) { oldValue, newValue in
            ComprehensiveLogger.shared.logDataChange("FeedChannels", operation: "update", before: oldValue.count, after: newValue.count)
        }
        .onChange(of: viewModel.isLoading) { oldValue, newValue in
            UIEventLogger.shared.logLoadingState(newValue, in: "TelegramFeedView", reason: "Feed state change")
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        ZStack {
            // Background
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search bar
                searchBarSection
                
                // Channels list
                channelsListSection
            }
            
            // Refresh view
            refreshOverlay
        }
        .navigationTitle("Новости")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { 
                    UIEventLogger.shared.logButtonTap("BackToClassic", in: "TelegramFeedView")
                    ComprehensiveLogger.shared.log(.ui, .info, "Switch to classic feed tapped", details: [
                        "from": "telegram",
                        "to": "classic"
                    ])
                    
                    // Переключаемся обратно на классическую ленту
                    UserDefaults.standard.set(false, forKey: "useNewFeedDesign")
                    FeedDesignManager.shared.setDesign(false)
                }) {
                    Label("Классическая лента", systemImage: "newspaper")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { 
                    UIEventLogger.shared.logButtonTap("Settings", in: "TelegramFeedView")
                    showSettings = true 
                }) {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
    
    @ViewBuilder
    private var searchBarSection: some View {
        FeedSearchBar(text: $searchText)
            .padding(.horizontal)
            .padding(.top, 8)
            .onChange(of: searchText) { oldValue, newValue in
                UIEventLogger.shared.logTextInput("feedSearch", oldValue: oldValue, newValue: newValue, in: "TelegramFeedView")
            }
    }
    
    @ViewBuilder
    private var channelsListSection: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if filteredChannels.isEmpty {
                    emptyStateView
                        .onAppear {
                            ComprehensiveLogger.shared.log(.ui, .warning, "Feed is empty", details: [
                                "totalChannels": viewModel.channels.count,
                                "isLoading": viewModel.isLoading,
                                "searchText": searchText
                            ])
                        }
                } else {
                    ForEach(filteredChannels) { channel in
                        channelRow(for: channel)
                    }
                }
            }
            .padding(.top, 8)
        }
        .refreshable {
            ComprehensiveLogger.shared.log(.ui, .info, "Feed refresh initiated")
            await viewModel.refresh()
        }
    }
    
    @ViewBuilder
    private var refreshOverlay: some View {
        // Loading overlay
        if viewModel.isLoading && viewModel.channels.isEmpty {
            FeedLoadingView()
                .onAppear {
                    UIEventLogger.shared.logLoadingState(true, in: "TelegramFeedView", reason: "Initial load")
                }
        }
    }
    
    // MARK: - Empty State View
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "newspaper.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Нет новостей")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Потяните вниз для обновления")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Computed Properties
    
    private var filteredChannels: [FeedChannel] {
        let filtered = searchText.isEmpty 
            ? viewModel.channels
            : viewModel.channels.filter { channel in
                channel.name.localizedCaseInsensitiveContains(searchText) ||
                channel.lastMessage.text.localizedCaseInsensitiveContains(searchText)
            }
        
        ComprehensiveLogger.shared.log(.ui, .debug, "Filtered channels", details: [
            "originalCount": viewModel.channels.count,
            "filteredCount": filtered.count,
            "searchText": searchText
        ])
        
        return filtered
    }
    
    // MARK: - Helper Methods
    
    @ViewBuilder
    private func channelRow(for channel: FeedChannel) -> some View {
        VStack(spacing: 0) {
            FeedChannelCell(channel: channel)
                .contentShape(Rectangle())
                .onTapGesture {
                    UIEventLogger.shared.logListItemTap(channel.name, index: filteredChannels.firstIndex(where: { $0.id == channel.id }) ?? -1, in: "TelegramFeedView", details: [
                        "channelId": channel.id,
                        "unreadCount": channel.unreadCount
                    ])
                    selectedChannel = channel
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    swipeActions(for: channel)
                }
                .contextMenu {
                    contextMenuItems(for: channel)
                }
            
            if channel.id != filteredChannels.last?.id {
                Divider()
                    .padding(.leading, 76)
            }
        }
    }
    
    @ViewBuilder
    private func swipeActions(for channel: FeedChannel) -> some View {
        // Delete action
        Button(role: .destructive) {
            UIEventLogger.shared.logSwipeAction("delete", on: channel.name, in: "TelegramFeedView")
            withAnimation {
                viewModel.deleteChannel(channel)
            }
        } label: {
            Label("Удалить", systemImage: "trash")
        }
        
        // Mark as read
        if channel.hasUnread {
            Button {
                UIEventLogger.shared.logSwipeAction("markAsRead", on: channel.name, in: "TelegramFeedView")
                viewModel.markAsRead(channel)
            } label: {
                Label("Прочитано", systemImage: "envelope.open")
            }
            .tint(.blue)
        }
        
        // Pin/Unpin
        Button {
            UIEventLogger.shared.logSwipeAction(channel.isPinned ? "unpin" : "pin", on: channel.name, in: "TelegramFeedView")
            viewModel.togglePin(channel)
        } label: {
            Label(channel.isPinned ? "Открепить" : "Закрепить",
                  systemImage: channel.isPinned ? "pin.slash" : "pin")
        }
        .tint(.orange)
    }
    
    @ViewBuilder
    private func contextMenuItems(for channel: FeedChannel) -> some View {
        // Mark as read/unread
        Button {
            if channel.hasUnread {
                viewModel.markAsRead(channel)
            } else {
                viewModel.markAsUnread(channel)
            }
        } label: {
            Label(channel.hasUnread ? "Отметить как прочитанное" : "Отметить как непрочитанное",
                  systemImage: channel.hasUnread ? "envelope.open" : "envelope")
        }
        
        // Pin/Unpin
        Button {
            viewModel.togglePin(channel)
        } label: {
            Label(channel.isPinned ? "Открепить" : "Закрепить",
                  systemImage: channel.isPinned ? "pin.slash" : "pin")
        }
        
        // Mute/Unmute
        Button {
            viewModel.toggleMute(channel)
        } label: {
            Label(channel.isMuted ? "Включить уведомления" : "Отключить уведомления",
                  systemImage: channel.isMuted ? "bell" : "bell.slash")
        }
        
        Divider()
        
        // Delete
        Button(role: .destructive) {
            viewModel.deleteChannel(channel)
        } label: {
            Label("Удалить", systemImage: "trash")
        }
    }
}

// MARK: - Search Bar

struct FeedSearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Поиск", text: $text)
                    .focused($isFocused)
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(10)
            
            if isFocused {
                Button("Отмена") {
                    text = ""
                    isFocused = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Loading View

struct FeedLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Загрузка каналов...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Settings View (временная заглушка)

// Settings view is in separate file: TelegramFeedSettingsView.swift

// MARK: - Previews

struct TelegramFeedView_Previews: PreviewProvider {
    static var previews: some View {
        TelegramFeedView()
    }
} 