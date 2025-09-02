//
//  PostRow.swift
//  LMS
//
//  Row view for displaying posts
//

import SwiftUI

struct PostRow: View {
    let post: FeedPost
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Author info
                HStack {
                    Circle()
                        .fill(avatarColor(for: post.author.role))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(post.author.name.prefix(1).uppercased())
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.author.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(formatDate(post.createdAt))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Content preview
                Text(post.content)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Stats
                if post.likes.count > 0 || post.comments.count > 0 {
                    HStack(spacing: 16) {
                        if post.likes.count > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                Text("\(post.likes.count)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if post.comments.count > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.left")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Text("\(post.comments.count)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func avatarColor(for role: UserRole) -> Color {
        switch role {
        case .student: return .green
        case .instructor: return .blue
        case .manager: return .orange
        case .admin: return .red
        case .superAdmin: return .purple
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "d MMM"
        }
        
        return formatter.string(from: date)
    }
} 