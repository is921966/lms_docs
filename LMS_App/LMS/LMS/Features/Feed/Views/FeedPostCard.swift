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

        if post.author.id == authService.currentUser?.id || feedService.permissions.canDelete {
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
        post.author.id == authService.currentUser?.id || feedService.permissions.canDelete
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

#if DEBUG
struct FeedPostCard_Previews: PreviewProvider {
    static var previews: some View {
        let samplePost = FeedPost(
            id: "1",
            author: UserResponse(id: "user1", email: "test@test.com", name: "Иван Петров", role: .instructor),
            content: "Это пример поста для превью. Он содержит несколько строк текста, чтобы проверить, как отображается контент.",
            images: [],
            attachments: [
                FeedAttachment(id: "att1", type: .document, url: "https://example.com/doc.pdf", name: "Пример документа.pdf", size: 123456, thumbnailUrl: nil)
            ],
            createdAt: Date().addingTimeInterval(-3600),
            visibility: .everyone,
            likes: ["user2", "user3"],
            comments: [
                FeedComment(id: "c1", postId: "1", author: UserResponse(id: "user2", email: "commenter@test.com", name: "Анна Иванова", role: .student), content: "Отличный пост!", createdAt: Date().addingTimeInterval(-1800), likes: [])
            ]
        )

        FeedPostCard(post: samplePost)
            .padding()
            .previewLayout(.sizeThatFits)
            .background(Color(.systemGray6))
    }
}
#endif
