import XCTest
import Combine
@testable import LMS

@MainActor
final class FeedViewModelTests: XCTestCase {
    
    private var sut: FeedViewModel!
    private var mockService: MockFeedServiceProtocol!
    private var mockCoordinator: MockFeedCoordinator!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockFeedServiceProtocol()
        mockCoordinator = MockFeedCoordinator()
        sut = FeedViewModel(feedService: mockService, coordinator: mockCoordinator)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        mockCoordinator = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testInitialState() {
        XCTAssertTrue(sut.posts.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
        XCTAssertTrue(sut.searchText.isEmpty)
        XCTAssertNil(sut.selectedVisibilityFilter)
    }
    
    func testPostsBinding() {
        // Given
        let expectation = expectation(description: "Posts updated")
        let testPosts = [
            FeedPost.mock(id: "1", content: "Test 1"),
            FeedPost.mock(id: "2", content: "Test 2")
        ]
        
        sut.$posts
            .dropFirst()
            .sink { posts in
                XCTAssertEqual(posts.count, 2)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        mockService.posts = testPosts
        
        // Then
        waitForExpectations(timeout: 1.0)
    }
    
    func testFilteredPostsBySearch() {
        // Given
        sut.posts = [
            FeedPost.mock(id: "1", content: "Swift programming"),
            FeedPost.mock(id: "2", content: "iOS development"),
            FeedPost.mock(id: "3", content: "SwiftUI tutorial")
        ]
        
        // When
        sut.searchText = "Swift"
        
        // Then
        XCTAssertEqual(sut.filteredPosts.count, 2)
        XCTAssertTrue(sut.filteredPosts.allSatisfy { $0.content.contains("Swift") })
    }
    
    func testFilteredPostsByVisibility() {
        // Given
        sut.posts = [
            FeedPost.mock(id: "1", visibility: .everyone),
            FeedPost.mock(id: "2", visibility: .department),
            FeedPost.mock(id: "3", visibility: .everyone)
        ]
        
        // When
        sut.selectedVisibilityFilter = .everyone
        
        // Then
        XCTAssertEqual(sut.filteredPosts.count, 2)
        XCTAssertTrue(sut.filteredPosts.allSatisfy { $0.visibility == .everyone })
    }
    
    func testShowPostDetailNavigation() {
        // Given
        let post = FeedPost.mock(id: "1", content: "Test")
        
        // When
        sut.showPostDetail(post)
        
        // Then
        XCTAssertTrue(mockCoordinator.showPostDetailCalled)
        XCTAssertEqual(mockCoordinator.lastShownPost?.id, post.id)
    }
    
    func testShowCreatePostNavigation() {
        // When
        sut.showCreatePost()
        
        // Then
        XCTAssertTrue(mockCoordinator.showCreatePostCalled)
    }
    
    func testRefresh() {
        // When
        sut.refresh()
        
        // Then
        XCTAssertTrue(mockService.refreshCalled)
    }
    
    func testCreatePost() async throws {
        // Given
        let content = "New post"
        let images = ["image1.jpg"]
        let visibility = FeedVisibility.everyone
        
        // When
        try await sut.createPost(
            content: content,
            images: images,
            attachments: [],
            visibility: visibility
        )
        
        // Then
        XCTAssertTrue(mockService.createPostCalled)
        XCTAssertEqual(mockService.lastCreatedContent, content)
        XCTAssertEqual(mockService.lastCreatedImages, images)
        XCTAssertEqual(mockService.lastCreatedVisibility, visibility)
    }
    
    func testToggleLike() async throws {
        // Given
        let postId = "123"
        
        // When
        try await sut.toggleLike(postId: postId)
        
        // Then
        XCTAssertTrue(mockService.toggleLikeCalled)
        XCTAssertEqual(mockService.lastToggledLikePostId, postId)
    }
    
    func testErrorHandling() async {
        // Given
        mockService.shouldThrowError = true
        
        // When/Then
        do {
            try await sut.createPost(content: "Test", images: [], attachments: [], visibility: .everyone)
            XCTFail("Should throw error")
        } catch {
            XCTAssertNotNil(sut.error)
        }
    }
}

// MARK: - Mocks

private class MockFeedServiceProtocol: FeedServiceProtocol {
    @Published var posts: [FeedPost] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var permissions = FeedPermissions.mock()
    
    var postsPublisher: AnyPublisher<[FeedPost], Never> {
        $posts.eraseToAnyPublisher()
    }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<Error?, Never> {
        $error.eraseToAnyPublisher()
    }
    
    var permissionsPublisher: AnyPublisher<FeedPermissions, Never> {
        $permissions.eraseToAnyPublisher()
    }
    
    var refreshCalled = false
    var createPostCalled = false
    var toggleLikeCalled = false
    var shouldThrowError = false
    
    var lastCreatedContent: String?
    var lastCreatedImages: [String]?
    var lastCreatedVisibility: FeedVisibility?
    var lastToggledLikePostId: String?
    
    func refresh() {
        refreshCalled = true
    }
    
    func createPost(content: String, images: [String], attachments: [FeedAttachment], visibility: FeedVisibility) async throws {
        createPostCalled = true
        lastCreatedContent = content
        lastCreatedImages = images
        lastCreatedVisibility = visibility
        
        if shouldThrowError {
            throw FeedError.networkError
        }
    }
    
    func deletePost(_ postId: String) async throws {}
    
    func toggleLike(postId: String) async throws {
        toggleLikeCalled = true
        lastToggledLikePostId = postId
    }
    
    func addComment(to postId: String, content: String) async throws {}
}

private class MockFeedCoordinator: FeedCoordinatorProtocol {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController = UINavigationController()
    
    var showPostDetailCalled = false
    var showCreatePostCalled = false
    var lastShownPost: FeedPost?
    
    func start() {}
    
    func showPostDetail(_ post: FeedPost) {
        showPostDetailCalled = true
        lastShownPost = post
    }
    
    func showCreatePost() {
        showCreatePostCalled = true
    }
    
    func showUserProfile(_ userId: String) {}
    func showSearch() {}
    func didFinish() {}
}

// MARK: - Test Helpers

private extension FeedPost {
    static func mock(
        id: String = UUID().uuidString,
        content: String = "Test post",
        visibility: FeedVisibility = .everyone
    ) -> FeedPost {
        FeedPost(
            id: id,
            author: FeedAuthor(id: "1", name: "Test User", avatar: nil, role: "Student"),
            content: content,
            timestamp: Date(),
            visibility: visibility,
            likes: [],
            comments: [],
            images: [],
            attachments: [],
            tags: nil,
            mentions: nil,
            isPinned: false,
            editedAt: nil
        )
    }
}

private extension FeedPermissions {
    static func mock() -> FeedPermissions {
        FeedPermissions(
            canPost: true,
            canComment: true,
            canLike: true,
            canShare: true,
            canDelete: false,
            canEdit: false,
            canModerate: false,
            visibilityOptions: [.everyone, .department]
        )
    }
} 