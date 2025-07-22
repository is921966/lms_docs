import Foundation
import SwiftUI

class CloudServerManager {
    static let shared = CloudServerManager()
    
    private init() {}
    
    // MARK: - Server URLs
    @AppStorage("logServerURL") private var _logServerURL: String = ""
    @AppStorage("feedbackServerURL") private var _feedbackServerURL: String = ""
    
    // Default URLs (can be updated after deployment)
    // Production URLs на Railway:
    // LOG SERVER: ✅ https://lms-log-server-production.up.railway.app (работает)
    // FEEDBACK SERVER: ✅ https://lms-feedback-server-production.up.railway.app (теперь работает!)
    
    // Используем production URLs на Railway для обоих серверов
    private let defaultLogServerURL = "https://lms-log-server-production.up.railway.app"
    private let defaultFeedbackServerURL = "https://lms-feedback-server-production.up.railway.app"
    
    // Для полностью локального тестирования (закомментировано):
    // private let defaultLogServerURL = "http://localhost:5002"
    // private let defaultFeedbackServerURL = "http://localhost:5001"
    
    var logServerURL: String {
        get { _logServerURL.isEmpty ? defaultLogServerURL : _logServerURL }
        set { _logServerURL = newValue }
    }
    
    var feedbackServerURL: String {
        get { _feedbackServerURL.isEmpty ? defaultFeedbackServerURL : _feedbackServerURL }
        set { _feedbackServerURL = newValue }
    }
    
    // MARK: - API Endpoints
    var logAPIEndpoint: String {
        "\(logServerURL)/api/logs"
    }
    
    var feedbackAPIEndpoint: String {
        "\(feedbackServerURL)/api/v1/feedback"
    }
    
    // MARK: - Health Check
    func checkServerHealth(completion: @escaping (Bool, Bool) -> Void) {
        var logServerHealthy = false
        var feedbackServerHealthy = false
        
        let group = DispatchGroup()
        
        // Check log server
        group.enter()
        if let url = URL(string: "\(logServerURL)/health") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {
                    logServerHealthy = true
                }
                group.leave()
            }.resume()
        } else {
            group.leave()
        }
        
        // Check feedback server
        group.enter()
        if let url = URL(string: "\(feedbackServerURL)/health") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {
                    feedbackServerHealthy = true
                }
                group.leave()
            }.resume()
        } else {
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(logServerHealthy, feedbackServerHealthy)
        }
    }
    
    // MARK: - Update URLs
    func updateURLs(logServer: String? = nil, feedbackServer: String? = nil) {
        if let logServer = logServer, !logServer.isEmpty {
            logServerURL = logServer
        }
        
        if let feedbackServer = feedbackServer, !feedbackServer.isEmpty {
            feedbackServerURL = feedbackServer
        }
        
        // Update services with new URLs
        updateServices()
    }
    
    private func updateServices() {
        // Notify services about URL changes
        NotificationCenter.default.post(name: NSNotification.Name("cloudServerURLsChanged"), object: nil)
    }
    
    // MARK: - Reset to Defaults
    func resetToDefaults() {
        _logServerURL = ""
        _feedbackServerURL = ""
        updateServices()
    }
} 