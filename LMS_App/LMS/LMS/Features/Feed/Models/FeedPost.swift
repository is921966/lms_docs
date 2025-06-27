import Foundation
import SwiftUI

// MARK: - Feed Post Model
struct FeedPost: Identifiable, Codable {
    let id: String
    let authorId: String
    let authorName: String
    let authorRole: UserRole
    let authorAvatar: String?
    let content: String
    let images: [String]
    let attachments: [FeedAttachment]
    let createdAt: Date
    let updatedAt: Date
    var likes: [String] // User IDs who liked
    var comments: [FeedComment]
    let visibility: FeedVisibility
    let tags: [String]
    let mentions: [String] // User IDs mentioned
    
    var likesCount: Int { likes.count }
    var commentsCount: Int { comments.count }
    var isEdited: Bool { updatedAt > createdAt }
}

// MARK: - Feed Comment
struct FeedComment: Identifiable, Codable {
    let id: String
    let postId: String
    let authorId: String
    let authorName: String
    let authorAvatar: String?
    let content: String
    let createdAt: Date
    var likes: [String]
    
    var likesCount: Int { likes.count }
}

// MARK: - Feed Attachment
struct FeedAttachment: Identifiable, Codable {
    let id: String
    let type: AttachmentType
    let url: String
    let name: String
    let size: Int64?
    let thumbnailUrl: String?
    
    enum AttachmentType: String, Codable, CaseIterable {
        case document = "document"
        case video = "video"
        case link = "link"
        case course = "course"
        case test = "test"
    }
}

// MARK: - Feed Visibility
enum FeedVisibility: String, Codable, CaseIterable {
    case everyone = "everyone"
    case students = "students"
    case admins = "admins"
    case specific = "specific" // Specific roles or users
    
    var icon: String {
        switch self {
        case .everyone: return "globe"
        case .students: return "studentdesk"
        case .admins: return "shield"
        case .specific: return "person.2"
        }
    }
    
    var title: String {
        switch self {
        case .everyone: return "Все пользователи"
        case .students: return "Только студенты"
        case .admins: return "Только администраторы"
        case .specific: return "Определенные пользователи"
        }
    }
}

// MARK: - Feed Permissions
struct FeedPermissions: Codable {
    let canPost: Bool
    let canComment: Bool
    let canLike: Bool
    let canShare: Bool
    let canDelete: Bool
    let canEdit: Bool
    let canModerate: Bool
    let visibilityOptions: [FeedVisibility]
    
    static let studentDefault = FeedPermissions(
        canPost: false,
        canComment: true,
        canLike: true,
        canShare: true,
        canDelete: false,
        canEdit: false,
        canModerate: false,
        visibilityOptions: []
    )
    
    static let adminDefault = FeedPermissions(
        canPost: true,
        canComment: true,
        canLike: true,
        canShare: true,
        canDelete: true,
        canEdit: true,
        canModerate: true,
        visibilityOptions: FeedVisibility.allCases
    )
}

// MARK: - Feed Activity
struct FeedActivity: Identifiable, Codable {
    let id: String
    let type: ActivityType
    let actorId: String
    let actorName: String
    let targetType: String
    let targetId: String
    let targetName: String
    let createdAt: Date
    
    enum ActivityType: String, Codable {
        case liked = "liked"
        case commented = "commented"
        case shared = "shared"
        case mentioned = "mentioned"
        case courseCompleted = "course_completed"
        case testPassed = "test_passed"
        case achievementUnlocked = "achievement_unlocked"
    }
} 