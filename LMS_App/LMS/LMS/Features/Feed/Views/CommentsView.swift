import SwiftUI

struct CommentsView: View {
    let post: FeedPost
    @Environment(\.dismiss) private var dismiss
    @StateObject private var feedService = MockFeedService.shared
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
                    .fill(roleColor(for: post.author.role))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(post.author.name.prefix(1).uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author.name)
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
        case .instructor:
            return .yellow
        case .manager:
            return .orange
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
    @StateObject private var feedService = MockFeedService.shared
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
                    Text(comment.author.name.prefix(1).uppercased())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                )

            VStack(alignment: .leading, spacing: 8) {
                // Comment content
                VStack(alignment: .leading, spacing: 4) {
                    Text(comment.author.name)
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
    let mockStudent = UserResponse(
        id: "user-1",
        email: "student@tsum.ru",
        name: "Иван Студентов",
        role: .student,
        firstName: "Иван",
        lastName: "Студентов",
        department: "IT",
        isActive: true
    )
    
    let mockAdmin = UserResponse(
        id: "user-2",
        email: "admin@tsum.ru",
        name: "Анна Администратор",
        role: .admin,
        firstName: "Анна",
        lastName: "Администратор",
        department: "HR",
        isActive: true
    )

    let mockPost = FeedPost(
        id: "post-1",
        author: mockAdmin,
        content: "Это пример поста для превью. В нем мы обсуждаем важные вопросы корпоративного обучения и последние обновления платформы.",
        images: [],
        attachments: [],
        createdAt: Date().addingTimeInterval(-3600), // 1 час назад
        visibility: .everyone,
        likes: ["user-2", "user-3"],
        comments: [
            FeedComment(id: "comment-1", postId: "post-1", author: mockStudent, content: "Отличный пост!", createdAt: Date().addingTimeInterval(-1800), likes: ["user-4"]),
            FeedComment(id: "comment-2", postId: "post-1", author: mockAdmin, content: "Полностью согласна. Важное обновление.", createdAt: Date().addingTimeInterval(-900), likes: [])
        ],
        tags: ["#обновление", "#обучение"],
        mentions: []
    )
    
    CommentsView(post: mockPost)
}
