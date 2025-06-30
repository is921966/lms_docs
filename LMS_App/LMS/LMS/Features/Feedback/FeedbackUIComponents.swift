import SwiftUI

/// Бейдж типа фидбэка
struct FeedbackTypeBadge: View {
    let type: FeedbackType

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.icon)
                .font(.caption2)
            Text(type.title)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
        .foregroundColor(.white)
    }

    private var backgroundColor: Color {
        switch type {
        case .bug: return .red
        case .feature: return .blue
        case .improvement: return .green
        case .question: return .orange
        }
    }
}

/// Бейдж статуса фидбэка
struct FeedbackStatusBadge: View {
    let status: FeedbackStatus

    var body: some View {
        Text(status.title)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor.opacity(0.2))
            )
            .foregroundColor(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(backgroundColor, lineWidth: 1)
            )
    }

    private var backgroundColor: Color {
        switch status {
        case .open: return .blue
        case .inProgress: return .orange
        case .resolved: return .green
        case .closed: return .gray
        }
    }
}

/// Отображение скриншота в фидбэке
struct FeedbackScreenshotView: View {
    let screenshot: String
    @State private var showingFullScreen = false

    var body: some View {
        Button(action: { showingFullScreen = true }) {
            if let imageData = Data(base64Encoded: screenshot),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingFullScreen) {
            FeedbackScreenshotFullScreenView(screenshot: screenshot)
        }
    }
}

/// Полноэкранный просмотр скриншота
struct FeedbackScreenshotFullScreenView: View {
    let screenshot: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if let imageData = Data(base64Encoded: screenshot),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    VStack {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Не удалось загрузить изображение")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Скриншот")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

/// Детальный просмотр фидбэка
struct FeedbackDetailView: View {
    let feedback: FeedbackItem
    @Environment(\.dismiss) private var dismiss
    @StateObject private var feedbackService = FeedbackService.shared
    @State private var newComment = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(feedback.title)
                                .font(.title2)
                                .fontWeight(.bold)

                            Spacer()

                            FeedbackTypeBadge(type: feedback.type)
                        }

                        HStack {
                            Text(feedback.author)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("•")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text(feedback.createdAt, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Spacer()

                            if feedback.status != .open {
                                FeedbackStatusBadge(status: feedback.status)
                            }
                        }
                    }

                    Divider()

                    // Описание
                    Text(feedback.description)
                        .font(.body)

                    // Скриншот
                    if let screenshot = feedback.screenshot {
                        FeedbackScreenshotView(screenshot: screenshot)
                            .frame(maxHeight: 200)
                    }

                    // Реакции
                    HStack(spacing: 20) {
                        ReactionButton(
                            type: .like,
                            count: feedback.reactions.like,
                            isSelected: feedback.userReaction == .like
                        )                            { feedbackService.addReaction(to: feedback.id, reaction: .like) }

                        ReactionButton(
                            type: .dislike,
                            count: feedback.reactions.dislike,
                            isSelected: feedback.userReaction == .dislike
                        )                            { feedbackService.addReaction(to: feedback.id, reaction: .dislike) }

                        ReactionButton(
                            type: .heart,
                            count: feedback.reactions.heart,
                            isSelected: feedback.userReaction == .heart
                        )                            { feedbackService.addReaction(to: feedback.id, reaction: .heart) }

                        ReactionButton(
                            type: .fire,
                            count: feedback.reactions.fire,
                            isSelected: feedback.userReaction == .fire
                        )                            { feedbackService.addReaction(to: feedback.id, reaction: .fire) }

                        Spacer()
                    }
                    .padding(.vertical)

                    Divider()

                    // Комментарии
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Комментарии (\(feedback.comments.count))")
                            .font(.headline)

                        ForEach(feedback.comments) { comment in
                            CommentDetailView(comment: comment)
                        }

                        if feedback.comments.isEmpty {
                            Text("Пока нет комментариев")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.vertical)
                        }
                    }

                    // Поле для нового комментария
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Добавить комментарий")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        HStack {
                            TextField("Ваш комментарий...", text: $newComment, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)

                            Button("Отправить") {
                                feedbackService.addComment(to: feedback.id, comment: newComment)
                                newComment = ""
                            }
                            .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Детали отзыва")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Детальное отображение комментария
struct CommentDetailView: View {
    let comment: FeedbackComment

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(comment.author)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        if comment.isAdmin {
                            Text("ADMIN")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }

                        Spacer()

                        Text(comment.createdAt, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Text(comment.text)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}
