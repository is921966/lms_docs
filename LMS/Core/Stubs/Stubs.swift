import Foundation
import SwiftUI

// MARK: - Storage Protocols

protocol TokenStorageProtocol {
    func save(token: String, key: String) throws
    func get(key: String) -> String?
    func delete(key: String) throws
}

protocol UserDefaultsStorageProtocol {
    func save<T: Codable>(_ object: T, key: String)
    func get<T: Codable>(_ type: T.Type, key: String) -> T?
    func delete(key: String)
}

protocol CacheStorageProtocol {
    func save<T: Codable>(_ object: T, key: String)
    func get<T: Codable>(_ type: T.Type, key: String) -> T?
    func delete(key: String)
    func clear()
}

// MARK: - Service Protocols

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> AuthToken
    func logout() async throws
    func refreshToken() async throws -> AuthToken
    var isAuthenticated: Bool { get }
}

protocol CourseServiceProtocol {
    func fetchCourses() async throws -> [Course]
    func fetchCourse(id: String) async throws -> Course
    func enrollInCourse(id: String) async throws
}

protocol UserServiceProtocol {
    func fetchCurrentUser() async throws -> User
    func updateProfile(_ profile: UserProfile) async throws
}

protocol FeedServiceProtocol {
    func fetchFeedItems() async throws -> [FeedItem]
}

// MARK: - Repository Protocols

protocol CourseRepositoryProtocol {
    func fetchCourses() async throws -> [Course]
    func fetchCourse(id: String) async throws -> Course
    func enrollInCourse(id: String) async throws
}

protocol UserRepositoryProtocol {
    func fetchCurrentUser() async throws -> User
    func updateProfile(_ profile: UserProfile) async throws
}

// MARK: - Use Case Protocols

protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) async throws
}

// MARK: - Models

struct AuthToken: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}

struct User: Identifiable, Codable {
    let id: String
    let email: String
    let name: String
    let position: String?
    let department: String?
    let avatarURL: String?
}

struct UserProfile: Codable {
    let name: String
    let position: String?
    let department: String?
}

struct FeedItem: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let date: Date
    let type: FeedItemType
    
    enum FeedItemType: String, Codable {
        case news
        case announcement
        case courseUpdate
        case achievement
    }
}

// MARK: - Implementations

class KeychainTokenStorage: TokenStorageProtocol {
    func save(token: String, key: String) throws {
        // Mock implementation
    }
    
    func get(key: String) -> String? {
        // Mock implementation
        return nil
    }
    
    func delete(key: String) throws {
        // Mock implementation
    }
}

class UserDefaultsStorage: UserDefaultsStorageProtocol {
    func save<T: Codable>(_ object: T, key: String) {
        // Mock implementation
    }
    
    func get<T: Codable>(_ type: T.Type, key: String) -> T? {
        // Mock implementation
        return nil
    }
    
    func delete(key: String) {
        // Mock implementation
    }
}

class CacheStorage: CacheStorageProtocol {
    func save<T: Codable>(_ object: T, key: String) {
        // Mock implementation
    }
    
    func get<T: Codable>(_ type: T.Type, key: String) -> T? {
        // Mock implementation
        return nil
    }
    
    func delete(key: String) {
        // Mock implementation
    }
    
    func clear() {
        // Mock implementation
    }
}

// MARK: - Services

class AuthService: AuthServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let tokenStorage: TokenStorageProtocol
    
    init(networkService: NetworkServiceProtocol, tokenStorage: TokenStorageProtocol) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
    }
    
    func login(email: String, password: String) async throws -> AuthToken {
        // Mock implementation
        return AuthToken(accessToken: "mock", refreshToken: "mock", expiresIn: 3600)
    }
    
    func logout() async throws {
        // Mock implementation
    }
    
    func refreshToken() async throws -> AuthToken {
        // Mock implementation
        return AuthToken(accessToken: "mock", refreshToken: "mock", expiresIn: 3600)
    }
    
    var isAuthenticated: Bool {
        // Mock implementation
        return false
    }
}

class CourseService: CourseServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchCourses() async throws -> [Course] {
        // Mock implementation
        return []
    }
    
    func fetchCourse(id: String) async throws -> Course {
        // Mock implementation
        throw NetworkError.noData
    }
    
    func enrollInCourse(id: String) async throws {
        // Mock implementation
    }
}

class UserService: UserServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchCurrentUser() async throws -> User {
        // Mock implementation
        return User(id: "1", email: "test@test.com", name: "Test User", position: nil, department: nil, avatarURL: nil)
    }
    
    func updateProfile(_ profile: UserProfile) async throws {
        // Mock implementation
    }
}

class FeedService: FeedServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchFeedItems() async throws -> [FeedItem] {
        // Mock implementation
        return []
    }
}

// MARK: - Repositories

class CourseRepository: CourseRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheStorage: CacheStorageProtocol
    
    init(networkService: NetworkServiceProtocol, cacheStorage: CacheStorageProtocol) {
        self.networkService = networkService
        self.cacheStorage = cacheStorage
    }
    
    func fetchCourses() async throws -> [Course] {
        // Mock implementation
        return []
    }
    
    func fetchCourse(id: String) async throws -> Course {
        // Mock implementation
        throw NetworkError.noData
    }
    
    func enrollInCourse(id: String) async throws {
        // Mock implementation
    }
}

class UserRepository: UserRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheStorage: CacheStorageProtocol
    
    init(networkService: NetworkServiceProtocol, cacheStorage: CacheStorageProtocol) {
        self.networkService = networkService
        self.cacheStorage = cacheStorage
    }
    
    func fetchCurrentUser() async throws -> User {
        // Mock implementation
        return User(id: "1", email: "test@test.com", name: "Test User", position: nil, department: nil, avatarURL: nil)
    }
    
    func updateProfile(_ profile: UserProfile) async throws {
        // Mock implementation
    }
}

// MARK: - Use Cases

class LoginUseCase: LoginUseCaseProtocol {
    private let authService: AuthServiceProtocol
    private let userRepository: UserRepositoryProtocol
    
    init(authService: AuthServiceProtocol, userRepository: UserRepositoryProtocol) {
        self.authService = authService
        self.userRepository = userRepository
    }
    
    func execute(email: String, password: String) async throws {
        // Mock implementation
        _ = try await authService.login(email: email, password: password)
    }
}

class FetchCoursesUseCase: FetchCoursesUseCaseProtocol {
    private let courseRepository: CourseRepositoryProtocol
    
    init(courseRepository: CourseRepositoryProtocol) {
        self.courseRepository = courseRepository
    }
    
    func execute() async throws -> [Course] {
        return try await courseRepository.fetchCourses()
    }
}

class EnrollCourseUseCase: EnrollCourseUseCaseProtocol {
    private let courseRepository: CourseRepositoryProtocol
    
    init(courseRepository: CourseRepositoryProtocol) {
        self.courseRepository = courseRepository
    }
    
    func execute(courseId: String) async throws {
        try await courseRepository.enrollInCourse(id: courseId)
    }
} 