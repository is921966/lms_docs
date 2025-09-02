//
//  MockFeedService.swift
//  LMS
//
//  Created by LMS Team on 13.01.2025.
//

import Foundation
import Combine

@MainActor
class MockFeedService: ObservableObject, FeedServiceProtocol {
    
    static let shared = MockFeedService()
    
    @Published private(set) var posts: [FeedPost] = []
    @Published private(set) var channels: [FeedChannel] = []
    @Published private(set) var channelPosts: [String: [FeedPost]] = [:] // channelId -> posts
    @Published private(set) var isLoading = false
    @Published var error: Error?
    @Published private(set) var permissions = FeedPermissions(
        canPost: false,
        canComment: true,
        canLike: true,
        canShare: true,
        canDelete: false,
        canEdit: false,
        canModerate: false,
        visibilityOptions: []
    )
    
    // Publishers for protocol conformance
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
    
    private let authService = MockAuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthObserver()
        loadMockData()
        checkAndAddReleaseNews()
        
        // Force synchronous update to ensure data is available
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            ComprehensiveLogger.shared.log(.data, .info, "MockFeedService: Force update after init", details: [
                "channelsCount": self.channels.count,
                "channelPostsCount": self.channelPosts.count,
                "totalPosts": self.posts.count
            ])
            
