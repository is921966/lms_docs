import SwiftUI

struct FeedPostCard: View {
    let post: FeedPost
    @StateObject private var feedService = MockFeedService.shared
    @StateObject private var authService = MockAuthService.shared
    @State private var showingComments = false
    @State private var showingOptions = false
    @State private var showingDetail = false
    @State private var isPressed = false

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
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            // Открываем детальный просмотр при нажатии на карточку
            showingDetail = true
        }
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .actionSheet(isPresented: $showingOptions) {
            postOptionsSheet
        }
        .sheet(isPresented: $showingComments) {
            CommentsView(post: post)
        }
        .sheet(isPresented: $showingDetail) {
            PostDetailView(post: post)
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

// MARK: - Post Detail View
struct PostDetailView: View {
    let post: FeedPost
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    PostHeaderView(
                        post: post,
                        showingOptions: .constant(false),
                        canShowOptions: false
                    )
                    
                    // Full content (always expanded in detail view)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(post.content)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Tags
                        if let tags = post.tags, !tags.isEmpty {
                            FeedFlowLayout(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding()
                    
                    // Images
                    if !post.images.isEmpty {
                        PostImagesView(images: post.images)
                    }
                    
                    // Attachments
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
                        isLiked: false,
                        showingComments: .constant(false),
                        onLike: {},
                        onShare: {}
                    )
                    
                    // All comments
                    if !post.comments.isEmpty {
                        Divider()
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Комментарии (\(post.comments.count))")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            ForEach(post.comments) { comment in
                                FeedCommentView(comment: comment)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Пост")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Full Comment View
struct FeedCommentView: View {
    let comment: FeedComment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(comment.author.name.prefix(1).uppercased())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.author.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("·")
                        .foregroundColor(.secondary)
                    
                    Text(comment.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(comment.content)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                if comment.likes.count > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text("\(comment.likes.count)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 2)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
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
