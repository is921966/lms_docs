import SwiftUI

struct PostContentView: View {
    let post: FeedPost

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            // Tags
            if let tags = post.tags, !tags.isEmpty {
                FeedFlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

// Simple flow layout for tags
struct FeedFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: result.positions[index].x + bounds.minX,
                                    y: result.positions[index].y + bounds.minY),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Post Images View
struct PostImagesView: View {
    let images: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(images, id: \.self) { _ in
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
}

// MARK: - Post Attachments View
struct PostAttachmentsView: View {
    let attachments: [FeedAttachment]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(attachments) { attachment in
                FeedAttachmentView(attachment: attachment)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

// MARK: - Feed Attachment View
struct FeedAttachmentView: View {
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

// MARK: - Post Stats View
struct PostStatsView: View {
    let post: FeedPost

    var body: some View {
        HStack {
            if post.likes.count > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("\(post.likes.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if post.comments.count > 0 {
                Text("\(post.comments.count) комментариев")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Post Comments Preview
struct PostCommentsPreview: View {
    let post: FeedPost
    @Binding var showingComments: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(post.comments.prefix(2)) { comment in
                FeedCommentPreviewView(comment: comment)
            }

            if post.comments.count > 2 {
                Button(action: { showingComments = true }) {
                    Text("Показать все комментарии (\(post.comments.count))")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
    }
}

// MARK: - Feed Comment Preview View
struct FeedCommentPreviewView: View {
    let comment: FeedComment

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(comment.author.name.prefix(1).uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(comment.author.name)
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
