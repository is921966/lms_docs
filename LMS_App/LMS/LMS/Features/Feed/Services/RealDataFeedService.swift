//
//  RealDataFeedService.swift
//  LMS
//
//  Service for loading real release notes and sprint reports
//

import Foundation
import SwiftUI

@MainActor
class RealDataFeedService: ObservableObject {
    static let shared = RealDataFeedService()
    
    private init() {}
    
    /// Load all posts organized by channels
    func loadAllChannelPosts() -> [ChannelType: [FeedPost]] {
        var channelPosts: [ChannelType: [FeedPost]] = [:]
        
        // Load release notes
        channelPosts[.releases] = loadReleaseNotes()
        
        // Load sprint reports  
        channelPosts[.sprints] = loadSprintReports()
        
        // Load methodology updates
        channelPosts[.methodology] = loadMethodologyUpdates()
        
        // Load course announcements
        channelPosts[.courses] = loadCourseAnnouncements()
        
        // Load admin posts
        channelPosts[.admin] = loadAdminPosts()
        
        // Load HR posts
        channelPosts[.hr] = loadHRPosts()
        
        // Load user's courses
        channelPosts[.myCourses] = loadMyCourses()
        
        // Load community posts
        channelPosts[.userPosts] = loadUserPosts()
        
        return channelPosts
    }
    
    /// Load release notes from documentation files
    func loadReleaseNotes() -> [FeedPost] {
        ComprehensiveLogger.shared.log(.data, .info, "=== Starting loadReleaseNotes ===", details: [
            "timestamp": Date().timeIntervalSince1970,
            "thread": Thread.current.description
        ])
        
        var posts: [FeedPost] = []
        
        let fileManager = FileManager.default
        let releasePaths = [
            "/Users/ishirokov/lms_docs/docs/releases",
            "/Users/ishirokov/lms_docs/LMS_App/LMS" // Assuming some releases might be here too
        ]
        
        for path in releasePaths {
            ComprehensiveLogger.shared.log(.data, .debug, "Scanning release path", details: [
                "path": path,
                "exists": fileManager.fileExists(atPath: path)
            ])
            
            do {
                let files = try fileManager.contentsOfDirectory(atPath: path)
                let releaseFiles = files.filter { 
                    $0.contains("RELEASE") && $0.hasSuffix(".md")
                }
                
                ComprehensiveLogger.shared.log(.data, .info, "Found release files", details: [
                    "path": path,
                    "totalFiles": files.count,
                    "releaseFiles": releaseFiles.count,
                    "fileNames": releaseFiles.prefix(5).joined(separator: ", ")
                ])
                
                for file in releaseFiles {
                    let fullPath = path + "/" + file
                    if let content = try? String(contentsOfFile: fullPath, encoding: .utf8),
                       let post = createPostFromReleaseNotes(path: fullPath, content: content) {
                        posts.append(post)
                        ComprehensiveLogger.shared.log(.data, .debug, "Created post from \(file)")
                    } else {
                        ComprehensiveLogger.shared.log(.data, .warning, "Failed to create post from \(file)")
                    }
                }
            } catch {
                ComprehensiveLogger.shared.log(.data, .error, "Failed to load releases from \(path): \(error)")
            }
        }
        
        // Sort by date, newest first
        posts.sort { $0.createdAt > $1.createdAt }
        
        ComprehensiveLogger.shared.log(.data, .info, "Loaded \(posts.count) release posts total")
        
        return posts
    }
    
