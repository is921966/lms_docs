import Foundation

// MARK: - Dependency Injection Container

@MainActor
final class DIContainer {
    static let shared = DIContainer()
    
    private init() {}
    
    // MARK: - Services
    
    lazy var authService: AuthService = {
        AuthService.shared
    }()
    
    lazy var feedService: FeedServiceProtocol = {
        return MockFeedService()
    }()
    
    lazy var courseService: MockCourseService = {
        return MockCourseService()
    }()
    
    lazy var cmi5Service: Cmi5Service = {
        return Cmi5Service()
    }()
    
    lazy var lrsService: LRSService = {
        return LRSService()
    }()
    
    // MARK: - View Models
    
    func makeFeedViewModel() -> FeedViewModel {
        FeedViewModel(feedService: feedService)
    }
    
    func makeCourseListViewModel() -> CourseListViewModel {
        CourseListViewModel()
    }
} 