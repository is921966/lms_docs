import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var feedService = FeedService.shared
    @StateObject private var authService = MockAuthService.shared

    @State private var postContent = ""
    @State private var selectedVisibility: FeedVisibility = .everyone
    @State private var isPosting = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var canPost: Bool {
        !postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isPosting
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with user info
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text((authService.currentUser?.firstName ?? "?").prefix(1).uppercased())
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    if let user = authService.currentUser {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.headline)
                    } else {
                        Text("Пользователь")
                            .font(.headline)
                    }

                    // Visibility selector
                    Menu {
                        ForEach(feedService.permissions.visibilityOptions, id: \.self) { visibility in
                            Button(action: { selectedVisibility = visibility }) {
                                Label(visibility.title, systemImage: visibility.icon)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: selectedVisibility.icon)
                                .font(.caption)
                            Text(selectedVisibility.title)
                                .font(.caption)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding()

            Divider()

            // Text editor
            TextEditor(text: $postContent)
                .padding(.horizontal)
                .padding(.top, 8)
                .overlay(
                    Group {
                        if postContent.isEmpty {
                            Text("Что у вас нового?")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )

            Spacer()

            // Bottom toolbar
            VStack(spacing: 0) {
                Divider()

                HStack {
                    // Add photo button
                    Button(action: { /* Add photo functionality */ }) {
                        Image(systemName: "photo")
                            .foregroundColor(.blue)
                            .padding(8)
                    }

                    // Add attachment button
                    Button(action: { /* Add attachment functionality */ }) {
                        Image(systemName: "paperclip")
                            .foregroundColor(.blue)
                            .padding(8)
                    }

                    // Add mention button
                    Button(action: { /* Add mention functionality */ }) {
                        Image(systemName: "at")
                            .foregroundColor(.blue)
                            .padding(8)
                    }

                    Spacer()

                    // Character count
                    if !postContent.isEmpty {
                        Text("\(postContent.count)")
                            .font(.caption)
                            .foregroundColor(postContent.count > 500 ? .red : .secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Создать запись")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Отмена") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Опубликовать") {
                    createPost()
                }
                .fontWeight(.semibold)
                .disabled(!canPost)
            }
        }
        .alert("Ошибка", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func createPost() {
        let content = postContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }

        isPosting = true

        Task {
            do {
                try await feedService.createPost(
                    content: content,
                    visibility: selectedVisibility
                )
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isPosting = false
                }
            }
        }
    }
}

#Preview {
    CreatePostView()
}