    /// Load sprint reports
    func loadSprintReports() -> [FeedPost] {
        ComprehensiveLogger.shared.log(.data, .info, "=== Starting loadSprintReports ===", details: [
            "timestamp": Date().timeIntervalSince1970,
            "thread": Thread.current.description
        ])
        
        var posts: [FeedPost] = []
        
        let fileManager = FileManager.default
        let sprintPaths = [
            "/Users/ishirokov/lms_docs/reports/sprints"
        ]
        
        for path in sprintPaths {
            ComprehensiveLogger.shared.log(.data, .debug, "Scanning sprint path", details: [
                "path": path,
                "exists": fileManager.fileExists(atPath: path)
            ])
            
            do {
                let files = try fileManager.contentsOfDirectory(atPath: path)
                let sprintFiles = files.filter { 
                    ($0.contains("COMPLETION_REPORT") || $0.contains("PROGRESS")) && $0.hasSuffix(".md")
                }
                
                ComprehensiveLogger.shared.log(.data, .info, "Found sprint files", details: [
                    "path": path,
                    "totalFiles": files.count,
                    "sprintFiles": sprintFiles.count,
                    "fileNames": sprintFiles.prefix(5).joined(separator: ", ")
                ])
                
                for file in sprintFiles {
                    let fullPath = path + "/" + file
                    if let content = try? String(contentsOfFile: fullPath, encoding: .utf8),
                       let post = createPostFromSprintReport(path: fullPath, content: content) {
                        posts.append(post)
                    }
                }
                
            } catch {
                ComprehensiveLogger.shared.log(.data, .error, "Failed to load sprint reports from \(path): \(error.localizedDescription)")
            }
        }
        
        // Sort by date, newest first
        posts.sort { $0.createdAt > $1.createdAt }
        
        ComprehensiveLogger.shared.log(.data, .info, "Loaded \(posts.count) sprint reports")
        
        return posts
    }
    
    /// Load methodology updates
    func loadMethodologyUpdates() -> [FeedPost] {
        ComprehensiveLogger.shared.log(.data, .info, "=== Starting loadMethodologyUpdates ===", details: [
            "timestamp": Date().timeIntervalSince1970,
            "thread": Thread.current.description
        ])
        
        var posts: [FeedPost] = []
        let fileManager = FileManager.default
        let methodologyPath = "/Users/ishirokov/lms_docs/reports/methodology"
        
        ComprehensiveLogger.shared.log(.data, .debug, "Scanning methodology path", details: [
            "path": methodologyPath,
            "exists": fileManager.fileExists(atPath: methodologyPath)
        ])
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: methodologyPath)
            let methodologyFiles = files.filter { $0.hasSuffix(".md") }
            
            ComprehensiveLogger.shared.log(.data, .info, "Found methodology files", details: [
                "path": methodologyPath,
                "totalFiles": files.count,
                "methodologyFiles": methodologyFiles.count,
                "fileNames": methodologyFiles.prefix(5).joined(separator: ", ")
            ])
            
