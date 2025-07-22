import Foundation
import Combine

protocol FeedServiceProtocol: AnyObject {
    var posts: [FeedPost] { get }
    var isLoading: Bool { get }
    var error: Error? { get }
    var permissions: FeedPermissions { get }
    
    var postsPublisher: AnyPublisher<[FeedPost], Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    var permissionsPublisher: AnyPublisher<FeedPermissions, Never> { get }
    
    func refresh()
    func createPost(
        content: String,
        images: [String],
        attachments: [FeedAttachment],
        visibility: FeedVisibility
    ) async throws
    func deletePost(_ postId: String) async throws
    func toggleLike(postId: String) async throws
    func addComment(to postId: String, content: String) async throws
} 