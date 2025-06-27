import SwiftUI

struct FeedView: View {
    @StateObject private var feedService = FeedService.shared
    @StateObject private var authService = MockAuthService.shared
    @State private var showingCreatePost = false
    @State private var showingSettings = false
    @State private var isRefreshing = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Create post button (only for admins)
                if feedService.permissions.canPost {
                    Button(action: {
                        showingCreatePost = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.pencil")
                            Text("Создать запись")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                // Posts
                if feedService.posts.isEmpty && !feedService.isLoading {
                    EmptyFeedView()
                        .padding(.top, 50)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(feedService.posts) { post in
                            FeedPostCard(post: post)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await refreshFeed()
        }
        .navigationTitle("Лента новостей")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // User avatar
                if let user = authService.currentUser {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(String(user.firstName.prefix(1)).uppercased())
                                .font(.caption)
                                .fontWeight(.semibold)
                        )
                }
            }
            
            if feedService.permissions.canModerate {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreatePost) {
            NavigationStack {
                CreatePostView()
            }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                FeedSettingsView()
            }
        }
    }
    
    private func refreshFeed() async {
        isRefreshing = true
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        feedService.refresh()
        isRefreshing = false
    }
}

struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "newspaper")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Пока нет записей")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Будьте первым, кто поделится новостями!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        FeedView()
    }
}