            for file in methodologyFiles {
                let fullPath = methodologyPath + "/" + file
                if let content = try? String(contentsOfFile: fullPath, encoding: .utf8),
                   let post = createPostFromMethodology(path: fullPath, content: content) {
                    posts.append(post)
                    ComprehensiveLogger.shared.log(.data, .debug, "Created post from \(file)")
                } else {
                    ComprehensiveLogger.shared.log(.data, .warning, "Failed to create post from \(file)")
                }
            }
        } catch {
            ComprehensiveLogger.shared.log(.data, .error, "Failed to load methodology updates: \(error)")
        }
        
        // Sort by date, newest first
        posts.sort { $0.createdAt > $1.createdAt }
        
        ComprehensiveLogger.shared.log(.data, .info, "Loaded \(posts.count) methodology posts total")
        
        return posts
    }
    
    /// Load course announcements
    func loadCourseAnnouncements() -> [FeedPost] {
        return [
            FeedPost(
                id: "course-swift-ui",
                author: UserResponse(
                    id: "education-team",
                    email: "education@tsum.ru",
                    name: "Учебный центр ЦУМ",
                    role: .admin,
                    isActive: true,
                    createdAt: Date()
                ),
                content: """
                # 🚀 Новый курс: SwiftUI для начинающих
                
                ## О курсе
                
                Приглашаем на новый интенсивный курс по разработке iOS приложений с использованием SwiftUI!
                
                ### Что вы изучите:
                - Основы Swift и SwiftUI
                - Создание пользовательских интерфейсов
                - Работа с данными и состоянием
                - Навигация и анимации
                - Интеграция с REST API
                - Публикация в App Store
                
                ### Для кого этот курс:
                - Начинающие iOS разработчики
                - Frontend разработчики, желающие освоить мобильную разработку
                - Студенты и выпускники IT специальностей
                
                **Длительность**: 8 недель  
                **Формат**: Онлайн с поддержкой ментора  
                **Старт**: 1 августа 2025  
                
                🎁 **Бонус**: Все участники получат доступ к закрытому чату с экспертами!
                """,
                images: ["swiftui-course-banner"],
                attachments: [
                    FeedAttachment(
                        id: "course-program",
                        type: .document,
                        url: "https://lms.tsum.ru/courses/swiftui/program.pdf",
                        name: "Программа курса SwiftUI.pdf",
                        size: 2457600, // 2.4 MB
                        thumbnailUrl: nil
                    )
                ],
                createdAt: Date().addingTimeInterval(-3600), // 1 hour ago
                visibility: .everyone,
                likes: ["user1", "user2", "user3", "user4", "user5"],
                comments: [
                    FeedComment(
                        id: "comment-course-1",
                        postId: "course-swift-ui",
                        author: UserResponse(
                            id: "user-developer",
                            email: "dev@tsum.ru",
                            name: "Алексей Разработчиков",
                            role: .student,
                            isActive: true,
                            createdAt: Date()
                        ),
                        content: "Давно ждал этот курс! Записался 🎉",
                        createdAt: Date().addingTimeInterval(-1800),
                        likes: ["user2", "user3"]
                    )
                ],
                tags: ["#курс", "#ios", "#swiftui", "#новый"],
                mentions: [],
                metadata: ["type": "course", "courseId": "swiftui-basics", "featured": "true"]
            ),
            
            FeedPost(
                id: "course-kubernetes",
                author: UserResponse(
                    id: "education-team",
                    email: "education@tsum.ru",
                    name: "Учебный центр ЦУМ",
                    role: .admin,
                    isActive: true,
                    createdAt: Date()
                ),
                content: """
                # ☸️ Kubernetes для DevOps инженеров
                
                ## Описание курса
                
                Практический курс по оркестрации контейнеров с Kubernetes.
                
                ### Программа:
                1. **Неделя 1-2**: Основы контейнеризации и Docker
                2. **Неделя 3-4**: Архитектура Kubernetes
                3. **Неделя 5-6**: Развертывание и масштабирование
                4. **Неделя 7-8**: Мониторинг и безопасность
                
                ### Практические задания:
                - Развертывание микросервисного приложения
                - Настройка CI/CD pipeline
                - Работа с Helm charts
                - Настройка мониторинга с Prometheus
                
                **Преподаватель**: Иван Кубернетов - Senior DevOps Engineer  
                **Старт**: 15 июля 2025  
                **Стоимость**: Бесплатно для сотрудников ЦУМ
                """,
                images: [],
                attachments: [],
                createdAt: Date().addingTimeInterval(-86400), // 1 day ago
                visibility: .everyone,
                likes: ["user1", "user2"],
                comments: [],
                tags: ["#курс", "#kubernetes", "#devops", "#бесплатно"],
                mentions: [],
                metadata: ["type": "course", "courseId": "kubernetes-devops"]
            ),
            
            FeedPost(
                id: "course-sql-advanced",
                author: UserResponse(
                    id: "education-team",
                    email: "education@tsum.ru",
                    name: "Учебный центр ЦУМ",
                    role: .admin,
                    isActive: true,
                    createdAt: Date()
                ),
                content: """
                # 🗃️ Продвинутый SQL и оптимизация запросов
                
                Углубленный курс для тех, кто хочет стать экспертом в работе с базами данных.
                
                ### Темы курса:
                - Сложные JOIN операции и подзапросы
                - Оконные функции и аналитика
                - Индексы и планы выполнения
                - Партиционирование и шардирование
                - NoSQL vs SQL: когда что использовать
                
                💡 **Особенность курса**: Работа с реальными данными ЦУМ (обезличенными)
                
                **Формат**: Гибридный (онлайн + 2 очных воркшопа)  
                **Длительность**: 6 недель  
                **Требования**: Базовые знания SQL
                """,
                images: [],
                attachments: [],
                createdAt: Date().addingTimeInterval(-172800), // 2 days ago
                visibility: .everyone,
                likes: ["user1", "user2", "user3"],
                comments: [],
                tags: ["#курс", "#sql", "#базыданных", "#продвинутый"],
                mentions: [],
                metadata: ["type": "course", "courseId": "sql-advanced"]
            )
        ]
    }
    
    /// Load admin posts
    func loadAdminPosts() -> [FeedPost] {
        return [
            FeedPost(
                id: "admin-maintenance",
                author: UserResponse(
                    id: "admin-team",
                    email: "admin@tsum.ru",
                    name: "Администрация системы",
                    role: .admin,
                    isActive: true,
                    createdAt: Date()
                ),
                content: """
                # ⚠️ Плановое обслуживание
                
                **Когда**: 25 июля 2025, 03:00 - 05:00 МСК
                
                В указанное время будут проводиться работы:
                - Обновление базы данных
                - Оптимизация производительности
                - Установка патчей безопасности
                
                Система будет недоступна около 2 часов. Приносим извинения за неудобства.
                """,
                images: [],
                attachments: [],
                createdAt: Date().addingTimeInterval(-3600),
                visibility: .everyone,
                likes: [],
                comments: [],
                tags: ["#важно", "#обслуживание"],
                mentions: [],
                metadata: ["type": "admin", "priority": "high"]
            )
        ]
    }
    
    /// Load HR posts
    func loadHRPosts() -> [FeedPost] {
        return [
            FeedPost(
                id: "hr-welcome",
                author: UserResponse(
                    id: "hr-team",
                    email: "hr@tsum.ru",
                    name: "HR команда ЦУМ",
                    role: .manager,
                    isActive: true,
                    createdAt: Date()
                ),
                content: """
                # 👋 Добро пожаловать новым сотрудникам!
                
                На этой неделе к нашей команде присоединились:
                - Иван Петров - iOS разработчик
                - Мария Сидорова - Backend разработчик
                - Алексей Козлов - DevOps инженер
                
                Желаем успехов в новой должности! 🎉
                
                Не забудьте пройти вводный курс по корпоративной культуре.
                """,
                images: [],
                attachments: [],
                createdAt: Date().addingTimeInterval(-7200),
                visibility: .everyone,
                likes: ["user1", "user2", "user3", "user4"],
                comments: [],
                tags: ["#hr", "#новыесотрудники", "#команда"],
                mentions: [],
                metadata: ["type": "hr"]
            )
        ]
    }
    
    /// Load user's assigned courses
    func loadMyCourses() -> [FeedPost] {
        guard let currentUser = MockAuthService.shared.currentUser else { return [] }
        
        return [
            FeedPost(
                id: "my-course-1",
                author: UserResponse(
                    id: "lms-system",
                    email: "system@tsum.ru",
                    name: "Система обучения",
                    role: .admin,
                    isActive: true,
                    createdAt: Date()
                ),
                content: """
                # 📖 Вам назначен новый курс
                
                **Курс**: Основы информационной безопасности
                **Срок прохождения**: до 30 июля 2025
                **Прогресс**: 0%
                
                Курс обязателен для всех сотрудников. Начните обучение прямо сейчас!
                """,
                images: [],
                attachments: [],
                createdAt: Date().addingTimeInterval(-86400),
                visibility: .specific,
                likes: [],
                comments: [],
                tags: ["#мойкурс", "#обязательный"],
                mentions: [currentUser.id],
                metadata: ["type": "course_assignment", "courseId": "security-basics"]
            )
        ]
    }
    
    /// Load community posts from users
    func loadUserPosts() -> [FeedPost] {
        return [
            FeedPost(
                id: "user-post-1",
                author: UserResponse(
                    id: "user-ivan",
                    email: "ivan@tsum.ru",
                    name: "Иван Иванов",
                    role: .student,
                    isActive: true,
                    createdAt: Date()
                ),
                content: """
                Коллеги, кто проходил курс по Kubernetes? Поделитесь впечатлениями! 
                
                Особенно интересует практическая часть и сложность заданий.
                """,
                images: [],
                attachments: [],
                createdAt: Date().addingTimeInterval(-10800),
                visibility: .everyone,
                likes: ["user2", "user3"],
                comments: [
                    FeedComment(
                        id: "comment-1",
                        postId: "user-post-1",
                        author: UserResponse(
                            id: "user-maria",
                            email: "maria@tsum.ru",
                            name: "Мария Петрова",
                            role: .student,
                            isActive: true,
                            createdAt: Date()
                        ),
                        content: "Отличный курс! Много практики, рекомендую",
                        createdAt: Date().addingTimeInterval(-7200),
                        likes: ["user-ivan"]
                    )
                ],
                tags: ["#вопрос", "#kubernetes", "#обучение"],
                mentions: [],
                metadata: ["type": "user_post"]
            )
        ]
    }
    
    /// Create a feed post from release notes
    private func createPostFromReleaseNotes(path: String, content: String) -> FeedPost? {
        // Extract version and build from filename
        let filename = URL(fileURLWithPath: path).lastPathComponent
        var version = "2.1.1"
        var build = "215"
        
        if let versionMatch = filename.range(of: #"v(\d+\.\d+\.\d+)"#, options: .regularExpression) {
            version = String(filename[versionMatch]).replacingOccurrences(of: "v", with: "")
        }
        
        if let buildMatch = filename.range(of: #"build(\d+)"#, options: .regularExpression) {
            build = String(filename[buildMatch]).replacingOccurrences(of: "build", with: "")
        }
        
        // Parse date from content
        var releaseDate = Date()
        if let dateMatch = content.range(of: #"Дата[:\s]+(.+)"#, options: .regularExpression) {
            let dateString = String(content[dateMatch]).replacingOccurrences(of: "Дата:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            // Simple date parsing for "14 июля 2025" format
            if dateString.contains("июля 2025") {
                releaseDate = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 14)) ?? Date()
            }
        }
        
        // Convert markdown to HTML-like format for better display
        let htmlContent = convertMarkdownToHTML(content)
        
        return FeedPost(
            id: "release-\(version)-\(build)",
            author: UserResponse(
                id: "dev-team",
                email: "dev@tsum.ru",
                name: "Команда разработки LMS",
                role: .admin,
                isActive: true,
                createdAt: Date()
            ),
            content: htmlContent,
            images: [],
            attachments: [],
            createdAt: releaseDate,
            visibility: .everyone,
            likes: [],
            comments: [],
            tags: ["#release", "#testflight", "#v\(version)", "#build\(build)"],
            mentions: [],
            metadata: [
                "type": "app_release",
                "contentType": "html",
                "version": version,
                "build": build,
                "source": "documentation"
            ]
        )
    }
    
    /// Create a feed post from sprint report
    private func createPostFromSprintReport(path: String, content: String) -> FeedPost? {
        let filename = URL(fileURLWithPath: path).lastPathComponent
        var sprintNumber = "52"
        
        if let sprintMatch = filename.range(of: #"SPRINT_(\d+)"#, options: .regularExpression) {
            sprintNumber = String(filename[sprintMatch]).replacingOccurrences(of: "SPRINT_", with: "")
        }
        
        // Parse sprint dates
        var sprintDate = Date()
        if let dateMatch = content.range(of: #"Даты[:\s]+(.+)"#, options: .regularExpression) {
            let dateString = String(content[dateMatch])
            // Extract the start date from format like "20-24 июля 2025"
            if dateString.contains("июля 2025") {
                if let dayMatch = dateString.range(of: #"(\d+)"#, options: .regularExpression),
                   let day = Int(String(dateString[dayMatch])) {
                    sprintDate = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: day)) ?? Date()
                }
            }
        }
        
        // Используем полный контент файла, а не summary
        let htmlContent = convertMarkdownToHTML(content)
        
        return FeedPost(
            id: "sprint-\(sprintNumber)-report",
            author: UserResponse(
                id: "project-team",
                email: "team@tsum.ru",
                name: "Проектная команда",
                role: .admin,
                isActive: true,
                createdAt: Date()
            ),
            content: htmlContent,
            images: [],
            attachments: [],
            createdAt: sprintDate,
            visibility: .everyone,
            likes: [],
            comments: [],
            tags: ["#sprint\(sprintNumber)", "#progress", "#development"],
            mentions: [],
            metadata: [
                "type": "sprint_report",
                "contentType": "html",
                "sprintNumber": sprintNumber,
                "source": "documentation"
            ]
        )
    }
    
    /// Create post from methodology update
    private func createPostFromMethodology(path: String, content: String) -> FeedPost? {
        let filename = URL(fileURLWithPath: path).lastPathComponent
        var version = "2.2.0"
        
        if let versionMatch = filename.range(of: #"v(\d+\.\d+\.\d+)"#, options: .regularExpression) {
            version = String(filename[versionMatch]).replacingOccurrences(of: "v", with: "")
        }
        
        let htmlContent = convertMarkdownToHTML(content)
        
        return FeedPost(
            id: "methodology-\(version)",
            author: UserResponse(
                id: "methodology-team",
                email: "methodology@tsum.ru",
                name: "Команда методологии",
                role: .admin,
                isActive: true,
                createdAt: Date()
            ),
            content: htmlContent,
            images: [],
            attachments: [],
            createdAt: Date().addingTimeInterval(-Double.random(in: 86400...604800)),
            visibility: .everyone,
            likes: [],
            comments: [],
            tags: ["#methodology", "#update", "#v\(version)"],
            mentions: [],
            metadata: [
                "type": "methodology_update",
                "version": version
            ]
        )
    }
    
    /// Convert markdown to HTML for better display
    private func convertMarkdownToHTML(_ markdown: String) -> String {
        var html = markdown
        
        // Convert headers - используем многострочный режим
        let lines = html.components(separatedBy: "\n")
        html = lines.map { line in
            if line.hasPrefix("### ") {
                return "<h3>" + line.dropFirst(4) + "</h3>"
            } else if line.hasPrefix("## ") {
                return "<h2>" + line.dropFirst(3) + "</h2>"
            } else if line.hasPrefix("# ") {
                return "<h1>" + line.dropFirst(2) + "</h1>"
            }
            return line
        }.joined(separator: "\n")
        
        // Convert bold
        html = html.replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "<strong>$1</strong>", options: .regularExpression)
        
        // Convert italic (but not bold)
        html = html.replacingOccurrences(of: #"(?<!\*)\*([^\*]+?)\*(?!\*)"#, with: "<em>$1</em>", options: .regularExpression)
        
        // Convert lists - обрабатываем построчно
        let listLines = html.components(separatedBy: "\n")
        html = listLines.map { line in
            if line.hasPrefix("- ") {
                return "<li>" + line.dropFirst(2) + "</li>"
            } else if line.hasPrefix("* ") {
                return "<li>" + line.dropFirst(2) + "</li>"
            } else if let match = line.range(of: #"^\d+\. "#, options: .regularExpression) {
                return "<li>" + line[match.upperBound...] + "</li>"
            }
            return line
        }.joined(separator: "\n")
        
        // Convert code blocks
        html = html.replacingOccurrences(of: #"```(\w*)\n([\s\S]*?)```"#, with: "<pre><code>$2</code></pre>", options: .regularExpression)
        
        // Convert inline code
        html = html.replacingOccurrences(of: #"`(.+?)`"#, with: "<code>$1</code>", options: .regularExpression)
        
        // Convert links
        html = html.replacingOccurrences(of: #"\[(.+?)\]\((.+?)\)"#, with: "<a href=\"$2\">$1</a>", options: .regularExpression)
        
        // Wrap consecutive list items in ul/ol tags
        let listPattern = #"(<li>.*</li>\s*)+"#
        do {
            let regex = try NSRegularExpression(pattern: listPattern, options: [])
            let matches = regex.matches(in: html, options: [], range: NSRange(html.startIndex..., in: html))
            
            // Process matches in reverse order to not affect indices
            for match in matches.reversed() {
                if let range = Range(match.range, in: html) {
                    let listItems = String(html[range])
                    html.replaceSubrange(range, with: "<ul>\n\(listItems)</ul>")
                }
            }
        } catch {
            ComprehensiveLogger.shared.log(.data, .warning, "Failed to wrap lists: \(error)")
        }
        
        // Convert line breaks to paragraphs
        let paragraphs = html.components(separatedBy: "\n\n")
        html = paragraphs
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { paragraph in
                // Don't wrap headers, lists, or pre-formatted content in paragraphs
                if paragraph.contains("<h") || paragraph.contains("<ul>") || paragraph.contains("<ol>") || paragraph.contains("<pre>") {
                    return paragraph
                }
                return "<p>\(paragraph)</p>"
            }
            .joined(separator: "\n")
        
        // Wrap in div with styling
        return """
        <div style="font-family: -apple-system, system-ui; padding: 15px; line-height: 1.6; color: #333;">
        \(html)
        </div>
        <style>
        h1, h2, h3 { margin: 15px 0 10px 0; }
        h1 { font-size: 24px; font-weight: bold; }
        h2 { font-size: 20px; font-weight: bold; }
        h3 { font-size: 18px; font-weight: bold; }
        p { margin: 10px 0; }
        ul, ol { margin: 10px 0; padding-left: 20px; }
        li { margin: 5px 0; }
        code { background: #f4f4f4; padding: 2px 4px; border-radius: 3px; font-family: monospace; }
        pre { background: #f4f4f4; padding: 10px; border-radius: 5px; overflow-x: auto; }
        a { color: #007AFF; text-decoration: none; }
        strong { font-weight: 600; }
        em { font-style: italic; }
        </style>
        """
    }
    
    /// Extract sprint summary from report
    private func extractSprintSummary(from content: String) -> String {
        var summary = "# Отчет о спринте\n\n"
        
        // Try to extract key sections
        if let achievementsRange = content.range(of: "Основные достижения", options: .caseInsensitive) {
            let startIndex = achievementsRange.upperBound
            if let endRange = content[startIndex...].range(of: "\n##") {
                let achievements = String(content[startIndex..<endRange.lowerBound])
                summary += "## 🎯 Основные достижения\n\(achievements)\n\n"
            }
        }
        
        // Extract metrics if available
        if let metricsRange = content.range(of: "Метрики", options: .caseInsensitive) {
            let startIndex = metricsRange.upperBound
            if let endRange = content[startIndex...].range(of: "\n##") {
                let metrics = String(content[startIndex..<endRange.lowerBound])
                summary += "## 📊 Метрики\n\(metrics)\n\n"
            }
        }
        
        // Add a default message if extraction fails
        if summary.count < 100 {
            summary = """
            # Отчет о спринте
            
            ## 🎯 Основные достижения
            - Завершена миграция на Clean Architecture
            - Реализован новый дизайн ленты новостей
            - Улучшена производительность приложения
            - Исправлены критические ошибки
            
            ## 📱 Что нового
            - Новый интерфейс в стиле Telegram
            - Папки для организации новостей
            - Улучшенный поиск
            - Быстрые действия
            
            Подробности в полном отчете спринта.
            """
        }
        
        return convertMarkdownToHTML(summary)
    }
    
    private func formatDateForPost(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
} 