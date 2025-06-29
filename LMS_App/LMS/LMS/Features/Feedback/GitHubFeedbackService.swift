import Foundation
import UIKit

/// Сервис для автоматического создания GitHub Issues из фидбэков пользователей
class GitHubFeedbackService {
    static let shared = GitHubFeedbackService()
    
    // MARK: - Configuration
    private let githubToken: String
    private let repositoryOwner: String
    private let repositoryName: String
    private let baseURL = "https://api.github.com"
    
    private init() {
        // TODO: Получить из конфигурации или Keychain
        self.githubToken = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] ?? ""
        self.repositoryOwner = "ishirokov" // Обновлено на реальный username
        self.repositoryName = "lms_docs" // Репозиторий проекта
    }
    
    // MARK: - Public Methods
    
    /// Создает GitHub Issue из фидбэка пользователя
    func createIssueFromFeedback(_ feedback: FeedbackItem) async -> Bool {
        guard !githubToken.isEmpty else {
            print("❌ GitHub token не настроен")
            return false
        }
        
        let issueData = createIssueData(from: feedback)
        
        let success = await createGitHubIssue(issueData)
        if success {
            print("✅ GitHub Issue создан для фидбэка: \(feedback.title)")
            await notifyFeedbackCreated(feedback)
        }
        return success
    }
    
    /// Обновляет статус GitHub Issue
    func updateIssueStatus(_ feedback: FeedbackItem) async -> Bool {
        // TODO: Реализовать обновление статуса существующего Issue
        return true
    }
    
    /// Добавляет комментарий к GitHub Issue
    func addCommentToIssue(_ feedback: FeedbackItem, comment: FeedbackComment) async -> Bool {
        // TODO: Реализовать добавление комментария к Issue
        return true
    }
    
    // MARK: - Private Methods
    
    private func createIssueData(from feedback: FeedbackItem) -> GitHubIssueData {
        let title = "[\(feedback.type.title)] \(feedback.title)"
        
        let body = """
        ## 📝 Описание
        \(feedback.description)
        
        ## 👤 Автор
        **\(feedback.author)** (ID: \(feedback.authorId))
        
        ## 🕒 Дата создания
        \(DateFormatter.iso8601.string(from: feedback.createdAt))
        
        ## 📱 Информация об устройстве
        - **Модель**: \(getDeviceInfo().model)
        - **iOS**: \(getDeviceInfo().osVersion)
        - **Версия приложения**: \(getDeviceInfo().appVersion)
        - **Сборка**: \(getDeviceInfo().buildNumber)
        
        ## 🔄 Статус
        **\(feedback.status.title)**
        
        ## 💭 Реакции пользователей
        👍 \(feedback.reactions.like) | 👎 \(feedback.reactions.dislike) | ❤️ \(feedback.reactions.heart) | 🔥 \(feedback.reactions.fire)
        
        \(feedback.comments.isEmpty ? "" : generateCommentsSection(feedback.comments))
        
        ---
        *Автоматически создано из мобильного приложения LMS*
        """
        
        let labels = generateLabels(for: feedback)
        
        return GitHubIssueData(
            title: title,
            body: body,
            labels: labels,
            assignees: getAssignees(for: feedback.type)
        )
    }
    
    private func generateLabels(for feedback: FeedbackItem) -> [String] {
        var labels = ["feedback", "mobile-app"]
        
        // Лейбл по типу
        switch feedback.type {
        case .bug:
            labels.append("bug")
        case .feature:
            labels.append("enhancement")
        case .improvement:
            labels.append("improvement")
        case .question:
            labels.append("question")
        }
        
        // Лейбл по статусу
        switch feedback.status {
        case .open:
            labels.append("status:open")
        case .inProgress:
            labels.append("status:in-progress")
        case .resolved:
            labels.append("status:resolved")
        case .closed:
            labels.append("status:closed")
        }
        
        // Приоритет на основе реакций
        let totalReactions = feedback.reactions.like + feedback.reactions.heart + feedback.reactions.fire
        if totalReactions > 10 {
            labels.append("priority:high")
        } else if totalReactions > 5 {
            labels.append("priority:medium")
        } else {
            labels.append("priority:low")
        }
        
        return labels
    }
    
    private func getAssignees(for type: FeedbackType) -> [String] {
        // Настроено автоматическое назначение ответственных
        switch type {
        case .bug:
            return ["ishirokov"] // Технический лид для багов
        case .feature, .improvement:
            return ["ishirokov"] // Продукт-менеджер для фич
        case .question:
            return ["ishirokov"] // Саппорт для вопросов
        }
    }
    
    private func generateCommentsSection(_ comments: [FeedbackComment]) -> String {
        guard !comments.isEmpty else { return "" }
        
        var section = "\n## 💬 Комментарии пользователей\n\n"
        
        for comment in comments {
            let authorBadge = comment.isAdmin ? " 👤 **ADMIN**" : ""
            section += """
            **\(comment.author)**\(authorBadge) - *\(DateFormatter.relative.string(from: comment.createdAt))*
            > \(comment.text)
            
            """
        }
        
        return section
    }
    
    private func createGitHubIssue(_ issueData: GitHubIssueData) async -> Bool {
        guard let url = URL(string: "\(baseURL)/repos/\(repositoryOwner)/\(repositoryName)/issues") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("token \(githubToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("LMS-Mobile-App/1.0", forHTTPHeaderField: "User-Agent")
        
        do {
            let jsonData = try JSONEncoder().encode(issueData)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    print("✅ GitHub Issue успешно создан")
                    if let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let issueNumber = responseData["number"] as? Int {
                        print("📝 Issue #\(issueNumber): \(issueData.title)")
                    }
                    return true
                } else {
                    print("❌ GitHub API вернул статус: \(httpResponse.statusCode)")
                    if let errorData = String(data: data, encoding: .utf8) {
                        print("❌ Ошибка: \(errorData)")
                    }
                }
            }
        } catch {
            print("❌ Ошибка при отправке запроса: \(error)")
        }
        
        return false
    }
    
    private func notifyFeedbackCreated(_ feedback: FeedbackItem) async {
        // TODO: Отправить уведомление команде через Slack/Discord
        print("📢 Уведомление: Новый фидбэк от \(feedback.author): \(feedback.title)")
    }
    
    private func getDeviceInfo() -> (model: String, osVersion: String, appVersion: String, buildNumber: String) {
        return (
            model: UIDevice.current.model,
            osVersion: UIDevice.current.systemVersion,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        )
    }
}

// MARK: - Data Models

struct GitHubIssueData: Codable {
    let title: String
    let body: String
    let labels: [String]
    let assignees: [String]
}

// MARK: - Date Formatters Extension

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    static let relative: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
} 