            // Force publish updates
            self.objectWillChange.send()
        }
    }
    
    private func setupAuthObserver() {
        authService.$currentUser
            .sink { [weak self] user in
                self?.updatePermissions(for: user)
            }
            .store(in: &cancellables)
    }
    
    private func updatePermissions(for user: UserResponse?) {
        guard let user = user else {
            permissions = FeedPermissions(
                canPost: false,
                canComment: true,
                canLike: true,
                canShare: true,
                canDelete: false,
                canEdit: false,
                canModerate: false,
                visibilityOptions: []
            )
            return
        }
        
        switch user.role {
        case .student:
            permissions = FeedPermissions.studentDefault
        case .instructor:
            permissions = FeedPermissions.instructorDefault
        case .admin, .superAdmin:
            permissions = FeedPermissions.adminDefault
        case .manager:
            permissions = FeedPermissions.managerDefault
        }
    }
    
    private func loadMockData() {
        let calendar = Calendar.current
        
        ComprehensiveLogger.shared.log(.data, .info, "MockFeedService: Starting to load data")
        
        // First, load real data from documentation and organize by channels
        let channelData = RealDataFeedService.shared.loadAllChannelPosts()
        
        ComprehensiveLogger.shared.log(.data, .info, "MockFeedService: Loaded channel data", details: [
            "channelTypes": channelData.keys.map { $0.rawValue },
            "totalChannels": channelData.count
        ])
        
        // Create channels and populate channelPosts
        channels = []
        channelPosts = [:]
        
        ComprehensiveLogger.shared.log(.data, .info, "Starting to create channels and channelPosts")
        
        for (channelType, posts) in channelData {
            ComprehensiveLogger.shared.log(.data, .debug, "Processing channel type: \(channelType.rawValue)", details: [
                "postsCount": posts.count
            ])
            
            if !posts.isEmpty {
                if let channel = FeedChannel.fromPosts(posts, type: channelType) {
                    channels.append(channel)
                    channelPosts[channel.id] = posts
                    
                    // Add all posts to the main posts array
                    self.posts.append(contentsOf: posts)
                    
                    ComprehensiveLogger.shared.log(.data, .info, "Created channel and added to channelPosts", details: [
                        "channelId": channel.id,
                        "channelName": channel.name,
                        "channelType": channelType.rawValue,
                        "postsCount": posts.count,
                        "unreadCount": channel.unreadCount,
                        "channelPostsKeys": Array(channelPosts.keys)
                    ])
                } else {
                    ComprehensiveLogger.shared.log(.data, .warning, "Failed to create channel for type: \(channelType.rawValue)")
                }
            } else {
                ComprehensiveLogger.shared.log(.data, .debug, "No posts for channel type: \(channelType.rawValue)")
            }
        }
        
        ComprehensiveLogger.shared.log(.data, .info, "Finished creating channels", details: [
            "totalChannels": channels.count,
            "channelPostsCount": channelPosts.count,
            "allChannelIds": Array(channelPosts.keys).sorted(),
            "postsPerChannel": channelPosts.mapValues { $0.count }
        ])
        
        // Sort channels by priority
        channels.sort { lhs, rhs in
            // Pinned channels first
            if lhs.isPinned != rhs.isPinned {
                return lhs.isPinned
            }
            // Then by last message date
            return lhs.lastMessage.date > rhs.lastMessage.date
        }
        
        // Sort all posts by date
        posts.sort { $0.createdAt > $1.createdAt }
        
        ComprehensiveLogger.shared.log(.data, .info, "MockFeedService: Data loading complete", details: [
            "totalChannels": channels.count,
            "totalPosts": posts.count,
            "channelNames": channels.map { $0.name }
        ])
    }
    
    private func checkAndAddReleaseNews() {
        // Проверяем флаг новой версии в Info.plist
        let hasNewRelease = Bundle.main.infoDictionary?["LMSHasNewRelease"] as? Bool ?? false
        
        // Получаем текущую версию
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        
        // Проверяем, есть ли уже новость о релизе в текущих постах
        let releasePostId = "release-\(currentVersion)-\(currentBuild)"
        let releaseNewsExists = posts.contains { $0.id == releasePostId }
        
        if hasNewRelease && !releaseNewsExists {
            // Пытаемся загрузить release notes из bundle
            var releaseContent = ""
            
            if let releaseNotesPath = Bundle.main.path(forResource: "RELEASE_NOTES", ofType: "md"),
               let content = try? String(contentsOfFile: releaseNotesPath) {
                // Используем содержимое из файла
                releaseContent = content
            } else {
                // Используем дефолтное содержимое в HTML формате
                releaseContent = """
                <div style="font-family: -apple-system, system-ui; padding: 10px;">
                    <h1 style="font-size: 24px; margin-bottom: 15px;">
                        🚀 Новая версия v2.1.1 <span style="color: #666; font-size: 18px;">(Build 213)</span>
                    </h1>
                    
                    <div style="margin-top: 20px;">
                        <h2 style="font-size: 20px; color: #333; margin-bottom: 10px;">
                            🎯 Основные изменения
                        </h2>
                        
                        <div style="margin-top: 15px;">
                            <h3 style="font-size: 18px; color: #333; margin-bottom: 8px;">
                                ✨ Новые функции
                            </h3>
                            <ul style="margin: 0; padding-left: 20px;">
                                <li style="margin-bottom: 5px; color: #555; line-height: 1.5;"><strong>Улучшенный импорт оргструктуры</strong> - добавлена обязательная колонка "Вышестоящий Код" для явного указания иерархии подразделений</li>
                                <li style="margin-bottom: 5px; color: #555; line-height: 1.5;"><strong>Обновленный шаблон Excel</strong> - теперь включает все необходимые колонки с примерами данных</li>
                                <li style="margin-bottom: 5px; color: #555; line-height: 1.5;"><strong>Улучшенная инструкция по импорту</strong> - добавлено подробное описание всех колонок</li>
                            </ul>
                        </div>
                        
                        <div style="margin-top: 15px;">
                            <h3 style="font-size: 18px; color: #333; margin-bottom: 8px;">
                                🔧 Улучшения
                            </h3>
                            <ul style="margin: 0; padding-left: 20px;">
                                <li style="margin-bottom: 5px; color: #555; line-height: 1.5;"><strong>Надежность импорта</strong> - удалена автоматическая логика определения иерархии по коду, теперь используется явная связь</li>
                                <li style="margin-bottom: 5px; color: #555; line-height: 1.5;"><strong>Гибкость структуры</strong> - можно использовать любые коды подразделений без привязки к формату</li>
                                <li style="margin-bottom: 5px; color: #555; line-height: 1.5;"><strong>Скачивание шаблона в симуляторе</strong> - файл сохраняется в Documents с подробной инструкцией</li>
                            </ul>
                        </div>
                        
                        <div style="margin-top: 15px;">
                            <h3 style="font-size: 18px; color: #333; margin-bottom: 8px;">
                                🔨 Исправления
                            </h3>
                            <ul style="margin: 0; padding-left: 20px;">
                                <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Исправлена проблема с открытием диалога сохранения на реальных устройствах</li>
                                <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Устранены ошибки при парсинге Excel файлов с пустыми строками</li>
                                <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Исправлено количество элементов в sharedStrings XML</li>
                            </ul>
                        </div>
                    </div>
                    
                    <div style="margin-top: 20px;">
                        <h2 style="font-size: 20px; color: #333; margin-bottom: 10px;">
                            📋 Инструкция по работе с оргструктурой
                        </h2>
                        
                        <ul style="margin: 0; padding-left: 20px;">
                            <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Скачайте шаблон Excel через кнопку "Скачать шаблон"</li>
                            <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Заполните колонку "Вышестоящий Код" для всех подразделений кроме корневых</li>
                            <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Загрузите файл через "Выбрать файл Excel"</li>
                        </ul>
                    </div>
                    
                    <div style="margin-top: 20px;">
                        <h2 style="font-size: 20px; color: #FF6B6B; margin-bottom: 10px;">
                            ⚠️ Важно для пользователей
                        </h2>
                        <ul style="margin: 0; padding-left: 20px;">
                            <li style="margin-bottom: 5px; color: #FF6B6B; line-height: 1.5;">Старые Excel файлы требуют добавления колонки "Вышестоящий Код"</li>
                            <li style="margin-bottom: 5px; color: #FF6B6B; line-height: 1.5;">Автоматическое определение иерархии по формату кода больше не работает</li>
                        </ul>
                    </div>
                    
                    <div style="margin-top: 25px; padding: 15px; background-color: #f5f5f5; border-radius: 8px;">
                        <h3 style="font-size: 16px; color: #666; margin-bottom: 8px;">📱 Техническая информация</h3>
                        <p style="margin: 3px 0; color: #888; font-size: 14px;">
                            Минимальная версия iOS: 17.0<br>
                            Рекомендуемая версия iOS: 18.5<br>
                            Размер приложения: ~45 MB
                        </p>
                    </div>
                    
                    <div style="margin-top: 20px; padding-top: 15px; border-top: 1px solid #e0e0e0;">
                        <p style="text-align: center; color: #007AFF; font-size: 14px;">
                            #release #update #testflight #orgstructure
                        </p>
                    </div>
                </div>
                """
            }
            
            let releasePost = FeedPost(
                id: releasePostId,
                author: UserResponse(
                    id: "system",
                    email: "system@lms.com",
                    name: "Команда разработки",
                    role: .admin,
                    isActive: true,
                    createdAt: Date()
                ),
                content: releaseContent,
                images: [],
                attachments: [],
                createdAt: Date(),
                visibility: .everyone,
                likes: [],
                comments: [],
                tags: ["#release", "#update", "#testflight"],
                mentions: [],
                metadata: [
                    "type": "app_release",
                    "contentType": "html",
                    "version": currentVersion,
                    "build": currentBuild
                ]
            )
            
            // Добавляем в начало ленты
            posts.insert(releasePost, at: 0)
        }
    }
    
    // MARK: - Public Methods
    
    func createPost(
        content: String,
        images: [String] = [],
        attachments: [FeedAttachment] = [],
        visibility: FeedVisibility = .everyone
    ) async throws {
        guard let currentUser = authService.currentUser else {
            throw FeedError.noPermission
        }
        
        guard permissions.canPost else {
            throw FeedError.noPermission
        }
        
        let newPost = FeedPost(
            id: UUID().uuidString,
            author: currentUser,
            content: content,
            images: images,
            attachments: attachments,
            createdAt: Date(),
            visibility: visibility,
            likes: [],
            comments: [],
            tags: extractTags(from: content),
            mentions: extractMentions(from: content)
        )
        
        posts.insert(newPost, at: 0)
    }
    
    func deletePost(_ postId: String) async throws {
        guard let post = posts.first(where: { $0.id == postId }) else {
            throw FeedError.postNotFound
        }
        
        let canDelete = post.author.id == authService.currentUser?.id || permissions.canModerate
        
        guard canDelete else {
            throw FeedError.noPermission
        }
        
        posts.removeAll { $0.id == postId }
    }
    
    func toggleLike(postId: String) async throws {
        guard let currentUser = authService.currentUser else {
            throw FeedError.noPermission
        }
        
        guard permissions.canLike else {
            throw FeedError.noPermission
        }
        
        guard let index = posts.firstIndex(where: { $0.id == postId }) else {
            throw FeedError.postNotFound
        }
        
        var post = posts[index]
        
        if post.likes.contains(currentUser.id) {
            post.likes.removeAll { $0 == currentUser.id }
        } else {
            post.likes.append(currentUser.id)
        }
        
        posts[index] = post
    }
    
    func addComment(to postId: String, content: String) async throws {
        guard let currentUser = authService.currentUser else {
            throw FeedError.noPermission
        }
        
        guard permissions.canComment else {
            throw FeedError.noPermission
        }
        
        guard let index = posts.firstIndex(where: { $0.id == postId }) else {
            throw FeedError.postNotFound
        }
        
        let newComment = FeedComment(
            id: UUID().uuidString,
            postId: postId,
            author: currentUser,
            content: content,
            createdAt: Date(),
            likes: []
        )
        
        var post = posts[index]
        post.comments.append(newComment)
        posts[index] = post
    }
    
    func refresh() {
        loadMockData()
        checkAndAddReleaseNews()
    }
    
    // MARK: - Helper Methods
    
    private func extractTags(from content: String) -> [String] {
        let pattern = "#[\\w\\u0400-\\u04FF]+"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: content) else { return nil }
            return String(content[range])
        }
    }
    
    private func extractMentions(from content: String) -> [String] {
        let pattern = "@[\\w\\u0400-\\u04FF]+"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: content) else { return nil }
            let mention = String(content[range])
            return String(mention.dropFirst()) // Remove @
        }
    }
    
    // MARK: - Test Helpers
    
    func reset() {
        posts.removeAll()
        error = nil
        isLoading = false
        loadMockData()
    }
    
    func setError(_ error: FeedError) {
        self.error = error
    }
    
    func setLoading(_ loading: Bool) {
        self.isLoading = loading
    }
} 