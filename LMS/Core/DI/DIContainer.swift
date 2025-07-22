import Foundation
import Combine

final class DIContainer: ObservableObject {
    // MARK: - Services
    
    lazy var networkService: NetworkServiceProtocol = {
        NetworkService(configuration: .default)
    }()
    
    lazy var authService: AuthServiceProtocol = {
        AuthService(networkService: networkService, tokenStorage: tokenStorage)
    }()
    
    lazy var courseService: CourseServiceProtocol = {
        CourseService(networkService: networkService)
    }()
    
    lazy var userService: UserServiceProtocol = {
        UserService(networkService: networkService)
    }()
    
    lazy var feedService: FeedServiceProtocol = {
        FeedService(networkService: networkService)
    }()
    
    // MARK: - Storage
    
    lazy var tokenStorage: TokenStorageProtocol = {
        KeychainTokenStorage()
    }()
    
    lazy var userDefaultsStorage: UserDefaultsStorageProtocol = {
        UserDefaultsStorage()
    }()
    
    lazy var cacheStorage: CacheStorageProtocol = {
        CacheStorage()
    }()
    
    // MARK: - Repositories
    
    lazy var courseRepository: CourseRepositoryProtocol = {
        CourseRepository(
            networkService: networkService,
            cacheStorage: cacheStorage
        )
    }()
    
    lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(
            networkService: networkService,
            cacheStorage: cacheStorage
        )
    }()
    
    // MARK: - Use Cases
    
    lazy var loginUseCase: LoginUseCaseProtocol = {
        LoginUseCase(
            authService: authService,
            userRepository: userRepository
        )
    }()
    
    lazy var fetchCoursesUseCase: FetchCoursesUseCaseProtocol = {
        FetchCoursesUseCase(courseRepository: courseRepository)
    }()
    
    lazy var enrollCourseUseCase: EnrollCourseUseCaseProtocol = {
        EnrollCourseUseCase(courseRepository: courseRepository)
    }()
    
    // MARK: - ViewModels Factory
    
    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(loginUseCase: loginUseCase)
    }
    
    func makeCourseListViewModel() -> CourseListViewModel {
        CourseListViewModel(
            fetchCoursesUseCase: fetchCoursesUseCase,
            enrollCourseUseCase: enrollCourseUseCase
        )
    }
    
    func makeFeedViewModel() -> FeedViewModel {
        FeedViewModel(feedService: feedService)
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            userService: userService,
            authService: authService,
            storage: userDefaultsStorage
        )
    }
    
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            userService: userService,
            authService: authService
        )
    }
} 