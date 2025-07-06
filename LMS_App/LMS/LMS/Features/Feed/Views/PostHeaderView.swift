import SwiftUI

struct PostHeaderView: View {
    let post: FeedPost
    @Binding var showingOptions: Bool
    let canShowOptions: Bool

    var body: some View {
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

                    if post.isEdited {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("изменено")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Options button
            if canShowOptions {
                Button(action: { showingOptions = true }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                        .padding(8)
                }
            }
        }
        .padding()
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
