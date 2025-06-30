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

        let feedback = FeedbackModel(
            id: item.id,
            type: item.type.rawValue,
            text: item.description,
            screenshot: screenshotBase64,
            deviceInfo: DeviceInfo(
                model: UIDevice.current.model,
                osVersion: UIDevice.current.systemVersion,
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
                locale: Locale.current.identifier,
                screenSize: "\(Int(UIScreen.main.bounds.width))x\(Int(UIScreen.main.bounds.height))"
            ),
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

    // Облачный сервер на Render - работает для всех устройств
    private let serverURL = "https://lms-feedback-server.onrender.com/api/v1/feedback"

    // Для локального тестирования используйте:
    // private let serverURL = "http://localhost:5001/api/v1/feedback"
    // Для реального устройства в локальной сети:
    // private let serverURL = "http://192.168.68.104:5001/api/v1/feedback"

    private let session = URLSession.shared
    private let queue = DispatchQueue(label: "feedback.queue")

    private init() {}

    func submitFeedback(_ feedback: FeedbackModel, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: serverURL) else {
            completion(.failure(NSError(domain: "ServerFeedbackService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
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
