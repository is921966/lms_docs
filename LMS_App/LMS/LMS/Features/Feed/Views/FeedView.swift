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
#Preview {
    FeedView()
}
