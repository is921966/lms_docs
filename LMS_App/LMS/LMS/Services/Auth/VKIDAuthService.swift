import Foundation
import SwiftUI
import VKID
import VKIDCore

// MARK: - VKIDAuthService
class VKIDAuthService: ObservableObject {
    static let shared = VKIDAuthService()
    
    @Published private(set) var currentUser: UserResponse?
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isApprovedByAdmin = false
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    
    private var vkid: VKID?
    private let networkService = NetworkService.shared
    
    private init() {
        setupVKID()
        checkAuthenticationStatus()
    }
    
    // MARK: - Setup
    private func setupVKID() {
        do {
            vkid = try VKID(
                config: Configuration(
                    appCredentials: AppCredentials(
                        clientId: "51920596", // TODO: Заменить на реальный VK App ID
                        clientSecret: "your_client_secret" // TODO: Заменить на реальный Client Secret
                    )
                )
            )
        } catch {
            print("Failed to initialize VKID: \(error)")
        }
    }
    
    // MARK: - Authentication
    func loginWithVK(from viewController: UIViewController) {
        guard let vkid = vkid else {
            self.error = "VK ID не инициализирован"
            return
        }
        
        isLoading = true
        error = nil
        
        vkid.authorize(
            with: .init(oAuth: .init(scopes: [.userInfo, .email])),
            using: viewController,
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let session):
                        self?.handleVKAuthSuccess(session: session)
                    case .failure(let error):
                        self?.handleVKAuthError(error)
                    }
                }
            }
        )
    }
    
    private func handleVKAuthSuccess(session: UserSession) {
        // Получаем информацию о пользователе из VK
        session.user.fetchUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let vkUser):
                    self?.syncWithBackend(vkUser: vkUser, vkAccessToken: session.accessToken.value)
                case .failure(let error):
                    self?.error = "Не удалось получить данные пользователя: \(error.localizedDescription)"
                    self?.isLoading = false
                }
            }
        }
    }
    
    private func handleVKAuthError(_ error: VKIDError) {
        self.error = "Ошибка авторизации VK: \(error.localizedDescription)"
        self.isLoading = false
    }
    
    // MARK: - Backend Sync
    private func syncWithBackend(vkUser: User, vkAccessToken: String) {
        let vkAuthRequest = VKAuthRequest(
            vkId: String(vkUser.id),
            accessToken: vkAccessToken,
            email: vkUser.email ?? "",
            firstName: vkUser.firstName ?? "",
            lastName: vkUser.lastName ?? "",
            avatar: vkUser.avatarURL?.absoluteString
        )
        
        networkService.post(
            endpoint: "/auth/vk",
            body: vkAuthRequest,
            responseType: VKAuthResponse.self
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            },
            receiveValue: { [weak self] response in
                self?.handleBackendAuthResponse(response)
            }
        )
        .store(in: &cancellables)
    }
    
    private func handleBackendAuthResponse(_ response: VKAuthResponse) {
        // Сохраняем токены от нашего backend
        TokenManager.shared.saveTokens(
            accessToken: response.tokens.accessToken,
            refreshToken: response.tokens.refreshToken
        )
        TokenManager.shared.userId = response.user.id
        
        // Обновляем состояние
        currentUser = response.user
        isAuthenticated = true
        isApprovedByAdmin = response.user.isApproved
        
        // Если пользователь не одобрен админом, показываем соответствующий экран
        if !response.user.isApproved {
            print("Пользователь авторизован через VK, но ожидает одобрения администратора")
        }
    }
    
    // MARK: - Check Admin Approval
    func checkAdminApproval() {
        guard isAuthenticated else { return }
        
        networkService.get(
            endpoint: "/users/me",
            responseType: UserResponse.self
        )
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] user in
                self?.currentUser = user
                self?.isApprovedByAdmin = user.isApproved
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Authentication Status
    private func checkAuthenticationStatus() {
        isAuthenticated = TokenManager.shared.isAuthenticated
        
        if isAuthenticated {
            checkAdminApproval()
        }
    }
    
    // MARK: - Logout
    func logout() {
        vkid?.logout { [weak self] _ in
            DispatchQueue.main.async {
                self?.clearAuthState()
            }
        }
    }
    
    private func clearAuthState() {
        TokenManager.shared.clearTokens()
        currentUser = nil
        isAuthenticated = false
        isApprovedByAdmin = false
        error = nil
    }
    
    // MARK: - Cancellables
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Request/Response Models
struct VKAuthRequest: Encodable {
    let vkId: String
    let accessToken: String
    let email: String
    let firstName: String
    let lastName: String
    let avatar: String?
    
    enum CodingKeys: String, CodingKey {
        case vkId = "vk_id"
        case accessToken = "access_token"
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
    }
}

struct VKAuthResponse: Decodable {
    let user: UserResponse
    let tokens: TokensResponse
}

// Update UserResponse model
extension UserResponse {
    var isApproved: Bool {
        return permissions.contains("access_courses") || roles.contains("student")
    }
} 