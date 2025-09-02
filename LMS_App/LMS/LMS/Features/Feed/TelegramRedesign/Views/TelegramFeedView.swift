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
    @State private var selectedFolder: FeedFolder = .all
    @State private var showSettings = false
    @State private var showCreateFolder = false
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedChannel: FeedChannel? = nil
    @State private var showingChannelDetail = false
    @State private var showDiagnostics = false  // Add this
    @State private var folderToDelete: FeedFolder? = nil
    @State private var showDeleteAlert = false
    
    init() {
        ComprehensiveLogger.shared.log(.ui, .info, "TelegramFeedView init started", details: [
            "timestamp": Date().timeIntervalSince1970,
            "thread": Thread.current.description
        ])
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            // Main content with safe area for header
            postsListSection
                .safeAreaInset(edge: .top) {
                    headerSection
                        .background(Color(UIColor.systemGroupedBackground))
                }
        }
        .navigationBarHidden(true)
        .trackScreen("TelegramFeedView", metadata: [
            "type": "telegram",
            "design": "new",
            "foldersCount": viewModel.folders.count
        ])
        .sheet(isPresented: $showSettings) {
            // Settings view - to be implemented
            Text("Настройки")
                .padding()
                .onAppear {
                    NavigationTracker.shared.trackScreen("Settings", metadata: ["parent": "TelegramFeedView"])
                }
        }
        .sheet(isPresented: $showCreateFolder) {
            CreateFolderView(viewModel: viewModel, onDismiss: {
                showCreateFolder = false
            })
        }
        .sheet(isPresented: $showingChannelDetail) {
            if let channel = selectedChannel,
               let posts = viewModel.channelPosts[channel.id] {
                ChannelDetailView(channel: channel, posts: posts)
            } else {
                // Debug view when posts not found
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Debug: Posts not found")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let channel = selectedChannel {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Channel: \(channel.name)")
                            Text("ID: \(channel.id)")
                            Text("Type: \(channel.type.rawValue)")
                            
                            Divider()
                            
                            Text("Available channel IDs:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            ForEach(Array(viewModel.channelPosts.keys).sorted(), id: \.self) { key in
                                HStack {
                                    Text(key)
                                        .font(.caption2)
                                    Spacer()
                                    Text("\(viewModel.channelPosts[key]?.count ?? 0) posts")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button("Close") {
                        showingChannelDetail = false
                    }
                    .padding()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showDiagnostics) {
            NavigationView {
                FeedDiagnosticView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showDiagnostics = false
                            }
                        }
                    }
            }
        }
        .onAppear {
            ComprehensiveLogger.shared.log(.ui, .info, "TelegramFeedView appeared", details: [
                "channelsCount": viewModel.channels.count,
                "foldersCount": viewModel.folders.count,
                "channelPostsCount": viewModel.channelPosts.count
            ])
            
            // Force refresh data
            Task {
                await viewModel.loadChannels()
            }
        }
        .trackScreen("TelegramFeedView", metadata: [
            "source": "MainTab",
            "variant": "telegram_style"
        ])
        .alert("Удалить папку?", isPresented: $showDeleteAlert, presenting: folderToDelete) { folder in
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                viewModel.deleteCustomFolder(folder)
            }
        } message: { folder in
            Text("Папка \"\(folder.name)\" будет удалена. Это действие нельзя отменить.")
        }
    }
    
    // MARK: - Header Section
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 0) {
            // Search bar with settings button
            HStack(spacing: 12) {
                // Title
                Text("LMS News")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Search button
                Button(action: {
                    // TODO: Show search interface
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 22))
                        .foregroundColor(.accentColor)
                        .frame(width: 40, height: 40)
                        .background(Color(UIColor.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 8)
            
            // Folders bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.folders) { folder in
                        FolderTab(
                            folder: folder,
                            isSelected: selectedFolder.id == folder.id,
                            unreadCount: viewModel.getUnreadCount(for: folder),
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedFolder = folder
                                }
                            },
                            onLongPress: {
                                // Показываем алерт подтверждения удаления
                                if case .custom = folder {
                                    showDeleteFolderAlert(folder)
                                }
                            }
                        )
                    }
                    
                    // Add folder button
                    Button(action: {
                        showCreateFolder = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.accentColor)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // Separator
            Divider()
        }
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Posts List Section
    
    @ViewBuilder
    private var postsListSection: some View {
        ScrollView {
            VStack(spacing: 0) {
                if filteredChannels.isEmpty {
                    emptyStateView
                        .padding(.top, 40)
                } else {
                    ForEach(Array(filteredChannels.enumerated()), id: \.element.id) { index, channel in
                        FeedChannelCell(channel: channel)
                            .onTapGesture {
                                ComprehensiveLogger.shared.log(.ui, .info, "Channel tapped", details: [
                                    "channelId": channel.id,
                                    "channelName": channel.name,
                                    "channelType": channel.type.rawValue
                                ])
                                
                                let postsForChannel = viewModel.channelPosts[channel.id]
                                
                                ComprehensiveLogger.shared.log(.ui, .info, "Channel lookup result", details: [
                                    "channelId": channel.id,
                                    "postsFound": postsForChannel != nil,
                                    "postsCount": postsForChannel?.count ?? 0,
                                    "allChannelIds": Array(viewModel.channelPosts.keys).sorted()
                                ])
                                
                                selectedChannel = channel
                                showingChannelDetail = true
                            }
                    }
                }
            }
        }
        .refreshable {
            ComprehensiveLogger.shared.log(.ui, .info, "Feed refresh initiated")
            await viewModel.refresh()
        }
    }
    
    // MARK: - Empty State View
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: selectedFolder.icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Нет каналов")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("В папке \"\(selectedFolder.name)\" пока нет каналов")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var filteredChannels: [FeedChannel] {
        let channels = viewModel.channels
        
        // Apply folder filter
        let folderFiltered: [FeedChannel]
        switch selectedFolder {
        case .all:
            folderFiltered = channels
        case .sprints:
            folderFiltered = channels.filter { $0.type == .sprints }
        case .docs:
            folderFiltered = channels.filter { $0.type == .methodology }
        case .system:
            folderFiltered = channels.filter { $0.type == .releases }
        case .custom(_, _, let filter):
            // Use the custom filter function
            folderFiltered = channels.filter(filter)
        }
        
        // Apply search filter
        if searchText.isEmpty {
            return folderFiltered
        } else {
            return folderFiltered.filter { channel in
                channel.name.localizedCaseInsensitiveContains(searchText) ||
                channel.lastMessage.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func showDeleteFolderAlert(_ folder: FeedFolder) {
        folderToDelete = folder
        showDeleteAlert = true
    }
}







// MARK: - Preview

#if DEBUG
struct TelegramFeedView_Previews: PreviewProvider {
    static var previews: some View {
        TelegramFeedView()
    }
}
#endif 