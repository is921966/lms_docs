import SwiftUI

/// Лента фидбэков с реакциями и комментариями
/// Доступна всем ролям пользователей в разделе настроек
struct FeedbackFeedView: View {
    @StateObject private var feedbackService = FeedbackService.shared
    @State private var selectedFilter: FeedbackFilter = .all
    @State private var showingNewFeedback = false
    @State private var searchText = ""
    @State private var selectedFeedback: FeedbackItem?
    @State private var isRefreshing = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header с фильтрами
                FeedbackFilterView(
                    selectedFilter: $selectedFilter,
                    searchText: $searchText
                )
                .padding(.horizontal)
                .padding(.top, 8)

                // Лента фидбэков
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredFeedbacks) { feedback in
                            FeedbackCardView(
                                feedback: feedback,
                                onTap: { selectedFeedback = feedback },
                                onReaction: { reaction in
                                    feedbackService.addReaction(to: feedback.id, reaction: reaction)
                                },
                                onComment: { comment in
                                    feedbackService.addComment(to: feedback.id, comment: comment)
                                }
                            )
                            .padding(.horizontal)
                        }

                        if filteredFeedbacks.isEmpty {
                            FeedbackEmptyStateView(filter: selectedFilter)
                                .padding(.top, 60)
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await refreshFeedbacks()
                }
            }
            .navigationTitle("Обратная связь")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewFeedback = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingNewFeedback) {
                FeedbackView()
            }
            .sheet(item: $selectedFeedback) { feedback in
                FeedbackDetailView(feedback: feedback)
            }
            .onAppear {
                Task {
                    await feedbackService.loadFeedbacks()
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var filteredFeedbacks: [FeedbackItem] {
        let feedbacks = feedbackService.feedbacks

        // Фильтрация по типу
        let typeFiltered = switch selectedFilter {
        case .all: feedbacks
        case .bugs: feedbacks.filter { $0.type == .bug }
        case .features: feedbacks.filter { $0.type == .feature }
        case .improvements: feedbacks.filter { $0.type == .improvement }
        case .questions: feedbacks.filter { $0.type == .question }
        case .myFeedbacks: feedbacks.filter { $0.isOwnFeedback }
        }

        // Поиск по тексту
        if searchText.isEmpty {
            return typeFiltered
        } else {
            return typeFiltered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    // MARK: - Methods

    @MainActor
    private func refreshFeedbacks() async {
        isRefreshing = true
        await feedbackService.refreshFeedbacks()
        isRefreshing = false
    }
}

// MARK: - Supporting Views

/// Фильтры для ленты фидбэков
struct FeedbackFilterView: View {
    @Binding var selectedFilter: FeedbackFilter
    @Binding var searchText: String

    var body: some View {
        VStack(spacing: 12) {
            // Поиск
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Поиск отзывов...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            // Фильтры
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FeedbackFilter.allCases, id: \.self) { filter in
                        FeedbackFilterButton(
                            filter: filter,
                            isSelected: selectedFilter == filter,
                            action: { selectedFilter = filter }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

/// Кнопка фильтра
struct FeedbackFilterButton: View {
    let filter: FeedbackFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                Text(filter.title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Карточка отдельного фидбэка
struct FeedbackCardView: View {
    let feedback: FeedbackItem
    let onTap: () -> Void
    let onReaction: (ReactionType) -> Void
    let onComment: (String) -> Void

    @State private var showingCommentField = false
    @State private var newComment = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(feedback.title)
                        .font(.headline)
                        .lineLimit(2)

                    Spacer()

                    FeedbackTypeBadge(type: feedback.type)
                }

                HStack {
                    Text(feedback.author)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(feedback.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    if feedback.status != .open {
                        FeedbackStatusBadge(status: feedback.status)
                    }
                }
            }

            // Описание
            Text(feedback.description)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.primary)

            // Скриншот (если есть)
            if let screenshot = feedback.screenshot {
                if let imageData = Data(base64Encoded: screenshot),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 150)
                        .clipped()
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }

            // Реакции и комментарии
            HStack {
                // Реакции
                HStack(spacing: 16) {
                    ReactionButton(
                        type: .like,
                        count: feedback.reactions.like,
                        isSelected: feedback.userReaction == .like,
                        action: { onReaction(.like) }
                    )

                    ReactionButton(
                        type: .dislike,
                        count: feedback.reactions.dislike,
                        isSelected: feedback.userReaction == .dislike,
                        action: { onReaction(.dislike) }
                    )

                    ReactionButton(
                        type: .heart,
                        count: feedback.reactions.heart,
                        isSelected: feedback.userReaction == .heart,
                        action: { onReaction(.heart) }
                    )

                    ReactionButton(
                        type: .fire,
                        count: feedback.reactions.fire,
                        isSelected: feedback.userReaction == .fire,
                        action: { onReaction(.fire) }
                    )
                }

                Spacer()

                // Комментарии
                Button(action: { showingCommentField.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "message")
                        Text("\(feedback.comments.count)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }

            // Поле для нового комментария
            if showingCommentField {
                HStack {
                    TextField("Добавить комментарий...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Отправить") {
                        onComment(newComment)
                        newComment = ""
                        showingCommentField = false
                    }
                    .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .transition(.slide)
            }

            // Последние комментарии (максимум 2)
            if !feedback.comments.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(feedback.comments.prefix(2)) { comment in
                        FeedbackCommentView(comment: comment)
                    }

                    if feedback.comments.count > 2 {
                        Button("Показать все комментарии (\(feedback.comments.count))") {
                            onTap()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
    }
}

/// Кнопка реакции
struct ReactionButton: View {
    let type: ReactionType
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(type.emoji)
                    .font(.system(size: 16))
                if !isEmpty {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Отображение комментария
struct FeedbackCommentView: View {
    let comment: FeedbackComment

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(comment.author)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(comment.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()
            }

            Text(comment.text)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

/// Пустое состояние ленты
struct FeedbackEmptyStateView: View {
    let filter: FeedbackFilter

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.gray)

            Text(emptyStateTitle)
                .font(.headline)
                .foregroundColor(.primary)

            Text(emptyStateDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var emptyStateTitle: String {
        switch filter {
        case .all: return "Пока нет отзывов"
        case .bugs: return "Нет сообщений об ошибках"
        case .features: return "Нет предложений функций"
        case .improvements: return "Нет предложений улучшений"
        case .questions: return "Нет вопросов"
        case .myFeedbacks: return "У вас нет отзывов"
        }
    }

    private var emptyStateDescription: String {
        switch filter {
        case .all: return "Станьте первым, кто оставит отзыв!"
        case .bugs: return "Отлично! Кажется, ошибок пока не найдено."
        case .features: return "Поделитесь идеями новых функций."
        case .improvements: return "Есть идеи, как сделать приложение лучше?"
        case .questions: return "Задавайте вопросы - мы поможем!"
        case .myFeedbacks: return "Поделитесь своими мыслями о приложении."
        }
    }
}

enum FeedbackFilter: CaseIterable {
    case all, bugs, features, improvements, questions, myFeedbacks

    var title: String {
        switch self {
        case .all: return "Все"
        case .bugs: return "Ошибки"
        case .features: return "Функции"
        case .improvements: return "Улучшения"
        case .questions: return "Вопросы"
        case .myFeedbacks: return "Мои"
        }
    }

    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .bugs: return "ladybug"
        case .features: return "star"
        case .improvements: return "arrow.up.circle"
        case .questions: return "questionmark.circle"
        case .myFeedbacks: return "person"
        }
    }
}
