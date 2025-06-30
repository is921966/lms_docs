import SwiftUI

struct FeedPostCard: View {
    let post: FeedPost
    @StateObject private var feedService = FeedService.shared
    @StateObject private var authService = MockAuthService.shared
    @State private var showingComments = false
    @State private var showingOptions = false

    var isLiked: Bool {
        post.likes.contains(authService.currentUser?.id ?? "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            PostHeaderView(
                post: post,
                showingOptions: $showingOptions,
                canShowOptions: canShowOptions()
            )

            // Content
            PostContentView(post: post)

            // Images (if any)
            if !post.images.isEmpty {
                PostImagesView(images: post.images)
            }

            // Attachments (if any)
            if !post.attachments.isEmpty {
                PostAttachmentsView(attachments: post.attachments)
            }

            // Stats
            PostStatsView(post: post)

            Divider()
                .padding(.horizontal)

            // Actions
            PostActionsView(
                post: post,
                isLiked: isLiked,
                showingComments: $showingComments,
                onLike: toggleLike,
                onShare: sharePost
            )

            // Comments preview
            if !post.comments.isEmpty {
                Divider()
                    .padding(.horizontal)
                PostCommentsPreview(
                    post: post,
                    showingComments: $showingComments
                )
            }
        }
        .actionSheet(isPresented: $showingOptions) {
            postOptionsSheet
        }
        .sheet(isPresented: $showingComments) {
            CommentsView(post: post)
        }
    }

    private var postOptionsSheet: ActionSheet {
        var buttons: [ActionSheet.Button] = []

        if post.authorId == authService.currentUser?.id || feedService.permissions.canDelete {
            buttons.append(.destructive(Text("Удалить")) {
                Task {
                    try? await feedService.deletePost(post.id)
                }
            })
        }

        buttons.append(.cancel())

        return ActionSheet(
            title: Text("Действия"),
            buttons: buttons
        )
    }

    // MARK: - Helper Methods

    private func canShowOptions() -> Bool {
        post.authorId == authService.currentUser?.id || feedService.permissions.canDelete
    }

    private func toggleLike() {
        Task {
            try? await feedService.toggleLike(postId: post.id)
        }
    }

    private func sharePost() {
        // In real app, would show share sheet
    }
}
