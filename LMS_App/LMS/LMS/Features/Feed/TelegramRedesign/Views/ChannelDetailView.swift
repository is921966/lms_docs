//
//  ChannelDetailView.swift
//  LMS
//
//  Детальный просмотр канала с полным списком постов
//

import SwiftUI

struct ChannelDetailView: View {
    let channel: FeedChannel
    let posts: [FeedPost]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPost: FeedPost?
    @State private var showingPostDetail = false
    
    // Computed property for sorted posts
    var sortedPosts: [FeedPost] {
        posts.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Channel header
                    channelHeader
                        .background(Color(UIColor.systemBackground))
                    
                    Divider()
                    
                    // Posts list
                    if posts.isEmpty {
                        VStack(spacing: 20) {
                            emptyStateView
                            
                            // Debug info
                            #if DEBUG
                            VStack(alignment: .leading, spacing: 8) {
                                Text("DEBUG INFO:")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                Text("Channel ID: \(channel.id)")
                                    .font(.caption2)
                                Text("Channel Type: \(channel.type.rawValue)")
                                    .font(.caption2)
                                Text("Posts count: \(posts.count)")
                                    .font(.caption2)
                            }
                            .padding()
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(8)
                            .padding()
                            #endif
                        }
                    } else {
                        ScrollView {
                            // Debug header
                            #if DEBUG
                            HStack {
                                Text("Posts: \(posts.count)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.horizontal)
                                Spacer()
                            }
                            #endif
                            
                            LazyVStack(spacing: 0) {
                                ForEach(sortedPosts) { post in
                                    PostCard(post: post)
                                        .onTapGesture {
                                            selectedPost = post
                                            showingPostDetail = true
                                        }
                                    
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingPostDetail) {
            if let post = selectedPost {
                TelegramPostDetailView(post: post)
            }
        }
    }
    
    // MARK: - Channel Header
    
    private var channelHeader: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "007AFF"))
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "007AFF"))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            // Channel info
            VStack(spacing: 16) {
                // Avatar
                Circle()
                    .fill(channel.type.color)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: channel.type.icon)
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    )
                
                // Name and stats
                VStack(spacing: 8) {
                    Text(channel.name)
                        .font(.system(size: 24, weight: .bold))
                    
                    HStack(spacing: 16) {
                        Label("\(posts.count) постов", systemImage: "doc.text")
                        if channel.members > 0 {
                            Label("\(channel.members) участников", systemImage: "person.2")
                        }
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                }
                
                if !channel.description.isEmpty {
                    Text(channel.description)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Пока нет постов")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("Новые посты появятся здесь")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

// MARK: - Post Card

struct PostCard: View {
    let post: FeedPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author and date
            HStack {
                Circle()
                    .fill(avatarColor(for: post.author.role))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(post.author.name.prefix(1).uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author.name)
                        .font(.system(size: 15, weight: .medium))
                    
                    Text(formatDate(post.createdAt))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Content preview
            Group {
                if post.metadata?["contentType"] == "html" {
                    // Show plain text preview for HTML content
                    Text(stripHTML(from: post.content))
                        .font(.system(size: 15))
                        .lineLimit(5)
                        .multilineTextAlignment(.leading)
                } else {
                    Text(post.content)
                        .font(.system(size: 15))
                        .lineLimit(5)
                        .multilineTextAlignment(.leading)
                }
            }
            
            // Tags
            if let tags = post.tags, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tags.prefix(5), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "007AFF"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "007AFF").opacity(0.1))
                                )
                        }
                    }
                }
            }
            
            // Stats
            HStack(spacing: 20) {
                HStack(spacing: 4) {
                    Image(systemName: "heart")
                        .font(.system(size: 14))
                    Text("\(post.likes.count)")
                        .font(.system(size: 13))
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 14))
                    Text("\(post.comments.count)")
                        .font(.system(size: 13))
                }
                
                Spacer()
                
                if !post.attachments.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "paperclip")
                            .font(.system(size: 14))
                        Text("\(post.attachments.count)")
                            .font(.system(size: 13))
                    }
                }
            }
            .foregroundColor(.secondary)
        }
        .padding()
    }
    
    // MARK: - Helpers
    
    private func stripHTML(from string: String) -> String {
        // Simple HTML stripping
        let pattern = "<[^>]+>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: string.utf16.count)
        let stripped = regex?.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "") ?? string
        
        // Clean up extra whitespace
        return stripped
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "\n\n\n", with: "\n\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func avatarColor(for role: UserRole) -> Color {
        switch role {
        case .admin: return .red
        case .instructor: return .blue
        case .manager: return .green
        case .student: return .purple
        case .superAdmin: return .orange
        }
    }
} 