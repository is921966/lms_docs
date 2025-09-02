//
//  TelegramPostDetailView.swift
//  LMS
//
//  Детальный просмотр поста в стиле Telegram
//

import SwiftUI
import WebKit

struct TelegramPostDetailView: View {
    let post: FeedPost
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showShareSheet = false
    @State private var isLiked = false
    @State private var showComments = false
    @State private var newComment = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var headerOpacity: Double = 0
    
    init(post: FeedPost) {
        self.post = post
        _isLiked = State(initialValue: post.likes.contains(MockAuthService.shared.currentUser?.id ?? ""))
    }
    
    var body: some View {
        ZStack {
            // Telegram-style background
            telegramBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom navigation bar with blur effect
                navigationBar
                    .background(
                        VisualEffectBlur(blurStyle: .systemThinMaterial)
                            .opacity(headerOpacity)
                            .ignoresSafeArea(edges: .top)
                    )
                
                // Content with scrolling
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            // Add padding for navigation bar
                            Color.clear.frame(height: 20)
                            
                            // Main content container
                            VStack(spacing: 0) {
                                // Post header with author info
                                postHeader
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                
                                // Main post content
                                postContent
                                    .padding(.horizontal)
                                
                                // Attachments
                                if !post.images.isEmpty || !post.attachments.isEmpty {
                                    attachmentsSection
                                        .padding(.top, 16)
                                }
                                
                                // Reactions and stats
                                reactionsBar
                                    .padding(.top, 20)
                                
                                // Comments section
                                if showComments || !post.comments.isEmpty {
                                    commentsSection
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onChange(of: geo.frame(in: .global).minY) { value in
                                            // Calculate header opacity based on scroll
                                            let offset = value - 100
                                            headerOpacity = min(1, max(0, -offset / 50))
                                        }
                                }
                            )
                        }
                        .id("scrollView")
                    }
                }
                
                // Bottom action bar or comment input
                if showComments {
                    commentInputBar
                        .transition(.move(edge: .bottom))
                } else {
                    bottomActionBar
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [post.content])
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeOut(duration: 0.3)) {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                keyboardHeight = 0
            }
        }
    }
    
    // MARK: - Background
    
    private var telegramBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: colorScheme == .dark ? "1c1c1e" : "f2f2f7"),
                Color(hex: colorScheme == .dark ? "000000" : "e5e5ea")
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Navigation Bar
    
    private var navigationBar: some View {
        HStack(spacing: 16) {
            // Back button
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(hex: "007AFF"))
                    .frame(width: 30, height: 30)
            }
            
            // Channel info
            HStack(spacing: 10) {
                channelAvatar
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(getChannelName())
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(formatDetailedDate(post.createdAt))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 20) {
                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "007AFF"))
                }
                
                Menu {
                    Button {
                        copyLink()
                    } label: {
                        Label("Скопировать ссылку", systemImage: "link")
                    }
                    
                    Button {
                        forward()
                    } label: {
                        Label("Переслать", systemImage: "arrowshape.turn.up.right")
                    }
                    
                    if post.author.id == MockAuthService.shared.currentUser?.id {
                        Divider()
                        
                        Button {
                            editPost()
                        } label: {
                            Label("Редактировать", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            deletePost()
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "007AFF"))
                        .frame(width: 30, height: 30)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color(UIColor.systemBackground)
                .opacity(0.001) // Almost transparent to allow blur to show through
        )
    }
    
    // MARK: - Channel Avatar
    
    private var channelAvatar: some View {
        Group {
            if let channelType = getChannelType() {
                Circle()
                    .fill(channelType.color)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(channelType.icon)
                            .font(.system(size: 18))
                    )
            } else {
                Circle()
                    .fill(avatarColor(for: post.author.role))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(post.author.name.prefix(1).uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
        }
    }
    
    // MARK: - Post Header
    
    private var postHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            channelAvatar
                .frame(width: 42, height: 42)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(post.author.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    if let channelType = getChannelType() {
                        Text(channelType.name)
                            .font(.system(size: 13))
                            .foregroundColor(channelType.color)
                        
                        Text("•")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(formatTime(post.createdAt))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Post Content
    
    private var postContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Debug info
            #if DEBUG
            if post.content.isEmpty {
                Text("DEBUG: Post content is empty!")
                    .foregroundColor(.red)
                    .font(.caption)
            } else {
                Text("DEBUG: Content length: \(post.content.count) chars")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
            #endif
            
            // Check if content is HTML
            if post.metadata?["contentType"] == "html" || post.content.contains("<") {
                HTMLContentWrapper(htmlContent: post.content)
                    .frame(minHeight: 300) // Добавляем минимальную высоту
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .padding(.vertical, 8)
            } else if post.content.contains("# ") || post.content.contains("## ") {
                // Markdown content
                MarkdownContentView(text: post.content)
                    .font(.system(size: 16))
            } else {
                // Plain text with Telegram-style formatting
                Text(post.content)
                    .font(.system(size: 16))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Tags with Telegram style
            if let tags = post.tags, !tags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "007AFF"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(hex: "007AFF").opacity(0.15))
                            )
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Attachments Section
    
    private var attachmentsSection: some View {
        VStack(spacing: 12) {
            // Images with Telegram-style preview
            if !post.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(post.images, id: \.self) { imageName in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 200, height: 150)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo")
                                            .font(.system(size: 32))
                                            .foregroundColor(.gray)
                                        Text(imageName)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Files with Telegram-style design
            if !post.attachments.isEmpty {
                VStack(spacing: 8) {
                    ForEach(post.attachments) { attachment in
                        HStack(spacing: 12) {
                            // File icon with gradient background
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "007AFF"),
                                                Color(hex: "0051D5")
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: iconForAttachment(attachment))
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(attachment.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                HStack(spacing: 4) {
                                    if let size = attachment.size {
                                        Text(formatFileSize(size))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("•")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(attachment.type.rawValue.capitalized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: { downloadAttachment(attachment) }) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: "007AFF"))
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Reactions Bar
    
    private var reactionsBar: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.horizontal)
            
            HStack {
                // Views counter
                HStack(spacing: 6) {
                    Image(systemName: "eye")
                        .font(.system(size: 14))
                    Text("\(post.metadata?["views"] as? Int ?? Int.random(in: 100...1000))")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                // Reactions
                HStack(spacing: 20) {
                    // Like button with animation
                    Button(action: toggleLike) {
                        HStack(spacing: 4) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 18))
                                .foregroundColor(isLiked ? Color(hex: "FF3B30") : .secondary)
                                .scaleEffect(isLiked ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLiked)
                            
                            if !post.likes.isEmpty || isLiked {
                                Text("\(post.likes.count + (isLiked && !post.likes.contains(MockAuthService.shared.currentUser?.id ?? "") ? 1 : 0))")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(isLiked ? Color(hex: "FF3B30") : .secondary)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Comments button
                    Button(action: { 
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showComments.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: showComments ? "bubble.left.fill" : "bubble.left")
                                .font(.system(size: 18))
                                .foregroundColor(showComments ? Color(hex: "007AFF") : .secondary)
                            
                            if !post.comments.isEmpty {
                                Text("\(post.comments.count)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(showComments ? Color(hex: "007AFF") : .secondary)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            Divider()
                .padding(.horizontal)
        }
    }
    
    // MARK: - Comments Section
    
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Comments header
            HStack {
                Text("Комментарии")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                if !post.comments.isEmpty {
                    Text("\(post.comments.count)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Comments list
            VStack(spacing: 0) {
                ForEach(post.comments) { comment in
                    VStack(spacing: 0) {
                        HStack(alignment: .top, spacing: 10) {
                            // Comment author avatar
                            Circle()
                                .fill(avatarColor(for: comment.author.role))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(comment.author.name.prefix(1).uppercased())
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                // Author and time
                                HStack(spacing: 6) {
                                    Text(comment.author.name)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("•")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                    
                                    Text(timeAgo(from: comment.createdAt))
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                
                                // Comment text
                                Text(comment.content)
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                // Comment reactions
                                if !comment.likes.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(hex: "FF3B30"))
                                        
                                        Text("\(comment.likes.count)")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            
                            Spacer()
                            
                            // Like comment button
                            Button(action: { likeComment(comment) }) {
                                Image(systemName: comment.likes.contains(MockAuthService.shared.currentUser?.id ?? "") ? "heart.fill" : "heart")
                                    .font(.system(size: 14))
                                    .foregroundColor(comment.likes.contains(MockAuthService.shared.currentUser?.id ?? "") ? Color(hex: "FF3B30") : .secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        
                        Divider()
                            .padding(.leading, 62)
                    }
                }
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Bottom Action Bar
    
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 0) {
                Button(action: { 
                    withAnimation {
                        showComments = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 18))
                        Text("Комментировать")
                            .font(.system(size: 15))
                    }
                    .foregroundColor(Color(hex: "007AFF"))
                    .frame(maxWidth: .infinity)
                }
                
                Divider()
                    .frame(height: 20)
                    .padding(.horizontal, 20)
                
                Button(action: { showShareSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "paperplane")
                            .font(.system(size: 18))
                        Text("Поделиться")
                            .font(.system(size: 15))
                    }
                    .foregroundColor(Color(hex: "007AFF"))
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
        }
    }
    
    // MARK: - Comment Input Bar
    
    private var commentInputBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                // Attach button
                Button(action: attachFile) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                
                // Input field with Telegram style
                HStack(spacing: 8) {
                    TextField("Написать комментарий...", text: $newComment)
                        .font(.system(size: 16))
                    
                    // Emoji button
                    Button(action: showEmojiPicker) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                
                // Send button
                Button(action: sendComment) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(newComment.isEmpty ? .secondary : Color(hex: "007AFF"))
                        .rotationEffect(.degrees(45))
                }
                .disabled(newComment.isEmpty)
                .animation(.easeInOut(duration: 0.2), value: newComment.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemBackground))
        }
        .padding(.bottom, keyboardHeight)
        .animation(.easeOut(duration: 0.3), value: keyboardHeight)
    }
    
    // MARK: - Helper Methods
    
    private func getChannelType() -> ChannelType? {
        // Determine channel type from post metadata or tags
        if let type = post.metadata?["type"] as? String {
            switch type {
            case "release": return .releases
            case "sprint": return .sprints
            case "methodology": return .methodology
            case "course": return .courses
            case "admin": return .admin
            case "hr": return .hr
            case "course_assignment": return .myCourses
            case "user_post": return .userPosts
            default: break
            }
        }
        
        // Check tags as fallback
        if let tags = post.tags {
            if tags.contains("#release") || tags.contains("#релиз") { return .releases }
            if tags.contains("#sprint") || tags.contains("#спринт") { return .sprints }
            if tags.contains("#methodology") || tags.contains("#методология") { return .methodology }
            if tags.contains("#course") || tags.contains("#курс") { return .courses }
            if tags.contains("#admin") || tags.contains("#администратор") { return .admin }
            if tags.contains("#hr") { return .hr }
            if tags.contains("#мойкурс") { return .myCourses }
        }
        
        return nil
    }
    
    private func getChannelName() -> String {
        if let channelType = getChannelType() {
            return channelType.name
        }
        return post.author.name
    }
    
    private func avatarColor(for role: UserRole) -> Color {
        switch role {
        case .student: return Color(hex: "34C759")
        case .instructor: return Color(hex: "007AFF")
        case .manager: return Color(hex: "FF9500")
        case .admin: return Color(hex: "FF3B30")
        case .superAdmin: return Color(hex: "AF52DE")
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDetailedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        
        if Calendar.current.isDateInToday(date) {
            return "сегодня в \(formatTime(date))"
        } else if Calendar.current.isDateInYesterday(date) {
            return "вчера в \(formatTime(date))"
        } else {
            formatter.dateFormat = "d MMMM в HH:mm"
            return formatter.string(from: date)
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func iconForAttachment(_ attachment: FeedAttachment) -> String {
        switch attachment.type {
        case .document: return "doc.text.fill"
        case .video: return "play.rectangle.fill"
        case .link: return "link"
        case .course: return "book.fill"
        case .test: return "checkmark.circle.fill"
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        return formatter.string(fromByteCount: bytes)
    }
    
    // MARK: - Actions
    
    private func toggleLike() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isLiked.toggle()
        }
        
        // Log action
        ComprehensiveLogger.shared.log(.ui, .info, "Post like toggled", details: [
            "postId": post.id,
            "isLiked": isLiked
        ])
        
        // Here would be the API call to update likes
    }
    
    private func likeComment(_ comment: FeedComment) {
        // Log action
        ComprehensiveLogger.shared.log(.ui, .info, "Comment like toggled", details: [
            "commentId": comment.id,
            "postId": post.id
        ])
        
        // Here would be the API call to update comment likes
    }
    
    private func sendComment() {
        guard !newComment.isEmpty else { return }
        
        // Log action
        ComprehensiveLogger.shared.log(.ui, .info, "Comment sent", details: [
            "postId": post.id,
            "commentLength": newComment.count
        ])
        
        // Here would be the API call to send comment
        newComment = ""
        
        // Dismiss keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func copyLink() {
        UIPasteboard.general.string = "lms://post/\(post.id)"
        
        ComprehensiveLogger.shared.log(.ui, .info, "Post link copied", details: [
            "postId": post.id
        ])
    }
    
    private func forward() {
        showShareSheet = true
    }
    
    private func editPost() {
        ComprehensiveLogger.shared.log(.ui, .info, "Edit post requested", details: [
            "postId": post.id
        ])
    }
    
    private func deletePost() {
        ComprehensiveLogger.shared.log(.ui, .info, "Delete post requested", details: [
            "postId": post.id
        ])
    }
    
    private func downloadAttachment(_ attachment: FeedAttachment) {
        ComprehensiveLogger.shared.log(.ui, .info, "Download attachment", details: [
            "attachmentId": attachment.id,
            "attachmentName": attachment.name
        ])
    }
    
    private func attachFile() {
        ComprehensiveLogger.shared.log(.ui, .info, "Attach file requested")
    }
    
    private func showEmojiPicker() {
        ComprehensiveLogger.shared.log(.ui, .info, "Emoji picker requested")
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        return rows.reduce(CGSize.zero) { size, row in
            CGSize(width: max(size.width, row.width), 
                   height: size.height + row.height + (size.height > 0 ? spacing : 0))
        }
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        
        for row in rows {
            var x = bounds.minX
            
            for item in row.items {
                item.subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += item.size.width + spacing
            }
            
            y += row.height + spacing
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var x: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > (proposal.width ?? .infinity) && !currentRow.items.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
                x = 0
            }
            
            currentRow.items.append(Item(subview: subview, size: size))
            x += size.width + spacing
        }
        
        if !currentRow.items.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private struct Row {
        var items: [Item] = []
        
        var width: CGFloat {
            items.reduce(0) { $0 + $1.size.width } + CGFloat(items.count - 1) * 8
        }
        
        var height: CGFloat {
            items.map(\.size.height).max() ?? 0
        }
    }
    
    private struct Item {
        let subview: LayoutSubview
        let size: CGSize
    }
}

// MARK: - HTML Content Wrapper

struct HTMLContentWrapper: UIViewRepresentable {
    let htmlContent: String
    @State private var dynamicHeight: CGFloat = 200
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = true // Включаем прокрутку
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        // Настройки для автоматической высоты
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        // Внедряем JavaScript для отслеживания высоты
        let script = """
            var observer = new ResizeObserver(function(entries) {
                window.webkit.messageHandlers.heightHandler.postMessage({
                    height: document.body.scrollHeight
                });
            });
            observer.observe(document.body);
        """
        
        let userScript = WKUserScript(
            source: script,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        
        webView.configuration.userContentController.addUserScript(userScript)
        webView.configuration.userContentController.add(
            context.coordinator,
            name: "heightHandler"
        )
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let wrappedHtml = wrapHTMLContent(htmlContent)
        webView.loadHTMLString(wrappedHtml, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: HTMLContentWrapper
        
        init(parent: HTMLContentWrapper) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated {
                if let url = navigationAction.request.url {
                    UIApplication.shared.open(url)
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Измеряем высоту контента после загрузки
            webView.evaluateJavaScript("document.body.scrollHeight") { (height, error) in
                if let height = height as? CGFloat {
                    DispatchQueue.main.async {
                        // Обновляем constraint высоты WebView
                        webView.constraints.forEach { constraint in
                            if constraint.firstAttribute == .height {
                                constraint.constant = height
                            }
                        }
                        
                        // Если нет constraint, создаем его
                        if !webView.constraints.contains(where: { $0.firstAttribute == .height }) {
                            webView.heightAnchor.constraint(equalToConstant: height).isActive = true
                        }
                    }
                }
            }
        }
        
        // Обработка сообщений от JavaScript о изменении высоты
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "heightHandler",
               let dict = message.body as? [String: Any],
               let height = dict["height"] as? CGFloat {
                DispatchQueue.main.async { [weak self] in
                    self?.parent.dynamicHeight = height
                }
            }
        }
    }
    
    private func wrapHTMLContent(_ content: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                body {
                    font-family: -apple-system, system-ui;
                    font-size: 16px;
                    line-height: 1.5;
                    color: #000000;
                    background-color: transparent;
                    margin: 0;
                    padding: 12px;
                    -webkit-text-size-adjust: 100%;
                    word-wrap: break-word;
                    overflow-wrap: break-word;
                }
                h1, h2, h3 { 
                    font-weight: 600; 
                    margin-top: 0.5em;
                    margin-bottom: 0.5em;
                }
                h1 { font-size: 24px; }
                h2 { font-size: 20px; }
                h3 { font-size: 18px; }
                p { margin: 0.5em 0; }
                ul, ol { 
                    padding-left: 20px; 
                    margin: 0.5em 0;
                }
                li { margin: 0.25em 0; }
                a { color: #007AFF; text-decoration: none; }
                code {
                    background-color: #F2F2F7;
                    padding: 2px 4px;
                    border-radius: 3px;
                    font-family: monospace;
                    font-size: 14px;
                }
                pre {
                    background-color: #F2F2F7;
                    padding: 10px;
                    border-radius: 5px;
                    overflow-x: auto;
                }
                blockquote {
                    border-left: 3px solid #007AFF;
                    margin: 0.5em 0;
                    padding-left: 10px;
                    color: #8E8E93;
                }
                strong { font-weight: 600; }
                em { font-style: italic; }
                
                /* Предотвращаем горизонтальную прокрутку */
                * {
                    max-width: 100%;
                    box-sizing: border-box;
                }
                
                img {
                    max-width: 100%;
                    height: auto;
                }
                
                table {
                    width: 100%;
                    border-collapse: collapse;
                }
                
                td, th {
                    padding: 8px;
                    border: 1px solid #E5E5EA;
                }
            </style>
        </head>
        <body>
            \(content)
        </body>
        </html>
        """
    }
}



// MARK: - Visual Effect Blur

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}





 