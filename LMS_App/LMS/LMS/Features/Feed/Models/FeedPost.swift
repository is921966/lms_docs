import Foundation
import SwiftUI

// MARK: - Feed Post Model
struct FeedPost: Identifiable, Codable, Equatable {
    var id: String
    var author: UserResponse
    var content: String
    var images: [String]
    var attachments: [FeedAttachment]
    var createdAt: Date
    var visibility: FeedVisibility
    var likes: [String] // Array of user IDs
    var comments: [FeedComment]
    var tags: [String]?
    var mentions: [String]?

    // Equatable conformance
    static func == (lhs: FeedPost, rhs: FeedPost) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Feed Comment
struct FeedComment: Identifiable, Codable {
    let id: String
    let postId: String
    let author: UserResponse
    let content: String
    let createdAt: Date
    var likes: [String] // Array of user IDs

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
    
    static let instructorDefault = FeedPermissions(
        canPost: true,
        canComment: true,
        canLike: true,
        canShare: true,
        canDelete: true,
        canEdit: true,
        canModerate: false,
        visibilityOptions: [.everyone, .students]
    )
    
    static let managerDefault = FeedPermissions(
        canPost: true,
        canComment: true,
        canLike: true,
        canShare: true,
        canDelete: true,
        canEdit: true,
        canModerate: true,
        visibilityOptions: [.everyone, .students, .specific]
    )
    
    static let guestDefault = FeedPermissions(
        canPost: false,
        canComment: false,
        canLike: false,
        canShare: false,
        canDelete: false,
        canEdit: false,
        canModerate: false,
        visibilityOptions: []
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
