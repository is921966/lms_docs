import Foundation
import UIKit

// Протокол для feedback сервисов
protocol FeedbackServiceProtocol {
    func submitFeedback(_ feedback: FeedbackModel, completion: @escaping (Result<String, Error>) -> Void)
}

// Расширение для работы с FeedbackItem
extension ServerFeedbackService {
    func sendFeedbackItem(_ item: FeedbackItem) async -> Bool {
        // Скриншот уже в формате base64 строки
        let screenshotBase64 = item.screenshot

        // Получаем device info в main actor context
        let deviceInfo = await MainActor.run {
            DeviceInfo(
                model: UIDevice.current.model,
                osVersion: UIDevice.current.systemVersion,
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
                locale: Locale.current.identifier,
                screenSize: "\(Int(UIScreen.main.bounds.width))x\(Int(UIScreen.main.bounds.height))"
            )
        }

        let feedback = FeedbackModel(
            id: item.id,
            type: item.type.rawValue,
            text: item.description,
            screenshot: screenshotBase64,
            deviceInfo: deviceInfo,
            timestamp: item.createdAt,
            userId: item.authorId,
            userEmail: item.author,
            appContext: nil
        )

        return await withCheckedContinuation { continuation in
            submitFeedback(feedback) { result in
                switch result {
                case .success:
                    continuation.resume(returning: true)
                case .failure:
                    continuation.resume(returning: false)
                }
            }
        }
    }
}

class ServerFeedbackService: FeedbackServiceProtocol {
    // Singleton instance
    static let shared = ServerFeedbackService()

    // Динамический URL из CloudServerManager
    private var serverURL: String {
        CloudServerManager.shared.feedbackAPIEndpoint
    }

    private let session = URLSession.shared
    private let queue = DispatchQueue(label: "feedback.queue")

    private init() {
        // Подписываемся на изменения URL
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(serverURLsChanged),
            name: NSNotification.Name("cloudServerURLsChanged"),
            object: nil
        )
    }

    @objc private func serverURLsChanged() {
        // URL обновлен, можно выполнить дополнительные действия если нужно
        print("📱 Feedback Server URL обновлен: \(serverURL)")
    }

    func submitFeedback(_ feedback: FeedbackModel, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: serverURL) else {
            completion(.failure(NSError(domain: "ServerFeedbackService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(serverURL)"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(feedback)

            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "ServerFeedbackService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }

                if httpResponse.statusCode == 201 {
                    if let data = data,
                       let response = try? JSONDecoder().decode(FeedbackResponse.self, from: data),
                       let githubIssue = response.github_issue {
                        completion(.success(githubIssue))
                    } else {
                        completion(.success("Feedback отправлен успешно"))
                    }
                } else {
                    completion(.failure(NSError(domain: "ServerFeedbackService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: HTTP \(httpResponse.statusCode)"])))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
}

// Response model
private struct FeedbackResponse: Codable {
    let status: String
    let id: String
    let message: String
    let github_issue: String?
}

// Device info для совместимости
struct DeviceInfo: Codable {
    let model: String
    let osVersion: String
    let appVersion: String
    let buildNumber: String
    let locale: String
    let screenSize: String
}
