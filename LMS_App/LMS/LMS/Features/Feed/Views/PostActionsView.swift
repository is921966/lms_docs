import SwiftUI

struct PostActionsView: View {
    let post: FeedPost
    let isLiked: Bool
    @Binding var showingComments: Bool
    let onLike: () -> Void
    let onShare: () -> Void
    @StateObject private var feedService = FeedService.shared

    var body: some View {
        HStack(spacing: 0) {
            // Like button
            Button(action: onLike) {
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

            // Share button
            Button(action: onShare) {
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
}
