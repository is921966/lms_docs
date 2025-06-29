import Foundation
import UIKit

/// Сервис для отправки фидбэков на локальный сервер
class ServerFeedbackService {
    static let shared = ServerFeedbackService()
    
    // MARK: - Configuration
    private let baseURL: String
    private let isDebug = true
    
    private init() {
        // Для тестирования используем localhost
        // В production замените на ваш сервер
        #if targetEnvironment(simulator)
        self.baseURL = "http://localhost:5000"
        #else
        // Для реального устройства используйте IP вашего компьютера
        // Узнать IP: System Preferences → Network → Wi-Fi → IP Address
        self.baseURL = "http://192.168.1.100:5000" // Замените на ваш IP
        #endif
    }
    
    // MARK: - Public Methods
    
    /// Отправляет фидбэк на сервер
    func sendFeedback(_ feedback: FeedbackModel) async -> Bool {
        guard let url = URL(string: "\(baseURL)/api/v1/feedback") else {
            print("❌ Invalid URL")
            return false
        }
        
        do {
            // Подготавливаем данные
            let feedbackData = FeedbackServerData(
                id: UUID().uuidString,
                type: feedback.type,
                text: feedback.text,
                timestamp: ISO8601DateFormatter().string(from: Date()),
                deviceInfo: feedback.deviceInfo,
                screenshot: feedback.screenshot
            )
            
            // Создаем запрос
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("LMS-iOS/1.0", forHTTPHeaderField: "User-Agent")
            
            // Кодируем данные
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(feedbackData)
            
            if isDebug {
                print("📤 Sending feedback to: \(url)")
            }
            
            // Отправляем
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Проверяем ответ
            if let httpResponse = response as? HTTPURLResponse {
                if isDebug {
                    print("📥 Response status: \(httpResponse.statusCode)")
                }
                
                if httpResponse.statusCode == 201 {
                    // Парсим ответ
                    if let responseData = try? JSONDecoder().decode(ServerResponse.self, from: data) {
                        print("✅ Feedback sent successfully!")
                        if let githubURL = responseData.github_issue {
                            print("📝 GitHub Issue: \(githubURL)")
                        }
                        return true
                    }
                    return true
                } else {
                    print("❌ Server error: \(httpResponse.statusCode)")
                    if let errorData = String(data: data, encoding: .utf8) {
                        print("Error details: \(errorData)")
                    }
                    return false
                }
            }
            
            return false
        } catch {
            print("❌ Failed to send feedback: \(error)")
            return false
        }
    }
    
    /// Отправляет фидбэк на сервер из FeedbackItem
    func sendFeedbackItem(_ feedbackItem: FeedbackItem) async -> Bool {
        // Конвертируем FeedbackItem в FeedbackModel
        let feedback = FeedbackModel(
            type: feedbackItem.type.rawValue,
            text: feedbackItem.description,
            screenshot: feedbackItem.screenshot,
            deviceInfo: DeviceInfo(
                model: UIDevice.current.model,
                osVersion: UIDevice.current.systemVersion,
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
            )
        )
        
        return await sendFeedback(feedback)
    }
    
    /// Проверяет доступность сервера
    func checkServerStatus() async -> Bool {
        guard let url = URL(string: "\(baseURL)/") else {
            return false
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            if isDebug {
                print("❌ Server not reachable: \(error)")
            }
            return false
        }
    }
}

// MARK: - Data Models

private struct FeedbackServerData: Encodable {
    let id: String
    let type: String
    let text: String
    let timestamp: String
    let deviceInfo: DeviceInfo
    let screenshot: String?
}

private struct ServerResponse: Decodable {
    let status: String
    let id: String
    let message: String
    let github_issue: String?
}

// MARK: - Helper Extension

extension ServerFeedbackService {
    /// Настройки для production
    func updateServerURL(_ url: String) {
        // В production версии можно добавить возможность
        // динамического изменения URL сервера
    }
    
    /// Получить текущий URL сервера
    var currentServerURL: String {
        return baseURL
    }
} 