import SwiftUI

struct FeedView: View {
    @StateObject private var feedService = FeedService.shared
    @StateObject private var authService = MockAuthService.shared
    @State private var showingCreatePost = false
    @State private var refreshing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Create post section (if user has permission)
                    if feedService.permissions.canPost {
                        CreatePostSection(showingCreatePost: $showingCreatePost)
                            .padding()
                    }
                    
                    // Posts feed
                    LazyVStack(spacing: 12) {
                        ForEach(feedService.posts) { post in
                            FeedPostCard(post: post)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .background(Color(.systemGray6))
            .navigationTitle("Лента новостей")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { refreshFeed() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                await refreshFeed()
            }
            .sheet(isPresented: $showingCreatePost) {
                CreatePostView()
            }
        }
    }
    
    @MainActor
    private func refreshFeed() async {
        refreshing = true
        // In real app, would fetch from server
        await Task.sleep(1_000_000_000) // 1 second
        refreshing = false
    }
}

// MARK: - Create Post Section
struct CreatePostSection: View {
    @Binding var showingCreatePost: Bool
    @StateObject private var authService = MockAuthService.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // User avatar
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(authService.currentUser?.name.prefix(1).uppercased() ?? "?")
                        .font(.headline)
                        .foregroundColor(.blue)
                )
            
            // Create post button
            Button(action: { showingCreatePost = true }) {
                HStack {
                    Text("Что у вас нового?")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray5))
                .cornerRadius(20)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Feed Post Card
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
            postHeader
            
            // Content
            postContent
            
            // Images (if any)
            if !post.images.isEmpty {
                postImages
            }
            
            // Attachments (if any)
            if !post.attachments.isEmpty {
                postAttachments
            }
            
            // Stats
            postStats
            
            Divider()
                .padding(.horizontal)
            
            // Actions
            postActions
            
            // Comments preview
            if !post.comments.isEmpty {
                Divider()
                    .padding(.horizontal)
                commentsPreview
            }
        }
    }
    
    private var postHeader: some View {
        HStack {
            // Author avatar
            Circle()
                .fill(roleColor(for: post.authorRole))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(post.authorName.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(post.authorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    if post.authorRole == .admin {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                HStack(spacing: 4) {
                    Text(timeAgo(from: post.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Image(systemName: post.visibility.icon)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Options button
            if canShowOptions() {
                Button(action: { showingOptions = true }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
                .actionSheet(isPresented: $showingOptions) {
                    postOptionsSheet
                }
            }
        }
        .padding()
    }
    
    private var postContent: some View {
        Text(post.content)
            .font(.body)
            .padding(.horizontal)
            .padding(.bottom, 8)
    }
    
    private var postImages: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(post.images, id: \.self) { imageUrl in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 200, height: 150)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }
    
    private var postAttachments: some View {
        VStack(spacing: 8) {
            ForEach(post.attachments) { attachment in
                AttachmentView(attachment: attachment)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var postStats: some View {
        HStack {
            if post.likesCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("\(post.likesCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if post.commentsCount > 0 {
                Text("\(post.commentsCount) комментариев")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var postActions: some View {
        HStack(spacing: 0) {
            // Like button
            Button(action: { toggleLike() }) {
                HStack {
                    Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .foregroundColor(isLiked ? .blue : .secondary)
                    Text("Нравится")
                        .font(.subheadline)
                        .foregroundColor(isLiked ? .blue : .secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .disabled(!feedService.permissions.canLike)
            
            // Comment button
            Button(action: { showingComments = true }) {
                HStack {
                    Image(systemName: "bubble.left")
                        .foregroundColor(.secondary)
                    Text("Комментировать")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .disabled(!feedService.permissions.canComment)
            .sheet(isPresented: $showingComments) {
                CommentsView(post: post)
            }
            
            // Share button
            Button(action: { sharePost() }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.secondary)
                    Text("Поделиться")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .disabled(!feedService.permissions.canShare)
        }
    }
    
    private var commentsPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(post.comments.prefix(2)) { comment in
                CommentPreviewView(comment: comment)
            }
            
            if post.commentsCount > 2 {
                Button(action: { showingComments = true }) {
                    Text("Показать все комментарии (\(post.commentsCount))")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
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
    
    private func roleColor(for role: UserRole) -> Color {
        switch role {
        case .admin, .superAdmin:
            return .blue
        case .student:
            return .green
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Attachment View
struct AttachmentView: View {
    let attachment: FeedAttachment
    
    var body: some View {
        HStack {
            Image(systemName: attachmentIcon)
                .font(.title3)
                .foregroundColor(attachmentColor)
                .frame(width: 40, height: 40)
                .background(attachmentColor.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.name)
                    .font(.subheadline)
                    .lineLimit(1)
                
                Text(attachment.type.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var attachmentIcon: String {
        switch attachment.type {
        case .document: return "doc.fill"
        case .video: return "play.rectangle.fill"
        case .link: return "link"
        case .course: return "book.fill"
        case .test: return "checkmark.circle.fill"
        }
    }
    
    private var attachmentColor: Color {
        switch attachment.type {
        case .document: return .blue
        case .video: return .red
        case .link: return .green
        case .course: return .purple
        case .test: return .orange
        }
    }
}

// MARK: - Comment Preview View
struct CommentPreviewView: View {
    let comment: FeedComment
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(comment.authorName.prefix(1).uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(comment.authorName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(comment.content)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    FeedView()
} 