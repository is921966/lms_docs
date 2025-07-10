//
//  FeedViewModel.swift
//  LMS
//
//  Created by LMS Team on 13.01.2025.
//

import Foundation
import Combine

@MainActor
class FeedViewModel: ObservableObject {
    
    @Published var posts: [FeedPost] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var permissions = FeedPermissions(
        canPost: false,
        canComment: true,
        canLike: true,
        canShare: true,
        canDelete: false,
        canEdit: false,
        canModerate: false,
        visibilityOptions: []
    )
    @Published var searchText = ""
    @Published var selectedVisibilityFilter: FeedVisibility?
    
    private let feedService: FeedService
    private var cancellables = Set<AnyCancellable>()
    
    var filteredPosts: [FeedPost] {
        var filtered = posts
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { post in
                post.content.localizedCaseInsensitiveContains(searchText) ||
                post.author.name.localizedCaseInsensitiveContains(searchText) ||
                (post.tags?.contains { $0.localizedCaseInsensitiveContains(searchText) } ?? false) ||
                (post.mentions?.contains { $0.localizedCaseInsensitiveContains(searchText) } ?? false)
            }
        }
        
        // Apply visibility filter
        if let visibility = selectedVisibilityFilter {
            filtered = filtered.filter { $0.visibility == visibility }
        }
        
        return filtered
    }
    
    init(feedService: FeedService = .shared) {
        self.feedService = feedService
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind to feed service state
        feedService.$posts
            .assign(to: &$posts)
        
        feedService.$isLoading
            .assign(to: &$isLoading)
        
        feedService.$error
            .assign(to: &$error)
        
        feedService.$permissions
            .assign(to: &$permissions)
    }
    
    // MARK: - Public Methods
    
    func refresh() {
        feedService.refresh()
    }
    
    func createPost(
        content: String,
        images: [String] = [],
        attachments: [FeedAttachment] = [],
        visibility: FeedVisibility = .everyone
    ) async throws {
        do {
            try await feedService.createPost(
                content: content,
                images: images,
                attachments: attachments,
                visibility: visibility
            )
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func deletePost(_ postId: String) async throws {
        do {
            try await feedService.deletePost(postId)
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func toggleLike(postId: String) async throws {
        do {
            try await feedService.toggleLike(postId: postId)
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func addComment(to postId: String, content: String) async throws {
        do {
            try await feedService.addComment(to: postId, content: content)
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func clearError() {
        error = nil
        feedService.error = nil
    }
    
    // MARK: - Computed Properties
    
    var hasError: Bool {
        error != nil
    }
    
    var errorMessage: String {
        error ?? ""
    }
    
    var canCreatePost: Bool {
        permissions.canPost
    }
    
    var availableVisibilityOptions: [FeedVisibility] {
        permissions.visibilityOptions
    }
} 