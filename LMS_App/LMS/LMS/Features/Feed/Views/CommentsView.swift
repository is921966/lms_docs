import SwiftUI

struct CommentsView: View {
    let post: FeedPost
    @Environment(\.dismiss) private var dismiss
    @StateObject private var feedService = FeedService.shared
    @State private var newComment = ""
    @State private var isAddingComment = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Comments list
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        // Original post preview
                        PostPreviewInComments(post: post)
                            .padding()
                            .background(Color(.systemGray6))

                        // Comments
                        ForEach(post.comments) { comment in
                            CommentView(comment: comment)
                                .padding(.horizontal)
                        }

                        if post.comments.isEmpty {
                            Text("Пока нет комментариев")
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical)
                }

                // Add comment section
                if feedService.permissions.canComment {
                    Divider()

                    HStack(spacing: 12) {
                        // Comment input
                        TextField("Напишите комментарий...", text: $newComment)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        // Send button
                        Button(action: addComment) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(newComment.isEmpty ? Color.gray : Color.blue)
                                .clipShape(Circle())
                        }
                        .disabled(newComment.isEmpty || isAddingComment)
                    }
                    .padding()
                }
            }
            .navigationTitle("Комментарии")
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

    private func addComment() {
        let content = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }

        isAddingComment = true

        Task {
            do {
                try await feedService.addComment(to: post.id, content: content)
                await MainActor.run {
                    newComment = ""
                    isAddingComment = false
                }
            } catch {
                await MainActor.run {
                    isAddingComment = false
                }
            }
        }
    }
}

// MARK: - Post Preview in Comments
struct PostPreviewInComments: View {
    let post: FeedPost

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(roleColor(for: post.authorRole))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(post.authorName.prefix(1).uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(timeAgo(from: post.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Text(post.content)
                .font(.subheadline)
                .lineLimit(3)
        }
    }

    private func roleColor(for role: UserRole) -> Color {
        switch role {
        case .student:
            return .green
        case .moderator:
            return .yellow
        case .admin:
            return .blue
        case .superAdmin:
            return .red
        }
    }

    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Comment View
struct CommentView: View {
    let comment: FeedComment
    @StateObject private var feedService = FeedService.shared
    @StateObject private var authService = MockAuthService.shared

    var isLiked: Bool {
        comment.likes.contains(authService.currentUser?.id ?? "")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Author avatar
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(comment.authorName.prefix(1).uppercased())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                )

            VStack(alignment: .leading, spacing: 8) {
                // Comment content
                VStack(alignment: .leading, spacing: 4) {
                    Text(comment.authorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(comment.content)
                        .font(.subheadline)
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(16)

                // Actions
                HStack(spacing: 16) {
                    Text(timeAgo(from: comment.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: { /* Toggle like */ }) {
                        Text(isLiked ? "Нравится" : "Нравится")
                            .font(.caption)
                            .fontWeight(isLiked ? .semibold : .regular)
                            .foregroundColor(isLiked ? .blue : .secondary)
                    }

                    if comment.likesCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            Text("\(comment.likesCount)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Spacer()
        }
    }

    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    CommentsView(post: FeedPost(
        id: "1",
        authorId: "1",
        authorName: "Test User",
        authorRole: .student,
        authorAvatar: nil,
        content: "Test post",
        images: [],
        attachments: [],
        createdAt: Date(),
        updatedAt: Date(),
        likes: [],
        comments: [],
        visibility: .everyone,
        tags: [],
        mentions: []
    ))
}
